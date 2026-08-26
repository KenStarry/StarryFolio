import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'eyebrow.dart';

/// Ground tone for a section.
///
/// Sections alternate so the page reads as stacked bands rather than one
/// continuous sheet — that segmentation is the structure of the reference.
enum SectionTone {
  /// The page's base tone, `#282739`.
  base,

  /// One step up, `#35364A`. Used for every other band.
  raised,

  /// The deepest tone, `#1E1F2B`. Reserved for the footer.
  deep,
}

/// A consistently spaced page section with an optional eyebrow, heading and lead.
///
/// The heading defaults to `<h2>`. A page whose main subject *is* the section —
/// the projects index, for example — passes [isPageHeading] so it renders `<h1>`
/// instead. Every page needs exactly one `<h1>`: zero leaves crawlers without a
/// primary topic, more than one splits it.
class SectionBlock extends StatelessComponent {
  const SectionBlock({
    required this.children,
    this.id,
    this.eyebrow,
    this.heading,
    this.lead,
    this.tone = SectionTone.base,
    this.classes = '',
    this.bodyClasses = '',
    this.isPageHeading = false,
    super.key,
  });

  final List<Component> children;

  /// Anchor target, e.g. `about` for `/#about`.
  final String? id;

  final String? eyebrow;
  final String? heading;
  final String? lead;
  final SectionTone tone;
  final String classes;
  final String bodyClasses;

  /// Renders [heading] as the page's `<h1>` rather than an `<h2>`.
  final bool isPageHeading;

  @override
  Component build(BuildContext context) {
    final ground = switch (tone) {
      SectionTone.base => 'bg-ink-900',
      SectionTone.raised => 'bg-ink-800',
      SectionTone.deep => 'bg-ink-950',
    };

    final hasHead = eyebrow != null || heading != null || lead != null;

    return section(
      id: id,
      classes: '$ground py-24 sm:py-32 lg:py-40 $classes',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            if (hasHead)
              div(
                classes: 'reveal max-w-2xl',
                [
                  if (eyebrow != null) Eyebrow(eyebrow!),
                  if (heading != null)
                    if (isPageHeading)
                      h1(classes: _headingClasses, _headingLines(heading!))
                    else
                      h2(classes: _headingClasses, _headingLines(heading!)),
                  if (lead != null)
                    p(
                      classes: 'mt-5 max-w-lg text-sm leading-relaxed '
                          'text-ink-400 sm:text-[0.9375rem]',
                      [Component.text(lead!)],
                    ),
                ],
              ),
            // The motif: a hairline that starts on the accent and fades out
            // rather than running edge to edge. Rendered once here so every
            // section inherits it and none can drift.
            if (hasHead) const div(classes: 'divider mt-12', []),
            div(
              classes: hasHead ? 'mt-12 sm:mt-16 $bodyClasses' : bodyClasses,
              children,
            ),
          ],
        ),
      ],
    );
  }

  /// Splits authored newlines into `<br>`-separated text, so a heading can set
  /// as a deliberate two-line block rather than wrapping wherever the container
  /// happens to end. A crawler still reads one continuous string.
  static List<Component> _headingLines(String heading) {
    final lines = heading.split('\n');
    return [
      for (final (i, line) in lines.indexed) ...[
        if (i > 0) const br(),
        Component.text(line),
      ],
    ];
  }

  static const String _headingClasses =
      'type-section mt-5 font-display font-bold text-ink-100';
}
