import '../domain/model/social_link.dart';

/// Build-time identity for the whole site.
///
/// This is deliberately a `const` class rather than a repository: `main.server.dart`
/// reads it while composing the `<html>` document, which happens *outside* the
/// component tree where no provider or async repository can reach. Every page
/// title, canonical URL and Open Graph tag traces back here, so keeping it
/// synchronous is what makes the SEO metadata resolvable at build time.
///
/// Content that could plausibly move to a CMS later — the projects, the
/// services — goes through the repository layer instead. See `features/`.
class SiteConfig {
  const SiteConfig._();

  static const String name = '$firstName $lastName';

  /// Split so the hero can set the name as two tight display lines, the way
  /// the reference does. [name] is derived from these rather than the other
  /// way round, so the two can never disagree.
  static const String firstName = 'Ken';
  static const String lastName = 'Starry';

  static const String shortName = 'KenStarry';

  /// Lowercase form used by the logo and footer. A `const` rather than
  /// `shortName.toLowerCase()` because both callers sit inside `const`
  /// component trees, where a method call is not allowed.
  static const String wordmark = 'kenstarry';

  /// Single-letter monogram for the logo tile.
  static const String monogram = 'K';
  static const String role = 'Flutter UI/UX Engineer';
  static const String location = 'Nairobi, Kenya';
  static const String domain = 'kenstarry.com';
  static const String siteUrl = 'https://kenstarry.com';
  static const String email = 'starrycodes@gmail.com';

  /// Fallback share image. 1200x630, lives at `web/images/og.png`.
  static const String defaultOgImage = '/images/og.png';

  // ── Hero ──────────────────────────────────────────────────────────────────

  /// Cutout portrait for the hero, as a path under `web/`.
  ///
  /// **To finish the hero:** drop a background-removed PNG (transparent,
  /// roughly 1200×1500, subject bottom-aligned) into `web/images/` and set this
  /// to e.g. `'images/ken.png'`. While it is `null` the hero renders the
  /// monogram on the same pale block, at the same proportions and baseline, so
  /// nothing shifts when the photo lands.
  static const String? portrait = null;

  static const String portraitAlt =
      '$name — $role, based in $location';

  static const bool available = true;
  static const String availabilityLabel = 'Available for select work';

  /// The introduction column's statement — the reference's "Product Designer
  /// and Developer, based in California." Short, factual, three lines.
  static const String heroStatement =
      'Flutter engineer and mobile product designer, based in Nairobi.';

  static const String tagline =
      'I design and ship polished mobile products end to end — design system, '
      'architecture, store listing.';

  /// The small paragraph under [heroStatement]. Deliberately short: the hero
  /// is a poster, not an essay.
  static const String heroLead =
      'I own the whole surface — design system, architecture, release. Apps '
      'people actually reopen.';

  // ── About ─────────────────────────────────────────────────────────────────

  static const List<String> bio = [
    "I care about the last 10% — the easing curve on a sheet, the empty state "
        "nobody scoped, the release build that just works.",
    "Today I own the full mobile lifecycle at a Kenyan telehealth platform: "
        "brand, design system, architecture, QA, and shipping to both stores. "
        "Alongside that I build bespoke Flutter products for businesses that "
        "have outgrown a website.",
  ];

  /// The line the numbers band is built around. Ken's own words, not a
  /// borrowed quote — a stock inspirational quote on a portfolio reads as
  /// filler.
  static const String pullQuote =
      'Everyone ships the first 90%. The last 10% is the whole product.';

  /// Short, punchy facts. Used large in the numbers band and compact as
  /// floating pills over the hero portrait.
  static const List<({String value, String label})> stats = [
    (value: '5+', label: 'years in Flutter'),
    (value: '2', label: 'app stores shipped to'),
    (value: '100%', label: 'of the mobile stack owned'),
  ];

  static const List<SocialLink> socials = [
    SocialLink(label: 'GitHub', handle: '@KenStarry', url: 'https://github.com/KenStarry'),
    SocialLink(label: 'LinkedIn', handle: 'Ken Starry', url: 'https://www.linkedin.com/in/kenstarry/'),
    SocialLink(label: 'X', handle: '@KenStarry', url: 'https://x.com/KenStarry'),
  ];

  /// Things you actually reach for, grouped for the About section.
  static const List<({String group, List<String> items})> toolkit = [
    (group: 'Core', items: ['Dart', 'Flutter', 'Jaspr', 'Kotlin']),
    (group: 'Architecture', items: ['Clean Architecture', 'Riverpod', 'BLoC', 'Isar / Drift']),
    (group: 'Craft', items: ['Design systems', 'Motion', 'Accessibility', 'Figma']),
    (group: 'Ship', items: ['CI/CD', 'Fastlane', 'Firebase', 'Play Console & App Store Connect']),
  ];

  /// Absolute URL for a site-relative [path]. Used for canonical + OG tags,
  /// which must be absolute to be honoured by crawlers and scrapers.
  static String absolute(String path) =>
      path == '/' ? siteUrl : '$siteUrl$path';
}
