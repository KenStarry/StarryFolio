# 4. Styling with Tailwind

Styling here is **ordinary Tailwind CSS v4**. Nothing about it is Dart-specific — the classes
you write are the classes you would write in an HTML file. The only thing worth understanding
is the pipeline that turns the source file into `styles.css`, because it has one sharp edge.

## Where the CSS comes from

```
web/styles.tw.css ──[jaspr_tailwind]──> tailwindcss CLI ──> build/jaspr/styles.css
       ▲                                       │
       │                                       └── scans lib/**/*.dart for class names
   your tokens
```

`web/styles.tw.css` is the only stylesheet. `.tw.css` is the trigger: the `jaspr_tailwind`
builder claims `web/{file}.tw.css` and produces `web/{file}.css`.

`main.server.dart` links the output:

```dart
link(rel: 'stylesheet', href: '/styles.css'),
```

`web/styles.css` is generated and **gitignored** — never edit it.

## Design tokens

Tailwind v4 configures itself in CSS, not a JS config file. The `@theme` block *is* the
design system:

```css
@import "tailwindcss";

@custom-variant dark (&:where(.dark, .dark *));

@theme {
  --font-display: "Space Grotesk", "Inter", ui-sans-serif, sans-serif;

  /* Ink — the night sky */
  --color-ink-950: #07070b;
  --color-ink-500: #43435c;
  --color-ink-50:  #f7f7fb;

  /* Star — the accent */
  --color-star-400: #f6c85a;

  --ease-expo: cubic-bezier(0.16, 1, 0.3, 1);
}
```

Every token automatically becomes utilities. `--color-star-400` gives you `bg-star-400`,
`text-star-400`, `border-star-400`, `decoration-star-400`, `from-star-400`. `--ease-expo`
gives you `ease-expo`. **Change one variable and the whole site follows** — that is the
entire point, and why colours should never be hardcoded in components.

Two scales: `ink` (11 steps of near-black to near-white) and `star` (3 steps of gold).

## Dark mode

Class-based, declared by the custom variant above, and dark is the **default**.

The class is applied by an inline script in `main.server.dart` that runs *before first paint*:

```js
(function(){try{
  var t = localStorage.getItem('theme');
  var dark = t ? t === 'dark' : true;
  document.documentElement.classList.toggle('dark', dark);
}catch(e){ document.documentElement.classList.add('dark'); }})();
```

It is inline and in the `<head>` on purpose. An external script, or one that ran after
hydration, would let the browser paint the light theme first and then flip — the "flash of
wrong theme". Reading `localStorage` synchronously before the body renders avoids that
entirely.

Components then write both variants inline, which is the normal Tailwind idiom:

```dart
classes: 'border-ink-200 text-ink-500 dark:border-ink-700 dark:text-ink-300'
```

The `ThemeToggle` island keeps the class, `localStorage` and provider state in sync at
runtime. See [doc 6](./06-state-and-riverpod.md).

## The sharp edge: classes must be literals

Tailwind works by **scanning your source files as text**. It has no idea what Dart is; it
looks for things that resemble class names. Verified on this project: it does read `.dart`
files, and it picks up arbitrary values like `tracking-[0.18em]` and `lg:grid-cols-[1.2fr_1fr]`
straight out of the source.

The consequence:

```dart
// ✅ scanner sees "bg-star-400"
classes: 'bg-star-400'

// ✅ still fine — the full literal appears in the source
classes: 'rounded-full px-2 py-0.5 ${project.status.classes}'

// ❌ nothing to find; the class gets purged and the style silently vanishes
classes: 'bg-star-$shade'
final color = 'star-400';
classes: 'bg-$color'
```

Interpolating a variable that *holds* a complete class is fine — because that literal exists
somewhere in the source. Assembling a class from fragments is not.

This is why `ProjectStatus` stores whole class strings:

```dart
enum ProjectStatus {
  shipped('Shipped', 'bg-emerald-500/15 text-emerald-600 dark:text-emerald-400'),
  building('Building', 'bg-star-400/15 text-star-500 dark:text-star-300'),
  archived('Archived', 'bg-ink-500/15 text-ink-500 dark:text-ink-300');
  // …
}
```

Ugly next to `'bg-${color}-500/15'`, and deliberately so.

## Custom CSS

For things utilities cannot express, use the layers:

```css
@layer components {
  .starfield {
    background-image:
      radial-gradient(1px 1px at 20% 30%, rgb(255 255 255 / 0.6) 50%, transparent 50%),
      radial-gradient(1.5px 1.5px at 45% 70%, rgb(246 200 90 / 0.5) 50%, transparent 50%);
    background-size: 100% 100%;
  }
}
```

`@layer base` holds element defaults (`body`, `::selection`, `:focus-visible`). There is also
a `prefers-reduced-motion` block that collapses every animation and transition to `0.01ms` —
an accessibility baseline worth keeping.

## Jaspr's own CSS API

Jaspr ships a `Styles` class for CSS-in-Dart, and most `dom` elements take a `styles:`
parameter. **This project does not use it.** Tailwind already owns styling, and mixing two
systems means two places to look when something is off. Stick to `classes:`.

## Working on styles

`jaspr serve` watches `.tw.css` and `.dart` files and recompiles on save. If a class appears
to do nothing:

1. Is it a literal in the source? (see above)
2. Is the token defined in `@theme`?
3. Try `rm -rf .dart_tool/build` — the builder caches aggressively.

And the failure that looks like nothing to do with CSS:

```
PathNotFoundException: Cannot open file, path = '…/scratch_space…/web/styles.css'
```

That means the `tailwindcss` binary is not on `PATH`. The builder shells out to it and
discards its stderr, so a missing CLI surfaces only as a missing output file. See
[doc 8](./08-build-toolchain.md).

---

Next: [SEO →](./05-seo.md)
