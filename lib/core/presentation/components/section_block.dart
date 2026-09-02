import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'eyebrow.dart';
import 'ghost_text.dart';
import 'two_tone_title.dart';

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
    this.headingTail = '',
    this.ghost = '',
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

  /// The half of [heading] that sits back, set muted by [TwoToneTitle]. The
  /// site's headline treatment — see CLAUDE.md.
  final String headingTail;
  final String? lead;
  /// A wayfinding watermark naming the page this section leads to.
  ///
  /// See [GhostText.bandCorner]. Empty renders none, which is right for a
  /// section that is not a doorway.
  final String ghost;

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
      // `isolate` and `overflow-hidden` only when there is a ghost: the first
      // gives its `-z-10` somewhere to sit rather than dropping it behind the
      // section background, the second is what crops the bleed. Adding them
      // unconditionally would make every section on the site a stacking
      // context for no reason.
      classes: '$ground py-24 sm:py-32 lg:py-40 '
          '${ghost.isEmpty ? '' : 'relative isolate overflow-hidden '}'
          '$classes',
      [
        if (ghost.isNotEmpty)
          GhostText(ghost, faint: true, classes: GhostText.bandCorner),

        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            if (hasHead)
              div(
                classes: 'reveal max-w-2xl',
                [
                  if (eyebrow != null) Eyebrow(eyebrow!),
                  if (heading != null)
                    TwoToneTitle(
                      lines: TwoToneTitle.tail(heading!, headingTail),
                      classes: _headingClasses,
                      isPageHeading: isPageHeading,
                      // One notch under this block's `font-bold`, where a page
                      // header steps down from `extrabold`.
                      mutedWeight: 'font-semibold',
                    ),
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

  static const String _headingClasses =
      'type-section mt-5 font-display font-bold text-ink-100';
}
