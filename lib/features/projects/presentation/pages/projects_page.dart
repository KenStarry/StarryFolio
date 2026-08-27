import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/company_marquee.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/page_header.dart';
import '../../../../core/presentation/components/section_rail.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/enum/project_category.dart';
import '../../domain/enum/project_kind.dart';
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
        // The two kinds are laid out separately. A package has no device
        // render and no store listing, so it cannot go through the showcase
        // and would sit oddly in a band titled by audience — see
        // [ProjectKind].
        final products = projects
            .where((item) => item.kind == ProjectKind.product)
            .toList(growable: false);
        final packages = projects
            .where((item) => item.kind == ProjectKind.package)
            .toList(growable: false);

        final featured = products
            .where((item) => item.featured && item.mockupImage != null)
            .toList(growable: false);

        final rest =
            products.where((item) => !featured.contains(item)).toList(growable: false);

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

        // Appended after the interleave, so open source always closes the
        // page rather than landing wherever the alternation happened to stop.
        if (packages.isNotEmpty) {
          blocks.add(_KindBand(
            kind: ProjectKind.package,
            projects: packages,
            index: n++,
            raised: n.isEven,
            timeline: slot(),
          ));
          stops.add((
            anchor: ProjectKind.package.slug,
            label: ProjectKind.package.label,
          ));
        }

        return Component.fragment([
          const _Meta(),
          StructuredData(
            id: 'ld-projects',
            // Only projects with a generated page. An ItemList entry pointing
            // at a URL that does not exist is a soft-404 handed straight to a
            // crawler.
            SchemaOrg.itemList(
              items: [
                for (final item in projects)
                  if (item.hasCaseStudy) (name: item.name, slug: item.slug),
              ],
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
    return PageHeader(
      trail: 'Work',
      ghost: 'Work',
      path: RoutePaths.projects,
      meta: '${featured.length} featured',
      title: 'All creative works,',
      titleTail: 'selected projects.',
      lead: 'Everything worth showing, grouped by what it was built for. Each '
          'one has a short case study — what it does, what was hard, and what '
          'I would redo given another pass.',
      facts: [
        (value: count.toString().padLeft(2, '0'), label: 'Case studies'),
        (
          value: featured.length.toString().padLeft(2, '0'),
          label: 'Flagships',
        ),
        (value: '02', label: 'App stores'),
        (value: '5+', label: 'Years shipping'),
      ],
      jumpStops: _stops(),
      jumpLabel: 'Jump to a section',
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


/// The open-source band.
///
/// Deliberately not a [_CategoryBand] with a different title. A package has no
/// device render, no store listing and no client, so the things a product card
/// leads with are all absent — and a bento of one card reads as an
/// afterthought rather than as a section.
///
/// A single package therefore gets a wide two-column card: its artwork beside
/// what actually distinguishes it, which for a library is the maintenance
/// record rather than the screens. Two or more fall back to the shared bento,
/// where the grid does the work again.
class _KindBand extends StatelessComponent {
  const _KindBand({
    required this.kind,
    required this.projects,
    required this.index,
    required this.raised,
    required this.timeline,
  });

  final ProjectKind kind;
  final List<ProjectModel> projects;
  final int index;
  final String timeline;
  final bool raised;

  @override
  Component build(BuildContext context) {
    final solo = projects.length == 1 ? projects.first : null;

    return section(
      id: kind.slug,
      classes: '$timeline relative '
          '${raised ? 'bg-ink-800' : 'bg-ink-900'} py-20 sm:py-28',
      [
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            _BandHeading(
              index: index,
              eyebrow: kind.label,
              title: kind.title,
              lead: kind.lead,
              count: projects.length,
              countLabel: projects.length == 1 ? 'package' : 'packages',
            ),

            div(
              classes: 'mt-12',
              [
                if (solo != null)
                  _PackageFeature(project: solo)
                else
                  ProjectBento(projects: projects),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// One package, wide: artwork on the left, the record on the right.
class _PackageFeature extends StatelessComponent {
  const _PackageFeature({required this.project});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    final href = RoutePaths.projectDetail(project.slug);

    return div(
      classes: 'float-card reveal grid overflow-hidden border border-ink-700 '
          'bg-ink-900 lg:grid-cols-[1.1fr_1fr]',
      [
        Link(
          to: href,
          classes: 'group block overflow-hidden bg-ink-850',
          children: [
            if (project.coverImage case final cover?)
              img(
                src: '/$cover',
                alt: '${project.name} — ${project.tagline}',
                classes: 'h-full w-full object-cover transition-transform '
                    'duration-700 ease-soft group-hover:scale-[1.03]',
                attributes: const {'loading': 'lazy', 'decoding': 'async'},
              ),
          ],
        ),

        div(
          classes: 'flex flex-col justify-center p-8 sm:p-10',
          [
            div(
              classes: 'flex flex-wrap items-center gap-3',
              [
                span(
                  classes: 'type-eyebrow font-mono text-iris-400',
                  [Component.text(kindEyebrow(project))],
                ),
                const span(classes: 'h-px w-8 bg-ink-600', []),
                span(
                  classes: 'border px-2.5 py-1 font-mono text-[10px] '
                      'uppercase tracking-wider ${project.status.classes}',
                  [Component.text(project.status.label)],
                ),
              ],
            ),

            h3(
              classes: 'mt-6 font-display text-2xl font-extrabold '
                  'tracking-tight text-ink-100 sm:text-3xl',
              [
                Link(
                  to: href,
                  classes: 'transition-colors duration-300 '
                      'hover:text-iris-300',
                  children: [Component.text(project.name)],
                ),
              ],
            ),

            p(
              classes: 'mt-4 text-[0.9375rem] leading-relaxed text-ink-300',
              [Component.text(project.tagline)],
            ),

            // The maintenance record — what a library is judged on, and the
            // part a product card has no slot for.
            if (project.highlights.isNotEmpty)
              ul(
                classes: 'mt-8 space-y-2.5',
                [
                  for (final line in project.highlights.take(3))
                    li(
                      classes: 'flex gap-3 text-sm leading-relaxed text-ink-400',
                      [
                        const span(
                          classes: 'shrink-0 pt-1.5 font-mono text-iris-400',
                          attributes: {'aria-hidden': 'true'},
                          [Component.text('—')],
                        ),
                        span([Component.text(line)]),
                      ],
                    ),
                ],
              ),

            div(
              classes: 'mt-9 flex flex-wrap items-center gap-6',
              [
                Link(
                  to: href,
                  classes: 'link-line type-eyebrow inline-flex items-center '
                      'font-mono text-ink-100',
                  children: [const Component.text('Read the case study →')],
                ),
                for (final link in project.links)
                  a(
                    href: link.url,
                    target: Target.blank,
                    attributes: const {'rel': 'noopener'},
                    classes: 'type-eyebrow inline-flex items-center gap-2 '
                        'font-mono text-ink-400 transition-colors '
                        'hover:text-ink-100',
                    [
                      AppIcons.byName(link.type.icon, classes: 'h-4 w-4'),
                      Component.text(link.label ?? link.type.title),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// The platform line, since a package that runs everywhere is worth saying
  /// out loud — it is the practical difference from every app on this page.
  static String kindEyebrow(ProjectModel project) =>
      project.platforms.length >= 4
          ? 'Every Flutter platform'
          : project.platforms.map((item) => item.label).join(' · ');
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
