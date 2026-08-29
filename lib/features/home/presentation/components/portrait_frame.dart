import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';

/// The hero avatar, built as a fanned stack of cards.
///
/// Three layers: two empty cards offset behind, and the avatar card in front.
/// At rest they sit tight, reading as one card with depth; on hover the back
/// layers push out and rotate while the front lifts, which is what sells the
/// stack as physical rather than as three stacked rectangles.
///
/// The frame is **square** because the artwork is: the subject fills the whole
/// canvas edge to edge and sits flush to the bottom. A portrait crop would
/// remove the laptop and the wine glass, which are most of the personality.
///
/// The avatar has a real alpha channel — roughly a third of it is transparent —
/// so the card's own surface shows through around the figure. It must be
/// exported from the **source image**, not from a Figma node render: a node
/// render composites the frame's own fill behind the art and ships a flat
/// opaque rectangle.
///
/// Behind the stack sits the ghost wordmark — the motif documented in
/// CLAUDE.md: texture, never content, `aria-hidden`, and faint enough that you
/// read it as depth rather than as a word.
class PortraitFrame extends StatelessComponent {
  const PortraitFrame({super.key});

  @override
  Component build(BuildContext context) {
    return const div(
      // `hero-mid` is the middle parallax plane. It rides `translate`, leaving
      // `transform` free for the stack's own hover fan.
      classes: 'stack hero-mid group relative mx-auto w-full max-w-md lg:mx-0 '
          'lg:max-w-none',
      [
        // Accent bloom. Larger than the stack so its edge never resolves into
        // a visible circle.
        div(
          classes: 'bloom pointer-events-none absolute -inset-20 -z-10',
          attributes: {'aria-hidden': 'true'},
          [],
        ),

        // Ghost wordmark, bleeding past the card on both sides. The far
        // parallax plane — it sinks as the rest lifts, and that divergence is
        // what reads as depth rather than as lag.
        div(
          classes: 'hero-far pointer-events-none absolute -inset-x-16 '
              'inset-y-0 -z-10 flex items-center justify-center '
              'overflow-visible',
          attributes: {'aria-hidden': 'true'},
          [
            span(
              classes: 'showcase-ghost select-none font-display font-extrabold '
                  'text-ink-100/[0.04]',
              [Component.text(SiteConfig.lastName)],
            ),
          ],
        ),

        div(
          classes: 'relative aspect-square w-full',
          [
            // ── Back layers ──
            div(
              classes: 'stack-layer stack-layer-1 absolute inset-0 '
                  '-translate-x-3 translate-y-2 -rotate-[5deg] rounded-sm '
                  'border border-ink-700 bg-ink-850',
              [],
            ),
            div(
              classes: 'stack-layer stack-layer-2 absolute inset-0 '
                  '-translate-x-1.5 translate-y-1 -rotate-[2.5deg] rounded-sm '
                  'border border-ink-700 bg-ink-800',
              [],
            ),

            // ── Front card ──
            div(
              classes: 'stack-front relative flex h-full w-full flex-col '
                  'overflow-hidden rounded-sm border border-ink-600 '
                  'bg-ink-850 shadow-2xl shadow-ink-950/60',
              [
                img(
                  src: '/${SiteConfig.portrait}',
                  alt: SiteConfig.portraitAlt,
                  // The avatar is the LCP element on this page — never lazy,
                  // and prioritised over everything below it. Intrinsic size
                  // reserves the box so nothing shifts as it loads.
                  attributes: {
                    'decoding': 'async',
                    'fetchpriority': 'high',
                    'width': '768',
                    'height': '768',
                  },
                  classes: 'h-full w-full object-contain object-bottom',
                ),

                // Caption strip, so the card reads as an object with a face
                // rather than a cropped image.
                div(
                  classes: 'absolute inset-x-0 bottom-0 flex items-center '
                      'justify-between border-t border-ink-700/80 '
                      'bg-ink-900/90 px-4 py-3 backdrop-blur-sm',
                  [
                    span(
                      classes: 'type-eyebrow font-mono text-ink-300',
                      [Component.text(SiteConfig.role)],
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
