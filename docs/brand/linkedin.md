# LinkedIn

Same brand as the site and the GitHub profile, on the surface where recruiters
actually search. Assets in this folder; copy below.

## Cover image

`linkedin-banner.png` (exported from `linkedin-banner.svg`, which is the source
of truth). 3168x792, which is LinkedIn's 1584x396 at 2x so it stays sharp on
retina. LinkedIn takes PNG or JPG, never SVG.

Two constraints shaped the layout, both LinkedIn's:

- **The profile photo covers the bottom left.** Nothing readable goes in roughly
  x 60-330, y 210-396. The ghost wordmark sits there instead, because losing
  part of a texture behind an avatar costs nothing.
- **Mobile crops inward from both sides.** All content is held between x 430 and
  x 1290. The stat labels originally ran past that and lost their tails on a
  phone.

It deliberately does not repeat the name. LinkedIn prints that directly
underneath at display size, so the cover spends its space on what LinkedIn does
not show: what he does, and where to go next.

**Upload:** profile → camera icon on the cover → upload `linkedin-banner.png`.

## Headline

220 characters allowed, and it is weighted heavily in LinkedIn's own search, so
it is written for that the same way the site's `<title>` tags are.

```
Flutter & Mobile App Developer · Nairobi, Kenya | Android and iOS, end to end: design system, architecture, release | kenstarry.com
```

## About

```
I build apps that move, breathe, and show off a little.

Five years deep in Flutter, taking mobile products the whole way: brand, design
system, architecture, QA, and the shipping to both stores. Right now that means
owning the full mobile lifecycle at a Kenyan telehealth platform, and building
Flutter products for businesses that have outgrown a website and know it.

The last 10% is where I live: the easing curve on a sheet, the empty state
nobody scoped, the release build that works first try. I have been told this is
a lot. I remain unbothered.

Shipped and on the stores: HealthX (telehealth, Android and iOS), Flow Music
Player (offline music, endlessly tunable and genuinely pretty), RezQ (resume
right way round), and work for Britam and Podii.

Open source: flutter_extend, a Dart extension library with 37 extensions, 80
tests and 13 releases of continuous maintenance.

Case studies, writing and the CV: kenstarry.com
```

## Featured section

Order matters, the first card is the most prominent. Four entries, no more:
Featured is a highlight reel and a fifth turns it into a list.

1. **kenstarry.com** — the portfolio
2. **kenstarry.com/projects/flow** — a real shipped product with a store listing
3. **pub.dev/packages/flutter_extend** — open source, maintained
4. **kenstarry.com/documents** — the CV, for anyone who needs the paper

Links render as cards built from `og:title`, `og:description` and `og:image`.
Those are already correct on every page (see `docs/05-seo.md`), with one
caveat noted below.

## Two things to do on LinkedIn itself

**Refresh LinkedIn's link cache before sharing anything.** LinkedIn caches
Open Graph data hard and this site's `og:title` and `og:description` both
changed. Run each URL through **linkedin.com/post-inspector** once, or the
Featured cards and any share will show the old copy for weeks.

**Claim a custom profile URL.** It is currently
`linkedin.com/in/ken-s-133a04217`, which is not a brand, it is a database row.
`linkedin.com/in/kenstarry` is the goal.

> **Order matters here.** That URL is hardcoded in `SiteConfig.socials` and
> feeds the `sameAs` array in the Person JSON-LD, which is what tells Google
> this profile and this site are the same identity. LinkedIn does not reliably
> redirect the old URL. So: change it on LinkedIn first, then update
> `SiteConfig`, then deploy. Doing it the other way round points `sameAs` at a
> dead URL and weakens the entity graph the SEO work was built on.

## Known gap: share cards are repetitive

Only `flutter-extend` has its own `coverImage`. Every other page falls back to
the same `/images/og.jpg`, so three of the four Featured cards above would
render an identical image.

Worse, `flutter-extend`'s card is a `.webp`, and LinkedIn's scraper support for
WebP is unreliable, so the one page with a custom image may render none at all.

The fix is per-project Open Graph cards at 1200x630 in JPG or PNG, generated
the same way `web/images/gh-card-*.svg` were. That would give every case study
a distinct card on LinkedIn, X, Slack and WhatsApp, not just in Featured.
Not done yet.
