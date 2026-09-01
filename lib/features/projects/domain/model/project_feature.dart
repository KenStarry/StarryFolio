/// One capability of a project, given its own spotlight on the case study.
///
/// This is what turns a case study from a wall of prose into a walkthrough: a
/// reader scanning the page should be able to learn what the product *does*
/// from the spotlights alone, without reading a paragraph.
///
/// `fromMap` parses defensively so that when this content moves behind a CMS a
/// malformed entry degrades rather than throwing.
class ProjectFeature {
  const ProjectFeature({
    required this.label,
    required this.title,
    required this.description,
    this.points = const [],
    this.image,
    this.imageWidth = 914,
    this.imageHeight = 1200,
  });

  /// Short eyebrow — the area of the product this belongs to.
  final String label;

  final String title;
  final String description;

  /// Specifics worth calling out. Kept short; the spotlight is a scan target,
  /// not documentation.
  final List<String> points;

  /// Path under `web/` to a device render. Null renders the spotlight as a
  /// text-only band rather than leaving an empty column.
  final String? image;

  /// Intrinsic pixels of [image], defaulting to the portrait phone render most
  /// spotlights use.
  ///
  /// These become the `width`/`height` attributes, which is how the browser
  /// reserves the right box before the file arrives. Leaving the phone default
  /// on a landscape laptop shot makes the page reserve a tall column and then
  /// reflow when the image loads, which is layout shift the site otherwise
  /// does not have.
  final int imageWidth;
  final int imageHeight;

  factory ProjectFeature.fromMap(Map<String, dynamic> map) => ProjectFeature(
        label: map['label']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        points: switch (map['points']) {
          final List<Object?> raw => [for (final p in raw) p.toString()],
          _ => const [],
        },
        image: map['image']?.toString(),
        imageWidth: int.tryParse(map['imageWidth']?.toString() ?? '') ?? 914,
        imageHeight: int.tryParse(map['imageHeight']?.toString() ?? '') ?? 1200,
      );

  Map<String, dynamic> toMap() => {
        'label': label,
        'title': title,
        'description': description,
        'points': points,
        if (image != null) 'image': image,
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
      };
}
