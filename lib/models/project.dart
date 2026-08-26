/// Lifecycle state of a project, used for the little badge on each card.
enum ProjectStatus {
  shipped('Shipped', 'bg-emerald-500/15 text-emerald-600 dark:text-emerald-400'),
  building('Building', 'bg-star-400/15 text-star-500 dark:text-star-300'),
  archived('Archived', 'bg-ink-500/15 text-ink-500 dark:text-ink-300');

  const ProjectStatus(this.label, this.classes);

  final String label;

  /// Tailwind classes for the badge. Written as literals so Tailwind's
  /// scanner picks them up at build time.
  final String classes;
}

class Project {
  const Project({
    required this.slug,
    required this.name,
    required this.tagline,
    required this.year,
    required this.status,
    required this.stack,
    required this.summary,
    this.highlights = const [],
    this.gradient = 'from-star-400/25 to-ink-600/10',
    this.repoUrl,
    this.liveUrl,
    this.storeUrl,
    this.coverImage,
  });

  /// URL segment: `/projects/<slug>`
  final String slug;
  final String name;
  final String tagline;
  final String year;
  final ProjectStatus status;
  final List<String> stack;

  /// Paragraphs shown on the detail page.
  final List<String> summary;

  /// Bullet points — what you actually built or learned.
  final List<String> highlights;

  /// Tailwind gradient stops for the card header.
  final String gradient;

  final String? repoUrl;
  final String? liveUrl;
  final String? storeUrl;

  /// Path under web/, e.g. 'images/criblynk.png'.
  final String? coverImage;
}
