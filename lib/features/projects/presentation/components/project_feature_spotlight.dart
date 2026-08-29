import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/ghost_text.dart';
import '../../domain/model/project_feature.dart';

/// One capability, given a full band on a case study.
///
/// Alternates side by index so a run of spotlights zig-zags rather than
/// repeating the same block. Like the project showcases, the mirroring is CSS
/// `order` — the copy stays first in the DOM either way, so reading and tab
/// order is always heading-then-image regardless of which side the device is
/// on.
///
/// Depth comes from the same three moves used across the site: a device on a
/// soft bloom, a ghost element behind it, and a hairline rule. Here the ghost
/// is the **feature number** rather than a wordmark — at four spotlights a
/// repeated product name would read as a stutter, while the numerals give the
/// section a spine.
///
/// A feature with no image renders as a centred text band rather than leaving
/// an empty column, so partially-illustrated case studies still look finished.
class ProjectFeatureSpotlight extends StatelessComponent {
  const ProjectFeatureSpotlight({
    required this.feature,
    required this.index,
    this.muted = false,
    super.key,
  });

  final ProjectFeature feature;

  /// Zero-based position. Drives both the numeral and which side the device
  /// sits on.
  final int index;

  /// Marks the feature as designed but not shipped.
  ///
  /// Keeps the identical layout — an unbuilt half of a product should still
  /// read as the same product — but dials the device back: smaller, slightly
  /// transparent, softer bloom, and a `Concept` chip in the eyebrow. Same
  /// structure, less volume.
  final bool muted;

  @override
  Component build(BuildContext context) {
    final number = (index + 1).toString().padLeft(2, '0');
    final reversed = index.isOdd;
    final image = feature.image;

    final copy = div(
      classes: 'reveal '
          '${image == null ? '' : (reversed ? 'lg:order-2' : 'lg:order-1')}',
      [
        div(
          classes: 'flex items-center gap-4',
          [
            span(
              classes: 'font-display text-sm font-extrabold text-iris-400',
              [Component.text(number)],
            ),
            const span(classes: 'h-px w-8 bg-ink-600', []),
            span(
              classes: 'type-eyebrow font-mono text-ink-400',
              [Component.text(feature.label)],
            ),
            if (muted)
              const span(
                classes: 'border border-ink-700 px-2 py-0.5 font-mono '
                    'text-[9px] uppercase tracking-wider text-ink-500',
                [Component.text('Concept')],
              ),
          ],
        ),

        h3(
          classes: 'mt-6 font-display text-2xl font-bold leading-tight '
              'tracking-tight text-ink-100 sm:text-3xl',
          [Component.text(feature.title)],
        ),

        p(
          classes: 'mt-5 max-w-md text-sm leading-relaxed text-ink-400 '
              'sm:text-[0.9375rem]',
          [Component.text(feature.description)],
        ),

        if (feature.points.isNotEmpty)
          ul(
            classes: 'mt-8 max-w-md border-t border-ink-800',
            [
              for (final point in feature.points)
                li(
                  classes: 'flex gap-4 border-b border-ink-800 py-3.5 '
                      'text-sm leading-relaxed text-ink-300',
                  [
                    const span(
                      classes: 'mt-2.5 h-px w-4 shrink-0 bg-iris-500',
                      [],
                    ),
                    span([Component.text(point)]),
                  ],
                ),
            ],
          ),
      ],
    );

    if (image == null) {
      return div(classes: 'mx-auto max-w-2xl', [copy]);
    }

    return div(
      classes: 'grid items-center gap-12 lg:gap-16 '
          '${reversed ? 'lg:grid-cols-[1.05fr_0.95fr]' : 'lg:grid-cols-[0.95fr_1.05fr]'}',
      [
        copy,
        div(
          classes: 'reveal relative flex items-center justify-center '
              '${reversed ? 'lg:order-1' : 'lg:order-2'}',
          [
            div(
              classes: 'bloom pointer-events-none absolute inset-0 -m-10 '
                  '${muted ? 'opacity-50' : ''}',
              attributes: const {'aria-hidden': 'true'},
              [],
            ),

            // Ghost numeral rather than the product name: across four
            // spotlights a repeated name reads as a stutter, while the numerals
            // give the run a spine.
            div(
              classes: 'pointer-events-none absolute inset-0 flex '
                  'items-center justify-center overflow-hidden',
              [
                GhostText(number, size: GhostSize.hero, faint: muted),
              ],
            ),

            img(
              src: '/$image',
              alt: '${feature.title}, ${feature.label}',
              // Spotlights are always below the fold on a case study.
              attributes: const {
                'loading': 'lazy',
                'decoding': 'async',
                'width': '914',
                'height': '1200',
              },
              classes: 'showcase-device relative w-full '
                  '${muted ? 'max-w-[15rem] opacity-90 lg:max-w-xs' : 'max-w-sm lg:max-w-md'}',
            ),
          ],
        ),
      ],
    );
  }
}
