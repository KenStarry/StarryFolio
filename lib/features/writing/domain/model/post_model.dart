import '../../../../core/routing/route_paths.dart';
import 'post_block.dart';

/// A written piece.
///
/// A post is one of three things, and the difference is load-bearing:
///
/// | | `body` | `url` | Renders as |
/// |---|---|---|---|
/// | Published here | non-empty | — | a card linking to `/writing/<slug>` |
/// | Published elsewhere | empty | set | a card linking out, in a new tab |
/// | Planned | empty | null | an unlinked card marked *Soon* |
///
/// That last row is why [isPublished] exists. A portfolio that lists five
/// essays and 404s on four of them is worse than one that lists a single essay
/// and says the rest are coming — so a bodyless, urlless post renders plainly
/// and gets no route. The route table reads [PostModel.hasBody] through
/// `WritingLocalDatasource.slugs`, so an unfinished piece cannot generate a
/// page.
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
    this.body = const [],
    this.dek,
    this.coverImage,
    this.coverAlt = '',
    this.tags = const [],
    this.dateIso,
    this.sourceUrl,
    this.sourceLabel,
  });

  final String slug;
  final String title;
  final String excerpt;

  /// Display date, e.g. `Mar 2026`. A string rather than a `DateTime` because
  /// nothing sorts or compares these yet, and the display form is the content.
  final String date;

  /// Machine-readable date, `YYYY-MM-DD`. Feeds `datePublished` in the
  /// BlogPosting JSON-LD and the `<time datetime>` attribute — crawlers cannot
  /// parse `Mar 2026`, and guessing a day from it would be a lie with a
  /// timestamp on it. Null omits both rather than inventing one.
  final String? dateIso;

  final int readMinutes;
  final String topic;

  /// External destination, for a piece published somewhere else. Null means it
  /// lives here (or nowhere yet).
  final String? url;

  /// The article itself. Empty means there is nothing to render a page from.
  final List<PostBlock> body;

  /// The standfirst — one sentence under the title, longer than [excerpt] and
  /// written for someone who has already committed to opening the piece.
  final String? dek;

  /// Path under `web/` to the header image.
  final String? coverImage;
  final String coverAlt;

  /// Topic keywords, for the JSON-LD and the header chips. [topic] is the one
  /// that categorises; these describe.
  final List<String> tags;

  /// Where the piece first appeared, if it was published elsewhere first.
  /// Rendered as a credit line at the foot of the article.
  final String? sourceUrl;
  final String? sourceLabel;

  /// Whether this post has a readable page on this site.
  bool get hasBody => body.isNotEmpty;

  /// Whether the card should link anywhere at all.
  bool get isPublished => hasBody || url != null;

  /// Where the card points. Null for a planned piece.
  String? get href => hasBody ? RoutePaths.post(slug) : url;

  /// Whether following [href] leaves the site.
  bool get isExternal => !hasBody && url != null;

  factory PostModel.fromMap(Map<String, dynamic> map) => PostModel(
        slug: map['slug']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        excerpt: map['excerpt']?.toString() ?? '',
        date: map['date']?.toString() ?? '',
        dateIso: map['dateIso']?.toString(),
        readMinutes: int.tryParse(map['readMinutes']?.toString() ?? '') ?? 1,
        topic: map['topic']?.toString() ?? 'Notes',
        url: map['url']?.toString(),
        dek: map['dek']?.toString(),
        coverImage: map['coverImage']?.toString(),
        coverAlt: map['coverAlt']?.toString() ?? '',
        sourceUrl: map['sourceUrl']?.toString(),
        sourceLabel: map['sourceLabel']?.toString(),
        tags: switch (map['tags']) {
          final List<Object?> raw => [for (final t in raw) t.toString()],
          _ => const [],
        },
        body: switch (map['body']) {
          final List<Object?> raw => [
              for (final entry in raw)
                if (entry is Map<String, dynamic>)
                  if (PostBlock.fromMap(entry) case final block?) block,
            ],
          _ => const [],
        },
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'title': title,
        'excerpt': excerpt,
        'date': date,
        if (dateIso != null) 'dateIso': dateIso,
        'readMinutes': readMinutes,
        'topic': topic,
        'url': url,
        if (dek != null) 'dek': dek,
        if (coverImage != null) 'coverImage': coverImage,
        'coverAlt': coverAlt,
        'tags': tags,
        if (sourceUrl != null) 'sourceUrl': sourceUrl,
        if (sourceLabel != null) 'sourceLabel': sourceLabel,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PostModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
