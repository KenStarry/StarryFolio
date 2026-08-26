# 5. SEO

The site's job is to be found, read and shared. This doc covers every mechanism doing that
work, plus the two traps that break it silently.

## Foundation: it's all pre-rendered

Everything below is decoration on one fact — **every page ships as complete HTML**. No
JavaScript is needed to read the content, so crawlers, link-preview bots and no-JS visitors
all get the full page. [Doc 2](./02-rendering-and-hydration.md) covers how, and how it breaks.

## The head, and who owns what

Two places write to `<head>`, and the split matters.

### Site-wide — `main.server.dart`

```dart
const Document(
  title: '${SiteConfig.name} — ${SiteConfig.role}',
  lang: 'en',
  meta: {
    'description': SiteConfig.tagline,
    'author': SiteConfig.name,
    'theme-color': '#07070b',
  },
  head: [
    link(rel: 'icon', href: '/favicon.svg', …),
    link(rel: 'preconnect', href: 'https://fonts.googleapis.com'),
    link(rel: 'stylesheet', href: '/styles.css'),
    meta(name: 'twitter:card', content: 'summary_large_image'),
    meta(name: 'robots', content: 'index, follow, max-image-preview:large'),
    script(content: _themeBoot),
  ],
  body: App(),
)
```

Only true constants belong in that `head:` list. Why is trap #1.

### Per-page — `core/seo/page_meta.dart`

Every route renders exactly one `PageMeta`, which owns title, description, canonical, Open
Graph and Twitter tags:

```dart
const PageMeta(
  path: RoutePaths.projects,
  title: 'Projects — ${SiteConfig.name}',
  description: 'Case studies from the mobile products I have designed and shipped…',
)
```

It builds on `Document.head`, which lifts children out of the tree and into `<head>` even
though you wrote them mid-page:

```dart
Document.head(
  title: title,
  meta: {'description': description},
  children: [
    link(id: 'canonical', rel: 'canonical', href: url),
    meta(id: 'og-url', attributes: {'property': 'og:url', 'content': url}),
    // …
  ],
)
```

## Trap #1 — head defaults that duplicate instead of override

Jaspr's override rules for nested `Document.head`:

- `<title>` and `<base>` override their own kind
- `<meta>` overrides another `<meta>` **with the same `name`**
- any element overrides another **with the same `id`**

Two consequences, both learned the hard way on this project:

**Open Graph tags key off `property`, not `name`.** `<meta property="og:url">` will never
match another by name — so without an `id` they stack. That is why every element in
`PageMeta` carries one (`id: 'og-url'`, `id: 'canonical'`, …).

**Entries in the root `Document`'s `head:` list are not part of the override system at all.**
They are emitted verbatim. Putting a default canonical there and a real one in the page
produced *both*:

```html
<link id="canonical" href="https://kenstarry.com" rel="canonical"/>
<link id="canonical" href="https://kenstarry.com/projects" rel="canonical"/>
```

Two canonicals on one page means search engines pick one, or ignore both. The fix was to
delete the defaults entirely — `PageMeta` is now the sole source, and the root `Document`
carries only genuinely global tags.

> **Rule:** never put `canonical` or `og:*` in `main.server.dart`. If a tag can vary per page,
> it belongs in `PageMeta`.

## Trap #2 — content that never reaches the HTML

Covered fully in [doc 2](./02-rendering-and-hydration.md), restated because it is the one that
matters most: a Riverpod async provider in a content page produces a build that **succeeds**,
a page that **looks correct in the browser**, and an HTML file containing `AsyncLoading` —
which is all a crawler ever sees.

Content pages are `AsyncStatelessComponent`s that `await` a repository. No exceptions.

## Canonical URLs

Every indexable page declares where it really lives:

```dart
static String absolute(String path) => path == '/' ? siteUrl : '$siteUrl$path';
```

Absolute, because relative canonicals are unreliable across scrapers. Verified output:

| Page | Canonical |
|---|---|
| `/` | `https://kenstarry.com` |
| `/projects` | `https://kenstarry.com/projects` |
| `/projects/flow` | `https://kenstarry.com/projects/flow` |
| `/404` | *none* — `noindex, follow` instead |

## Open Graph & Twitter

Controls what appears when a link is pasted into Slack, WhatsApp, LinkedIn or X.

```html
<meta property="og:type"        content="article"/>
<meta property="og:url"         content="https://kenstarry.com/projects/flow"/>
<meta property="og:title"       content="Flow — Ken Starry"/>
<meta property="og:description" content="A money tracker that does not nag."/>
<meta property="og:image"       content="https://kenstarry.com/images/og.png"/>
```

