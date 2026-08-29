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

  /// Leads the band, set larger. At most one should carry this.
  final bool featured;

  /// The clause worth reading if you only read one.
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
        featured: map['featured'] == true,
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
        'featured': featured,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestimonialModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
