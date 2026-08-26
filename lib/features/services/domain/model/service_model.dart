/// One thing Ken is hired to do.
///
/// `fromMap` parses defensively so that when this content moves behind a CMS
/// the section degrades rather than throws on a missing or renamed field.
class ServiceModel {
  const ServiceModel({
    required this.slug,
    required this.title,
    required this.blurb,
    required this.icon,
    this.tags = const [],
    this.featured = false,
  });

  final String slug;
  final String title;
  final String blurb;

  /// Key into `AppIcons.byName` — `device`, `layers`, `rocket`, `star`.
  /// An unknown value falls back to a sparkle rather than breaking the card.
  final String icon;

  final List<String> tags;

  /// Renders as the solid-gold card in the row.
  ///
  /// Both design references make exactly one card in the row a filled accent
  /// block, and that asymmetry is what stops three equal cards reading as a
  /// pricing table. Marking a second service featured would undo it, so the
  /// section only honours the first.
  final bool featured;

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
        slug: map['slug']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        blurb: map['blurb']?.toString() ?? '',
        icon: map['icon']?.toString() ?? 'sparkle',
        tags: _stringList(map['tags']),
        featured: map['featured'] == true,
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'title': title,
        'blurb': blurb,
        'icon': icon,
        'tags': tags,
        'featured': featured,
      };

  static List<String> _stringList(Object? value) => value is List
      ? value.map((e) => e.toString()).toList(growable: false)
      : const [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ServiceModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
