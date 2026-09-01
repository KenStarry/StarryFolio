import 'person_link.dart';

/// Something someone said about the work.
///
/// ## Attribution is not optional
///
/// [name] and [role] are required, and [source] should be set wherever there
/// is somewhere to point. That is deliberate: an unattributed quote is not
/// social proof, it is copy — a visitor discounts "great to work with" from
/// nobody in particular, and they are right to. A testimonial's whole value is
/// that a named person put their reputation next to it.
///
/// Placeholder entries are allowed, but only behind [draft] — which makes the
/// band label itself on the page. A fabricated endorsement that *looks* real is
/// the thing to avoid; one that announces it is a sample is just a layout
/// fixture.
///
/// [projectSlug] links a quote to the case study it came out of, which is the
/// difference between a claim and a claim you can go and check.
///
/// [links] are the contributor's *own* profiles, carried as [PersonLink]
/// rather than `SocialLink` — see that class for why the distinction is not
/// cosmetic.
///
/// `fromMap` parses defensively so this can move behind a CMS without the
/// component learning anything new.
class TestimonialModel {
  const TestimonialModel({
    required this.slug,
    required this.quote,
    required this.name,
    required this.role,
    this.company = '',
    this.source,
    this.projectSlug,
    this.avatar,
    this.links = const [],
    this.featured = false,
    this.draft = false,
    this.emphasis = '',
  });

  final String slug;

  /// The quote itself, without surrounding quotation marks — the component
  /// sets those typographically.
  final String quote;

  final String name;

  /// Their job title. What makes the quote weigh something.
  final String role;

  final String company;

  /// Where the quote can be verified — a LinkedIn recommendation, a public
  /// review. Null renders the attribution unlinked rather than pointing
  /// nowhere.
  final String? source;

  /// The case study this came out of, if there is one.
  final String? projectSlug;

  /// Path under `web/` to their photo. Null falls back to a monogram, which
  /// is honest about being a placeholder in a way a stock face is not.
  final String? avatar;

  /// Where else this person can be found. Rendered as chips beside their
  /// name, and emitted in the `Review` JSON-LD, so a contributor gets real
  /// crawlable credit for saying something rather than a dead line of text.
  final List<PersonLink> links;

  /// Leads the band, set larger. At most one should carry this.
  final bool featured;

  /// The clause worth reading if you only read one.
  ///
  /// **It does two jobs, and the second constrains it.** Inside a full quote
  /// it is the run set bright against the rest. On the home band it stands
  /// entirely alone as the pull-quote — so it should be a span that survives
  /// being read on its own. A fragment opening on a lowercase pronoun is
  /// perfectly good emphasis and a poor standalone line.
  ///
  /// Must be a **verbatim substring** of [quote]. The featured slot sets it in
  /// `ink-100` against the rest of the quote in `ink-300` — the site's two-tone
  /// headline device applied to running text, at a narrower tonal gap than
  /// `TwoToneTitle` uses because a quote has to stay readable at length.
  ///
  /// Empty, or not found in [quote], and the whole quote renders bright. That
  /// is the safe default: a highlight that silently matched the wrong words
  /// would be worse than no highlight.
  final String emphasis;

  /// Splits [quote] around [emphasis] into the three runs the featured slot
  /// renders. The middle run is the emphasised one; either side may be empty.
  ///
  /// Returns a single bright run when there is nothing to emphasise, so the
  /// caller never has to special-case it.
  ({String before, String highlight, String after}) get runs {
    if (emphasis.isEmpty) return (before: '', highlight: quote, after: '');
    final at = quote.indexOf(emphasis);
    if (at < 0) return (before: '', highlight: quote, after: '');
    return (
      before: quote.substring(0, at),
      highlight: emphasis,
      after: quote.substring(at + emphasis.length),
    );
  }

  /// Marks the entry as placeholder content.
  ///
  /// The same mechanism `ExperienceModel` uses for unconfirmed dates, and here
  /// for the same reason: an authored stand-in that could be mistaken for a
  /// fact should say so on the page rather than rely on somebody remembering
  /// to take it out. While any entry carries this, `TestimonialBand` renders a
  /// visible *Sample content* marker — so if placeholders ever reach
  /// production they are labelled rather than passing as real endorsements.
  ///
  /// Clear the flag when the quote is real. The marker disappears on its own.
  final bool draft;

  /// Their initial, for the monogram fallback. Uses `substring` rather than
  /// `characters` so the model stays free of a package dependency.
  String get initial => name.isEmpty ? '·' : name.substring(0, 1).toUpperCase();

  /// `Role, Company` — or just the role when there is no company.
  String get attribution =>
      company.isEmpty ? role : '$role, $company';

  /// Rough length of the quote, for choosing a type scale and deciding whether
  /// a card needs a "read in full" affordance.
  ///
  /// Words rather than characters: character counts punish long words and a
  /// quote's *reading* length is what the layout actually has to survive.
  int get wordCount => quote.trim().split(RegExp(r'\s+')).length;

  /// Whether the home band should tease this rather than print it whole.
  ///
  /// The threshold is deliberately low. A home band is a doorway, and a
  /// hundred-word paragraph in one is a wall — see `TestimonialTeaser`.
  bool get isLong => wordCount > 45;

  /// The single clause worth reading, for the home teaser.
  ///
  /// Falls back to the whole quote when nothing is emphasised, which is
  /// correct for a short one and why [isLong] gates the teaser separately.
  String get lede => emphasis.isEmpty ? quote : emphasis;

  factory TestimonialModel.fromMap(Map<String, dynamic> map) =>
      TestimonialModel(
        slug: map['slug']?.toString() ?? '',
        quote: map['quote']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        role: map['role']?.toString() ?? '',
        company: map['company']?.toString() ?? '',
        source: map['source']?.toString(),
        projectSlug: map['projectSlug']?.toString(),
        avatar: map['avatar']?.toString(),
        links: PersonLink.listOf(map['links']),
        featured: map['featured'] == true,
        // Both of these used to be dropped here. `draft` in particular is a
        // safety marker: a round-trip through this parser silently promoted a
        // labelled placeholder into something that renders as a real
        // endorsement, which is the exact failure the flag exists to prevent.
        draft: map['draft'] == true,
        emphasis: map['emphasis']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'quote': quote,
        'name': name,
        'role': role,
        'company': company,
        if (source != null) 'source': source,
        if (projectSlug != null) 'projectSlug': projectSlug,
        if (avatar != null) 'avatar': avatar,
        if (links.isNotEmpty) 'links': [for (final l in links) l.url],
        'featured': featured,
        'draft': draft,
        if (emphasis.isNotEmpty) 'emphasis': emphasis,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestimonialModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
