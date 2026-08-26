import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// One line of a [TwoToneTitle], and whether it sits back.
typedef TitleLine = ({String text, bool muted});

/// A display heading set in two tones — the site's headline treatment.
///
/// One half of the headline is `ink-100` at the weight the caller sets; the
/// other is `ink-400` one weight step lighter. The tail sits back in *two*
/// dimensions rather than one, which is the whole difference between a
/// heading that looks recoloured and a heading that looks typeset.
///
/// Why a component rather than a pair of spans at each call site: this is the
/// treatment on every `<h1>` on the site, and the moment it is inlined twice
/// the two copies start disagreeing about which grey, which weight and whether
/// the muted half gets its own line. There is one definition, and pages choose
/// only *which* lines are muted.
///
/// **Which half sits back is a judgement, not a rule.** On a page header the
/// muted line is the clause that qualifies the first — "What I build, / *and
/// how I work.*" On the home hero it is inverted: a name is not a sentence,
/// and running muted → bright → the accent rule under it builds a crescendo
/// into the mark instead of trailing away from it.
///
/// Contrast is the constraint. `ink-400` on `ink-900` is about 4.3:1; the
/// `ink-500` used for small mono labels is about 2.5:1, under the 3:1 floor
/// that even large text has to clear. A headline is content, never decoration,
/// so the muted half stops at `ink-400`.
class TwoToneTitle extends StatelessComponent {
  const TwoToneTitle({
    required this.lines,
    this.classes = '',
    this.isPageHeading = true,
    this.mutedWeight = 'font-bold',
    super.key,
  });

  /// The headline, one entry per rendered line. Lines are joined with `<br>`,
  /// so display type breaks where the copy wants it to rather than wherever
  /// the container happens to end — a crawler still reads one string.
  final List<TitleLine> lines;

  /// Type scale and bright weight — `type-page font-display font-extrabold
  /// text-ink-100`. The muted lines step down from whatever weight is set
  /// here, so it has to be the *bright* one.
  final String classes;

  /// Renders `<h1>` rather than `<h2>`. Every page needs exactly one `<h1>`:
  /// zero leaves crawlers without a primary topic, two split it.
  final bool isPageHeading;

  /// The step down for muted lines. One notch below the bright weight —
  /// `font-bold` under an `extrabold` headline, `font-semibold` under a bold
  /// one. Two notches reads as a mistake.
  final String mutedWeight;

  @override
  Component build(BuildContext context) {
    final children = <Component>[
      for (final (i, line) in lines.indexed) ...[
        if (i > 0) const br(),
        if (line.muted)
          span(
            classes: 'text-ink-400 $mutedWeight',
            [Component.text(line.text)],
          )
        else
          Component.text(line.text),
      ],
    ];

    return isPageHeading
        ? h1(classes: classes, children)
        : h2(classes: classes, children);
  }

  /// Builds the page-header shape: a bright headline, optionally closed by one
  /// muted line. [head] may carry newlines of its own.
  static List<TitleLine> tail(String head, [String tail = '']) => [
        for (final line in head.split('\n')) (text: line, muted: false),
        if (tail.isNotEmpty) (text: tail, muted: true),
      ];
}
