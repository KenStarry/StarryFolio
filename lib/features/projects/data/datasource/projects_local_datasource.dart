import '../../../../core/domain/enum/app_link_type.dart';
import '../../../../core/domain/model/app_link.dart';
import '../../domain/enum/project_category.dart';
import '../../domain/enum/project_status.dart';
import '../../domain/model/project_model.dart';

/// The case studies, as compile-time constants.
///
/// `healthx` and `flow` are the real featured builds. **Everything except
/// `healthx`, `flow`, `criblynk` and `eduflow` is sample content**
/// added to fill out the sections — replace that copy with real work before
/// launch. Categories drive which section a project lands in.
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
      category: ProjectCategory.commercial,
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
      slug: 'flow',
      name: 'Flow Music Player',
      tagline: 'An offline player built to rival Poweramp.',
      year: '2026',
      status: ProjectStatus.shipped,
      category: ProjectCategory.personal,
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
      category: ProjectCategory.enterprise,
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
    ProjectModel(
      slug: 'tuza',
      name: 'Tuza',
      tagline: 'Group savings that settle themselves.',
      year: '2024',
      status: ProjectStatus.shipped,
      category: ProjectCategory.commercial,
      stack: ['Flutter', 'Riverpod', 'Firebase', 'M-Pesa Daraja'],
      summary: [
        'A chama app for the way Kenyan savings groups already work — rotating '
            'payouts, contribution reminders and a ledger every member can '
            'audit without asking the treasurer.',
        'The hard part was reconciliation. Mobile money callbacks arrive late, '
            'twice, or not at all, so the ledger is built to be replayed rather '
            'than corrected.',
      ],
      highlights: [
        'Idempotent payment reconciliation against Daraja callbacks',
        'Offline ledger that replays cleanly once the network returns',
        'Per-member statements exportable as PDF',
      ],
    ),
    ProjectModel(
      slug: 'njia',
      name: 'Njia',
      tagline: 'Fleet visibility without the dashboard tax.',
      year: '2024',
      status: ProjectStatus.shipped,
      category: ProjectCategory.enterprise,
      stack: ['Flutter', 'BLoC', 'Mapbox', 'WebSockets'],
      summary: [
        'Live vehicle tracking for a distribution business running 40 vehicles '
            'across three counties — dispatch, proof of delivery and route '
            'history in one app for drivers and controllers alike.',
        'Built around intermittent connectivity: the driver app is the source '
            'of truth and the server catches up, not the other way round.',
      ],
      highlights: [
        'Single codebase serving both the driver and controller roles',
        'Batched location sync that survives hours without signal',
        'Proof-of-delivery capture with signature and geotag',
      ],
    ),
    ProjectModel(
      slug: 'pulse',
      name: 'Pulse',
      tagline: 'Habits, without the streak guilt.',
      year: '2023',
      status: ProjectStatus.archived,
      category: ProjectCategory.personal,
      stack: ['Flutter', 'Drift', 'Riverpod', 'Health Connect'],
      summary: [
        'A habit tracker built on the idea that missing a day is data, not '
            'failure. No streaks to break — just an honest picture of what you '
            'actually do.',
        'Shelved once the idea was proven, but the motion and charting work in '
            'it went straight into Flow.',
      ],
      highlights: [
        'Health Connect and HealthKit ingestion behind one interface',
        'Custom chart rendering on raw canvas for 60fps scrubbing',
        'Fully local — no account, no sync, no telemetry',
      ],
    ),
    ProjectModel(
      slug: 'rafiki',
      name: 'Rafiki',
      tagline: 'Field data collection that works off-grid.',
      year: '2023',
      status: ProjectStatus.shipped,
      category: ProjectCategory.enterprise,
      stack: ['Flutter', 'Isar', 'Clean Architecture', 'REST'],
      summary: [
        'A survey tool for NGO field officers working days away from a signal — '
            'forms, photos and GPS captured offline and reconciled in bulk once '
            'a device gets back to town.',
        'Form definitions ship as data rather than code, so a programme lead '
            'can change a questionnaire without waiting on a release.',
      ],
      highlights: [
        'Server-driven forms rendered from a JSON schema',
        'Multi-day offline capture with conflict-free bulk sync',
        'Battery-aware GPS sampling for all-day fieldwork',
      ],
    ),
    ProjectModel(
      slug: 'mavuno',
      name: 'Mavuno',
      tagline: 'Produce, straight from the farm gate.',
      year: '2023',
      status: ProjectStatus.shipped,
      category: ProjectCategory.commercial,
      stack: ['Flutter', 'Riverpod', 'Supabase', 'Stripe'],
      summary: [
        'A marketplace putting smallholder farmers in front of restaurant '
            'buyers directly — listings, cold-chain logistics and settlement in '
            'one place.',
        'Two very different users share one codebase: a farmer on a budget '
            'Android phone and a chef on an iPad.',
      ],
      highlights: [
        'Role-aware shell serving farmers and buyers from one build',
        'Image pipeline that keeps uploads usable on 3G',
        'Settlement ledger reconciled against the payment provider nightly',
      ],
    ),
    ProjectModel(
      slug: 'duka',
      name: 'Duka',
      tagline: 'A till that survives the power cut.',
      year: '2022',
      status: ProjectStatus.archived,
      category: ProjectCategory.commercial,
      stack: ['Flutter', 'BLoC', 'SQLite', 'Bluetooth'],
      summary: [
        'Point of sale for small retailers — stock, receipts and daily takings '
            'on a phone plus a Bluetooth printer, with no server required.',
        'Designed for shops where the network and the mains are both optional. '
            'Everything is local, and the backup is a file you can copy.',
      ],
      highlights: [
        'Entirely offline — no account, no server, no subscription',
        'ESC/POS receipt printing over Bluetooth',
        'Day-close report that reconciles cash against recorded sales',
      ],
    ),
    ProjectModel(
      slug: 'orbit',
      name: 'Orbit',
      tagline: 'Motion primitives for Flutter.',
      year: '2022',
      status: ProjectStatus.shipped,
      category: ProjectCategory.personal,
      stack: ['Dart', 'Flutter', 'CustomPainter'],
      summary: [
        'A small open-source package of the transitions I kept rewriting — '
            'staggered reveals, shared-axis routes and a spring curve that does '
            'not overshoot into ugliness.',
        'Written mostly to force myself to document motion decisions instead of '
            'copying magic numbers between projects.',
      ],
      highlights: [
        'Zero dependencies beyond the Flutter SDK',
        'Every curve documented with a rationale, not just a name',
        'Golden tests pinning the visual output of each transition',
      ],
      links: [
        AppLink(type: AppLinkType.repo, url: 'https://github.com/KenStarry/orbit'),
      ],
    ),
  ];

  /// Every slug, in display order. Consumed by the router to pre-render one
  /// static page per project.
  static List<String> get slugs =>
      projects.map((p) => p.slug).toList(growable: false);
}
