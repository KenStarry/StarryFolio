import '../domain/model/company.dart';
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

  /// The logo mark — a crop of the hero avatar, which is the trademark.
  /// Replaces the letter monogram that stood in before the artwork existed.
  static const String logoMark = 'images/logo-mark.webp';
  static const String role = 'Flutter UI/UX Engineer';
  static const String location = 'Nairobi, Kenya';
  static const String domain = 'kenstarry.com';
  static const String siteUrl = 'https://kenstarry.com';
  static const String email = 'starrycodes@gmail.com';

  /// Fallback share image, 1200×630 at `web/images/og.jpg`.
  ///
  /// JPEG rather than PNG: the card contains a photographic avatar, which PNG
  /// stores badly — the same image is 92 KB here against 347 KB as a PNG, with
  /// no visible difference at the size a feed renders it.
  ///
  /// Regenerate with `tools/og-card.html` — see the note at the top of that
  /// file.
  static const String defaultOgImage = '/images/og.jpg';

  /// Declared alongside the image so a scraper can lay out the preview before
  /// it has finished downloading it.
  static const String ogImageWidth = '1200';
  static const String ogImageHeight = '630';

  static const String ogImageAlt =
      '$name — $role. Apps people actually reopen.';

  // ── Hero ──────────────────────────────────────────────────────────────────

  /// Avatar for the hero card, as a path under `web/`.
  ///
  /// **Authored square.** The subject fills the full frame and sits flush to
  /// the bottom edge, so the card is `aspect-square` and the image is
  /// `object-contain` — cropping it to a portrait ratio would cut the laptop
  /// and the glass straight off, which is the whole joke.
  static const String portrait = 'images/ken-avatar.webp';

  /// Describes what is actually in the frame rather than claiming to be a
  /// photograph of a person — the avatar is an illustration.
  static const String portraitAlt =
      "$name's avatar — a ginger cat in a hoodie working at a laptop";

  /// Named in the About section's "Currently" panel. Kept here so the panel
  /// never has to hard-code a project name that could go stale.
  static const String currentSideProject = 'CribLynk';

  /// Whether the site paints its own pointer (`CustomCursor`).
  ///
  /// A deliberate switch rather than a decision baked into the layout: a
  /// custom cursor overrides a pointer some visitors have sized or
  /// contrast-adjusted on purpose, and on a portfolio it can read as flourish
  /// rather than craft. Set it to `false` and the two elements and their
  /// script stop being emitted entirely — nothing else changes.
  ///
  /// It already declines to run on touch devices and under
  /// `prefers-reduced-motion`; this is the blanket off.
  static const bool customCursor = true;

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

  /// Places the work has been done. Rendered as the marquee in the enterprise
  /// band. **Logos to come** — drop monochrome or white SVGs into `web/images/`
  /// and set `logo:` on each entry; the marquee falls back to a wordmark until
  /// then and its layout does not change when they land.
  static const List<Company> companies = [
    Company(name: 'Britam', role: 'Insurance · mobile'),
    Company(name: 'Dentsu', role: 'Digital product'),
    Company(name: 'HealthX', role: 'Telehealth · full mobile lifecycle'),
    Company(name: 'Podii', role: 'Product engineering'),
  ];

  /// WhatsApp number in international format, digits only — no `+`, spaces or
  /// dashes, because `wa.me` rejects them.
  ///
  /// Empty until provided; the channel tile is omitted rather than rendering a
  /// link to `wa.me/` that opens WhatsApp on nothing.
  ///
  /// `254…` not `+254…` — wa.me takes the country code but rejects the plus.
  static const String whatsappNumber = '254717446607';

  /// Buy Me a Coffee username, the part after `buymeacoffee.com/`. Empty hides
  /// the support section entirely.
  static const String buyMeACoffee = 'kenstarry';

  /// Pre-fills the opening message, so the visitor is not dropped into an
  /// empty thread wondering how to start — and so the enquiry arrives already
  /// labelled with where it came from.
  static String get whatsappUrl =>
      'https://wa.me/$whatsappNumber'
      '?text=${Uri.encodeComponent('Hi Ken — I found you via kenstarry.com.')}';
  static String get buyMeACoffeeUrl => 'https://buymeacoffee.com/$buyMeACoffee';

  static const List<SocialLink> socials = [
    SocialLink(label: 'GitHub', handle: '@KenStarry', url: 'https://github.com/KenStarry'),
    SocialLink(
      label: 'LinkedIn',
      handle: 'Ken Starry',
      url: 'https://www.linkedin.com/in/ken-s-133a04217/',
    ),
    SocialLink(label: 'X', handle: '@ken_starry', url: 'https://x.com/ken_starry'),
  ];

  // The toolkit used to live here as a flat list of names. It now lives in
  // `features/about/data/datasource/about_local_datasource.dart`, where each
  // entry also carries how deeply it is held — and it is the same list the
  // Person JSON-LD's `knowsAbout` is built from, so the machine-readable
  // claim and the visible matrix cannot drift apart.

  /// Absolute URL for a site-relative [path]. Used for canonical + OG tags,
  /// which must be absolute to be honoured by crawlers and scrapers.
  static String absolute(String path) =>
      path == '/' ? siteUrl : '$siteUrl$path';
}
