import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../../writing/domain/model/post_model.dart';
import '../../../writing/presentation/components/post_card.dart';
import '../../domain/enum/project_category.dart';
import '../../domain/model/project_model.dart';
import '../components/project_bento.dart';
import '../components/project_showcase.dart';
import '../components/section_jump_nav.dart';

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
    final posts = await Locator.writing.getPosts();

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
        final postList = posts.getOrElse((_) => const []);

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
        var f = 0, b = 0, n = 1;
        while (f < featured.length || b < bands.length) {
          if (f < featured.length) {
            blocks.add(_Showcase(
              project: featured[f],
              index: n++,
              // Every other showcase mirrors, so the eye zig-zags down.
              reversed: f.isOdd,
              raised: n.isEven,
            ));
            f++;
          }
          if (b < bands.length) {
            blocks.add(_CategoryBand(
              category: bands[b].category,
              projects: bands[b].items,
              index: n++,
              raised: n.isEven,
            ));
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
            postCount: postList.length,
          ),
          ...blocks,
          _WritingBand(posts: postList, index: n),
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
    required this.postCount,
  });

  final int count;

  /// The projects grouped into category bands. Drives the category jump pills,
  /// so a pill can never point at an anchor the page did not render.
  final List<ProjectModel> jumpProjects;

  /// Featured projects, which each get their own band anchored on their slug.
  final List<ProjectModel> featured;

  final int postCount;

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
                SectionJumpNav(
                  projects: jumpProjects,
                  featured: featured,
                  postCount: postCount,
                ),
              ],
            ),
          ],
        ),
      ],
    );
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
  });

  final ProjectModel project;
  final int index;
  final bool reversed;
  final bool raised;

  @override
  Component build(BuildContext context) {
    return section(
      id: project.slug,
      classes: 'relative ${raised ? 'bg-ink-800' : 'bg-ink-900'} '
          'py-20 sm:py-28',
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
  });

  final ProjectCategory category;
  final List<ProjectModel> projects;
  final int index;

  /// Alternates the ground so consecutive bands stay visually separate.
  final bool raised;

  @override
  Component build(BuildContext context) {
    return section(
      id: category.slug,
      classes: 'relative ${raised ? 'bg-ink-800' : 'bg-ink-900'} '
          'py-20 sm:py-28',
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

/// Writing. Deliberately the last band and deliberately the odd one out — text
/// cards on the deepest ground, so it reads as a different kind of content
/// rather than more projects.
class _WritingBand extends StatelessComponent {
  const _WritingBand({required this.posts, required this.index});

  final List<PostModel> posts;
  final int index;

  @override
  Component build(BuildContext context) {
    if (posts.isEmpty) return const div([]);

    return section(
      id: 'writing',
      classes: 'relative bg-ink-950 py-20 sm:py-28',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            _BandHeading(
              index: index,
              eyebrow: 'Writing',
              title: 'Notes from the build.',
              lead: 'Occasional posts on Flutter architecture, motion and the '
                  'unglamorous last 10% that decides whether a product feels '
                  'finished.',
              count: posts.length,
              countLabel: posts.length == 1 ? 'post' : 'posts',
            ),
            div(
              classes: 'mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3',
              [
                for (final (i, post) in posts.indexed)
                  PostCard(post: post, index: i),
              ],
            ),
            const div(
              classes: 'reveal mt-14',
              [
                CtaButton(
                  label: 'Start a project',
                  href: 'mailto:${SiteConfig.email}',
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
        path: RoutePaths.projects,
        title: 'Projects — ${SiteConfig.name}',
        description: 'Case studies from the mobile products I have designed and '
            'shipped — enterprise systems, client work and pet projects, with '
            'what was hard in each.',
      );
}
