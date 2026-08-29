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
  static const String role = 'Senior Flutter Engineer & UI/UX';
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
      '$name, $role. Apps people actually reopen.';

  /// Handle on X, with the `@`. Sets `twitter:site` and `twitter:creator`,
  /// which is what attaches a shared card to an account instead of letting it
  /// sit anonymous in a timeline: the card gets a byline and the account gets
  /// the click.
  static const String xHandle = '@ken_starry';

  /// The other spellings people actually type into a search box.
  ///
  /// Fed to `Person.alternateName`, which is how a crawler learns that the
  /// one-word handle and the two-word name are the same entity rather than two
  /// people who happen to look alike. Only forms that are genuinely in use
  /// belong here: inventing a variant to catch a query puts a false claim in
  /// machine-readable data, which is the category of error that gets a site's
  /// structured data distrusted wholesale.
  static const List<String> nameVariants = ['KenStarry', 'kenstarry', 'Ken'];

  /// `og:locale`.
  ///
  /// `en_GB` rather than `en_KE`: the copy is in British spelling, and `en_KE`
  /// is not on the list of locales scrapers recognise, so it would be dropped
  /// rather than honoured. The country is carried by the `PostalAddress` in
  /// the Person JSON-LD, which is where a crawler actually looks for it.
  static const String ogLocale = 'en_GB';

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
      "$name's avatar: a ginger cat in a hoodie, hunched over a laptop";

  /// Named in the About section's "Currently" panel. Kept here so the panel
  /// never has to hard-code a project name that could go stale.
  static const String currentSideProject = 'RezQ';

  /// Whether the home page carries the testimonials band.
  ///
  /// A blanket off-switch, separate from whether there is anything to show.
  /// `TestimonialBand` already renders nothing when the list is empty, so this
  /// is not about the empty case — it is for the case where the quotes exist
  /// but should not be up yet: placeholders still in place, permission not
  /// confirmed, a name being changed.
  ///
  /// While it is `false` the repository is not even read and the band never
  /// reaches the page, which is a stronger guarantee than the `draft` marker
  /// on its own. Leave it off until the quotes are real and cleared to
  /// publish.
  static const bool showTestimonials = true;

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

  /// The downloadable CV, served straight from `web/`.
  ///
  /// The `/cv` page is generated from the same facts (see
  /// `AboutLocalDatasource`), so the two cannot drift — but the file is the
  /// artefact people actually attach to an application, and it has to exist as
  /// a file for that.
  static const String cvFile = '/cv.pdf';

  static const bool available = true;
  static const String availabilityLabel =
      'Free for new work, and unreasonably keen';

  /// The introduction column's statement: the first line anyone actually
  /// reads.
  ///
  /// **One short sentence, and never more.** It sits directly under a name set
  /// at display scale, and a paragraph there asks a visitor to start reading
  /// before they have decided to.
  ///
  /// It carries no job title and no location on purpose. The portrait card
  /// beside it already prints [role] and [location], so stating them here
  /// spends the most-read line on a repeat. That leaves it free to be the one
  /// line with a joke in it.
  static const String heroStatement =
      'I build whole apps, then argue with myself about the spacing.';

  static const String tagline =
      'I design and ship mobile products end to end, from the first design '
      'token to the store listing. Then I fuss over the parts nobody was '
      'supposed to notice.';

  /// The small paragraph under [heroStatement]. Deliberately short: the hero
  /// is a poster, not an essay.
  static const String heroLead =
      'Design system, architecture, release. All of it, aimed at one thing: '
      'an app people open again tomorrow.';

  // ── About ─────────────────────────────────────────────────────────────────

  static const List<String> bio = [
    "The last 10% is where I live: the easing curve on a sheet, the empty "
        "state nobody scoped, the release build that works first try. Yes, I "
        "have been told this is a lot. I remain unbothered.",
    "Right now that means owning the whole mobile lifecycle at a Kenyan "
        "telehealth platform: brand, design system, architecture, QA, and the "
        "shipping to both stores. Alongside it I build Flutter products for "
        "businesses that have outgrown a website and know it.",
  ];

  /// The line the numbers band is built around. Ken's own words, not a
  /// borrowed quote — a stock inspirational quote on a portfolio reads as
  /// filler.
  static const String pullQuote =
      'Everyone ships the first 90%. The last 10% is the whole product.';

  /// Short, punchy facts. Used large in the numbers band and compact as
  /// floating pills over the hero portrait.
  static const List<({String value, String label})> stats = [
    (value: '5+', label: 'years deep in Flutter'),
    (value: '2', label: 'app stores survived'),
    (value: '100%', label: 'of the stack, mine'),
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
      '?text=${Uri.encodeComponent('Hi Ken, I found you via kenstarry.com.')}';
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