Index pages use `og:type: website`; case studies use `article`. A project with a `coverImage`
uses it as the share image, falling back to `/images/og.png`.

> **To do:** add `web/images/og.png` at 1200×630. The tag points there already; the file does
> not exist yet, so shared links currently render without a preview image.

## Structured data (JSON-LD)

`core/seo/structured_data.dart` emits machine-readable descriptions of each page. This is how
a search engine learns that "Ken Starry" is a *person*, with a *job title*, who owns *these*
social profiles — rather than inferring it from prose.

| Page | Schemas |
|---|---|
| `/` | `Person` + `WebSite` |
| `/projects` | `ItemList` + `BreadcrumbList` |
| `/projects/<slug>` | `CreativeWork` + `BreadcrumbList` |
| `/404` | none |

The `Person` block draws entirely from `SiteConfig`, so it cannot drift from the visible page:

```json
{
  "@context": "https://schema.org",
  "@type": "Person",
  "name": "Ken Starry",
  "jobTitle": "Flutter UI/UX Engineer",
  "email": "mailto:starrycodes@gmail.com",
  "address": { "@type": "PostalAddress",
               "addressLocality": "Nairobi", "addressCountry": "Kenya" },
  "knowsAbout": ["Dart", "Flutter", "Jaspr", "Clean Architecture", …],
  "sameAs": ["https://github.com/KenStarry",
             "https://www.linkedin.com/in/kenstarry/",
             "https://x.com/KenStarry"]
}
```

`sameAs` is the property that ties those profiles to this identity. The same URLs carry
`rel="me"` in the footer and contact section, corroborating the claim from both directions.

`BreadcrumbList` is what renders `kenstarry.com › Projects › Flow` under a search result
instead of a bare URL.

### One escaping detail

`script(content: …)` renders its content **raw** (via `RawText`). A literal `</script>` or
`<!--` inside a string value would close the tag early and break the page. So the encoder
neutralises it:

```dart
content: jsonEncode(data).replaceAll('<', r'\u003c'),
```

`\u003c` is a valid escape anywhere inside a JSON string, and `jsonEncode` only ever emits
`<` inside string values — structural characters are `{}[]",:`. Safe, and the JSON still
parses.

Validate after changes:

```bash
python3 - <<'PY'
import json, re, pathlib
for f in ['index.html', 'projects/index.html', 'projects/flow/index.html']:
    s = pathlib.Path('build/jaspr/' + f).read_text()
    for b in re.findall(r'<script[^>]*application/ld\+json[^>]*>(.*?)</script>', s, re.S):
        print(f, '->', json.loads(b)['@type'])
PY
```

Or paste a page into Google's Rich Results Test.

## Heading hierarchy

**Exactly one `<h1>` per page.** Zero leaves a crawler without a primary topic; two split it.

`SectionBlock` renders `<h2>` by default. Where the section *is* the page — the projects index
— it takes `isPageHeading: true` and renders `<h1>` instead. That flag exists because the
projects index shipped with **zero** `<h1>` elements until it was caught by grepping the
output.

Current state, verified:

| Page | `<h1>` |
|---|---|
| `/` | 1 (hero) |
| `/projects` | 1 (section heading) |
| `/projects/<slug>` | 1 (project name) |
| `/404` | 1 |

## Sitemap & robots

```bash
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'
```

Generates `sitemap.xml` from the route table — add a project, get a sitemap entry, free. The
exclusion keeps the `noindex` 404 out of it.

```
https://kenstarry.com/
https://kenstarry.com/projects
https://kenstarry.com/projects/criblynk
https://kenstarry.com/projects/flow
https://kenstarry.com/projects/eduflow
```

`web/robots.txt` is served as-is and should point at the sitemap.

## Performance (it is a ranking factor)

- **Fonts:** `preconnect` to both Google Fonts origins, and `display=swap` so text renders in
  a fallback rather than staying invisible.
- **Images:** `loading="lazy"` + `decoding="async"` on project covers, with descriptive `alt`
  (`"Flow — A money tracker that does not nag."`, not `"screenshot"`).
- **JS:** 176 KB total, `defer`red, and needed by nothing that matters for reading.
- **No layout shift** from theme: the pre-paint script settles it before first render.

## Checklist for any change

```bash
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'
```

- [ ] Content is in `build/jaspr/**/*.html`, not just the browser
- [ ] Exactly one `<h1>`
- [ ] Exactly one `rel="canonical"` (or `noindex` and none)
- [ ] `og:title` / `og:description` / `og:image` present and page-specific
- [ ] JSON-LD parses
- [ ] New images have `alt`, `loading`, `decoding`
- [ ] New route appears in `sitemap.xml`

---

Next: [State & Riverpod →](./06-state-and-riverpod.md)
