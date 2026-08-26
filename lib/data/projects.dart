import '../models/project.dart';

/// Add a project here and it appears on the home page, the projects index,
/// and gets its own statically generated `/projects/<slug>` page. That's it.
const List<Project> projects = [
  Project(
    slug: 'criblynk',
    name: 'CribLynk',
    tagline: 'Rentals, minus the WhatsApp chaos.',
    year: '2026',
    status: ProjectStatus.building,
    gradient: 'from-star-400/30 to-violet-500/10',
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
    repoUrl: 'https://github.com/KenStarry/CribLynk',
  ),
  Project(
    slug: 'flow',
    name: 'Flow',
    tagline: 'A money tracker that does not nag.',
    year: '2025',
    status: ProjectStatus.shipped,
    gradient: 'from-emerald-400/25 to-star-400/10',
    stack: ['Flutter', 'BLoC', 'Isar', 'fl_chart'],
    summary: [
      'Personal finance for people who bounce off budgeting apps. Flow logs '
          'spending in two taps and only speaks up when a pattern is worth '
          'noticing.',
      'Everything is local-first — the database is on device, sync is opt-in, '
          'and the app is fully usable in airplane mode.',
    ],
    highlights: [
      'Isar-backed local store with sub-16ms query times on a 3-year ledger',
      'Custom chart interactions built on fl_chart',
      'Haptics and motion tuned so logging feels lighter than a spreadsheet',
    ],
    repoUrl: 'https://github.com/KenStarry/Flow',
  ),
  Project(
    slug: 'eduflow',
    name: 'EduFlow',
    tagline: 'Junior-secondary school operations in one app.',
    year: '2025',
    status: ProjectStatus.shipped,
    gradient: 'from-sky-400/25 to-star-400/10',
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
];

/// Lookup helper used by the detail route.
Project? projectBySlug(String slug) {
  for (final project in projects) {
    if (project.slug == slug) return project;
  }
  return null;
}

/// The three most recent projects, for the home page teaser.
List<Project> get featuredProjects => projects.take(3).toList();
