import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';

/// The hero portrait, built as a fanned stack of cards.
///
/// Three layers: two empty cards offset behind, and the photo card in front.
/// At rest they sit tight, reading as a single card with depth; on hover the
/// back layers push out and rotate while the front lifts, which is what makes
/// the stack feel physical rather than like three stacked rectangles.
///
/// The offsets are authored as literal utility strings rather than computed,
/// because Tailwind's scanner reads `.dart` source — a class assembled by
/// interpolation would be purged out of the stylesheet.
class PortraitFrame extends StatelessComponent {
  const PortraitFrame({super.key});

  @override
  Component build(BuildContext context) {
    return const div(
      classes: 'stack group relative mx-auto w-full max-w-sm lg:mx-0 '
          'lg:max-w-none',
      [
        // The single accent bloom on the site. Sits behind everything and is
        // deliberately larger than the stack so its edge never resolves.
        div(
          classes: 'bloom pointer-events-none absolute -inset-16 -z-10',
          attributes: {'aria-hidden': 'true'},
          [],
        ),

        div(
          classes: 'relative aspect-[4/5] w-full',
          [
            // ── Back layers ──
            div(
              classes: 'stack-layer stack-layer-1 absolute inset-0 '
                  '-translate-x-3 translate-y-2 -rotate-[5deg] rounded-sm '
                  'border border-ink-700 bg-ink-850',
              attributes: {'aria-hidden': 'true'},
              [],
            ),
            div(
              classes: 'stack-layer stack-layer-2 absolute inset-0 '
                  '-translate-x-1.5 translate-y-1 -rotate-[2.5deg] rounded-sm '
                  'border border-ink-700 bg-ink-800',
              attributes: {'aria-hidden': 'true'},
              [],
            ),

            // ── Front card ──
            div(
              classes: 'stack-front relative h-full w-full overflow-hidden '
                  'rounded-sm border border-ink-600 bg-ink-800 shadow-2xl '
                  'shadow-ink-950/60',
              [
                img(
                  src: '/${SiteConfig.portrait}',
                  alt: SiteConfig.portraitAlt,
                  // The hero image is the LCP element — never lazy, and given
                  // priority over everything below it.
                  attributes: {
                    'decoding': 'async',
                    'fetchpriority': 'high',
                  },
                  classes: 'h-full w-full object-cover',
                ),

                // Caption strip, so the card reads as an object with a face
                // rather than a cropped photo.
                div(
                  classes: 'absolute inset-x-0 bottom-0 flex items-center '
                      'justify-between border-t border-ink-700/80 '
                      'bg-ink-900/85 px-4 py-3 backdrop-blur-sm',
                  [
                    span(
                      classes: 'type-eyebrow font-mono text-ink-300',
                      [Component.text(SiteConfig.shortName)],
                    ),
                    span(
                      classes: 'type-eyebrow font-mono text-iris-400',
                      [Component.text(SiteConfig.location)],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
