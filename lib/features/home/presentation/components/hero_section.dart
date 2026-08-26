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
/// the portrait in the middle, and a narrow introduction column on the right.
/// Below `lg` it collapses to a single column with the portrait last, so the
/// name and the introduction stay adjacent on a phone.
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
                  classes: 'reveal lg:pb-6',
                  [
                    const h1(
                      classes: 'type-display font-display font-extrabold '
                          'text-ink-100',
                      [
                        Component.text(SiteConfig.firstName),
                        br(),
                        Component.text('${SiteConfig.lastName}.'),
                      ],
                    ),

                    // The short rule under the name, straight from the
                    // reference. It replaces what was an amber bar there.
                    const div(classes: 'mt-8 h-1 w-16 bg-ink-200', []),

                    _socials(),
                  ],
                ),

                // ── Portrait ──
                // `order-last` on small screens keeps the reading order
                // name → introduction → portrait, while the DOM order stays
                // name → portrait → introduction for the desktop grid.
                const div(
                  classes: 'reveal order-last lg:order-none',
                  [PortraitFrame()],
                ),

                // ── Introduction ──
                const div(
                  classes: 'reveal lg:pb-6',
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

  static Component _socials() => div(
        classes: 'mt-12 flex items-center gap-5',
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
                  'hover:text-ink-100',
              [AppIcons.social(social.label, classes: 'h-[1.15rem] w-[1.15rem]')],
            ),
        ],
      );
}
