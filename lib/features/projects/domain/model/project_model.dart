import '../../../../core/domain/enum/app_link_type.dart';
import '../../../../core/domain/model/app_link.dart';
import '../enum/project_category.dart';
import 'project_feature.dart';
import 'project_module.dart';
import '../enum/project_platform.dart';
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
    this.client,
    this.platforms = const [],
    required this.stack,
    required this.summary,
    this.highlights = const [],
    this.features = const [],
    this.modules = const [],
    this.links = const [],
    this.featured = false,
    this.coverImage,
    this.mockupImage,
  });

  /// URL segment: `/projects/<slug>`.
  final String slug;
  final String name;
  final String tagline;
  final String year;
  final ProjectStatus status;

  /// Grouping for the filter pills on the work section.
  final ProjectCategory category;

  /// Who the work was for — "Britam Insurance × Dentsu", "HealthX Africa".
  ///
  /// Null for personal projects, where there is no client and inventing one
  /// would be worse than the absence.
  final String? client;

  /// Where it runs. Rendered on the card, since a product that ships as both
  /// an app and a portal has two entries that are otherwise near-identical.
  final List<ProjectPlatform> platforms;

  final List<String> stack;

  /// Paragraphs shown on the detail page.
  final List<String> summary;

  /// Bullet points — what was actually built or learned.
  final List<String> highlights;

  /// Capability spotlights on the case study. Empty simply omits the section —
  /// not every project needs a walkthrough.
  final List<ProjectFeature> features;

  /// Distinct halves of the product, each with its own band. Takes precedence
  /// over [features] when present: a product with modules is described by them.
  final List<ProjectModule> modules;

  /// Where this project can actually be used — store listings, a web app, the
  /// source. Replaced three separate URL fields: a product routinely ships to
  /// more than one store, and a flat list keeps their order meaningful.
  final List<AppLink> links;

  /// Whether this project has enough written up to justify its own page.
  ///
  /// A case study with no walkthrough is a title, a tagline and a stack list —
  /// which is exactly what the card already showed, so the click is a
  /// disappointment. Projects without one render as unlinked cards and get no
  /// route generated at all, so there is no thin page for a crawler to find
  /// and no dead link pointing at one.
  bool get hasCaseStudy => features.isNotEmpty || modules.isNotEmpty;

  /// First repository link, for the `codeRepository` field in the JSON-LD.
  String? get repoUrl => links
      .where((l) => l.type == AppLinkType.repo)
      .map((l) => l.url)
      .firstOrNull;

  /// Path under `web/`, e.g. `images/criblynk.png`.
  final String? coverImage;

  /// Promotes this project to its own full-width showcase band rather than a
  /// card in a category grid. Requires [mockupImage] — the flat treatment is
  /// built around a transparent device render and has nothing to show without
  /// one.
  final bool featured;

  /// Transparent device mockup, for the flat featured treatment. Distinct from
  /// [coverImage]: a cover is cropped to fill a box, whereas a mockup has its
  /// own silhouette and must sit unframed on the section ground.
  final String? mockupImage;

  /// Share image for this project, falling back to the site default upstream.
  String? get ogImage => coverImage == null ? null : '/$coverImage';

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
        slug: map['slug']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        tagline: map['tagline']?.toString() ?? '',
        year: map['year']?.toString() ?? '',
        status: ProjectStatus.fromName(map['status']?.toString()),
        category: ProjectCategory.fromName(map['category']?.toString()),
        client: map['client']?.toString(),
        platforms: switch (map['platforms']) {
          final List<Object?> raw => [
              for (final entry in raw)
                ProjectPlatform.fromName(entry?.toString()),
            ],
          _ => const [],
        },
        stack: _stringList(map['stack']),
        summary: _stringList(map['summary']),
        highlights: _stringList(map['highlights']),
        features: switch (map['features']) {
          final List<Object?> raw => [
              for (final entry in raw)
                if (entry is Map<String, dynamic>) ProjectFeature.fromMap(entry),
            ],
          _ => const [],
        },
        modules: switch (map['modules']) {
          final List<Object?> raw => [
              for (final entry in raw)
                if (entry is Map<String, dynamic>) ProjectModule.fromMap(entry),
            ],
          _ => const [],
        },
        links: switch (map['links']) {
          final List<Object?> raw => [
              for (final entry in raw)
                if (entry is Map<String, dynamic>) AppLink.fromMap(entry),
            ],
          _ => const [],
        },
        coverImage: map['coverImage']?.toString(),
        mockupImage: map['mockupImage']?.toString(),
        featured: map['featured'] == true,
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'name': name,
        'tagline': tagline,
        'year': year,
        'status': status.name,
        'category': category.name,
        'client': client,
        'platforms': [for (final p in platforms) p.name],
        'stack': stack,
        'summary': summary,
        'highlights': highlights,
        'features': [for (final f in features) f.toMap()],
        'modules': [for (final m in modules) m.toMap()],
        'links': [for (final link in links) link.toMap()],
        'coverImage': coverImage,
        'mockupImage': mockupImage,
        'featured': featured,
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
