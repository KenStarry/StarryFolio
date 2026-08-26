import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/company_marquee.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/section_rail.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/enum/project_category.dart';
import '../../domain/model/project_model.dart';
import '../components/project_bento.dart';
import '../components/project_showcase.dart';
import '../../../../core/presentation/components/jump_nav.dart';

/// The projects index.
///
/// An [AsyncStatelessComponent] so the repositories are awaited *during*
/// pre-rendering — the generated HTML contains every card. Reaching for a
/// Riverpod async provider here instead would ship a loading state to crawlers.
///
/// The page is a sequence of distinct, numbered bands rather than one long
/// grid: a full-width feature, then one section per [ProjectCategory] carrying
/// its own title and standfirst, then writing. Section copy lives on the enum,
/// so adding a category cannot produce an unlabelled band.
///
/// The category pills that used to sit here are gone — with every group given
/// its own titled section, a filter would be a second way to do the same job.
class ProjectsPage extends AsyncStatelessComponent {
  const ProjectsPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.projects.getProjects();

    return result.fold(
      (error) => Component.fragment([
        const _Meta(),
        SectionBlock(
          eyebrow: 'Work',
          heading: 'Projects',
          isPageHeading: true,
          children: [ErrorNotice(message: error)],
        ),
      ]),
      (projects) {

        // A featured project needs a mockup — the flat showcase is built around
        // one and has nothing to render without it. Anything flagged but
        // missing its render falls back to a card in its category grid rather
        // than producing an empty band.
        final featured = projects
            .where((item) => item.featured && item.mockupImage != null)
            .toList(growable: false);

        final rest =
            projects.where((item) => !featured.contains(item)).toList(growable: false);

        // Only categories that actually have projects get a band, so the page
        // can never render an empty titled section.
        final bands = [
          for (final cat in ProjectCategory.values)
            (
              category: cat,
              items:
                  rest.where((item) => item.category == cat).toList(growable: false)
            ),
        ].where((band) => band.items.isNotEmpty).toList(growable: false);

        // Alternate showcase, grid, showcase, grid… then whatever is left over.
        // Interleaving is what stops the page reading as one feature followed
        // by a long uniform tail.
        final blocks = <Component>[];
        final stops = <RailStop>[];
        var f = 0, b = 0, n = 1;

        // `tl-N` classes come from a fixed pool in the stylesheet, since CSS
        // timeline names cannot be generated at runtime. Past the pool a band
        // still renders — its rail dot just does not self-highlight.
        String slot() => blocks.length < SectionRail.maxTracked
            ? 'tl-${blocks.length + 1}'
            : '';

        while (f < featured.length || b < bands.length) {
          if (f < featured.length) {
            final item = featured[f];
            blocks.add(_Showcase(
              project: item,
              index: n++,
              // Every other showcase mirrors, so the eye zig-zags down.
              reversed: f.isOdd,
              raised: n.isEven,
              timeline: slot(),
            ));
            stops.add((anchor: item.slug, label: item.name));
            f++;
          }
          if (b < bands.length) {
            final band = bands[b];
            blocks.add(_CategoryBand(
              category: band.category,
              projects: band.items,
              index: n++,
              raised: n.isEven,
              timeline: slot(),
            ));
            stops.add((anchor: band.category.slug, label: band.category.title));
            b++;
          }
        }

        return Component.fragment([
          const _Meta(),
          StructuredData(
            id: 'ld-projects',
            SchemaOrg.itemList(
              items: [for (final item in projects) (name: item.name, slug: item.slug)],
            ),
          ),
          StructuredData(
            id: 'ld-breadcrumbs',
            SchemaOrg.breadcrumbs(const [
              (label: 'Home', path: RoutePaths.home),
              (label: 'Projects', path: RoutePaths.projects),
            ]),
          ),

          _Header(
            count: projects.length,
            jumpProjects: rest,
            featured: featured,
          ),
          // `timeline-scope` publishes the bands' timeline names to this
          // element's **subtree** only — so the rail has to live inside the
          // same wrapper as the bands, not beside it, or its dots would
          // reference names they cannot see. The rail is `position: fixed` and
          // this wrapper sets no transform or filter, so nesting it here does
          // not change where it renders.
          div(
            classes: 'rail-scope',
            [
              ...blocks,
              SectionRail(stops: stops, path: RoutePaths.projects),
            ],
          ),
        ]);
      },
    );
  }
}

/// A numbered heading shared by every band, so the page reads as one sequence.
class _BandHeading extends StatelessComponent {
  const _BandHeading({
    required this.index,
    required this.eyebrow,
    required this.title,
    required this.lead,
    required this.count,
    required this.countLabel,
  });

  final int index;
  final String eyebrow;
  final String title;
  final String lead;
  final int count;
  final String countLabel;

  @override
  Component build(BuildContext context) {
    return div([
      div(
        classes: 'reveal flex items-start justify-between gap-8',
        [
          div(
            classes: 'max-w-xl',
            [
              Eyebrow(eyebrow),
              h2(
                classes: 'type-section mt-5 font-display font-bold '
                    'text-ink-100',
                [Component.text(title)],
              ),
              p(
                classes: 'mt-5 text-sm leading-relaxed text-ink-400 '
                    'sm:text-[0.9375rem]',
                [Component.text(lead)],
              ),
            ],
          ),
          // The band number. Hidden on small screens — at that width it
          // competes with the heading instead of framing it.
          div(
            classes: 'hidden shrink-0 text-right sm:block',
            [
              p(
                classes: 'font-display text-5xl font-extrabold leading-none '
                    'text-ink-800',
                [Component.text(index.toString().padLeft(2, '0'))],
              ),
              p(
                classes: 'type-eyebrow mt-3 font-mono text-ink-500',
                [Component.text('$count $countLabel')],
              ),
            ],
          ),
        ],
      ),
      const div(classes: 'divider mt-12', []),
    ]);
  }
}

