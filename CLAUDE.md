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

Major Current features: `home`, `projects`, `services`, `about`, `contact`, `writing`,
`documents`, `testimonials`, `not_found`.

`/writing` has **no nav tab** — seven of them read as a site map rather than a
navigation. The route, the pages and the sitemap entries all still exist, and
the footer carries the link so the section is not orphaned. Add the tab back
when it has enough posts to earn the slot.

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

### The documents hub

`/documents` is the hub for everything a recruiter files: the CV, the portfolio
as paper, and the degree. It is a full feature (`features/documents/`) with its
own model, enum, datasource and repository, but it *composes* `Locator.about`
and `Locator.projects` rather than restating them — so the hub, `/about` and
`web/cv.pdf` cannot describe three different careers.

**`/cv` still works.** It is a 301 in `web/_redirects`, not a route — a second
route would be a duplicate page competing with the real one. `/resume` redirects
too.

| Band | Is |
|---|---|
| `#cv` | the file, its own pages fanned beside it as `PaperStack` |
| `#degree` | the credential, `SealedDocument`, on request |

**Two bands, and only two.** Everything here has to be a document somebody
would actually file. A print band and a readable copy of the CV both lived here
briefly and both were cut: the hub stopped reading as a records desk and
started reading as a features list. There is no `@media print` block any more —
it existed only to reformat the readable copy, and dead rules that reference
nothing are worse than no rules, because the next person reads them as a
feature.

**The page renders are generated, never drawn.** `web/images/cv-page-*.webp`
come out of the PDF itself:

```bash
pdftoppm -png -r 150 -f 1 -l 3 web/cv.pdf out
cwebp -q 88 -resize 900 0 out-1.png -o web/images/cv-page-1.webp
```

Regenerate them whenever `cv.pdf` changes, or the preview shows a layout the
download does not have.

**`DocumentAccess` is content, not security.** A gated document has no file on
the server at all, and the request goes to a human by `mailto:`. Nothing here
pretends to be access control — on a static site it could not be, and
"available on request" is a normal sentence on a CV. Never publish a blurred
image of a withheld document: it implies a file is sitting there behind a
filter, one URL guess away.

**The university crest is a stencil, never an image.** `web/images/mmust-crest.webp`
carries no colour at all — only an alpha channel where the logo's linework is
opaque and its paper is clear. `.crest` paints `currentColor` through it, so the
mark takes whatever tone the element is set to. That is the *only* way a
two-colour third-party logo can enter a site whose design rule is two tones and
no accent hue; dropping the original PNG in would import a light blue the
palette does not have.

It also means tint and opacity are ordinary Tailwind text-colour utilities —
`text-ink-200` for the crest, `text-ink-100/[0.065]` for the watermark. One CSS
class, every variant.

Regenerate it from the source logo with: alpha = existing alpha × (1 −
luminance), discarding anything under an alpha floor of ~34 so the source's
soft drop shadow does not engrave as a smudge under the ribbon. Export the
**complete lockup** — roundel *and* the "Technology for Development" ribbon —
trimmed to its bounding box, at 512×464 (aspect 1.10), `cwebp -q 75 -alpha_q
70`. The fine outer text ring is indistinguishable from `alpha_q 100` at every
size it is displayed, for a third of the weight.

**The mark is 1.10:1, not square.** Every box that holds it carries that
aspect, and `.crest-seat` has no `rounded-full` — `closest-side` then resolves
the bloom to a soft ellipse that follows the lockup instead of a circle with
the ribbon hanging out of it.

**The mark appears at two scales on both surfaces**, which is what a real
certificate does: the crest at the head, and the same mark again large and
barely there, embossed through the paper. On the home plate the watermark is
hung far enough off the right edge (`-right-40` against a 19rem mark) that the
roundel's *centre* clears the plate and only its outer ring shows — parked any
closer, the dense gear-and-book middle sits under the Verify link and turns it
to mush. An arc reads as embossing; a whole logo behind a button reads as clip
art.

