# 1. The Jaspr mental model

## What it actually is

Jaspr is a web framework for Dart. You describe a page as a tree of **components**, and
Jaspr turns that tree into real DOM elements — `<div>`, `<p>`, `<header>`. If you have used
React, the model will feel familiar. If you have used Flutter, it will feel *very* familiar,
because Jaspr deliberately copies Flutter's component API.

The important thing it is **not**: Flutter Web. Flutter Web paints your UI into a canvas,
which produces markup a crawler cannot read. Jaspr emits ordinary HTML elements that you can
inspect, style with real CSS, and hand to Googlebot.

```
React                  Jaspr
─────                  ─────
JSX                    Dart function calls
component              StatelessComponent / StatefulComponent
props                  constructor parameters
useState               StatefulComponent + setState
Context                InheritedComponent / context extensions
```

## HTML in Dart

There are no templates and no JSX. HTML elements are Dart classes with lowercase names, used
like functions. `div(...)` really is a class constructor — that is why they compose and why
`const` works on them.

```dart
import 'package:jaspr/dom.dart';   // <- gives you div, p, a, img, section, ...

div(classes: 'flex items-center gap-2', [
  Component.text('Hello'),
  a(href: '/projects', [Component.text('Work')]),
])
```

renders

```html
<div class="flex items-center gap-2">Hello<a href="/projects">Work</a></div>
```

Children are the **last positional argument** — a plain `List<Component>`. Attributes are
named parameters. Anything without a dedicated parameter goes in `attributes:`.

### Translation table

| HTML / JS | Jaspr |
|---|---|
| `<div class="x">` | `div(classes: 'x', [...])` |
| `<p id="lead">` | `p(id: 'lead', [...])` |
| `<img src="a.png" alt="A">` | `img(src: 'a.png', alt: 'A')` |
| `<a href="..." target="_blank">` | `a(href: '...', target: Target.blank, [...])` |
| text node | `Component.text('...')` |
| `<>…</>` (fragment) | `Component.fragment([...])` |
| `element.innerHTML = '<svg…>'` | `RawText('<svg…>')` |
| `data-*`, `aria-*`, `rel` | `attributes: {'aria-label': 'Menu'}` |
| `onclick` | `onClick: () { … }` |
| conditional render | `if (cond) child` inside the list |
| `.map()` in JSX | `for (final x in xs) Child(x)` inside the list |

Those last two are Dart **collection-if** and **collection-for**. They work directly inside
a list literal, which is why Jaspr trees read cleanly without ternaries:

```dart
div([
  if (project.coverImage != null)
    img(src: '/${project.coverImage}', alt: project.name)
  else
    const div(classes: 'starfield absolute inset-0', []),

  for (final tech in project.stack.take(4))
    span(classes: 'rounded-md bg-ink-100 px-2 py-1', [Component.text(tech)]),
])
```

### RawText, and why the icons use it

`Component.text` escapes its input — `<` becomes `&lt;`, which is what you want for anything
user-facing. `RawText` does not escape, so it is how you inject literal markup.
`core/presentation/components/app_icons.dart` uses it to inline SVGs:

```dart
static Component star({String classes = 'h-5 w-5'}) => RawText(
      '<svg class="$classes" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
      '<path d="M12 2l2.6 6.6L21.5 10l-5.2 4.1 1.1 6.9L12 17.6 6.6 21l1.1-6.9L2.5 10l6.9-1.4z"/>'
      '</svg>',
    );
```

Inline SVG costs zero extra requests and inherits `currentColor`, so the icon follows the
text colour in both themes for free. `RawText` is unescaped by definition — never pass it
anything that came from outside the codebase.

## Components

### Stateless — the default

```dart
class SiteFooter extends StatelessComponent {
  const SiteFooter({super.key});

  @override
  Component build(BuildContext context) {
    return footer(classes: 'border-t border-ink-200/60', [ /* … */ ]);
  }
}
```

`build` returns one component. `context` is your handle on the tree — it is how
`context.watch` (Riverpod) and `context.push` (router) find what they need.

Note `const` on the constructor. A `const` component is canonicalised by Dart, so Jaspr can
skip rebuilding a subtree whose configuration provably has not changed. Free performance,
which is why `analysis_options.yaml` turns `prefer_const_constructors` on.

### Stateful — when it changes over time

```dart
class Counter extends StatefulComponent {
  const Counter({super.key});
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  Component build(BuildContext context) => button(
        onClick: () => setState(() => _count++),
        [Component.text('$_count')],
      );
}
```

`setState` mutates and schedules a rebuild — forgetting the wrapper means the value changes
but the DOM does not. Lifecycle hooks on `State`: `initState`, `didChangeDependencies`,
`didUpdateComponent`, `dispose`.

**This codebase has no `StatefulComponent`.** Interactive state lives in Riverpod
controllers instead — see [doc 6](./06-state-and-riverpod.md).

### Async — the one Jaspr adds

`AsyncStatelessComponent` has an *awaitable* build. It exists so a page can fetch data and
have the framework wait for it before serialising HTML. It is **server-only** — importable
from `package:jaspr/server.dart`, unusable in client code. It is the backbone of every
content page here, and [doc 2](./02-rendering-and-hydration.md) explains why.

## Events

Simple handlers get a named parameter:

```dart
button(onClick: () => print('clicked'), [Component.text('Go')])
```

For input events, the `events()` helper gives you typed values:

```dart
input(events: events(onInput: (String value) => print(value)))
```

The generic tracks the element: `bool` for checkboxes, `num` for number/range inputs,
`DateTime` for date inputs, `List<File>` for file inputs, `String` for the rest. One
convenience worth knowing: `onClick` on an `<a>` automatically calls `preventDefault()`, so
a handler on a link will not also navigate.

## Browser APIs

Dart has no `window` or `document` built in. Jaspr projects use `package:universal_web`,
which exposes the browser API on the client and **mocks it on the server** so the same file
compiles for both.

```dart
import 'package:universal_web/web.dart' as web;

if (kIsWeb) {
  web.document.documentElement?.classList.add('dark');
}
```

`kIsWeb` is a compile-time constant: `true` in the browser, `false` during the static build.
Guard every DOM touch with it. Island code runs during pre-rendering too, where there is no
document — and an unguarded call there fails the build.

Real example, `core/state/controllers/theme_controller.dart`:

```dart
@override
AppTheme build() {
  if (!kIsWeb) return AppTheme.dark;   // pre-render: no document, assume the default
  final isDark = web.document.documentElement?.classList.contains('dark') ?? true;
  return isDark ? AppTheme.dark : AppTheme.light;
}
```

## Where things come from

| Import | Gives you |
|---|---|
| `package:jaspr/jaspr.dart` | `Component`, `StatelessComponent`, `State`, `BuildContext`, `kIsWeb`, `@client` |
| `package:jaspr/dom.dart` | HTML elements (`div`, `p`, `a`, …), `RawText`, `events()`, `Styles` |
| `package:jaspr/server.dart` | everything above **plus** `AsyncStatelessComponent`, `Document` — server only |
| `package:jaspr/client.dart` | client entrypoint APIs |
| `package:jaspr_router/…` | `Router`, `Route`, `Link` |

`server.dart` re-exports `jaspr.dart`, so a page importing it does not need both — `dart fix`
will strip the redundant one.

---

Next: [Rendering & hydration →](./02-rendering-and-hydration.md)
