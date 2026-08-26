/// Where a project runs.
///
/// Several products here ship as both an app and a web portal, and the pair
/// are separate case studies — so the platform has to be part of the model
/// rather than something inferred from the name.
enum ProjectPlatform {
  android('Android'),
  ios('iOS'),
  web('Web'),
  desktop('Desktop');

  const ProjectPlatform(this.label);

  final String label;

  /// Resolves a wire value defensively, so an unknown platform from a future
  /// API degrades rather than throwing.
  static ProjectPlatform fromName(String? value) => values.firstWhere(
        (p) => p.name == value || p.label == value,
        orElse: () => ProjectPlatform.android,
      );
}
