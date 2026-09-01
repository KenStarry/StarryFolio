import '../../../../core/domain/enum/app_link_type.dart';
import '../../../../core/domain/model/app_link.dart';
import '../enum/project_category.dart';
import '../enum/project_kind.dart';
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
    this.kind = ProjectKind.product,
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
    this.mockupWidth = 914,
    this.mockupHeight = 1200,
    this.applicationCategory,
    this.ogCard,
  });

  /// URL segment: `/projects/<slug>`.
  final String slug;
  final String name;
  final String tagline;
  final String year;
  final ProjectStatus status;

  /// Grouping for the filter pills on the work section.
  final ProjectCategory category;

  /// What sort of thing this is — an application or a package. Defaults to
  /// [ProjectKind.product], which is what every entry was before the axis
  /// existed, so adding it recategorised nothing.
  final ProjectKind kind;

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

  /// The store listings, if any.
  ///
  /// A project with one of these is a thing a person can install, which is a
  /// different kind of search result from a page describing one — see
  /// [SchemaOrg.mobileApplication].
  List<AppLink> get storeLinks =>
      links.where((l) => l.isStore).toList(growable: false);

  bool get isInstallableApp => storeLinks.isNotEmpty;

  /// schema.org `applicationCategory`, for a project that ships to a store.
  ///
  /// Always a value from schema.org's own enumeration — `MultimediaApplication`,
  /// `HealthApplication`, `BusinessApplication` — never a phrase invented here.
  /// It is what turns a case study from *a page about an app* into *an app*,
  /// which is the difference between being reachable from "Flutter portfolio"
  /// and being reachable from "offline music player".
  ///
  /// Null for anything with no store listing: a category on something nobody
  /// can install is a claim with nothing behind it.
  final String? applicationCategory;

  /// The `<title>` for this project's case study.
  ///
  /// `name · tagline`, not `name · Ken Starry`. The title is the strongest
  /// on-page signal there is, and half of it was going to the site name — a
  /// query nobody types, already declared to scrapers through `og:site_name`,
  /// and appended to results by Google on its own. The tagline is where the
  /// searchable words actually live: "Flow Music Player · Offline music,
  /// endlessly tunable and genuinely pretty" can be found by someone looking
  /// for offline music, where "Flow Music Player, Ken Starry" can only be
  /// found by someone who already knows both names.
  ///
  /// The trailing full stop goes: taglines are written as sentences, and a
  /// full stop mid-title reads as a truncation.
  String get seoTitle {
    final phrase =
        tagline.endsWith('.') ? tagline.substring(0, tagline.length - 1) : tagline;
    return '$name · $phrase';
  }

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

  /// Intrinsic pixels of [mockupImage], defaulting to the portrait phone
  /// render most projects use.
  ///
  /// Two things read this. The `width`/`height` attributes come from it, so
  /// the browser reserves the right box before the file lands. And
  /// [isWideMockup] switches `ProjectCover` between two treatments, because a
  /// laptop and a phone cannot share one: the phone treatment overscales past
  /// the frame and anchors to the bottom, which on a landscape render clips
  /// the top of the screen clean off.
  final int mockupWidth;
  final int mockupHeight;

  /// Whether the mockup is wider than it is tall, i.e. a desktop or tablet
  /// render rather than a phone.
  bool get isWideMockup => mockupWidth > mockupHeight;

  /// Purpose-built 1200x630 share card, as a path under `web/`.
  ///
  /// **JPEG, never WebP.** Several scrapers, LinkedIn's among them, will not
  /// render a WebP `og:image` at all, so a `.webp` share card is indistinct
  /// from having none. That is exactly what was happening to `flutter_extend`,
  /// the one project that had its own image.
  ///
  /// Generated by `tools/make-og-cards.py`, in the site's own visual language,
  /// so a link shared to LinkedIn, X, Slack or WhatsApp arrives looking like
  /// the site it points at. Without one, every case study fell back to the
  /// single default `og.jpg` and four different links shared one picture.
  final String? ogCard;

  /// Share image for this project, falling back to the site default upstream.
  ///
  /// [ogCard] wins over [coverImage]: a cover is authored to be cropped into a
  /// card on the site, where a share card is composed for a 1.91:1 frame with
  /// its own type in it, and the two are not interchangeable.
  String? get ogImage {
    if (ogCard != null) return '/$ogCard';
    return coverImage == null ? null : '/$coverImage';
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
        slug: map['slug']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        tagline: map['tagline']?.toString() ?? '',
        year: map['year']?.toString() ?? '',
        status: ProjectStatus.fromName(map['status']?.toString()),
        category: ProjectCategory.fromName(map['category']?.toString()),
        kind: ProjectKind.fromName(map['kind']?.toString()),
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
        mockupWidth: int.tryParse(map['mockupWidth']?.toString() ?? '') ?? 914,
        mockupHeight: int.tryParse(map['mockupHeight']?.toString() ?? '') ?? 1200,
        featured: map['featured'] == true,
        applicationCategory: map['applicationCategory']?.toString(),
        ogCard: map['ogCard']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'name': name,
        'tagline': tagline,
        'year': year,
        'status': status.name,
        'category': category.name,
        'client': client,
        'kind': kind.name,
        'platforms': [for (final p in platforms) p.name],
        'stack': stack,
        'summary': summary,
        'highlights': highlights,
        'features': [for (final f in features) f.toMap()],
        'modules': [for (final m in modules) m.toMap()],
        'links': [for (final link in links) link.toMap()],
        'applicationCategory': applicationCategory,
        'ogCard': ogCard,
        'coverImage': coverImage,
        'mockupImage': mockupImage,
        'mockupWidth': mockupWidth,
        'mockupHeight': mockupHeight,
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
