import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/jump_nav.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/presentation/components/section_rail.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/model/about_profile.dart';
import '../components/about_dossier.dart';
import '../components/education_card.dart';
import '../components/experience_entry.dart';
import '../components/facet_grid.dart';
import '../components/milestone_spine.dart';
import '../components/process_arc.dart';
import '../components/skill_matrix.dart';

/// The About page.
///
/// An [AsyncStatelessComponent] so the profile is awaited *during*
/// pre-rendering: every role, every year and every skill is in the generated
/// HTML. A Riverpod async provider here would ship crawlers a loading state,
/// which on the page that carries the Person schema would be the single worst
/// place on the site to do it.
///
/// One repository call, one `fold`. The bands are stacked in the order the
/// question is actually asked — who is this, what have they done, what do they
/// know, how do they work, how did they get here, and who are they when they
/// are not working.
///
/// Structurally a sibling of `/services`: same header-with-jump-pills, same
/// `rail-scope` wrapper, same closing band. What differs is that no two bands
/// here share a layout — a timeline, a panel, a matrix, a step row and a spine
/// — because a page about one person reads as a form to fill in the moment two
/// of its sections look alike.
class AboutPage extends AsyncStatelessComponent {
  const AboutPage({super.key});

  /// The bands, in order. Drives the jump pills, the rail and the band
  /// sequence from one list, so a section can never appear in the navigation
  /// without existing on the page.
  static const List<({String anchor, String label})> _stops = [
    (anchor: 'story', label: 'The short version'),
    (anchor: 'experience', label: 'Experience'),
    (anchor: 'education', label: 'Education'),
    (anchor: 'skills', label: 'Toolkit'),
    (anchor: 'process', label: 'How I work'),
    (anchor: 'milestones', label: 'Milestones'),
    (anchor: 'beyond', label: 'Beyond the code'),
  ];

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.about.getProfile();

    return result.fold(
      (error) => Component.fragment([
        const _Meta(),
        SectionBlock(
          eyebrow: 'About',
          heading: 'About',
          isPageHeading: true,
          children: [ErrorNotice(message: error)],
        ),
      ]),
      (profile) => Component.fragment([
        const _Meta(),
        StructuredData(
          id: 'ld-person',
          SchemaOrg.person(knowsAbout: profile.skillNames),
        ),
        StructuredData(
          id: 'ld-profile',
          SchemaOrg.profilePage(
            employers: [
              for (final role in profile.experience)
                (name: role.company, role: role.role),
            ],
            education: [
              for (final school in profile.education) school.institution,
            ],
          ),
        ),
        StructuredData(
          id: 'ld-breadcrumbs',
          SchemaOrg.breadcrumbs(const [
            (label: 'Home', path: RoutePaths.home),
            (label: 'About', path: RoutePaths.about),
          ]),
        ),

        _Header(profile: profile),

        // `timeline-scope` publishes the bands' timeline names to this
        // element's subtree only, so the fixed rail has to live inside the
        // same wrapper as the bands rather than beside it.
        div(
          classes: 'rail-scope',
          [
            _Story(profile: profile),
            _Experience(profile: profile),
            _Education(profile: profile),
            _Skills(profile: profile),
            _Process(profile: profile),
            _Milestones(profile: profile),
            _Beyond(profile: profile),

            const SectionRail(path: RoutePaths.about, stops: _stops),
          ],
        ),

        const _Close(),
      ]),
    );
  }
}

