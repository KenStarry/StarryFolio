import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/store_badge.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/project_model.dart';
import 'project_cover.dart';

/// A large, boxy, floating case-study card.
///
/// **Every card is the same size, everywhere.** The cover ratio and the caption
/// scale are fixed here rather than exposed as parameters, so no caller can
/// reintroduce size variation. What varies between layouts is position —
/// [classes] takes grid placement and stagger offsets, and nothing else.
///
/// The card is an `<article>`, not a link. Products that ship to a store carry
/// their own store links in the footer, and an `<a>` cannot legally contain
/// another `<a>` — browsers close the outer one early and the layout falls
/// apart. Instead the title is the real link and `.stretch-link` pulls its hit
/// area over the whole card, while the badges sit above it on `z-index`. One
/// clearly-named card link, plus separately-named store links.
class ProjectCard extends StatelessComponent {
  const ProjectCard({
    required this.project,
    this.classes = '',
    super.key,
  });

  final ProjectModel project;

  /// Placement only — grid column, stagger offset, reveal. Never sizing.
  final String classes;

  /// The one cover ratio on the site. 4:3 rather than a portrait crop: with a
  /// caption panel underneath, a tall cover made the whole card elongated.
  static const String _coverAspect = 'aspect-[4/3]';

  @override
  Component build(BuildContext context) {
    final links = project.links;

    return article(
      // The card is a jump target. Collection pages list every project in
      // their jump nav, and only the full-width showcase bands carried an id
      // — so a pill for anything in the grid pointed at nothing and silently
      // did nothing. `scroll-mt` clears the sticky nav on arrival, matching
      // every other anchored element on the site.
      id: project.slug,
      classes: 'float-card group relative flex flex-col scroll-mt-28 '
          'overflow-hidden '
          'border border-ink-700 bg-ink-800 $classes',
      attributes: {'data-cat': project.category.slug},
      [
        // ── Cover ──
        div(
          classes: 'relative w-full overflow-hidden $_coverAspect',
          [
            ProjectCover(project: project, fill: true),
            span(
              classes: 'absolute left-4 top-4 z-10 border bg-ink-900/70 '
                  'px-2.5 py-1 font-mono text-[10px] uppercase tracking-wider '
                  'backdrop-blur-sm ${project.status.classes}',
              [Component.text(project.status.label)],
            ),
          ],
        ),

        // ── Caption panel ──
        div(
          classes: 'flex flex-1 flex-col border-t border-ink-700 p-6 sm:p-7',
          [
            div(
              classes: 'flex items-center gap-3',
              [
                span(
                  classes: 'type-eyebrow truncate font-mono text-iris-400',
                  // The client is the credential; the category is already the
                  // band heading this card sits under, so repeating it here
                  // spends the line on something the reader already knows.
                  [Component.text(project.client ?? project.category.label)],
                ),
                const span(classes: 'h-px flex-1 bg-ink-700', []),
                if (project.year.isNotEmpty)
                  span(
                    classes: 'shrink-0 font-mono text-[11px] text-ink-500',
                    [Component.text(project.year)],
                  ),
              ],
            ),

            h3(
              classes: 'mt-4 font-display text-xl font-extrabold '
                  'tracking-tight text-ink-100 sm:text-2xl',
              [
                // Linked only when there is a case study to reach. Without one
                // the stretched hit area would cover the whole card and lead
                // to a page saying less than the card already does — and the
                // route is not generated for those projects anyway.
                if (project.hasCaseStudy)
                  Link(
                    to: RoutePaths.projectDetail(project.slug),
                    classes: 'stretch-link inline-flex items-center gap-2 '
                        'transition-colors duration-300 '
                        'hover:text-iris-300 group-hover:text-iris-300',
                    children: [
                      Component.text(project.name),
                      span(
                        classes: 'text-ink-500 transition-transform '
                            'duration-500 ease-soft group-hover:translate-x-1 '
                            'group-hover:text-iris-300',
                        [AppIcons.arrowUpRight(classes: 'h-4 w-4')],
                      ),
                    ],
                  )
                else
                  Component.text(project.name),
              ],
            ),

            p(
              classes: 'mt-2.5 text-sm leading-relaxed text-ink-400',
              [Component.text(project.tagline)],
            ),

            // Holds the footer on the card's floor so a row of cards with
            // different tagline lengths still shares one baseline.
            const div(classes: 'flex-1 min-h-6', []),

            if (links.isEmpty)
              p(
                classes: 'mt-6 font-mono text-[11px] text-ink-500',
                // Falls back to the platforms when the stack is not recorded,
                // so the footer is never an empty line.
                [
                  Component.text(
                    project.stack.isNotEmpty
                        ? project.stack.take(3).join('  ·  ')
                        : project.platforms.map((e) => e.label).join('  ·  '),
                  ),
                ],
              )
            else
              StoreBadgeRow(
                links: links,
                product: project.name,
                compact: true,
                // Two is what fits at card width; the rest stay reachable on
                // the case-study page.
                limit: 2,
                classes: 'mt-6',
              ),
          ],
        ),
      ],
    );
  }
}
