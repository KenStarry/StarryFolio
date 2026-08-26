/// Lifecycle state of a project, used for the badge on each card.
enum ProjectStatus {
  shipped('Shipped', 'bg-emerald-500/15 text-emerald-600 dark:text-emerald-400'),
  building('Building', 'bg-star-400/15 text-star-500 dark:text-star-300'),
  archived('Archived', 'bg-ink-500/15 text-ink-500 dark:text-ink-300');

  const ProjectStatus(this.label, this.classes);

  final String label;

  /// Tailwind classes for the badge. Written as literals so Tailwind's scanner
  /// picks them up — build these dynamically and the classes get purged.
  final String classes;

  /// Resolves a wire value defensively, so an unknown status from a future API
  /// degrades to a sensible default instead of throwing.
  static ProjectStatus fromName(String? value) => values.firstWhere(
        (s) => s.name == value,
        orElse: () => ProjectStatus.building,
      );
}
