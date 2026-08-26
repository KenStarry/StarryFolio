import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/eyebrow.dart';

/// About + the numbers + the toolkit.
///
/// A two-column split rather than a [SectionBlock], because that centres a
/// single narrow measure and this band is deliberately asymmetric. It owns its
/// own ground and divider so the rhythm still matches the sections around it.
///
/// The toolkit is pills rather than the ruled rows it was: four dense rows of
/// dot-separated text read as a spec sheet, where pills read as a palette you
/// can scan. Each one lifts and picks up the accent on hover, which is the
/// cheapest way to make a static block feel alive.
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
            // ── Header ──
            const div(
              classes: 'reveal max-w-2xl',
              [
                Eyebrow('About'),
                h2(
                  classes: 'type-section mt-5 font-display font-bold '
                      'text-ink-100',
                  [
                    Component.text('The last 10%'),
                    br(),
                    Component.text('is the product.'),
                  ],
                ),
              ],
            ),
            const div(classes: 'divider mt-12', []),

            div(
              classes: 'mt-12 grid gap-14 lg:grid-cols-[0.9fr_1.1fr] '
                  'lg:gap-20 sm:mt-16',
              [
                // ── Left: the words ──
                div(
                  classes: 'reveal',
                  [
                    const p(
                      classes: 'type-quote font-display font-semibold '
                          'text-ink-100',
                      [Component.text(SiteConfig.pullQuote)],
                    ),
                    div(
                      classes: 'mt-8 space-y-4',
                      [
                        for (final para in SiteConfig.bio)
                          p(
                            classes: 'text-sm leading-relaxed text-ink-400',
                            [Component.text(para)],
                          ),
                      ],
                    ),
                    _nowCard(),
                  ],
                ),

                // ── Right: numbers, then the toolkit ──
                div(
                  classes: 'reveal',
                  [
                    div(
                      classes: 'grid grid-cols-3 gap-6',
                      [
                        for (final stat in SiteConfig.stats)
                          div([
                            p(
                              classes: 'type-stat font-display font-extrabold '
                                  'text-ink-100',
                              [Component.text(stat.value)],
                            ),
                            const div(
                              classes: 'mt-3 h-px w-8 bg-iris-500',
                              [],
                            ),
                            p(
                              classes: 'mt-3 text-xs leading-snug text-ink-400',
                              [Component.text(stat.label)],
                            ),
                          ]),
                      ],
                    ),

                    const div(classes: 'divider-quiet mt-14', []),

                    div(
                      classes: 'mt-10 space-y-8',
                      [
                        for (final group in SiteConfig.toolkit)
                          div([
                            h3(
                              classes: 'type-eyebrow font-mono text-ink-500',
                              [Component.text(group.group)],
                            ),
                            div(
                              classes: 'mt-4 flex flex-wrap gap-2',
                              [
                                for (final item in group.items)
                                  span(
                                    classes: 'pill',
                                    [Component.text(item)],
                                  ),
                              ],
                            ),
                          ]),
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

  /// A small "currently" panel. Grounds the bio in something present-tense,
  /// which is what stops an about section reading as a CV.
  static Component _nowCard() => const div(
        classes: 'mt-10 border border-ink-700 bg-ink-850 p-6',
        [
          div(
            classes: 'flex items-center gap-2.5',
            [
              span(
                classes: 'h-1.5 w-1.5 rounded-full bg-iris-400 dot-live',
                [],
              ),
              span(
                classes: 'type-eyebrow font-mono text-ink-400',
                [Component.text('Currently')],
              ),
            ],
          ),
          p(
            classes: 'mt-4 text-sm leading-relaxed text-ink-300',
            [
              Component.text(
                'Owning the full mobile lifecycle at a Kenyan telehealth '
                'platform — and building ${SiteConfig.currentSideProject} on '
                'the side.',
              ),
            ],
          ),
          div(
            classes: 'mt-5 flex items-center gap-3',
            [
              span(
                classes: 'type-eyebrow font-mono text-ink-500',
                [Component.text(SiteConfig.location)],
              ),
              span(classes: 'h-px flex-1 bg-ink-700', []),
              span(
                classes: 'type-eyebrow font-mono text-iris-400',
                [Component.text('UTC+3')],
              ),
            ],
          ),
        ],
      );
}
