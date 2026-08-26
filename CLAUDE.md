# CLAUDE.md — starry

Ken Starry's portfolio, **[kenstarry.com](https://kenstarry.com)**. Dart on the web via
[Jaspr](https://docs.jaspr.site) in `static` mode: every route is pre-rendered to plain
HTML at build time.

> **This is a Jaspr project, not Flutter.** `~/.claude/flutter_architecture_spec.md` is the
> house architecture and its *structure* applies here in full. Its Flutter-specific stack
> does not — see [Spec deviations](#spec-deviations) for what changed and why.

> **Background reading:** [`docs/`](./docs/README.md) explains the stack from first
> principles — Jaspr's component model, static rendering, hydration, Tailwind, SEO and the
> architecture. This file is the enforcement summary; `docs/` is the reasoning behind it.

---

## 0. The rule that outranks the others

**SEO is the top priority. It wins over architectural purity, every time.**

This is a static marketing site. Its entire job is to be crawled, indexed and shared. A
refactor that is cleaner but leaves content out of the pre-rendered HTML is a regression,
not an improvement.

The practical test, after **any** change:

```bash
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'
grep -c "Case study" build/jaspr/index.html   # expect 3, not 0
```

If content renders in the browser but is missing from `build/jaspr/**/*.html`, it is
invisible to crawlers. Ship nothing in that state.

---

## 1. The constraint everything else follows from

Riverpod **cannot** be used in the content path. This is measured, not assumed:

| Pattern | What lands in the static HTML |
|---|---|
| `AsyncStatelessComponent` awaiting a repository | ✅ the real content |
| `context.watch(someAsyncProvider)` in a `StatelessComponent` | ❌ `AsyncLoading<T>` — a spinner |
| `await context.watch(p.future)` inside `AsyncStatelessComponent` | 💥 throws `Bad state: context.watch can only be used within the build method` |

`AsyncStatelessElement.buildAsync` does not set the flag `jaspr_riverpod` requires, and
after an `await` you are no longer inside the synchronous build. There is no arrangement of
these two that works.

**So the codebase has two separate paths, and they do not mix:**

```
Content path  (SEO-critical, server-only)     Interaction path  (client islands)
─────────────────────────────────────────     ──────────────────────────────────
AsyncStatelessComponent                       @client + ProviderScope
  └─ await Locator.<repo>.method()              └─ context.watch / context.read
  └─ result.fold(error, data)                   └─ @riverpod controllers + codegen
  └─ pre-rendered into HTML                     └─ hydrates after load
```

Everything reachable from a `Route` builder is the content path. The **only** island is
`core/presentation/components/nav/nav_bar.dart`.

---

## 2. Structure

```
lib/
├── app.dart                      route table; composes feature pages
├── main.server.dart              <html> document, site-wide head, theme boot script
├── main.client.dart              hydration entrypoint for @client components
│
├── core/                         shared across 2+ features
│   ├── config/site_config.dart   build-time identity — name, urls, socials, toolkit
│   ├── di/locator.dart           composition root; picks repository impls
│   ├── domain/model/             shared models (SocialLink)
│   ├── presentation/components/  AppLayout, SectionBlock, SiteFooter, AppIcons, ErrorNotice
│   │   └── nav/                  NavBar (the island) + ThemeToggle
│   ├── routing/route_paths.dart  every path, in one place
│   ├── seo/                      PageMeta + StructuredData/SchemaOrg
│   └── state/controllers/        @riverpod controllers (client-side only)
│
└── features/<feature>/
    ├── domain/                   model/ · enum/ · repository/   (abstract contract)
    ├── data/                     datasource/ · repository/      (impl + mock)
    └── presentation/             pages/ · components/
```

**Dependency direction:** `presentation → domain ← data`. Presentation depends on the
abstract repository, never on `*_impl`. Models live in `domain/`.

**Core vs feature:** content-agnostic goes in `core/`; domain-specific stays in the feature.
Extract to `core/` once it is used in 2+ places.

Major Current features: `home`, `projects`, `services`, `not_found`.

---

## 3. Adding a feature

1. `features/<name>/domain/model/<name>_model.dart` — with defensive `fromMap`.
2. `features/<name>/domain/repository/<name>_repository.dart` — abstract, returning
   `Future<Either<String, T>>` (fpdart). `Left` is a message ready to render.
3. `features/<name>/data/datasource/` then `data/repository/<name>_repository_impl.dart`.
   Add a `_mock_repository.dart` alongside it.
4. Register the impl in `core/di/locator.dart`.
5. `features/<name>/presentation/pages/<name>_page.dart` — an `AsyncStatelessComponent`
   that awaits the repository and `fold`s both branches. **The error branch must render a
   real page**, not an empty one.
6. Add the path to `core/routing/route_paths.dart`, then a `Route` in `app.dart`.
7. Add `PageMeta` and, where it fits, `StructuredData`.
8. Build and grep the HTML for the new content.

### Adding a project

Append to `features/projects/data/datasource/projects_local_datasource.dart`. It appears on
the home page, the index, and gets its own pre-rendered `/projects/<slug>` page — the route
table reads `ProjectsLocalDatasource.slugs` directly, because static generation must
enumerate every page synchronously before any async work runs.

---

## 4. SEO rules

- **One `<h1>` per page.** Zero leaves crawlers without a topic; two split it. Sections use
  `<h2>` via `SectionBlock`; pass `isPageHeading: true` where the section *is* the page.
- **Every route renders exactly one `PageMeta`** — title, description, canonical, Open Graph,
  Twitter. Nothing else should emit those tags.
- **Never put canonical or `og:*` in `main.server.dart`'s `head:` list.** Entries there are
  emitted verbatim and bypass Jaspr's override system, so a page-level tag *duplicates*
  rather than replaces. Only `title` and `meta` on `Document` participate in overriding, and
  `<meta>` only dedupes by `name` — which is why `PageMeta` puts an `id` on every element.
- **JSON-LD** via `StructuredData` + `SchemaOrg`. It goes in `Document.head`, so it survives
  into the HTML for crawlers that never run JS. Validate after changes:
  `python3 -c "..."` — or paste a page into Google's Rich Results Test.
- **404 sets `noindex, follow`**, has no canonical, and is kept out of the sitemap via
  `--sitemap-exclude '^/404'` — a noindex page listed in the sitemap is a crawl-budget
  contradiction.
- New images need `loading="lazy"` + `decoding="async"` and a descriptive `alt`.
- External links get `rel="me noopener"` where they are identity profiles — `me` corroborates
  the `sameAs` entries in the Person JSON-LD.

---

## 5. State (client islands only)

Riverpod 3 via `jaspr_riverpod`, always with codegen:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'x_controller.g.dart';

@Riverpod(keepAlive: true)   // persists; use @riverpod for autoDispose
class XController extends _$XController {
  @override
  X build() => ...;
}
```

`jaspr_riverpod` has **no** `ConsumerWidget` or `WidgetRef` — use `context.watch`,
`context.read`, `context.listen` on any component's `BuildContext`. To scope rebuilds, wrap
in `Builder`.

An island owns its own `ProviderScope` (see `NavBar`). A nested component must **not** carry
its own `@client` — that would hydrate it as a second root outside that scope. `ThemeToggle`
is the worked example.

Guard every browser API with `kIsWeb`: island code also runs during the static build, where
there is no `document`.

---

## 6. Commands

```bash
jaspr serve                                          # localhost:8080, hot reload
jaspr build --sitemap-domain https://kenstarry.com \
  --sitemap-exclude '^/404'                          # -> build/jaspr/
dart run build_runner build --delete-conflicting-outputs
dart analyze                                         # must be clean
```

**Environment** — both must be on `PATH` or the build fails:

```bash
# Real Dart SDK. On a Homebrew *cask* install `which flutter` is a symlink into
# /opt/homebrew/bin, which has no cache/ dir — resolve the symlink first.
export PATH="$(dirname $(readlink -f $(which flutter)))/cache/dart-sdk/bin:$PATH"
export PATH="$PATH:$HOME/.pub-cache/bin:$HOME/.local/bin"            # jaspr + tailwindcss
```

On this machine that resolves to
`/opt/homebrew/share/flutter/bin/cache/dart-sdk/bin`. Verify with
`which dart` before building — it must **not** print `/opt/homebrew/bin/dart`.

**`dart analyze` is not sufficient on its own.** It analyses one target. An
island's Dart is compiled for *both* server and client, so a web-only import
(`dart:js_interop`) passes analysis and then fails the server build. Anything
touching a `@client` component must be proven with a real `jaspr build`. Use
`package:universal_web/js_interop.dart`, which conditionally exports the real
library on web and throwing stubs on the VM.

**Deployment — Cloudflare Workers** (not Pages; Pages is in maintenance mode
and the dashboard now steers new projects to Workers).

| Setting | Value |
|---|---|
| Build command | `./scripts/build.sh` |
| Deploy command | `npx wrangler deploy` |

There is no output-directory field — `wrangler.jsonc` declares it via
`assets.directory`. `git push` to `main` is the deploy.

`scripts/build.sh` fetches Dart and the Tailwind binary (neither is in
Cloudflare's image), then does what the platform needs:

1. **Prunes `build/jaspr/packages/`** of everything except `starry/`. Jaspr
   copies the test runner, DDC dev-compiler and analyzer assets into the output
   — ~1.3 MB, over half the artefact, referenced by nothing. `packages/starry/`
   stays; it is this package's own builder metadata.
2. **Copies `404/index.html` to `404.html`** — Pages serves the latter for
   unmatched routes, Jaspr only emits the former.
3. **Compiles `functions/` into `_worker.js`** with `wrangler pages functions
   build`, and writes `.assetsignore` so that bundle is not *also* served as a
   downloadable static asset. Skip this step and the site deploys with a dead
   contact form.

`functions/api/contact.js` keeps the Pages Functions layout — file path *is*
the route — because that build step converts it. It runs on Workers, not Node:
no `process`, secrets arrive on `context.env`.

Also pruned: `.dart_tool/`, `.build.manifest`, `styles.tw.css` (the Tailwind
*source*, next to the compiled `styles.css` the pages actually link) and
`images/.gitkeep`.

- `which dart` resolving to a Flutter *wrapper* makes the Jaspr CLI refuse to start
  ("failed to verify the surrounding Dart SDK").
- The standalone `tailwindcss` binary is required — `jaspr_tailwind` shells out to it and
  discards its stderr, so a missing binary surfaces only as
  `PathNotFoundException: .../web/styles.css`.
- When a failure looks impossible, `rm -rf .dart_tool/build` and retry.

---

## 7. Pinned versions — do not bump blindly

- **`build_web_compilers: >=4.4.19 <4.5.0`.** It compiles the `@client` components to JS.
  Without it, `main.client.dart.js` is never emitted, the `<script>` 404s, and the site
  renders but never hydrates. From 4.5.0 it inlines the `build_modules` builders, which
  collide with the copy `jaspr_tailwind` pulls in
  (`outputs collide: package:collection/collection.module.library`). Unpin only once
  `jaspr_tailwind` drops its `build_modules` dependency.
- `dartz` is **not** usable — its constraint is `<3.0.0` and this project is on Dart 3.12.
  `fpdart` provides `Either` instead.

---

## 8. Conventions

Files `snake_case.dart`; generated `*.g.dart` never hand-edited.

| Artifact | Pattern | Example |
|---|---|---|
| Page | `*_page.dart` → `*Page` | `projects_page.dart` |
| Section block | `*_section.dart` | `hero_section.dart` |
| Card | `*_card.dart` | `project_card.dart` |
| Controller | `*_controller.dart` → `*Controller` | `theme_controller.dart` |
| Abstract repo | `*_repository.dart` → `*Repository` | `projects_repository.dart` |
| Live impl | `*_repository_impl.dart` | `projects_repository_impl.dart` |
| Mock impl | `*_mock_repository.dart` | `projects_mock_repository.dart` |
| Datasource | `*_datasource.dart` | `projects_local_datasource.dart` |
| Model | `*_model.dart` → `*Model` | `project_model.dart` |
| Enum | `*_status.dart` → `*Status` | `project_status.dart` |

**Design system:** two tones and a pale, and nothing else.

| Token | Hex | Role |
|---|---|---|
| `ink-950` | `#1E1F2B` | footer — the page closes darker than it opens |
| `ink-900` | `#282739` | base section ground |
| `ink-800` | `#35364A` | raised section ground · card surface |
| `ink-700` | `#434659` | card hover · hairline borders |
| `ink-400` | `#8A8EA8` | muted text |
| `ink-200` | `#D0D4ED` | primary text · the inverted card |
| `ink-100` | `#E9EBF7` | headings |

**There is no accent hue.** Emphasis comes from weight, scale, elevation and
inversion. Sections alternate `ink-900` / `ink-800` so the page reads as stacked
bands. Exactly one element per screen inverts (`.card-invert`) — a second
cancels the first. Adding a second hue, a gradient, a glow or a texture is a
regression, not an enhancement: that is precisely what the first pass got wrong.

**Dark only.** There is no light palette, no `dark:` variant and no theme
toggle. `#282739` *is* the design.

**The ghost-wordmark motif — the golden standard.** Behind the featured
showcase, the project's own name is set enormous (`clamp(5rem, 17vw, 13rem)`) at
`text-ink-100/[0.035]`, `aria-hidden`, `select-none`, sitting under the device.
It is the single detail that makes the section read as premium rather than
merely tidy, and it is the pattern to reach for when a section needs depth:

- **Texture, never content.** Always `aria-hidden` and `select-none` — it must
  never enter the document outline or be read aloud. It repeats text that is
  already a real heading nearby.
- **Barely there.** 3–4% opacity. If you can consciously read it, it is too
  strong and starts competing with the copy.
- **Anchored to something real.** It echoes the adjacent heading or name. A
  decorative word with no referent is just noise.

The footer wordmark is the same idea at page scale.

**No vertical lists of projects.** Projects are always large boxy floating cards
(`.float-card`) — a cover, a hairline, a solid caption panel, mirroring the hero's
portrait card. Home shows **at most three**, vertically staggered; `/projects`
shows a full-width feature card plus a bento grid whose six-column span pattern
repeats every six cards. A list layout is a regression.

**Filtering is CSS-only.** The category pills are `<label>`s for visually-hidden
radios, and sibling selectors hide non-matching cards (`#pf-*` in
`web/styles.tw.css`). This is not a stylistic choice — a Riverpod-filtered grid
would ship crawlers one category and hide the rest behind JS, which §0 forbids.
Every card stays in the document; `display:none` is presentational.

**Tailwind:** classes must be **string literals** — the scanner reads `.dart`
source, so a class built by concatenation gets purged. Design tokens live in
`web/styles.tw.css`; change `--color-ink-200` and the pale moves everywhere.

**Copy:** warm and human, never system-speak. "This page drifted off", not "Error 404".

---

## Spec deviations

From `~/.claude/flutter_architecture_spec.md`, and why:

| Spec | Here | Why |
|---|---|---|
| Riverpod everywhere | Client islands only | Cannot resolve during pre-render — §1. Kills SEO. |
| `ConsumerWidget` + `ref` | `context.watch/read` | `jaspr_riverpod` has no `WidgetRef`. |
| `dartz` for `Either` | `fpdart` | `dartz` caps at Dart `<3.0.0`. |
| `go_router` | `jaspr_router` | Jaspr's own router; drives static page enumeration. |
| `get_it` + Riverpod DI | `core/di/locator.dart` | Providers are unreachable in the content path; one flat composition root instead. |
| `dio` | none yet | No network calls. Slots in behind `ProjectsRepository` unchanged. |
| `ThemeExtension<AppColors>` | Tailwind `@theme` in `web/styles.tw.css` | CSS tokens are the web equivalent. |
| Light + dark themes | Dark only | The two-tone palette *is* the design; there is no second theme to switch to. |
| Hive / secure storage / `flutter_animate` / `JourneyStepper` | n/a | No Flutter runtime. |
