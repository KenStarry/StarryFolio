import '../../../../core/domain/enum/app_link_type.dart';
import '../../../../core/domain/model/app_link.dart';
import '../../domain/enum/project_category.dart';
import '../../domain/enum/project_platform.dart';
import '../../domain/enum/project_status.dart';
import '../../domain/model/project_model.dart';

/// The case studies, as compile-time constants.
///
/// Every entry here is real work. `healthx`, `rezq` and `flow` are the
/// featured builds and appear as full-width showcases in that order.
///
/// Categories drive which band a project lands in on `/projects`; a project
/// marked `featured` is lifted out of its band into its own showcase and needs
/// a `mockupImage` to have anything to show.
///
/// **Add a project here** and it appears on the home page, the projects index,
/// and gets its own statically generated `/projects/<slug>` page.
///
/// This is deliberately `const` and synchronous. Static generation has to
/// enumerate every project route *before* any async work can run, so
/// `app.dart` reads [slugs] directly to build the route table. The repository
/// layer on top provides the async `Either` API the pages consume — when this
/// content moves to a CMS, only this class and the route enumeration change.
abstract final class ProjectsLocalDatasource {
  static const List<ProjectModel> projects = [
    ProjectModel(
      slug: 'healthx',
      name: 'HealthX',
      tagline: 'Care, a pharmacy and a doctor — in one app.',
      year: '2026',
      status: ProjectStatus.shipped,
      category: ProjectCategory.enterprise,
      client: 'HealthX Africa',
      platforms: [ProjectPlatform.android, ProjectPlatform.ios],
      mockupImage: 'images/healthx-mockup.webp',
      featured: true,
      stack: [
        'Flutter',
        'Riverpod 3',
        'GoRouter',
        'Dio',
        'Clean Architecture',
      ],
      summary: [
        'HealthX Africa puts consultations, appointments, prescriptions and '
            'pharmacy delivery behind one login — video calls with a doctor, a '
            'prescription photographed and filled, and the order tracked to the '
            'door.',
        'I own the full mobile lifecycle here: the design system and brand '
            'through architecture, QA and shipping to both stores. The hard '
            'part is that health data is unforgiving — every screen has to '
            'degrade honestly when the network does not cooperate.',
      ],
      highlights: [
        'Clean Architecture across seven feature modules, sharing one shell',
        'Riverpod 3 with codegen throughout — no hand-rolled providers',
        'Semantic theming via a HealthXColors ThemeExtension, not scattered hex',
        'Stateful shell navigation that keeps each tab’s stack alive',
        'On-device PDF receipt generation for orders and consultations',
      ],
      links: [
        AppLink(
          type: AppLinkType.playStore,
          url: 'https://play.google.com/store/apps/details?id=com.healthx.app&hl=en',
        ),
        AppLink(
          type: AppLinkType.appStore,
          url: 'https://apps.apple.com/ke/app/healthx-africa/id1570107533',
        ),
        AppLink(
          type: AppLinkType.web,
          url: 'https://portal.healthxafrica.com',
          label: 'Customer Portal',
        ),
      ],
    ),
    ProjectModel(
      slug: 'criblynk',
      name: 'CribLynk',
      tagline: 'Rentals, minus the WhatsApp chaos.',
      year: '2026',
      status: ProjectStatus.building,
      category: ProjectCategory.personal,
      platforms: [ProjectPlatform.android],
      stack: ['Flutter', 'Riverpod', 'Firebase', 'Google Maps'],
      summary: [
        'A marketplace that connects tenants with verified landlords — listings, '
            'viewings and payment tracking in one place instead of scattered across '
            'chat threads.',
        'The hard part was trust, not CRUD: verification flows, dispute-friendly '
            'audit trails, and making a listing feel worth believing.',
      ],
      highlights: [
        'Offline-first listing cache so browsing survives a bad connection',
        'Map + list view sharing a single source of truth',
        'Design system built before the first screen, not after the tenth',
      ],
      links: [
        AppLink(type: AppLinkType.repo, url: 'https://github.com/KenStarry/CribLynk'),
      ],
    ),
    ProjectModel(
      slug: 'rezq',
      name: 'RezQ',
      tagline: 'Resume building, the right way round.',
      year: '2026',
      status: ProjectStatus.shipped,
      category: ProjectCategory.personal,
      platforms: [ProjectPlatform.android],
      mockupImage: 'images/rezq-mockup.webp',
      featured: true,
      stack: [
        'Flutter',
        'Riverpod 3',
        'GoRouter',
        'Hive',
        'pdf / printing',
      ],
      summary: [
        'Most resume tools have you edit one document per application. RezQ '
            'inverts that: you build a master profile once in the Workshop, cut '
            'role-specific snapshots from it, and generate a polished PDF from '
            'any role using interchangeable templates.',
        'The interesting half is the PDF engine. Each section dispatches its own '
            'rendering per template, so adding a template is a new builder '
            'rather than a rewrite of every section.',
      ],
      highlights: [
        'Master profile → role snapshot → PDF, instead of a document per job',
        'Three interchangeable templates, each with its own typographic ramp '
            'and PdfColor palette',
        'Strategy-dispatch section enum, so a new template does not touch '
            'existing section code',
        'A borderless design system — depth carried by a three-level shadow '
            'ramp and surface contrast, never by lines',
        'Local-first on Hive, with PDF thumbnails rastered on device',
      ],
      links: [
        AppLink(
          type: AppLinkType.playStore,
          url: 'https://play.google.com/store/apps/details'
              '?id=com.kenstarry.rezq&pcampaignid=web_share',
        ),
      ],
    ),
    ProjectModel(
      slug: 'flow',
      name: 'Flow Music Player',
      tagline: 'An offline player built to rival Poweramp.',
      year: '2026',
      status: ProjectStatus.shipped,
      category: ProjectCategory.personal,
      platforms: [ProjectPlatform.android],
      mockupImage: 'images/flow-mockup.webp',
      featured: true,
      stack: [
        'Flutter',
        'BLoC',
        'flutter_soloud',
        'Hive',
        'get_it',
        'Shorebird',
      ],
      summary: [
        'A local music player for people who still keep their library on the '
            'device — parametric EQ, gapless playback, internet radio and a '
            'home-screen widget, with no account and no streaming tier.',
        'The audio path runs on SoLoud through FFI rather than on the platform '
            'player, which is what makes a real parametric EQ and scheduled '
            'playback possible at all. Most of the work is in the engine, not '
            'the screens.',
      ],
      highlights: [
        'C++ SoLoud audio engine over FFI — parametric EQ, buses, scheduling',
        'Home-screen widget painted in Dart and pushed to Android as raw pixels, '
            'so the in-app preview runs the identical painter',
        'Shorebird code push for Dart-only patches without a Play review',
        'Internet radio over the radio-browser.info directory',
        'flutter_extend — an in-house extension package with its own test suite',
      ],
      links: [
        AppLink(
          type: AppLinkType.playStore,
          url: 'https://play.google.com/store/apps/details'
              '?id=com.kenstarry.flow&pcampaignid=web_share',
        ),
      ],
    ),
    ProjectModel(
      slug: 'eduflow',
      name: 'EduFlow',
      tagline: 'Junior-secondary school operations in one app.',
      year: '2025',
      status: ProjectStatus.shipped,
      category: ProjectCategory.commercial,
      platforms: [ProjectPlatform.android],
      stack: ['Flutter', 'Clean Architecture', 'REST', 'Hive'],
      summary: [
        'Attendance, grade books and parent comms for Kenyan junior secondary '
            'schools, built for teachers whose phones are mid-range and whose '
            'network is not.',
        'Every screen degrades gracefully: queue the write, show the truth, sync '
            'when the signal comes back.',
      ],
      highlights: [
        'Offline write queue with conflict resolution',
        'Role-based UI shell shared by teachers, admins and parents',
        'Localised for English and Kiswahili',
      ],
    ),
    // ─────────────────────────────────────────────────────────────────────
    // TODO(ken): the four entries below are drafted from public sources —
    // what the products do is researched and accurate, but `highlights` and
    // `stack` describe *your* contribution and are deliberately left empty
    // rather than guessed. Nothing false renders while they are blank: the
    // card and case study simply omit those blocks. Fill them in and they
    // appear.
    // `year` is empty for the same reason — the card hides it rather than
    // printing a date I invented.
    // ─────────────────────────────────────────────────────────────────────
    ProjectModel(
      slug: 'healthx-portal',
      name: 'HealthX Customer Portal',
      tagline: 'The same care, without installing anything.',
      year: '',
      status: ProjectStatus.shipped,
      category: ProjectCategory.enterprise,
      client: 'HealthX Africa',
      platforms: [ProjectPlatform.web],
      stack: [],
      summary: [
        'The browser counterpart to the HealthX app — consultations, '
            'prescriptions, orders and health records for people who would '
            'rather not install anything, or who are reaching for a laptop '
            'rather than a phone.',
      ],
      links: [
        AppLink(
          type: AppLinkType.web,
          url: 'https://portal.healthxafrica.com',
          label: 'Customer Portal',
        ),
      ],
    ),
    ProjectModel(
      slug: 'britam-app',
      name: 'Britam App',
      tagline: 'Policies, investments and loans in one app.',
      year: '',
      status: ProjectStatus.shipped,
      category: ProjectCategory.enterprise,
      client: 'Britam Insurance × Dentsu',
      platforms: [ProjectPlatform.android, ProjectPlatform.ios],
      stack: [],
      summary: [
        'MyBritam puts statements, new product sign-up, policy loans and '
            'investment top-ups in a single app for Britam customers, with a '
            'one-time password guarding every financial action.',
      ],
      links: [
        AppLink(
          type: AppLinkType.playStore,
          url: 'https://play.google.com/store/apps/details?id=com.app.britam',
        ),
      ],
    ),
    ProjectModel(
      slug: 'britam-portal',
      name: 'Britam Customer Portal',
      tagline: 'Self-service for policies, on the web.',
      year: '',
      status: ProjectStatus.shipped,
      category: ProjectCategory.enterprise,
      client: 'Britam Insurance × Dentsu',
      platforms: [ProjectPlatform.web],
      stack: [],
      summary: [
        'The web counterpart to the app: one interface for managing Britam '
            'policies, starting with the Life book and folding in further '
            'product lines over time.',
      ],
      links: [
        AppLink(
          type: AppLinkType.web,
          url: 'https://customerportal.britam.com',
          label: 'Customer Portal',
        ),
      ],
    ),
    ProjectModel(
      slug: 'elvs',
      name: 'Elvs Mobile',
      tagline: 'Volunteer reporting, tracked end to end.',
      year: '',
      status: ProjectStatus.shipped,
      category: ProjectCategory.commercial,
      client: 'Podii Consultants',
      platforms: [ProjectPlatform.android],
      stack: [],
      summary: [
        'Tracks and manages the reports school volunteers submit and prepare, '
            'so a programme lead can see what has been filed without chasing '
            'anyone for it.',
      ],
      links: [
        AppLink(
          type: AppLinkType.playStore,
          url: 'https://play.google.com/store/apps/details?id=com.podii.elvs',
        ),
      ],
    ),
  ];

  /// Every slug, in display order. Consumed by the router to pre-render one
  /// static page per project.
  static List<String> get slugs =>
      projects.map((p) => p.slug).toList(growable: false);
}
