import '../enum/project_category.dart';
import '../enum/project_status.dart';

/// A case study.
///
/// `fromMap` parses defensively so that when this data moves behind an API the
/// page degrades rather than throws on a missing or renamed field.
class ProjectModel {
  const ProjectModel({
    required this.slug,
    required this.name,
    required this.tagline,
    required this.year,
    required this.status,
    required this.category,
    required this.stack,
    required this.summary,
    this.highlights = const [],
    this.repoUrl,
    this.liveUrl,
    this.storeUrl,
    this.coverImage,
  });

  /// URL segment: `/projects/<slug>`.
  final String slug;
  final String name;
  final String tagline;
  final String year;
  final ProjectStatus status;

  /// Grouping for the filter pills on the work section.
  final ProjectCategory category;

  final List<String> stack;

  /// Paragraphs shown on the detail page.
  final List<String> summary;

  /// Bullet points — what was actually built or learned.
  final List<String> highlights;

  final String? repoUrl;
  final String? liveUrl;
  final String? storeUrl;

  /// Path under `web/`, e.g. `images/criblynk.png`.
  final String? coverImage;

  /// Share image for this project, falling back to the site default upstream.
  String? get ogImage => coverImage == null ? null : '/$coverImage';

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
        slug: map['slug']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        tagline: map['tagline']?.toString() ?? '',
        year: map['year']?.toString() ?? '',
        status: ProjectStatus.fromName(map['status']?.toString()),
        category: ProjectCategory.fromName(map['category']?.toString()),
        stack: _stringList(map['stack']),
        summary: _stringList(map['summary']),
        highlights: _stringList(map['highlights']),
        repoUrl: map['repoUrl']?.toString(),
        liveUrl: map['liveUrl']?.toString(),
        storeUrl: map['storeUrl']?.toString(),
        coverImage: map['coverImage']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'name': name,
        'tagline': tagline,
        'year': year,
        'status': status.name,
        'category': category.name,
        'stack': stack,
        'summary': summary,
        'highlights': highlights,
        'repoUrl': repoUrl,
        'liveUrl': liveUrl,
        'storeUrl': storeUrl,
        'coverImage': coverImage,
      };

  static List<String> _stringList(Object? value) => value is List
      ? value.map((e) => e.toString()).toList(growable: false)
      : const [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ProjectModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
