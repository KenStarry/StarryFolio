/// How deeply a skill is actually held.
///
/// Three levels, not five and not a percentage. A percentage on a portfolio is
/// a number nobody can verify and everybody discounts; three honest bands read
/// as a person describing their own hands rather than a progress bar.
///
/// Rendered as filled dots against a fixed track, so the whole matrix can be
/// scanned in one pass without reading a single label.
enum SkillLevel {
  /// Reached for daily. The tools the work is actually made of.
  core('Core', 3),

  /// Comfortable and shipped with, without it being the centre of the job.
  fluent('Fluent', 2),

  /// Used in anger, kept sharp, not claimed as a speciality.
  working('Working', 1);

  const SkillLevel(this.label, this.dots);

  /// Legend label.
  final String label;

  /// Filled dots out of [track].
  final int dots;

  /// Total dots drawn, filled or not.
  static const int track = 3;

  /// Parses a stored value, falling back rather than throwing — a renamed
  /// level in a future CMS must not take the page down.
  static SkillLevel fromName(String? name) => values.firstWhere(
        (level) => level.name == name,
        orElse: () => working,
      );
}