Both instances are `aria-hidden`: the institution is named in text beside them,
and a screen reader announcing the crest would be repeating it.

**The degree also appears on the home page**, as `HonoursBand` directly under
the hero — the certificate language from `SealedDocument` (drawn seal, double
hairline frame, ruled ground) at strip scale, so the two read as one claim seen
twice rather than as two designs. It is fed the same `AboutLocalDatasource`
education entry, and renders nothing when there is none.

It is a band rather than a pill inside the hero on purpose: the hero is already
a name, a statement, a portrait and three stat pills, and a fourth claim in
there reads as competition, not emphasis. It is also deliberately slim — a full
section for one line of credential would overplay it.

### Adding a post

Append to `features/writing/data/datasource/writing_local_datasource.dart`, then add
it to the `posts` list — which is the running order, newest first, with no sort step
to disagree with it.

**A post's `body` decides whether it gets a page.** `WritingLocalDatasource.slugs`
filters on `PostModel.hasBody` and `app.dart` enumerates that, so:

| `body` | `url` | Result |
|---|---|---|
| set | — | card links to `/writing/<slug>`, page is generated |
| empty | set | card links out in a new tab, no page |
| empty | null | unlinked card marked *Soon*, no page |

That third row is deliberate. Listing a piece you have not written is honest; 404ing
on it is not. Give it a `body` later and the page appears on the next build with no
other change.

The body is a `List<PostBlock>` — a sealed hierarchy in
`domain/model/post_block.dart` (`PostHeading`, `PostProse`, `PostCode`, `PostImage`,
`PostList`, `PostNote`, `PostSteps`). `PostBody` switches over it exhaustively, so a
new block type is a compile error until it is rendered.

**Prose carries three inline forms and no more:** `` `code` ``, `**bold**` and
`[label](href)`. Everything else is escaped through `Component.text`, so authored
content can never inject markup. If you need a fourth construct, add a `PostBlock` —
not a new escape sequence, which would be a thing the stylesheet has no rules for.

Headings in a body are `h2`/`h3` only. The `h1` is the post title in the masthead
(§4), and `PostHeading.anchor` derives its own id so the contents rail cannot list a
section that is not there.

### Adding a project

Append to `features/projects/data/datasource/projects_local_datasource.dart`. It appears on
the home page, the index, and gets its own pre-rendered `/projects/<slug>` page — the route
table reads `ProjectsLocalDatasource.caseStudySlugs`, because static generation must
enumerate every page synchronously before any async work runs. A project with no `features`
and no `modules` has no case study written, so it gets no route and cannot be linked to.

#### The three axes — keep them separate

A project is described on three independent axes. They answer different questions, and
collapsing any two produces an enum with no coherent meaning:

| Axis | Question | Values | Drives |
|---|---|---|---|
| `ProjectKind` | what is it? | `product` · `package` | the top-level split on `/projects` |
| `ProjectCategory` | who was it for? | enterprise · commercial · personal | the bands within products |
| `ProjectPlatform` | where does it run? | android · iOS · web · desktop | a badge on the card |

**"Open source" is not a category.** It is a licence plus a public repo — a *property*, not
a grouping. A mobile app can be open source too, which is exactly how an axis breaks. What
separates `flutter_extend` from every other entry is that it is not an application: no
screens, no store listing, no users. Developers depend on it. That is a difference of
*kind*.

`ProjectKind` defaults to `product`, so adding the axis recategorised nothing. Products flow
through the featured showcase and the category bands unchanged; packages get `_KindBand`,
which closes the page. A single package renders as a wide two-column card rather than a bento
of one — and it leads with `highlights`, because a library is judged on its maintenance
record, not its screenshots.

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

The footer wordmark is the same idea at page scale, and `PageHeader` carries it
on every inner page — the page's own name bleeding off the bottom-left corner,
sized in three steps by word length (`.ghost-title-lg/md/sm`), because one clamp
that flatters `Work` sets `Services` at a width no viewport can hold.

