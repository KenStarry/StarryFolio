/// Lifecycle state of a project, used for the badge on each card.
enum ProjectStatus {
  shipped('Shipped', 'border-ink-500 text-ink-200'),
  building('Building', 'border-ink-600 text-ink-400'),
  archived('Archived', 'border-ink-700 text-ink-500');

  const ProjectStatus(this.label, this.classes);

  final String label;

  /// Tailwind classes for the badge — a hairline border and a text tone, no
  /// fill. Written as literals so Tailwind's scanner picks them up; build
  /// these dynamically and the classes get purged.
  final String classes;

  /// Resolves a wire value defensively, so an unknown status from a future API
  /// degrades to a sensible default instead of throwing.
  static ProjectStatus fromName(String? value) => values.firstWhere(
        (s) => s.name == value,
        orElse: () => ProjectStatus.building,
      );
}
