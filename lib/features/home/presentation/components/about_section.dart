import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../about/domain/model/about_profile.dart';
import '../../../about/domain/model/experience_model.dart';

/// The home page's About band — an overview, and a door.
///
/// A two-column split rather than a `SectionBlock`, because that centres a
/// single narrow measure and this band is deliberately asymmetric. It owns its
/// own ground and divider so the rhythm still matches the sections around it.
///
/// It used to carry the whole toolkit as pills. That now lives on `/about`
/// with a depth against each entry, and what is left here is the shortest
/// honest answer to "who is this": the line he works by, the bio, the
/// numbers, and the three most recent roles. Everything else is one click
/// away, which is the entire job of a teaser — the same relationship the
/// services row has to `/services`.
///
/// Receives an already-resolved profile rather than fetching: the home page
/// owns its awaits, so the whole page renders in one pass.
class AboutSection extends StatelessComponent {
  const AboutSection({required this.profile, this.error, super.key});

  final AboutProfile profile;

  /// Set when the repository returned a `Left`. The band still renders its
  /// heading and prose — only the roles strip is replaced, because everything
  /// else here is static content that still deserves to be indexed.
  final String? error;

  @override
  Component build(BuildContext context) {
    final recent = profile.experience.take(3).toList(growable: false);

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
              classes: 'mt-12 grid gap-14 lg:grid-cols-[0.95fr_1.05fr] '
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

                // ── Right: the numbers, then where they came from ──
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
                            const div(classes: 'mt-3 h-px w-8 bg-iris-500', []),
                            p(
                              classes: 'mt-3 text-xs leading-snug text-ink-400',
                              [Component.text(stat.label)],
                            ),
                          ]),
                      ],
                    ),

                    const div(classes: 'divider-quiet mt-14', []),

                    if (error != null)
                      div(classes: 'mt-10', [ErrorNotice(message: error!)])
                    else ...[
                      const p(
                        classes: 'type-eyebrow mt-10 font-mono text-ink-500',
                        [Component.text('Recently')],
                      ),
                      div(
                        classes: 'mt-2',
                        [for (final role in recent) _roleRow(role)],
                      ),
                    ],

                    _storyLink(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// One role, as a ruled row. Three of these say more about a career than a
  /// paragraph describing it does, and they cost four lines of markup each.
  static Component _roleRow(ExperienceModel role) => div(
        classes: 'grid grid-cols-[6.5rem_1fr] items-baseline gap-4 border-t '
            'border-ink-700/50 py-4',
        [
          p(
            classes: 'font-mono text-xs text-ink-500',
            [Component.text(role.period)],
          ),
          div([
            p(
              classes: 'text-sm text-ink-200',
              [Component.text(role.role)],
            ),
            p(
              classes: 'mt-1 text-xs text-ink-500',
              [Component.text(role.company)],
            ),
          ]),
        ],
      );

  /// The door through to `/about`.
  static Component _storyLink() => Link(
        to: RoutePaths.about,
        classes: 'link-line group mt-10 inline-flex items-center gap-3 '
            'text-sm font-medium text-ink-200 transition-colors duration-300 '
            'hover:text-ink-100',
        children: [
          const Component.text('The full story'),
          span(
            classes: 'transition-transform duration-500 ease-soft '
                'group-hover:translate-x-1.5',
            [AppIcons.arrow(classes: 'h-4 w-4')],
          ),
        ],
      );

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
