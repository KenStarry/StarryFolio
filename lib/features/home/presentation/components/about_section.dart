import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/eyebrow.dart';

/// About + the numbers.
///
/// Modelled on the reference's contact band: an eyebrow and heading in the
/// left column, the quote in the middle, and the stats sitting on the baseline
/// beneath it. Not a [SectionBlock] because that centres a single narrow
/// column, and this band is deliberately a two-column split.
class AboutSection extends StatelessComponent {
  const AboutSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(
      id: 'about',
      classes: 'bg-ink-900 py-24 sm:py-32 lg:py-40',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid gap-14 lg:grid-cols-[0.85fr_1.15fr] lg:gap-20',
              [
                // ── Left: who ──
                div(
                  classes: 'reveal',
                  [
                    const Eyebrow('About'),
                    const h2(
                      classes: 'type-section mt-5 font-display font-bold '
                          'text-ink-100',
                      [
                        Component.text('The last 10%'),
                        br(),
                        Component.text('is the product.'),
                      ],
                    ),
                    div(
                      classes: 'mt-7 space-y-4',
                      [
                        for (final para in SiteConfig.bio)
                          p(
                            classes: 'text-sm leading-relaxed text-ink-400',
                            [Component.text(para)],
                          ),
                      ],
                    ),
                  ],
                ),

                // ── Right: quote, stats, toolkit ──
                div(
                  classes: 'reveal',
                  [
                    const p(
                      classes: 'type-quote font-display font-semibold '
                          'text-ink-100',
                      [Component.text(SiteConfig.pullQuote)],
                    ),

                    // Stats sit on a rule, as in the reference.
                    div(
                      classes: 'mt-12 grid grid-cols-3 gap-6 border-t '
                          'border-ink-700 pt-8',
                      [
                        for (final stat in SiteConfig.stats)
                          div([
                            p(
                              classes: 'type-stat font-display font-extrabold '
                                  'text-ink-200',
                              [Component.text(stat.value)],
                            ),
                            p(
                              classes: 'mt-2 text-xs leading-snug text-ink-400',
                              [Component.text(stat.label)],
                            ),
                          ]),
                      ],
                    ),

                    // Toolkit as plain ruled rows. No chips, no borders per
                    // item — at four groups the chips became visual noise.
                    div(
                      classes: 'mt-12 border-t border-ink-700',
                      [
                        for (final group in SiteConfig.toolkit)
                          div(
                            classes: 'grid gap-1 border-b border-ink-700 py-4 '
                                'sm:grid-cols-[8rem_1fr] sm:gap-6',
                            [
                              h3(
                                classes: 'type-eyebrow font-mono text-ink-500',
                                [Component.text(group.group)],
                              ),
                              p(
                                classes: 'text-sm text-ink-300',
                                [Component.text(group.items.join('  ·  '))],
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
        ),
      ],
    );
  }
}
