/// The design side of a build, for the `design` collection.
///
/// ## Why this is a block rather than a few loose fields
///
/// `/projects/design` shows the same products as `/projects/mobile`. That is
/// only defensible if the two pages say genuinely different things — and the
/// cheapest way to guarantee that is to make the design page read from copy
/// that does not exist anywhere else. A project with no [ProjectDesign] is
/// simply not in the collection, so the page can never pad itself out by
/// reprinting an engineering summary under a design heading.
///
/// ## The shape is deliberate
///
/// Problem, then system, then what shipped. That is the order the work
/// actually happens in, and each part answers a question a reader has:
/// *what made this hard*, *what did you decide*, *what came out*. A single
/// paragraph of design prose answers none of them and reads as a portfolio
/// caption.
///
/// [draft] behaves as it does everywhere else on this site — while it is set,
/// the surface renders a visible marker rather than presenting authored
/// scaffolding as a record of decisions somebody actually made.
class ProjectDesign {
  const ProjectDesign({
    required this.problem,
    this.system = const [],
    this.shipped = const [],
    this.note = '',
    this.draft = false,
  });

  /// What made this hard before a pixel was drawn. One or two sentences.
  final String problem;

  /// The decisions that became the system — type, colour, spacing, motion,
  /// states. Rendered as ruled rows, so each one has to stand alone.
  final List<String> system;

  /// What actually came out of it: a component library, store assets, a motion
  /// spec. Artefacts, not adjectives.
  final List<String> shipped;

  /// Optional closing line, where there is something worth saying that is not
  /// a problem, a decision or an artefact.
  final String note;

  /// The copy is authored scaffolding rather than a record of real decisions.
  final bool draft;

  factory ProjectDesign.fromMap(Map<String, dynamic> map) => ProjectDesign(
        problem: map['problem']?.toString() ?? '',
        system: _stringList(map['system']),
        shipped: _stringList(map['shipped']),
        note: map['note']?.toString() ?? '',
        draft: map['draft'] == true,
      );

  Map<String, dynamic> toMap() => {
        'problem': problem,
        'system': system,
        'shipped': shipped,
        if (note.isNotEmpty) 'note': note,
        'draft': draft,
      };

  static List<String> _stringList(Object? value) => value is List
      ? value.map((e) => e.toString()).toList(growable: false)
      : const [];
}