/// Page header — the `<h1>`, the dossier card and the jump pills.
class _Header extends StatelessComponent {
  const _Header({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return section(
      // `isolate` matters: the ghost wordmark below sits at `-z-10`, and
      // without a stacking context here it would paint *behind* this
      // section's own background and simply never be seen.
      classes: 'relative isolate overflow-hidden bg-ink-900 pb-16 pt-16 '
          'sm:pb-20 sm:pt-24',
      [
        // The ghost wordmark at page scale, anchored to the eyebrow directly
        // beneath it. Texture, never content.
        const div(
          classes: 'pointer-events-none absolute -right-10 -top-6 -z-10 '
              'select-none',
          attributes: {'aria-hidden': 'true'},
          [
            span(
              classes: 'showcase-ghost font-display font-extrabold '
                  'text-ink-100/[0.035]',
              [Component.text('About')],
            ),
          ],
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid items-center gap-12 lg:grid-cols-[1.15fr_0.85fr] '
                  'lg:gap-20',
              [
                div(
                  classes: 'reveal',
                  [
                    const Eyebrow('About'),

                    const h1(
                      classes: 'type-section mt-5 font-display font-extrabold '
                          'text-ink-100',
                      [
                        Component.text('${SiteConfig.name},'),
                        br(),
                        Component.text('end to end.'),
                      ],
                    ),

                    const p(
                      classes: 'mt-6 max-w-lg text-base leading-relaxed '
                          'text-ink-300',
                      [Component.text(SiteConfig.heroStatement)],
                    ),

                    p(
                      classes: 'mt-5 max-w-lg text-sm leading-relaxed '
                          'text-ink-400',
                      [Component.text(SiteConfig.bio.first)],
                    ),

                    const div(
                      classes: 'mt-9 flex flex-wrap items-center gap-3',
                      [
                        CtaButton(
                          label: 'Start a project',
                          href: 'mailto:${SiteConfig.email}',
                        ),
                        CtaButton(
                          label: 'See the work',
                          href: RoutePaths.projects,
                          variant: CtaVariant.outline,
                        ),
                      ],
                    ),
                  ],
                ),

                div(
                  classes: 'reveal',
                  [
                    AboutDossier(
                      currentCompany: profile.currentRole?.company ?? '',
                    ),
                  ],
                ),
              ],
            ),

            const div(classes: 'divider mt-16', []),

            div(
              classes: 'mt-8',
              [
                JumpNav(
                  path: RoutePaths.about,
                  label: 'Jump to a section',
                  stops: [
                    for (final stop in AboutPage._stops)
                      (anchor: stop.anchor, label: stop.label, count: 0),
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

/// The words, and the numbers beside them.
class _Story extends StatelessComponent {
  const _Story({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'story',
      classes: 'relative tl-1',
      tone: SectionTone.raised,
      eyebrow: 'The short version',
      heading: 'The last 10%\nis the product.',
      bodyClasses: 'grid gap-14 lg:grid-cols-[1.1fr_0.9fr] lg:gap-20',
      children: [
        div(
          classes: 'reveal',
          [
            const p(
              classes: 'type-quote font-display font-semibold text-ink-100',
              [Component.text(SiteConfig.pullQuote)],
            ),
            div(
              classes: 'mt-8 space-y-5',
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

        // The numbers, stacked and ruled rather than in a row: beside a column
        // of prose a horizontal stat row would fight the reading line.
        div(
          classes: 'reveal',
          [
            for (final stat in SiteConfig.stats)
              div(
                classes: 'border-t border-ink-700/60 py-7 first:border-t-0 '
                    'first:pt-0',
                [
                  p(
                    classes: 'type-stat font-display font-extrabold '
                        'text-ink-100',
                    [Component.text(stat.value)],
                  ),
                  p(
                    classes: 'mt-3 text-sm leading-snug text-ink-400',
                    [Component.text(stat.label)],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _Experience extends StatelessComponent {
  const _Experience({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'experience',
      classes: 'relative tl-2',
      eyebrow: 'Experience',
      heading: 'Where the work\nactually happened.',
      lead: 'Reverse-chronological, and honest about which parts were mine. '
          'Where a role produced something you can hold, it links to the case '
          'study.',
      children: [
        if (profile.experience.isEmpty)
          const ErrorNotice(message: 'No roles to show yet.')
        else
          div(
            classes: 'mt-4',
            [
              for (final role in profile.experience)
                ExperienceEntry(experience: role),
            ],
          ),
      ],
    );
  }
}

class _Education extends StatelessComponent {
  const _Education({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'education',
      classes: 'relative tl-3',
      tone: SectionTone.raised,
      eyebrow: 'Education',
      heading: 'The fundamentals\nthat do not expire.',
      bodyClasses: 'space-y-5',
      children: [
        for (final school in profile.education)
          EducationCard(education: school),

        // The honest footnote to any engineer's education section. Set as a
        // dashed panel so it reads as an aside rather than a second degree.
        const div(
          classes: 'reveal border border-dashed border-ink-700 p-7 sm:p-8',
          [
            p(
              classes: 'type-eyebrow font-mono text-ink-500',
              [Component.text('And since')],
            ),
            p(
              classes: 'mt-4 max-w-2xl text-sm leading-relaxed text-ink-300',
              [
                Component.text(
                  'Everything framework-shaped has been self-taught and '
                  'kept current in production — documentation, source, other '
                  "people's code, and shipping the thing to find out what the "
                  'tutorial left out. The degree taught me how to learn the '
                  'rest.',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Skills extends StatelessComponent {
  const _Skills({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'skills',
      classes: 'relative tl-4',
      eyebrow: 'Toolkit',
      heading: 'What I reach for,\nand how deep it goes.',
      lead: 'Depth stated in three honest bands rather than a percentage. A '
          'number nobody can verify is a number everybody discounts.',
      children: [SkillMatrix(groups: profile.skillGroups)],
    );
  }
}

class _Process extends StatelessComponent {
  const _Process({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'process',
      classes: 'relative tl-5',
      tone: SectionTone.raised,
      eyebrow: 'How I work',
      heading: 'Four steps, and\nwhat each hands over.',
      lead: 'The same order every time, whether it is a two-week build or a '
          'two-year product. What changes is how long each step takes.',
      children: [ProcessArc(steps: profile.process)],
    );
  }
}

class _Milestones extends StatelessComponent {
  const _Milestones({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'milestones',
      classes: 'relative tl-6',
      eyebrow: 'Milestones',
      heading: 'The road so far.',
      children: [MilestoneSpine(milestones: profile.milestones)],
    );
  }
}

class _Beyond extends StatelessComponent {
  const _Beyond({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'beyond',
      classes: 'relative tl-7',
      tone: SectionTone.raised,
      eyebrow: 'Beyond the code',
      heading: 'The part that\nis not work.',
      children: [FacetGrid(facets: profile.facets)],
    );
  }
}

/// Closing band, on the deepest tone so the page ends the way the footer
/// begins.
class _Close extends StatelessComponent {
  const _Close();

  @override
  Component build(BuildContext context) {
    return const section(
      classes: 'bg-ink-950 py-20 sm:py-28',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 text-center sm:px-8 lg:px-12',
          [
            div(
              classes: 'reveal mx-auto max-w-xl',
              [
                h2(
                  classes: 'type-section font-display font-bold text-ink-100',
                  [Component.text('That is the whole of it.')],
                ),
                p(
                  classes: 'mx-auto mt-6 max-w-md text-sm leading-relaxed '
                      'text-ink-400',
                  [
                    Component.text(
                      'If any of it sounds like the person your product needs, '
                      'the fastest way to find out is to tell me what your '
                      'users keep coming back for.',
                    ),
                  ],
                ),
              ],
            ),
            div(
              classes: 'reveal mt-10 flex flex-wrap justify-center gap-3',
              [
                CtaButton(
                  label: 'Start a project',
                  href: 'mailto:${SiteConfig.email}',
                ),
                CtaButton(
                  label: 'What I offer',
                  href: RoutePaths.services,
                  variant: CtaVariant.outline,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Meta extends StatelessComponent {
  const _Meta();

  @override
  Component build(BuildContext context) => const PageMeta(
        path: RoutePaths.about,
        title: 'About — ${SiteConfig.name}',
        description: 'Flutter engineer and mobile product designer in Nairobi '
            '— five years of experience, the full mobile lifecycle owned, and '
            'the toolkit, process and roles behind it.',
        type: 'profile',
      );
}
