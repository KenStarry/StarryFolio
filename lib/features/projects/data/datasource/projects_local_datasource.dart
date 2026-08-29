import '../../../../core/domain/enum/app_link_type.dart';
import '../../../../core/domain/model/app_link.dart';
import '../../domain/enum/project_category.dart';
import '../../domain/enum/project_kind.dart';
import '../../domain/enum/project_platform.dart';
import '../../domain/enum/project_status.dart';
import '../../domain/model/project_feature.dart';
import '../../domain/model/project_module.dart';
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
      tagline: 'Care, a pharmacy and a doctor, in one app.',
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
            'pharmacy delivery behind one login: video calls with a doctor, a '
            'prescription photographed and filled, and the order tracked to the '
            'door.',
        'I own the full mobile lifecycle here: design system and brand '
            'through architecture, QA and both store listings. No designer, '
            'no PM, which is either a dream or a warning depending on the '
            'week. The hard part is that health data is unforgiving, so every '
            'screen has to degrade honestly when the network does not.',
      ],
      highlights: [
        'Clean Architecture across seven feature modules, sharing one shell',
        'Riverpod 3 with codegen throughout, no hand-rolled providers',
        'Semantic theming via a HealthXColors ThemeExtension, not scattered hex',
        'Stateful shell navigation that keeps each tab’s stack alive',
        'On-device PDF receipt generation for orders and consultations',
      ],
      // HealthX is two products sharing one account, so the case study is
      // described by modules rather than a flat feature list. Clinical ships
      // today; Bloom is designed and partly built, which is why its features
      // carry no renders and fall back to the card treatment.
      modules: [
        ProjectModule(
          name: 'Clinical',
          tagline: 'Care, delivered.',
          blurb: 'The transactional half. See a doctor, fill a prescription, '
              'track it to the door: efficient, trustworthy, get-in-get-out.',
          accent: '#E9552B',
          surfaces: ['Home', 'Bookings', 'Consult', 'Pharmacy', 'Labs'],
          features: [
          ProjectFeature(
            label: 'Consult',
            title: 'A doctor, without the queue.',
            description: 'Voice and video consultations booked in the app, with '
                'the clinical notes and any prescription landing back in the '
                'patient record the moment the call ends.',
            points: [
              'In-call state survives a backgrounded app or a dropped network',
              'Notes and prescriptions written straight onto the record',
              'Toll-free fallback when the connection will not hold a video call',
            ],
            image: 'images/healthx-mockup.webp',
          ),
          ProjectFeature(
            label: 'Pharmacy',
            title: 'Photograph the script. Track the box.',
            description: 'A prescription is uploaded as a photo, verified by a '
                'pharmacist, and the resulting order is tracked to the door, '
                'the whole path in one place instead of three phone calls.',
            points: [
              'Upload, verification and dispatch as one tracked flow',
              'Live order status with delivery handover confirmation',
              'Reorder from any past prescription in two taps',
            ],
            image: 'images/healthx-mockup.webp',
          ),
          ProjectFeature(
            label: 'Appointments',
            title: 'Booking that survives a bad signal.',
            description: 'Slots, reminders and rescheduling built for mid-range '
                'phones on unreliable networks: every action queues locally and '
                'reconciles when the connection returns.',
            points: [
              'Optimistic booking with server reconciliation on reconnect',
              'Local reminders that fire without a push connection',
              'Reschedule and cancel without losing the original slot history',
            ],
            image: 'images/healthx-mockup.webp',
          ),
          ProjectFeature(
            label: 'Records',
            title: 'One calm home for your health.',
            description: 'Consultations, orders and receipts collected into a '
                'single history, with PDFs generated on the device so a receipt '
                'is available with no connection at all.',
            points: [
              'On-device PDF generation for orders and consultations',
              'Chronological record spanning every part of the app',
              'Shareable receipts without a round trip to the server',
            ],
            image: 'images/healthx-mockup.webp',
          ),
  ],
        ),
        ProjectModule(
          name: 'Bloom',
          tagline: 'Grow, daily.',
          blurb: 'The reflective half. Record how the day felt, breathe, track '
              'a cycle: calm, unhurried, warm. One account and one wallet, '
              'seen through a different lens.',
          accent: '#16A34A',
          badge: 'In build',
          conceptual: true,
          surfaces: ['Bloom Home', 'Journal', 'Breathe', 'Cycle', 'Stats'],
          features: [
            ProjectFeature(
              label: 'Journal',
              title: 'Record how the day felt.',
              description: 'A low-friction daily entry that asks for a feeling '
                  'before it asks for a number. The habit has to survive a bad '
                  'day to be worth anything.',
              image: 'images/healthx-mockup.webp',
            ),
            ProjectFeature(
              label: 'Breathe',
              title: 'Guided sessions that do not nag.',
              description: 'Short breathing exercises that open in one tap and '
                  'never guilt a missed streak.',
              image: 'images/healthx-mockup.webp',
            ),
            ProjectFeature(
              label: 'Cycle',
              title: 'Tracking that stays private.',
              description: 'Cycle logging held on the device, surfaced in Bloom '
                  'and never leaked into the clinical side.',
              image: 'images/healthx-mockup.webp',
            ),
            ProjectFeature(
              label: 'The morph',
              title: 'Switching worlds is one tap, and it animates.',
              description: 'Every switch runs a single 0→1 value over ~700ms: '
                  'the accent lerps between worlds, the imagery and copy '
                  'cross-dissolve, and a radial glow blooms out of the control '
                  'you touched. It never cuts.',
              points: [
                'One driver value keeps accent, backdrop, copy and wash in step',
                'Urgent clinical signals still reach you inside Bloom',
                'Auth is byte-for-byte identical across both worlds',
              ],
            ),
          ],
        ),
        ProjectModule(
          name: 'Portal',
          kind: 'Surface',
          tagline: 'The same care, on a bigger screen.',
          blurb: 'The clinical half again, in the browser. Not a cut-down '
              'companion: the same consultations, the same pharmacy, the same '
              'records, for the moments a phone is simply the wrong tool. Bloom '
              'stays on mobile, where a reflective habit belongs.',
          accent: '#E9552B',
          badge: 'Web',
          surfaces: ['Consult', 'Pharmacy', 'Orders', 'Records'],
          features: [
            ProjectFeature(
              label: 'Consult',
              title: 'Take the call at a desk.',
              description: 'The same consultation, joined from a laptop, '
                  'useful when you need to take notes, or when the person who '
                  'books the appointment is not the person attending it.',
            ),
            ProjectFeature(
              label: 'Pharmacy',
              title: 'A prescription is easier to read at full size.',
              description: 'Uploading from a desktop means a scanned script '
                  'rather than a photograph of one, and a basket that is far '
                  'quicker to assemble with a keyboard.',
            ),
            ProjectFeature(
              label: 'Orders',
              title: 'A wide screen is a better dashboard.',
              description: 'Order history, delivery status and repeat orders '
                  'laid out at once instead of paged through, the view that '
                  'suits someone managing care for a whole household.',
            ),
            ProjectFeature(
              label: 'Records',
              title: 'Read it, print it, keep it.',
              description: 'The same record the app holds, in a form you can '
                  'actually print or hand to a clinic that still runs on '
                  'paper.',
            ),
          ],
        ),
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
        'A marketplace that connects tenants with verified landlords: listings, '
            'viewings and payment tracking in one place instead of scattered across '
            'chat threads.',
        'The hard part was trust, not CRUD: verification flows, '
            'dispute-friendly audit trails, and making a listing feel worth '
            'believing. Anyone who has hunted for a flat over WhatsApp knows '
            'exactly which problem this is solving.',
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
        'It exists because I got tired of keeping eleven slightly different '
            'copies of my own CV in sync. The interesting half is the PDF '
            'engine: each section dispatches its own rendering per template, '
            'so adding a template is a new builder rather than a rewrite of '
            'every section.',
      ],
      highlights: [
        'Master profile → role snapshot → PDF, instead of a document per job',
        'Three interchangeable templates, each with its own typographic ramp '
            'and PdfColor palette',
        'Strategy-dispatch section enum, so a new template does not touch '
            'existing section code',
        'A borderless design system, depth carried by a three-level shadow '
            'ramp and surface contrast, never by lines',
        'Local-first on Hive, with PDF thumbnails rastered on device',
      ],
      // Drawn from the project's own specs. The two entries without an image
      // are documented as spec-only there, so they are told as notes rather
      // than mocked up as if they shipped.
      features: [
        ProjectFeature(
          label: 'Workshop',
          title: 'Write your career once.',
          description: 'The master profile lives in the Workshop, eight '
              'sections covering everything you have ever done. Nothing else '
              'in the app works until this exists, so it is the part that had '
              'to feel effortless.',
          points: [
            'Eight sections: personal, summary, experience, education, skills, '
                'projects, socials, hobbies',
            'Edited in place, never through a wizard',
            'Held locally on Hive: it works with no account and no signal',
          ],
          image: 'images/rezq-mockup.webp',
        ),
        ProjectFeature(
          label: 'Roles',
          title: 'A snapshot per job, not a document per job.',
          description: 'A Role is a tailored view of the master profile for a '
              'target job: pick the experience that matters, choose a template '
              'and a theme, and the PDF follows. Editing the profile updates '
              'every role that draws on it.',
          points: [
            'Roles select from the profile rather than copying it',
            'Share and download live on the role itself',
            'Rewriting a job description once fixes it everywhere',
          ],
          image: 'images/rezq-mockup.webp',
        ),
        ProjectFeature(
          label: 'Templates',
          title: 'Three templates, each with its own voice.',
          description: 'Maverick, Zenith and Visiona are not colour swaps, '
              'each carries its own typographic ramp, spacing tokens and PDF '
              'colour palette, browsable by tone.',
          points: [
            'Every template owns its ramp and palette, not just an accent',
            'Browsable with a tone-based filter',
            'Thumbnails rastered on device from the real document',
          ],
          image: 'images/rezq-mockup.webp',
        ),
        ProjectFeature(
          label: 'PDF engine',
          title: 'A section renders itself, per template.',
          description: 'The document pipeline runs fonts, config, theme and '
              'data into a template implementation. Sections dispatch through '
              'a strategy enum, so adding a template is a new builder rather '
              'than an edit to every section.',
          points: [
            'Strategy dispatch keeps templates and sections independent',
            'Async TTF loading with a typography ramp per document',
            'Generated on device, no server round trip to see your CV',
          ],
          image: 'images/rezq-mockup.webp',
        ),
        ProjectFeature(
          label: 'Next, Smart Import',
          title: 'Upload an old CV, watch the Workshop fill in.',
          description: 'The Workshop has a cold-start wall: typing a whole '
              'career into a blank screen is the single biggest reason people '
              'give up. Smart Import turns a CV you already have into a '
              'populated profile, and Role Tailoring builds a role from a '
              'pasted job description on the same foundation.',
          points: [
            'Specced, not shipped',
            'Targets a first CV in under three minutes',
            'Role Tailoring rides the same layer once import lands',
          ],
        ),
        ProjectFeature(
          label: 'Next, Live links',
          title: 'A resume that is a link, not an attachment.',
          description: 'Every competitor ends at "Download PDF". A live link '
              'would let a role be shared as a URL that stays current when the '
              'profile behind it changes.',
          points: [
            'Spec only, nothing wired yet',
            'The role stays the source of truth, not the download',
          ],
        ),
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
            'device: parametric EQ, gapless playback, internet radio and a '
            'home-screen widget, with no account and no streaming tier.',
        'The audio path runs on SoLoud through FFI rather than the platform '
            'player, which is the only reason a real parametric EQ and '
            'scheduled playback are possible at all. Most of the work is in '
            'the engine rather than the screens, which is an odd thing to say '
            'about a music player until you try building an EQ without one.',
      ],
      highlights: [
        'C++ SoLoud audio engine over FFI: parametric EQ, buses, scheduling',
        'Home-screen widget painted in Dart and pushed to Android as raw pixels, '
            'so the in-app preview runs the identical painter',
        'Shorebird code push for Dart-only patches without a Play review',
        'Internet radio over the radio-browser.info directory',
        'flutter_extend, an in-house extension package with its own test suite',
      ],
      // Drawn from the project's own reference doc. Every image is the same
      // composite mockup for now; swap each `image:` as real screenshots land.
      // `Radio` deliberately carries none — it is built but withheld, and that
      // is a story rather than a screen.
      features: [
        ProjectFeature(
          label: 'Engine',
          title: 'A C++ audio engine, driven from Dart.',
          description: 'The playback path was rebuilt from nothing on SoLoud '
              'over FFI rather than the platform player, because a real '
              'parametric EQ and scheduled playback are not things a platform '
              'player will give you.',
          points: [
            'Every voice plays through one music bus; filters attach to the bus',
            'Gain staging with strictly separated writers, so nothing fights '
                'over volume',
            'Engine core is pure Dart with zero state-management imports',
          ],
          image: 'images/flow-mockup.webp',
        ),
        ProjectFeature(
          label: 'Search',
          title: 'Finds the thing, not just the song.',
          description: 'The old search could not find an album, an artist, a '
              'playlist, a folder or a setting, and ranked every match the '
              'same. This one is a tiered ladder that narrows as you type.',
          points: [
            'Albums, artists, playlists, folders and settings are all findable',
            'A command palette sits on the same index',
            'The ranking engine knows nothing about music. It is testable alone',
          ],
          image: 'images/flow-mockup.webp',
        ),
        ProjectFeature(
          label: 'Lyrics',
          title: 'Timed lyrics, parsed purely.',
          description: 'Synced and unsynced lyrics resolved from several '
              'sources, with the parsing kept free of any file, clock or widget '
              'so a mis-read timestamp fails a test rather than a listener.',
          points: [
            'Pure parser, tested with no file and no clock',
            'Reachable from the three places you would actually reach for it',
            'Falls back gracefully when a track has no words at all',
          ],
          image: 'images/flow-mockup.webp',
        ),
        ProjectFeature(
          label: 'Language',
          title: 'Eight languages, and the plural rules to match.',
          description: 'Around 690 hard-coded strings across 446 files were '
              'lifted into a translation layer where the language you end up '
              'reading is decided by a pure function.',
          points: [
            'Eight complete languages, not eight partial ones',
            'Plural rules, which is the half a plain string table does not buy',
            'Adding a language is two steps',
          ],
          image: 'images/flow-mockup.webp',
        ),
        ProjectFeature(
          label: 'Home widget',
          title: 'A widget painted in Dart.',
          description: 'The home-screen widget is built in-house rather than '
              'with a plugin: a pane is painted in Dart and pushed to Android '
              'as raw pixels, which is what lets the in-app preview run the '
              'identical painter the home screen runs.',
          points: [
            'One painter serves both the widget and its in-app preview',
            'No divergence between what you configure and what you get',
            'Shorebird code push ships Dart-only fixes without a store review',
          ],
          image: 'images/flow-mockup.webp',
        ),
        ProjectFeature(
          label: 'Radio',
          title: 'Built, tested, and deliberately switched off.',
          description: 'Internet radio is whole and wired, a distinct playback '
              'mode rather than a track with odd properties, mutually exclusive '
              'with the queue in both directions. It ships behind a flag that '
              'is currently false, because the public station directory is '
              'missing most of the big Kenyan commercial stations. A flagship '
              'surface that cannot find the stations its audience listens to '
              'reads as broken rather than as incomplete.',
          points: [
            'A separate playback mode, not a track pretending to be one',
            'Pausing a live stream disconnects it, which fixed a real bug',
            'Held back on the directory, not on the code',
          ],
        ),
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
      tagline: 'A whole school, running off one app.',
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
      tagline: 'Consultations and prescriptions, no download required.',
      year: '',
      status: ProjectStatus.shipped,
      category: ProjectCategory.enterprise,
      client: 'HealthX Africa',
      platforms: [ProjectPlatform.web],
      stack: [],
      summary: [
        'The browser counterpart to the HealthX app: consultations, '
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
      tagline: 'Policies, investments and loans, finally in one place.',
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
      tagline: 'Everything the app does, in a browser tab.',
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
      tagline: 'Volunteer work, finally accounted for.',
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
    // ── Open source ────────────────────────────────────────────────────────
    // The only `ProjectKind.package` on the index, and the reason that axis
    // exists. Every figure below is verifiable from the repository — release
    // count, test count, extension count, CI steps — so the case study needs
    // no pub.dev metrics, which would go stale between deploys anyway.
    ProjectModel(
      slug: 'flutter-extend',
      name: 'flutter_extend',
      tagline: 'The boilerplate you stop writing.',
      year: '2025',
      status: ProjectStatus.shipped,
      category: ProjectCategory.personal,
      kind: ProjectKind.package,
      platforms: [
        ProjectPlatform.android,
        ProjectPlatform.ios,
        ProjectPlatform.web,
        ProjectPlatform.desktop,
      ],
      coverImage: 'images/flutter-extend-cover.webp',
      stack: [
        'Dart',
        'Flutter',
        'Extension methods',
        'GitHub Actions',
        'flutter_test',
        'intl',
        'flutter_animate',
      ],
      links: [
        AppLink(
          type: AppLinkType.pubDev,
          url: 'https://pub.dev/packages/flutter_extend',
        ),
        AppLink(
          type: AppLinkType.repo,
          url: 'https://github.com/KenStarry/flutter_extend',
        ),
        AppLink(
          type: AppLinkType.web,
          url: 'https://starrycodes.mintlify.app/flutter_extend/introduction',
          label: 'Documentation',
        ),
      ],
      summary: [
        'A Dart extension library that removes the boilerplate every Flutter '
            'codebase rewrites: navigation without the `context` clutter, '
            'padding declared on the widget itself, theme access that does not '
            'go through `Theme.of(context)`, and string, date, file and list '
            'helpers that would otherwise be a `utils.dart` in every project.',
        'It started as the shared layer inside Flow Music Player and got '
            'pulled out once the same twenty helpers had been copied into a '
            'third codebase. Thirteen releases later it is 37 extensions '
            'across 12 core types, with 80 tests and CI gating every pull '
            'request.',
        'The interesting part is not the extension list, the docs cover that '
            'better than a case study can. It is that a package other people '
            'depend on has to be maintained differently from an app you own: '
            'nothing can be renamed on a whim, and every removal needs a '
            'migration path shipped ahead of it.',
      ],
      highlights: [
        '13 releases over a year of continuous maintenance, v0.0.1 to v0.3.1',
        '37 extensions across 12 types: String, BuildContext, Widget, File, '
            'DateTime, num, Color and more',
        '80 tests in 13 files, run by GitHub Actions on every pull request',
        'CI also enforces formatting: `dart format --set-exit-if-changed`',
        'Deprecations ship with a named removal version and a migration target',
        'Split into per-area entrypoints, so importing strings does not pull '
            'in the animation layer',
      ],
      features: [
        ProjectFeature(
          label: 'Ergonomics',
          title: 'The call site is the design.',
          description: 'Every extension was judged by one question, does the '
              'line that uses it read better than the line it replaces? Where '
              'the answer was no, it did not ship, however useful the helper '
              'was in isolation.',
          points: [
            'Navigation: `context.pushScreen(Home())` over the Navigator dance',
            'Layout: `Text(...).padding()` declared on the widget, not around '
                'it',
            'Theme: `context.colorScheme` instead of `Theme.of(context)`',
            'Validation: `email.isValidEmail`, `password.hasMinimumLength(8)`',
          ],
        ),
        ProjectFeature(
          label: 'Maintenance',
          title: 'A deprecation policy, on a v0.x side project.',
          description: 'The rename from `"".generateLoremIpsum()` to '
              '`30.loremWords` could have been a breaking change in a patch '
              'release. Instead the old form stayed, marked deprecated, '
              'pointing at its replacement and naming the version it would be '
              'removed in.',
          points: [
            'Four generator methods deprecated in v0.2.0 with 1.0.0 named as '
                'the removal',
            'Every deprecation carries the exact call to migrate to',
            'v0.3.1 restructured the library into smaller entrypoints without '
                'breaking a single import',
          ],
        ),
        ProjectFeature(
          label: 'Discipline',
          title: 'CI that can actually fail.',
          description: 'A solo package is where test suites usually go to die. '
              'This one runs `flutter test` and a formatting check on every '
              'pull request, against a pinned Flutter version, so a red '
              'branch cannot be merged and a reformatted file cannot sneak in '
              'unreviewed.',
          points: [
            'GitHub Actions, pinned to Flutter 3.27.1',
            '80 tests across generators, strings, dates, files, lists, numbers',
            '51+ pull requests: features branched, reviewed and merged rather '
                'than pushed to main',
          ],
        ),
      ],
    ),
  ];

  /// Every slug, in display order.
  static List<String> get slugs =>
      projects.map((p) => p.slug).toList(growable: false);

  /// Slugs that actually have a case study written. Consumed by the router to
  /// pre-render one static page per *written-up* project — a project without a
  /// walkthrough gets no route, so it can neither be linked to nor found.
  static List<String> get caseStudySlugs => projects
      .where((p) => p.hasCaseStudy)
      .map((p) => p.slug)
      .toList(growable: false);
}
