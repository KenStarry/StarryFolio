import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/routing/route_paths.dart';
import 'portrait_frame.dart';

/// Above-the-fold hero. Owns the page's only `<h1>`.
///
/// Three columns, as in the reference: the name at display size on the left,
/// the card stack in the middle, and a narrow introduction column on the right.
/// Below `lg` it collapses to one column with the stack last, so the name and
/// the introduction stay adjacent on a phone.
///
/// Entrances here are time-based (`.rise` + `.d-N`) rather than scroll-driven:
/// this content is already in view on load, so a scroll timeline would have
/// nothing to advance it and the hero would sit at its start state forever.
class HeroSection extends StatelessComponent {
  const HeroSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'bg-ink-900 pb-24 pt-10 sm:pb-32 lg:pb-40',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid items-end gap-14 '
                  'lg:grid-cols-[minmax(0,1fr)_minmax(0,0.92fr)_minmax(0,0.86fr)] '
                  'lg:gap-10',
              [
                // ── Name ──
                div(
                  classes: 'lg:pb-6',
                  [
                    if (SiteConfig.available) _availability(),

                    const h1(
                      classes: 'rise d-2 type-display mt-7 font-display '
                          'font-extrabold text-ink-100',
                      [
                        Component.text(SiteConfig.firstName),
                        br(),
                        Component.text('${SiteConfig.lastName}.'),
                      ],
                    ),

                    // The mark under the name. Two weights of the same accent
                    // rather than one bar — it reads as a considered detail at
                    // the exact place the eye lands after the name.
                    const div(
                      classes: 'rise d-3 mt-8 flex items-center gap-2',
                      [
                        span(classes: 'h-1 w-14 bg-iris-400', []),
                        span(classes: 'h-1 w-2.5 bg-iris-600', []),
                      ],
                    ),

                    _socials(),
                  ],
                ),

                // ── Card stack ──
                // `order-last` on small screens keeps the reading order
                // name → introduction → portrait, while the DOM order stays
                // name → portrait → introduction for the desktop grid.
                const div(
                  classes: 'rise d-5 order-last lg:order-none',
                  [PortraitFrame()],
                ),

                // ── Introduction ──
                const div(
                  classes: 'rise d-4 lg:pb-6',
                  [
                    Eyebrow('Introduction'),
                    p(
                      classes: 'type-quote mt-6 font-display font-semibold '
                          'text-ink-100',
                      [Component.text(SiteConfig.heroStatement)],
                    ),
                    p(
                      classes: 'mt-6 text-sm leading-relaxed text-ink-400',
                      [Component.text(SiteConfig.heroLead)],
                    ),
                    div(
                      classes: 'mt-9',
                      [
                        CtaButton(
                          label: 'My story',
                          href: '${RoutePaths.home}#about',
                          variant: CtaVariant.quiet,
                        ),
                      ],
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

  /// Availability marker. The breathing dot is the page's only looping
  /// animation — one live element reads as a signal, several read as noise.
  static Component _availability() => const div(
        classes: 'rise d-1 inline-flex items-center gap-2.5',
        [
          span(
            classes: 'h-1.5 w-1.5 rounded-full bg-iris-400 dot-live',
            [],
          ),
          span(
            classes: 'type-eyebrow font-mono text-ink-400',
            [Component.text(SiteConfig.availabilityLabel)],
          ),
        ],
      );

  static Component _socials() => div(
        classes: 'rise d-6 mt-12 flex items-center gap-5',
        [
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
