# Starry

The source for **[kenstarry.com](https://kenstarry.com)** — a static, server-rendered
portfolio built with [Jaspr](https://docs.jaspr.site) (Dart on the web) and
Tailwind CSS v4.

Every route is pre-rendered to plain HTML at build time, so the site is fast,
crawlable, and hosts anywhere that serves files. The interactive bits (theme
switch, mobile menu) hydrate on the client as Dart.

---

## Learning the stack

New to Jaspr? **[`docs/`](./docs/README.md)** is a full guide written for someone who knows
HTML, CSS and JavaScript but has never seen Jaspr — the component model, static rendering and
hydration, routing, Tailwind, the SEO layer, state, architecture, and a cookbook of recipes.

Start with [Rendering & hydration](./docs/02-rendering-and-hydration.md) and
[SEO](./docs/05-seo.md); together they explain why the code is shaped the way it is.

---

## Prerequisites

Two tools have to be on your **PATH** before anything builds:

```bash
# 1. the Jaspr CLI
dart pub global activate jaspr_cli
export PATH="$PATH:$HOME/.pub-cache/bin"

# 2. the standalone Tailwind CLI — jaspr_tailwind shells out to `tailwindcss`
curl -sLo ~/.local/bin/tailwindcss \
  https://github.com/tailwindlabs/tailwindcss/releases/download/v4.3.3/tailwindcss-macos-arm64
chmod +x ~/.local/bin/tailwindcss
export PATH="$PATH:$HOME/.local/bin"
```

If `tailwindcss` is missing the build fails with a `PathNotFoundException` on
`web/styles.css` — the builder discards the CLI's own error, so that stack trace
is the only symptom you get.

**On a Flutter-managed Dart:** if `which dart` resolves to a Flutter wrapper
rather than a real SDK directory, the Jaspr CLI refuses to start with *"failed
to verify the surrounding Dart SDK"*. Point PATH at the bundled SDK instead:

```bash
export PATH="$(dirname $(which flutter))/cache/dart-sdk/bin:$PATH"
```

## Run it

```bash
jaspr serve   # http://localhost:8080, hot reload
```

The first run generates `lib/main.server.options.dart` and
`lib/main.client.options.dart`. Until then your IDE will flag those two imports
as missing — that is expected, not a bug.

If a build ever fails in a way that looks impossible, `rm -rf .dart_tool/build`
and retry — build_runner caches enough state to keep replaying a fixed error.

## Build it

```bash
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'
```

Output lands in `build/jaspr/` as `index.html`, `projects/index.html`,
`projects/<slug>/index.html`, plus `sitemap.xml`. Point Cloudflare Pages,
Netlify, Vercel or GitHub Pages at that folder.

`netlify.toml` is included as a working example.

---

## Where things live

Feature-based clean architecture. Each feature owns `domain/` (models + the abstract
repository), `data/` (datasource + implementations) and `presentation/` (pages +
components); anything shared by two or more features lives in `core/`.

```
lib/
  app.dart                     route table
  main.server.dart             <html> document, site-wide head, theme boot script
  main.client.dart             hydration entrypoint
  core/
    config/site_config.dart    name, bio, stats, email, socials, toolkit  ← edit this first
    di/locator.dart            picks repository implementations
    presentation/components/   AppLayout, SectionBlock, SiteFooter, AppIcons, ErrorNotice
      nav/                     NavBar (the one @client island) + ThemeToggle
    routing/route_paths.dart   every path, in one place
    seo/                       PageMeta (title/canonical/OG) + StructuredData (JSON-LD)
    state/controllers/         @riverpod controllers — client-side only
  features/
    home/       presentation/{pages,components}
    projects/   domain/{model,enum,repository} · data/{datasource,repository} · presentation
    not_found/  presentation/pages
web/
  styles.tw.css                Tailwind v4 theme tokens (colors, fonts, easing)
  favicon.svg
  images/                      project covers and og.png
```

## Make it yours

1. **`lib/core/config/site_config.dart`** — name, tagline, bio, stats, email, socials.
2. **`lib/features/projects/data/datasource/projects_local_datasource.dart`** — add a
   `ProjectModel`; it appears on the home page, the projects index, and gets its own
   pre-rendered `/projects/<slug>` page.
3. **`web/styles.tw.css`** — the `@theme` block is the whole design system. Change
   `--color-star-400` and the accent shifts everywhere.
4. Add `web/images/og.png` (1200×630) so shared links get a preview card.

## How rendering works

Two paths, and they must not be mixed — see `CLAUDE.md` for the full rationale:

- **Content** is server-only. Pages are `AsyncStatelessComponent`s that await a repository,
  so the data is resolved *during* pre-rendering and the HTML ships complete. This is what
  makes the site indexable.
- **Interaction** lives in `@client` islands, which own a `ProviderScope` and use Riverpod.
  Riverpod cannot be used in the content path: its async providers resolve after the HTML
  has been serialized, so a crawler would receive a loading state.

## Notes

- `build_web_compilers` is pinned to `>=4.4.19 <4.5.0` on purpose. It is what
  compiles the `@client` components to JS; without it `main.client.dart.js` is
  never emitted, the `<script>` tag 404s, and the site renders correctly but
  never hydrates — the theme switch and mobile menu just do nothing. From 4.5.0
  it inlines the `build_modules` builders, which then collide with the copy
  `jaspr_tailwind` pulls in (`outputs collide: package:collection/...`).
  Unpin only once `jaspr_tailwind` drops its `build_modules` dependency.
- Per-page `<title>`, canonical and Open Graph tags come from `core/seo/page_meta.dart`,
  not from the root `Document`. Entries in that `Document`'s `head:` list are
  emitted verbatim and bypass Jaspr's override system, so a default there would
  duplicate rather than be replaced by the page-level tag.
- `dartz` cannot be used on this SDK (its constraint caps at Dart `<3.0.0`);
  `fpdart` supplies `Either` instead.

- Dark mode is the default and is stored in `localStorage` under `theme`. The
  inline script in `main.server.dart` applies it before first paint, so there is
  no flash.
- Interactive components are annotated `@client`. They are pre-rendered on the
  server too, so any browser API must be guarded with `kIsWeb` and imported from
  `package:universal_web` (which mocks those APIs server-side).
- Tailwind scans your `.dart` files for class names. Keep classes as string
  literals — build them dynamically and the compiler will not see them.

## Ideas parked for later

- `jaspr_content` for a markdown-driven `/blog`
- `jaspr_flutter_embed` to drop a real Flutter widget into a case study
- A `/uses` page, and an `og:image` generated per project at build time
