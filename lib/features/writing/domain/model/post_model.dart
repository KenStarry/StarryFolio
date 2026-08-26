/// A written piece.
///
/// `fromMap` parses defensively so that when this content moves behind a CMS
/// the section degrades rather than throws on a missing or renamed field.
class PostModel {
  const PostModel({
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.date,
    required this.readMinutes,
    this.topic = 'Notes',
    this.url,
  });

  final String slug;
  final String title;
  final String excerpt;

  /// Display date, e.g. `Mar 2026`. A string rather than a `DateTime` because
  /// nothing sorts or compares these yet, and the display form is the content.
  final String date;

  final int readMinutes;
  final String topic;

  /// External destination. Null means the piece is not published yet, and the
  /// card renders unlinked rather than pointing at a dead route.
  final String? url;

  bool get isPublished => url != null;

  factory PostModel.fromMap(Map<String, dynamic> map) => PostModel(
        slug: map['slug']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        excerpt: map['excerpt']?.toString() ?? '',
        date: map['date']?.toString() ?? '',
        readMinutes: int.tryParse(map['readMinutes']?.toString() ?? '') ?? 1,
        topic: map['topic']?.toString() ?? 'Notes',
        url: map['url']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'title': title,
        'excerpt': excerpt,
        'date': date,
        'readMinutes': readMinutes,
        'topic': topic,
        'url': url,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PostModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
