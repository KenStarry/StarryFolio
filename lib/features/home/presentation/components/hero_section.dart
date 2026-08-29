import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/two_tone_title.dart';
import '../../../../core/routing/route_paths.dart';
import 'portrait_frame.dart';

/// Above-the-fold hero. Owns the page's only `<h1>`.
///
/// Two columns rather than the reference's three. The reference's middle column
/// held a tall cutout figure that filled it vertically; this avatar is square,
/// and squeezed into a narrow middle column it had no presence at all. Merging
/// the name and the introduction into one column gives the card roughly half
/// the width to sit in, and lets the name run at real display size.
///
/// Entrances are time-based (`.rise` + `.d-N`) rather than scroll-driven: this
/// content is already in view on load, so a scroll timeline would have nothing
/// to advance it and the hero would sit at its start state forever.
class HeroSection extends StatelessComponent {
  const HeroSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative bg-ink-900 pb-24 pt-12 sm:pb-32 lg:pb-36 lg:pt-6',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid items-center gap-16 lg:grid-cols-[1.06fr_0.94fr] '
                  'lg:gap-20',
              [
                // ── Copy ──
                // The near parallax plane: lifts furthest and dims slightly as
                // the hero leaves, so it passes *in front of* the portrait.
                div(
                  classes: 'hero-near',
                  [
                    if (SiteConfig.available) _availability(),

                    // Two-tone, inverted against the page headers: the
                    // muted line comes *first*, so the name reads
                    // muted → bright → the accent rule below it. A name is
                    // not a sentence with a clause to send to the back; the
                    // composition here is a crescendo into the mark, and
                    // `Starry` is the half that carries the domain, the
                    // wordmark and the ghost behind the portrait.
                    const TwoToneTitle(
                      classes: 'rise d-2 type-display mt-8 font-display '
                          'font-extrabold text-ink-100',
                      lines: [
                        (text: SiteConfig.firstName, muted: true),
                        (text: '${SiteConfig.lastName}.', muted: false),
                      ],
                    ),

                    // The mark under the name. Two weights of the same accent
                    // rather than one bar — a considered detail exactly where
                    // the eye lands after reading the name.
                    const div(
                      classes: 'rise d-3 mt-8 flex items-center gap-2',
                      [
                        span(classes: 'h-1 w-14 bg-iris-400', []),
                        span(classes: 'h-1 w-2.5 bg-iris-600', []),
                      ],
                    ),

                    const p(
                      classes: 'rise d-4 type-quote mt-9 max-w-md font-display '
                          'font-semibold text-ink-100',
                      [Component.text(SiteConfig.heroStatement)],
                    ),

                    const p(
                      classes: 'rise d-5 mt-6 max-w-md text-sm leading-relaxed '
                          'text-ink-400',
                      [Component.text(SiteConfig.heroLead)],
                    ),

                    const div(
                      classes: 'rise d-6 mt-10 flex flex-wrap items-center '
                          'gap-x-8 gap-y-4',
                      [
                        CtaButton(
                          label: 'See the work',
                          href: RoutePaths.projects,
                        ),
                        CtaButton(
                          label: 'My story',
                          href: RoutePaths.about,
                          variant: CtaVariant.quiet,
                        ),
                      ],
                    ),

                    _socials(),
                  ],
                ),

                // ── Avatar ──
                const div(
                  classes: 'rise d-4 order-first lg:order-none',
                  [PortraitFrame()],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Availability marker. The breathing dot is the page's only looping
  /// animation — one live element reads as a signal, several read as noise.
  static Component _availability() => const div(
        classes: 'rise d-1 inline-flex items-center gap-2.5',
        [
          span(classes: 'h-1.5 w-1.5 rounded-full bg-iris-400 dot-live', []),
          span(
            classes: 'type-eyebrow font-mono text-ink-400',
            [Component.text(SiteConfig.availabilityLabel)],
          ),
        ],
      );

  static Component _socials() => div(
        classes: 'rise d-7 mt-14 flex items-center gap-5 border-t '
            'border-ink-800 pt-8',
        [
          const span(
            classes: 'type-eyebrow font-mono text-ink-500',
            [Component.text('Find me')],
          ),
          const span(classes: 'h-px w-6 bg-ink-700', []),
          for (final social in SiteConfig.socials)
            a(
              href: social.url,
              target: Target.blank,
              attributes: {
                'rel': 'me noopener',
                'aria-label': '${social.label} — ${social.handle}',
              },
              classes: 'text-ink-400 transition-colors duration-300 '
                  'hover:text-iris-400',
              [AppIcons.social(social.label, classes: 'h-[1.15rem] w-[1.15rem]')],
            ),
        ],
      );
}