**Two-tone display titles — the headline treatment.** Every `<h1>` on the site
is set in two tones by `TwoToneTitle`: one half `ink-100` at `font-extrabold`,
the other `ink-400` one weight step lighter. The muted half sits back in *two*
dimensions rather than one, which is the difference between a heading that looks
recoloured and one that looks typeset.

- **One definition, never inlined.** The moment the pair of spans is written out
  twice, the copies start disagreeing about which grey, which weight, and
  whether the muted half gets its own line.
- **`ink-400`, never `ink-500`.** A headline is content. `ink-400` on `ink-900`
  is ~4.3:1; `ink-500` is ~2.5:1, under the 3:1 floor even large text must
  clear. The `ink-500` used for mono labels is not available here.
- **One weight step.** `font-bold` under an `extrabold` headline. Two notches
  reads as a mistake, and both weights must actually be loaded — Plus Jakarta
  Sans ships 700 and 800 in `main.server.dart`, so neither is synthesised.
- **Which half sits back is a judgement.** On a page header it is the clause
  that qualifies the first — "What I build, / *and how I work.*" On the home
  hero it is inverted: a name is not a sentence with a clause to send to the
  back, so it runs muted → bright → the accent rule beneath, cresting into the
  mark rather than trailing away from it.

**`PageHeader` opens every page except home.** Trail, title, standfirst,
optional aside, ruled numbers, jump pills — in that order, from one component,
so three pages cannot drift into three ideas of what a header is. Its motion is
the time-based `.rise` stagger, never `.reveal`: a header is above the fold and
there is nothing to scroll yet.

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

**`SiteConfig.showTestimonials` is the blanket off-switch.** While it is
`false` the repository is not read and the band never reaches the page — a
stronger guarantee than the `draft` marker alone, and the right state to deploy
in until the quotes are real and cleared to publish. It sits alongside
`SiteConfig.customCursor` and works the same way.

**Placeholder testimonials must carry `draft: true`.** `git push` to `main`
deploys this site, and a fabricated endorsement that *looks* real is the thing
to avoid — one that announces itself is just a layout fixture. While any entry
is a draft, `TestimonialBand` renders a visible **Sample content** marker beside
the heading. Clear the flag when the quote is real and the marker disappears on
its own; it is the same mechanism `ExperienceModel` uses for unconfirmed dates.

**Never attribute an invented quote to a real person or organisation**, even
behind the draft flag. The current placeholders say `Placeholder Name` at
`Sample Company` for exactly that reason.

`TestimonialBand` renders **nothing** when the list is empty — no heading, no
empty state, no "coming soon", because a section announcing it has no social
proof is worse than no section.

Attribution is required by the model: a quote with no name is dropped by the
repository rather than rendered, because an anonymous testimonial reads as
invented even when it is not. `source` links to somewhere it can be verified;
`projectSlug` links to the build it came out of.

The lead quote is set **flat, not on `.card-invert`** — the home page already
spends its one permitted inversion on the featured service card, and flat is
how `/projects` presents its featured work anyway. It is composed as a magazine
pull-quote: an oversized opening mark, the quote at display scale, and the
byline in its own column behind a vertical rule. Three devices, none of them a
box.

`TestimonialModel.emphasis` is the clause set bright (`ink-100`) against the
rest of the quote (`ink-300`) — the site's two-tone headline device applied to
running text, at a narrower tonal gap than `TwoToneTitle` uses because a quote
has to stay readable across four lines. It must be a **verbatim substring** of
`quote`; anything else renders the whole quote bright, which is the safe
failure.

**That blockquote is a single `RawText`, and it has to be.** Jaspr indents child
components onto their own lines, and that whitespace collapses to a rendered
space between inline siblings — a `<span>` ending mid-sentence produced
`product .` with a gap before the full stop. One node has no siblings to be
separated from. Everything interpolated goes through the file's `_esc` helper,
so authored content still cannot inject markup.

