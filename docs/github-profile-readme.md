<!--
  This is not documentation for this repo. It is the source of truth for the
  README rendered on the GitHub profile at github.com/KenStarry — a special
  repo named `KenStarry/KenStarry`, which GitHub renders above the pinned
  repositories.

  It lives here because it is an off-site surface built from *this* repo's
  facts: every figure below traces back to `SiteConfig` or to
  `ProjectsLocalDatasource`, and the whole point of keeping the two together is
  that they cannot drift into describing two different careers.

  To publish: copy this file verbatim to `README.md` in the profile repo. The
  comment goes with it and renders as nothing.

  When a project ships, a store URL changes or a `flutter_extend` figure moves,
  update it here and re-copy. If they ever disagree, this file is wrong and the
  datasource is right.
-->
<div align="center">

# Ken Starry

### Flutter & Mobile App Developer · Nairobi, Kenya

**I build whole apps, then argue with myself about the spacing.**

[![Portfolio](https://img.shields.io/badge/kenstarry.com-1E1F2B?style=for-the-badge&logo=safari&logoColor=D0D4ED)](https://kenstarry.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-282739?style=for-the-badge&logo=linkedin&logoColor=D0D4ED)](https://www.linkedin.com/in/ken-s-133a04217/)
[![X](https://img.shields.io/badge/@ken__starry-35364A?style=for-the-badge&logo=x&logoColor=D0D4ED)](https://x.com/ken_starry)
[![Email](https://img.shields.io/badge/starrycodes@gmail.com-434659?style=for-the-badge&logo=gmail&logoColor=D0D4ED)](mailto:starrycodes@gmail.com)

</div>

---

Five years deep in Flutter. I take mobile products the whole way: brand, design
system, architecture, QA, and the shipping to both stores. Right now that means
owning the full mobile lifecycle at a Kenyan telehealth platform, and building
Flutter products for businesses that have outgrown a website and know it.

The last 10% is where I live: the easing curve on a sheet, the empty state
nobody scoped, the release build that works first try. I have been told this is
a lot. I remain unbothered.

**→ The full story, with case studies: [kenstarry.com](https://kenstarry.com)**

---

## 📱 Shipped

| | What it is | Where |
|---|---|---|
| **HealthX** | Telehealth: care, a pharmacy and a doctor in one app | [Play](https://play.google.com/store/apps/details?id=com.healthx.app&hl=en) · [App Store](https://apps.apple.com/ke/app/healthx-africa/id1570107533) · [Case study](https://kenstarry.com/projects/healthx) |
| **Flow Music Player** | Offline player built to rival Poweramp. Parametric EQ, gapless playback, no account | [Play](https://play.google.com/store/apps/details?id=com.kenstarry.flow) · [Case study](https://kenstarry.com/projects/flow) |
| **RezQ** | Resume building, the right way round | [Play](https://play.google.com/store/apps/details?id=com.kenstarry.rezq) · [Case study](https://kenstarry.com/projects/rezq) |
| **Britam** | Policies, investments and loans, finally in one place | [Play](https://play.google.com/store/apps/details?id=com.app.britam) |
| **Elvs Mobile** | Volunteer work, finally accounted for | [Play](https://play.google.com/store/apps/details?id=com.podii.elvs) |

Built with and for **Britam · Dentsu · HealthX · Podii**.

---

## 📦 Open source

### [`flutter_extend`](https://github.com/KenStarry/flutter_extend) · [pub.dev](https://pub.dev/packages/flutter_extend)

The boilerplate you stop writing. It started as the shared layer inside Flow,
and got pulled out once the same twenty helpers had been copied into a third
codebase.

- **37 extensions** across 12 core types: `String`, `BuildContext`, `Widget`, `File`, `DateTime`, `num`, `Color` and more
- **80 tests** in 13 files, run by GitHub Actions on every pull request
- **13 releases** over a year of continuous maintenance, v0.0.1 to v0.3.1
- Deprecations ship with a named removal version and the exact call to migrate to

```dart
context.pushScreen(Home());        // not the Navigator dance
Text('hi').padding();              // declared on the widget, not around it
context.colorScheme;               // not Theme.of(context)
email.isValidEmail;
```

[Docs](https://starrycodes.mintlify.app/flutter_extend/introduction) · [How it was built](https://kenstarry.com/projects/flutter-extend)

---

## 🧰 Toolkit

**Flutter · Dart · BLoC · Riverpod · Clean Architecture · Firebase · FFI · Shorebird · Figma · Jaspr**

Yes, [my portfolio is written in Dart too](https://kenstarry.com/projects). Every
route pre-rendered to static HTML, because a portfolio that needs JavaScript to
show its own content is a portfolio nobody finds.

---

## ✍️ Writing

Long-form notes on Flutter, architecture and actually shipping things:
**[kenstarry.com/writing](https://kenstarry.com/writing)**

---

<div align="center">

### Free for new work, and unreasonably keen.

**[Start a project →](https://kenstarry.com/contact)**

<sub>Nairobi, Kenya · <a href="https://kenstarry.com">kenstarry.com</a> · <a href="https://buymeacoffee.com/kenstarry">Buy me a coffee</a></sub>

</div>
