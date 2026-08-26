import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/page_header.dart';
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

/// Page header, on the shared [PageHeader] template.
///
/// The one page whose header carries an aside — the dossier answers *who* while
/// the title is still saying *what* — and the numbers come straight off the
/// profile, so a role added to the datasource moves the count without anyone
/// remembering to.
class _Header extends StatelessComponent {
  const _Header({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return PageHeader(
      trail: 'About',
      ghost: 'About',
      path: RoutePaths.about,
      meta: '${SiteConfig.location} · UTC+3',
      title: '${SiteConfig.name},',
      titleTail: 'end to end.',
      lead: 'A Flutter engineer who owns the whole surface — design system, '
          'architecture, release. This is the long version: the roles, the '
          'tools, the process, and the part that is not work.',
      aside: AboutDossier(
        currentCompany: profile.currentRole?.company ?? '',
      ),
      facts: [
        (value: '5+', label: 'Years in Flutter'),
        (
          value: profile.experience.length.toString().padLeft(2, '0'),
          label: 'Roles held',
        ),
        (value: '02', label: 'App stores'),
        (value: '100%', label: 'Of the stack owned'),
      ],
      jumpStops: [
        for (final stop in AboutPage._stops)
          (anchor: stop.anchor, label: stop.label, count: 0),
      ],
    );
  }
}

/// The statement band.
///
/// Centred, and deliberately short. The header above it already carries the
/// dossier, four numbers and a standfirst; repeating the stats here — as the
/// first pass did — made the page open by saying the same thing three times in
/// three type sizes. What is left is the one line the work is actually built
/// on, and a single paragraph under it.
class _Story extends StatelessComponent {
  const _Story({required this.profile});

  final AboutProfile profile;

  @override
  Component build(BuildContext context) {
    return section(
      id: 'story',
      classes: 'relative tl-1 bg-ink-800 py-24 sm:py-28',
      [
        div(
          classes: 'mx-auto w-full max-w-3xl px-6 text-center sm:px-8',
          [
            const div(
              classes: 'reveal mx-auto flex w-fit',
              [Eyebrow('What I care about')],
            ),

            const p(
              classes: 'reveal type-quote mt-8 font-display font-semibold '
                  'text-ink-100',
              [Component.text(SiteConfig.pullQuote)],
            ),

            p(
              classes: 'reveal mx-auto mt-7 max-w-xl text-sm leading-relaxed '
                  'text-ink-400',
              [Component.text(SiteConfig.bio.first)],
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
      heading: 'Where the work',
      headingTail: 'actually happened.',
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
      heading: 'The fundamentals',
      headingTail: 'that do not expire.',
      children: [
        for (final school in profile.education)
          EducationCard(education: school),
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
      heading: 'What I reach for,',
      headingTail: 'and how deep it goes.',
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
      heading: 'Four steps, and',
      headingTail: 'what each hands over.',
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
      heading: 'The road',
      headingTail: 'so far.',
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
      heading: 'The part that',
      headingTail: 'is not work.',
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