**Motion is scroll-driven, and the base state is always visible.** Every
entrance animation hangs off `animation-timeline: view()` or `scroll()` inside
an `@supports` guard, with the *un-animated* state being the visible one. A
browser without scroll-timeline support — and every crawler — sees a finished
page, never a grid of invisible boxes. The one exception is `.rise`, which is
time-based because it runs above the fold where there is nothing to scroll yet.

The vocabulary, all in `web/styles.tw.css`:

| Class | Does |
|---|---|
| `.reveal` | the standard entrance — fade and 18px lift |
| `.rise` + `.d-1`…`.d-7` | time-based entrance, for above-the-fold |
| `.stagger` | on a **container**; children enter over successive slices of one timeline |
| `.draw-rule` | a hairline sweeps out from the left |
| `.reveal-media` | a cover uncovers upward from a slight overscale |
| `.press` | `scale(0.97)` on `:active`, spring on release |
| `.to-top` / `.to-top-btn` | the back-to-top control's appearance and hover |
| `.hero-far` / `.hero-mid` / `.hero-near` | the hero's three parallax planes |

Two rules that are easy to get wrong:

- **`.stagger` replaces `.reveal` on its children — never both.** Both animate
  the same element on the same timeline and the later declaration silently wins.
- **The hero's parallax rides `translate`, never `transform`.** Every element
  in the hero already animates `transform` through `.rise`, and a second
  animation on the same property overwrites the first. The independent
  `translate` property lets the entrance and the parallax coexist without
  either knowing about the other — the same separation the custom cursor uses.
  The planes deliberately *diverge* (the ghost sinks while the copy lifts):
  moving everything one way at different speeds reads as lag, not depth.
- **Never put `.reveal-media` on an element that owns a `transform`.** It
  animates `transform`, and with `both` fill it *holds* its end value once out
  of range, overriding any hover scale. Put it on a wrapper instead — that is
  why `ProjectCover` carries it on the frame rather than on the `<img>`.

Everything degrades under `prefers-reduced-motion`, at the foot of the
stylesheet. The back-to-top button is deliberately exempt from being hidden
there: it is navigation, not decoration.

**The custom cursor is a `<script>`, not an island**, and is gated by
`SiteConfig.customCursor`. **Its geometry is fixed** — hover and press change
colour, fill and bloom only, never size. A cursor that resizes under the hand
stops reading as a cursor and makes precise targeting harder at the exact
moment you are aiming at something. It declines to run on coarse pointers and under
reduced motion, and the native cursor is only hidden once the script has
confirmed it is running (`body.has-cursor`) — so the failure mode is "no custom
cursor", never "no cursor at all". It is the site's only inline script;
`NavBar` remains the only `@client` island.

**Tailwind:** classes must be **string literals** — the scanner reads `.dart`
source, so a class built by concatenation gets purged. Design tokens live in
`web/styles.tw.css`; change `--color-ink-200` and the pale moves everywhere.

**Copy: no em dashes. Anywhere.** Not in prose, not as a bullet, not as a
separator, not in a date range. They read as machine-written and the brand does
not want that. Use a colon for an elaboration, a comma for an aside, a full stop
for a second clause, `·` for a separator or bullet, and a plain hyphen for a date
range. `dart analyze` will not catch one, so grep the built HTML:

```bash
python3 -c "import re,pathlib,glob;print(sum(re.sub(r'<[^>]+>',' ',pathlib.Path(f).read_text()).count(chr(8212)) for f in glob.glob('build/jaspr/**/index.html',recursive=True) if 'packages/' not in f))"
```

**Voice: goofy, not corporate.** Ken likes this work and the copy should sound
like it. Self-aware, a bit playful, happy to admit to losing a weekend to
spacing. What it must never become is either a CV read aloud or a startup
landing page: no "leverage", no "passionate about", no "solutions". The test is
whether a sentence is more fun to read than the same fact stated plainly. If it
is not, it is just longer.

Restraint still applies in two places: the credential surfaces
(`HonoursBand`, `SealedDocument`) stay dignified, because formality *is* the
aesthetic there, and error copy stays warm and plain: "This page drifted off",
not "Error 404".

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
