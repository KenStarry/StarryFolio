import '../model/project_model.dart';
import 'project_kind.dart';
import 'project_platform.dart';

/// A curated way into the work — the sub-pages under Works.
///
/// ## This is a *view*, not a fourth property
///
/// Nothing on [ProjectModel] says which collection it belongs to, and nothing
/// should: a collection is a **predicate over the axes that already exist**.
/// `mobile` is "a product that runs on a phone"; `web` is "a product that runs
/// in a browser". Storing that twice would let the stored value disagree with
/// the platforms right beside it, and the first time they disagreed nobody
/// would know which one was lying.
///
/// The one exception is [design], which cannot be derived — whether design was
/// a substantial part of a build is genuinely new information, so it is opted
/// into by a project carrying a `design` block. That is the same test the rest
/// of the site uses: a project has a case study *because* it has `features` or
/// `modules`, not because a flag says so.
///
/// ## Collections overlap, deliberately
///
/// HealthX is in `mobile` and in `design`. That is not a modelling failure, it
/// is the truth about the work — but it is only *honest* if the two pages say
/// different things, which is why `design` reads from a different block of copy
/// rather than reprinting the engineering case study under a new heading.
enum ProjectCollection {
  mobile(
    slug: 'mobile',
    label: 'Mobile apps',
    ghost: 'Mobile',
    title: 'Apps that live',
    titleTail: 'in a pocket.',
    lead: 'iOS and Android from one Flutter codebase. Built to hold up on a '
        'mid-range phone with two bars of signal, because that is the phone '
        'most people actually have.',
    blurb: 'Flutter apps shipped to both stores',
    collective: 'mobile apps',
  ),

  web(
    slug: 'web',
    label: 'Web',
    ghost: 'Web',
    title: 'Portals, sites,',
    titleTail: 'and this one.',
    lead: 'The other half of a product: the portal the staff use, the site the '
        'customers find. Rendered so a crawler sees the same page a person '
        'does.',
    blurb: 'Portals and sites that load fast and rank',
    collective: 'web projects',
  ),

  design(
    slug: 'design',
    label: 'Design',
    ghost: 'Design',
    title: 'The system before',
    titleTail: 'the first screen.',
    lead: 'Tokens, type, motion and every state a component can be in, decided '
        'once and built against. The same products as elsewhere on this site, '
        'seen from the side that decides how they feel.',
    blurb: 'Design systems, motion and interface craft',
    collective: 'design cases',
  ),

  packages(
    slug: 'packages',
    label: 'Packages',
    ghost: 'Open',
    title: 'Code other people',
    titleTail: 'build on.',
    lead: 'No screens, no store listing, no users. Developers depend on it '
        'instead, which is a different discipline from shipping an app and a '
        'harder one to fake.',
    blurb: 'Published, versioned and maintained in the open',
    collective: 'packages',
  );

  const ProjectCollection({
    required this.slug,
    required this.label,
    required this.ghost,
    required this.title,
    required this.titleTail,
    required this.lead,
    required this.blurb,
    required this.collective,
  });

  /// URL segment, and the anchor its tile links to.
  final String slug;

  /// Short form — the nav item, the tile heading, the badge.
  final String label;

  /// The watermark behind the page header. Kept separate from [label] because
  /// `Mobile apps` is too long to set at page scale without clipping.
  final String ghost;

  /// Page `<h1>`, bright half.
  final String title;

  /// Page `<h1>`, muted half.
  final String titleTail;

  /// Page standfirst.
  final String lead;

  /// One line for the collection's tile on `/projects`.
  final String blurb;

  /// The plural noun for counting: `All 7 mobile apps`.
  ///
  /// [label] cannot do this job. It is a nav item, so it reads as a heading —
  /// `Web`, `Design` — and "All 3 web" is not a sentence. Two fields because
  /// they are two different registers, not because one is a formatting of the
  /// other.
  final String collective;

  /// Whether [project] belongs in this collection.
  ///
  /// Packages are excluded from `mobile` and `web` even though
  /// `flutter_extend` declares every platform: it does not *run* anywhere a
  /// person can see, and listing a library among the apps is how a grid of
  /// screenshots acquires an entry with no screenshot.
  bool contains(ProjectModel project) => switch (this) {
        ProjectCollection.mobile => project.kind == ProjectKind.product &&
            (project.platforms.contains(ProjectPlatform.android) ||
                project.platforms.contains(ProjectPlatform.ios)),
        ProjectCollection.web => project.kind == ProjectKind.product &&
            project.platforms.contains(ProjectPlatform.web),
        ProjectCollection.design => project.design != null,
        ProjectCollection.packages => project.kind == ProjectKind.package,
      };

  /// Everything in this collection, in datasource order.
  List<ProjectModel> from(List<ProjectModel> projects) =>
      [for (final p in projects) if (contains(p)) p];

  /// Every collection slug. Used by the route table to prove no project slug
  /// can shadow a collection page — see `ProjectsLocalDatasource.slugs`.
  static const Set<String> reservedSlugs = {'mobile', 'web', 'design', 'packages'};

  /// Resolves a wire value defensively.
  static ProjectCollection? fromSlug(String? value) {
    for (final c in values) {
      if (c.slug == value || c.name == value) return c;
    }
    return null;
  }
}
