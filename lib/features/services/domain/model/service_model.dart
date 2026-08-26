/// One thing Ken is hired to do.
///
/// Carries copy for two very different surfaces: the short [blurb] for the home
/// overview card, and [detail] plus [deliverables] for the service's own band on
/// `/services`. Keeping both here means the two can never drift into describing
/// the same offering differently.
///
/// `fromMap` parses defensively so that when this content moves behind a CMS the
/// section degrades rather than throws on a missing or renamed field.
class ServiceModel {
  const ServiceModel({
    required this.slug,
    required this.title,
    required this.blurb,
    required this.icon,
    this.detail = '',
    this.deliverables = const [],
    this.ctaQuestion = 'Got a project?',
    this.tags = const [],
    this.featured = false,
  });

  final String slug;

  /// Display title. May contain a newline where the copy owns its own line
  /// break, so display type sets as a deliberate block rather than wrapping
  /// wherever the container ends.
  final String title;

  /// One or two lines, for the home overview card.
  final String blurb;

  /// Key into `AppIcons.byName`. An unknown value falls back rather than
  /// breaking the card.
  final String icon;

  /// Longer paragraph for the service's band on `/services`.
  final String detail;

  /// What the client actually receives. Rendered as ruled rows beside the copy.
  final List<String> deliverables;

  /// The band's own call to action — "Need an app?", "Need a design system?".
  ///
  /// Asking a question in the client's own words converts better than a
  /// generic "Get in touch", and it lets each band close itself rather than
  /// deferring every enquiry to one contact section at the bottom of the page.
  final String ctaQuestion;

  final List<String> tags;

  /// Renders as the inverted card in the home overview row.
  ///
  /// Both design references make exactly one card in a row a filled block, and
  /// that asymmetry is what stops equal cards reading as a pricing table. The
  /// section only honours the first.
  final bool featured;

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
        slug: map['slug']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        blurb: map['blurb']?.toString() ?? '',
        icon: map['icon']?.toString() ?? 'layers',
        detail: map['detail']?.toString() ?? '',
        deliverables: _stringList(map['deliverables']),
        ctaQuestion: map['ctaQuestion']?.toString() ?? 'Got a project?',
        tags: _stringList(map['tags']),
        featured: map['featured'] == true,
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'title': title,
        'blurb': blurb,
        'icon': icon,
        'detail': detail,
        'deliverables': deliverables,
        'ctaQuestion': ctaQuestion,
        'tags': tags,
        'featured': featured,
      };

  /// Title with its authored line breaks flattened — for `aria-label`s, page
  /// metadata and anywhere a single-line string is needed.
  String get plainTitle => title.replaceAll('\n', ' ');

  static List<String> _stringList(Object? value) => value is List
      ? value.map((e) => e.toString()).toList(growable: false)
      : const [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ServiceModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