/// Page header. Owns the `<h1>`, and carries the counts as a small stat rail so
/// the top of the page has something to look at besides type.
class _Header extends StatelessComponent {
  const _Header({
    required this.count,
    required this.jumpProjects,
    required this.featured,
  });

  final int count;

  /// The projects grouped into category bands. Drives the category jump pills,
  /// so a pill can never point at an anchor the page did not render.
  final List<ProjectModel> jumpProjects;

  /// Featured projects, which each get their own band anchored on their slug.
  final List<ProjectModel> featured;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'bg-ink-900 pb-16 pt-16 sm:pb-20 sm:pt-24',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const div(
              classes: 'reveal max-w-2xl',
              [
                Eyebrow('Work'),
                h1(
                  classes: 'type-section mt-5 font-display font-extrabold '
                      'text-ink-100',
                  [
                    Component.text('All creative works,'),
                    br(),
                    Component.text('selected projects.'),
                  ],
                ),
                p(
                  classes: 'mt-6 max-w-lg text-sm leading-relaxed text-ink-400 '
                      'sm:text-[0.9375rem]',
                  [
                    Component.text(
                      'Everything worth showing, grouped by what it was built '
                      'for. Each one has a short case study — what it does, '
                      'what was hard, and what I would redo given another pass.',
                    ),
                  ],
                ),
              ],
            ),
            const div(classes: 'divider mt-12', []),
            div(
              classes: 'reveal mt-8 flex flex-wrap items-center gap-x-10 gap-y-4',
              [
                _stat(count.toString().padLeft(2, '0'), 'case studies'),
                _stat('02', 'app stores'),
                _stat('5+', 'years shipping'),
              ],
            ),
            div(
              classes: 'mt-10',
              [
                JumpNav(path: RoutePaths.projects, stops: _stops()),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Flagships lead, since they are what the page is built around, then the
  /// categories that actually rendered a band.
  List<JumpStop> _stops() {
    final counts = <ProjectCategory, int>{};
    for (final item in jumpProjects) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    return [
      for (final item in featured)
        (anchor: item.slug, label: item.name, count: 0),
      for (final cat in ProjectCategory.values)
        if (counts.containsKey(cat))
          (anchor: cat.slug, label: cat.title, count: counts[cat]!),
    ];
  }

  static Component _stat(String value, String label) => div(
        classes: 'flex items-baseline gap-3',
        [
          span(
            classes: 'font-display text-2xl font-extrabold text-ink-100',
            [Component.text(value)],
          ),
          span(
            classes: 'type-eyebrow font-mono text-ink-500',
            [Component.text(label)],
          ),
        ],
      );
}

/// A featured project, presented flat on its own band.
class _Showcase extends StatelessComponent {
  const _Showcase({
    required this.project,
    required this.index,
    required this.reversed,
    required this.raised,
    required this.timeline,
  });

  final ProjectModel project;
  final int index;
  final bool reversed;
  final bool raised;

  /// `tl-N` utility naming this band's view-timeline, which the matching rail
  /// dot animates on.
  final String timeline;

  @override
  Component build(BuildContext context) {
    return section(
      id: project.slug,
      classes: '$timeline relative '
          '${raised ? 'bg-ink-800' : 'bg-ink-900'} py-20 sm:py-28',
      [
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            _BandHeading(
              index: index,
              eyebrow: 'Featured',
              title: project.name,
              lead: project.tagline,
              count: 1,
              countLabel: 'flagship',
            ),
            div(
              classes: 'mt-16',
              [ProjectShowcase(project: project, reversed: reversed)],
            ),
          ],
        ),
      ],
    );
  }
}

/// One titled band per project category.
class _CategoryBand extends StatelessComponent {
  const _CategoryBand({
    required this.category,
    required this.projects,
    required this.index,
    required this.raised,
    required this.timeline,
  });

  final ProjectCategory category;
  final List<ProjectModel> projects;
  final int index;

  /// `tl-N` utility naming this band's view-timeline.
  final String timeline;

  /// Alternates the ground so consecutive bands stay visually separate.
  final bool raised;

  @override
  Component build(BuildContext context) {
    return section(
      id: category.slug,
      classes: '$timeline relative '
          '${raised ? 'bg-ink-800' : 'bg-ink-900'} py-20 sm:py-28',
      [
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            _BandHeading(
              index: index,
              eyebrow: category.label,
              title: category.title,
              lead: category.lead,
              count: projects.length,
              countLabel: projects.length == 1 ? 'project' : 'projects',
            ),

            // The enterprise band gets the client strip: the names are the
            // credential the section's projects are trading on, so they belong
            // above the work rather than buried in an about page.
            if (category == ProjectCategory.enterprise) ...[
              const div(
                classes: 'reveal mt-12 flex items-center gap-4',
                [
                  span(
                    classes: 'type-eyebrow shrink-0 font-mono text-ink-500',
                    [Component.text('Built for')],
                  ),
                  span(classes: 'h-px flex-1 bg-ink-700', []),
                ],
              ),
              const div(
                classes: 'reveal mt-6',
                [CompanyMarquee()],
              ),
            ],

            div(
              classes: 'mt-12',
              [ProjectBento(projects: projects)],
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
        path: RoutePaths.projects,
        title: 'Projects — ${SiteConfig.name}',
        description: 'Case studies from the mobile products I have designed and '
            'shipped — enterprise systems, client work and pet projects, with '
            'what was hard in each.',
      );
}
