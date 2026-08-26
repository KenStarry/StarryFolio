/// One step of how the work actually runs, for the process arc on `/about`.
///
/// The services page says *what* is on offer; this says *in what order it
/// happens*, which is the question a client is really asking when they ask
/// what it is like to work with someone.
class ProcessStepModel {
  const ProcessStepModel({
    required this.slug,
    required this.title,
    required this.blurb,
    this.icon = 'layers',
    this.artefact = '',
  });

  final String slug;
  final String title;
  final String blurb;

  /// Key into `AppIcons.byName`.
  final String icon;

  /// What you are actually holding when the step ends. A process that cannot
  /// name its output at each stage is a diagram, not a process.
  final String artefact;

  factory ProcessStepModel.fromMap(Map<String, dynamic> map) => ProcessStepModel(
        slug: map['slug']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        blurb: map['blurb']?.toString() ?? '',
        icon: map['icon']?.toString() ?? 'layers',
        artefact: map['artefact']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'title': title,
        'blurb': blurb,
        'icon': icon,
        'artefact': artefact,
      };
}
