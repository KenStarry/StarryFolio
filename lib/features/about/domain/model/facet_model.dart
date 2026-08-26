/// One side of the person away from the editor, for the closing band.
///
/// This band is the reason the page is called *about* rather than *CV*. Kept
/// as its own model — rather than reusing a service or a skill — because these
/// entries must never grow deliverables, levels or links. The moment one does,
/// it has stopped being personal and started being a pitch.
class FacetModel {
  const FacetModel({
    required this.title,
    required this.blurb,
    this.icon = 'compass',
    this.marker = '',
  });

  final String title;
  final String blurb;

  /// Key into `AppIcons.byName`.
  final String icon;

  /// A small mono aside — a place, a count, a year.
  final String marker;

  factory FacetModel.fromMap(Map<String, dynamic> map) => FacetModel(
        title: map['title']?.toString() ?? '',
        blurb: map['blurb']?.toString() ?? '',
        icon: map['icon']?.toString() ?? 'compass',
        marker: map['marker']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'blurb': blurb,
        'icon': icon,
        'marker': marker,
      };
}
