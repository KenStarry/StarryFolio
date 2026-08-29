# Starry — how this site works

A guide to the stack behind **kenstarry.com**, written for someone who knows HTML, CSS and
JavaScript but has never touched Jaspr.

Nothing here is theoretical. Every claim was checked against this repo, and the surprising
ones were verified by building the site and reading the generated HTML.

## Read in this order

| # | Doc | What you get out of it |
|---|---|---|
| 1 | [Jaspr mental model](./01-jaspr-mental-model.md) | What Jaspr *is*, and the HTML→Dart translation table |
| 2 | [Rendering & hydration](./02-rendering-and-hydration.md) | Static vs server vs client, pre-rendering, islands |
| 3 | [Routing](./03-routing.md) | `Router`, `Route`, `Link`, and how URLs become files |
| 4 | [Styling with Tailwind](./04-styling-with-tailwind.md) | How CSS is compiled, design tokens, dark mode |
| 5 | [SEO](./05-seo.md) | The whole SEO layer — and the trap that silently breaks it |
| 6 | [State & Riverpod](./06-state-and-riverpod.md) | Where interactivity lives, and where it must not |
| 7 | [Architecture](./07-architecture.md) | The clean-architecture wiring, layer by layer |
| 8 | [Build toolchain](./08-build-toolchain.md) | Codegen, version pins, deploy, and the sharp edges |
| 9 | [Cookbook](./09-cookbook.md) | Step-by-step recipes for common changes |

If you only read two: **[2](./02-rendering-and-hydration.md)** and
**[5](./05-seo.md)**. Together they explain why the code is shaped the way it is.

## Off-site surfaces

Not stack documentation, and deliberately not numbered into the sequence above:
these are assets that live somewhere else but are built from this repo's facts,
kept here so the two cannot drift apart.

| File | Is | Published to |
|---|---|---|
| [GitHub profile README](./github-profile-readme.md) | The profile page above the pinned repos | `KenStarry/KenStarry` |

## The 60-second version

Jaspr is a web framework where you write **Dart instead of JavaScript**, and describe HTML
with **function calls instead of tags**. It borrows Flutter's component model but emits real
DOM — no canvas, no widget layer.

This site runs in **static mode**: at build time Jaspr renders every route to a plain
`.html` file. A browser (or a crawler) receives complete markup and needs no JavaScript to
read it. A single interactive piece — the nav bar — ships as an "island" of Dart-compiled
JS that wakes up after load.

```
lib/*.dart ──jaspr build──> build/jaspr/
                              index.html                  complete HTML, no JS needed
                              projects/index.html
                              projects/flow/index.html
                              main.client.dart.js         176 KB — just the nav island
                              styles.css                  30 KB — Tailwind output
                              sitemap.xml
```

The rule that governs every design decision in this codebase:

> **If content is not in the pre-rendered HTML, it does not exist.**
> Crawlers, link previews and no-JS visitors only ever see that file.

`CLAUDE.md` in the repo root is the enforcement version of this guide — terser, and aimed
at anyone (human or AI) making changes.
