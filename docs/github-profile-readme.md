<!--
  Source of truth for the README rendered on the GitHub profile at
  github.com/KenStarry (the special `KenStarry/KenStarry` repo). Not
  documentation for this repo.

  It lives here because every figure below traces back to `SiteConfig` or
  `ProjectsLocalDatasource`, and keeping the two together is what stops the
  profile and the site describing two different careers. If they ever
  disagree, this file is wrong and the datasource is right.

  The banner is `web/images/gh-banner.svg` and the showcase cards are
  `web/images/gh-card-*.svg`, all in this repo, served from kenstarry.com and
  built from the site's own design tokens. The cards are generated: the
  mockups carry alpha, so dropping them into a README raw would render a
  device silhouette on the reader's theme background. Compositing them onto
  the card's ink ground makes each one self-contained.

  Camo caches these hard: to change the art, change the FILENAME, not just
  the contents.

  Deliberately no tables anywhere. Projects are cards, the way they are on
  the site, and a table here would be the README's version of the vertical
  list the design system already rules out.

  To publish: copy this file verbatim to `README.md` in the profile repo.
-->

<div align="center">

<a href="https://kenstarry.com">
  <img src="https://kenstarry.com/images/gh-banner.svg" width="100%"
       alt="Ken Starry, Flutter and Mobile App Developer in Nairobi, Kenya" />
</a>

<br/>

[![Portfolio](https://img.shields.io/badge/Portfolio-kenstarry.com-1E1F2B?style=for-the-badge&logo=safari&logoColor=E9EBF7&labelColor=1E1F2B)](https://kenstarry.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-282739?style=for-the-badge&logo=linkedin&logoColor=D0D4ED&labelColor=282739)](https://www.linkedin.com/in/ken-s-133a04217/)
[![X](https://img.shields.io/badge/@ken__starry-35364A?style=for-the-badge&logo=x&logoColor=D0D4ED&labelColor=35364A)](https://x.com/ken_starry)
[![Email](https://img.shields.io/badge/Email-434659?style=for-the-badge&logo=gmail&logoColor=D0D4ED&labelColor=434659)](mailto:starrycodes@gmail.com)

</div>

---

Five years deep in Flutter. I take mobile products the whole way: brand, design
system, architecture, QA, and the shipping to both stores.

Right now that means owning the full mobile lifecycle at a Kenyan telehealth
platform, and building Flutter products for businesses that have outgrown a
website and know it. The last 10% is where I live: the easing curve on a sheet,
the empty state nobody scoped, the release build that works first try. I have
been told this is a lot. I remain unbothered.

> [!NOTE]
> **Free for new work, and unreasonably keen.**
> The full story, with case studies, lives at **[kenstarry.com](https://kenstarry.com)**.

---

## Shipped

[![HealthX: care, a pharmacy and a doctor, in one app](https://kenstarry.com/images/gh-card-healthx.svg)](https://kenstarry.com/projects/healthx)

<sub>**HealthX** on [Google Play](https://play.google.com/store/apps/details?id=com.healthx.app&hl=en) and the [App Store](https://apps.apple.com/ke/app/healthx-africa/id1570107533) · [read the case study](https://kenstarry.com/projects/healthx)</sub>

<br/>

[![Flow Music Player: an offline player built to rival Poweramp](https://kenstarry.com/images/gh-card-flow.svg)](https://kenstarry.com/projects/flow)

<sub>**Flow Music Player** on [Google Play](https://play.google.com/store/apps/details?id=com.kenstarry.flow) · [read the case study](https://kenstarry.com/projects/flow)</sub>

<br/>

[![RezQ: resume building, the right way round](https://kenstarry.com/images/gh-card-rezq.svg)](https://kenstarry.com/projects/rezq)

<sub>**RezQ** on [Google Play](https://play.google.com/store/apps/details?id=com.kenstarry.rezq) · [read the case study](https://kenstarry.com/projects/rezq)</sub>

<br/>

Also shipped: **Britam**, policies, investments and loans finally in one place,
on [Google Play](https://play.google.com/store/apps/details?id=com.app.britam).
And **Elvs Mobile**, volunteer work finally accounted for.

<sub>Built with and for **Britam · Dentsu · HealthX · Podii** · [see all the work](https://kenstarry.com/projects)</sub>

---

## Open source

### [`flutter_extend`](https://pub.dev/packages/flutter_extend)

The boilerplate you stop writing. It started as the shared layer inside Flow,
and got pulled out once the same twenty helpers had been copied into a third
codebase.

```dart
context.pushScreen(Home());   // not the Navigator dance
Text('hi').padding();         // declared on the widget, not around it
context.colorScheme;          // not Theme.of(context)
email.isValidEmail;
```

**37 extensions** across 12 core types · **80 tests** in 13 files, gated by CI on
every PR · **13 releases** of continuous maintenance · deprecations ship with a
named removal version and the exact call to migrate to.

[Docs](https://starrycodes.mintlify.app/flutter_extend/introduction) · [Source](https://github.com/KenStarry/flutter_extend) · [**How it was built**](https://kenstarry.com/projects/flutter-extend)

---

## Toolkit

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-35364A?style=for-the-badge&logo=flutter&logoColor=D0D4ED&labelColor=35364A)
![Dart](https://img.shields.io/badge/Dart-35364A?style=for-the-badge&logo=dart&logoColor=D0D4ED&labelColor=35364A)
![Firebase](https://img.shields.io/badge/Firebase-35364A?style=for-the-badge&logo=firebase&logoColor=D0D4ED&labelColor=35364A)
![Android](https://img.shields.io/badge/Android-35364A?style=for-the-badge&logo=android&logoColor=D0D4ED&labelColor=35364A)
![iOS](https://img.shields.io/badge/iOS-35364A?style=for-the-badge&logo=apple&logoColor=D0D4ED&labelColor=35364A)
![Figma](https://img.shields.io/badge/Figma-35364A?style=for-the-badge&logo=figma&logoColor=D0D4ED&labelColor=35364A)
![GitHub Actions](https://img.shields.io/badge/Actions-35364A?style=for-the-badge&logo=githubactions&logoColor=D0D4ED&labelColor=35364A)

</div>

Yes, [my portfolio is written in Dart too](https://kenstarry.com/projects).
Every route pre-rendered to static HTML, because a portfolio that needs
JavaScript to show its own content is a portfolio nobody finds.

---

## Writing

Long-form notes on Flutter, architecture and actually shipping things:
**[kenstarry.com/writing](https://kenstarry.com/writing)**

---

<div align="center">

### Got something you want built properly?

[![Start a project](https://img.shields.io/badge/Start%20a%20project-E9EBF7?style=for-the-badge&logoColor=1E1F2B&labelColor=E9EBF7&color=E9EBF7)](https://kenstarry.com/contact)

<sub>Nairobi, Kenya · <a href="https://kenstarry.com">kenstarry.com</a> · <a href="https://buymeacoffee.com/kenstarry">Buy me a coffee</a></sub>

</div>
