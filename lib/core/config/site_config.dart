import '../domain/model/social_link.dart';

/// Build-time identity for the whole site.
///
/// This is deliberately a `const` class rather than a repository: `main.server.dart`
/// reads it while composing the `<html>` document, which happens *outside* the
/// component tree where no provider or async repository can reach. Every page
/// title, canonical URL and Open Graph tag traces back here, so keeping it
/// synchronous is what makes the SEO metadata resolvable at build time.
///
/// Content that could plausibly move to a CMS later — the projects — goes
/// through the repository layer instead. See `features/projects/`.
class SiteConfig {
  const SiteConfig._();

  static const String name = 'Ken Starry';
  static const String shortName = 'KenStarry';
  static const String role = 'Flutter UI/UX Engineer';
  static const String location = 'Nairobi, Kenya';
  static const String domain = 'kenstarry.com';
  static const String siteUrl = 'https://kenstarry.com';
  static const String email = 'starrycodes@gmail.com';

  /// Fallback share image. 1200x630, lives at `web/images/og.png`.
  static const String defaultOgImage = '/images/og.png';

  static const String tagline =
      'I design and ship polished mobile products — end to end, from the '
      'design system to the store listing.';

  static const List<String> bio = [
    "I'm a Flutter engineer who cares about the last 10% — the easing curve on "
        "a sheet, the empty state nobody scoped, the release build that just "
        "works. I currently own the full mobile lifecycle at a Kenyan "
        "telehealth platform: brand, design system, architecture, QA and "
        "shipping on both stores.",
    "Outside of that I build bespoke Flutter products for businesses that have "
        "outgrown a website. If your customers come back weekly, an app usually "
        "pays for itself — and I like building the ones people actually reopen.",
  ];

  /// Short, punchy facts rendered as a strip under the hero.
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
