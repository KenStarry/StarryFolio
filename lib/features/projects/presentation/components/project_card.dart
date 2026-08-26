import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/project_model.dart';
import 'project_cover.dart';

/// The case-study card, used on the home teaser and the projects index.
class ProjectCard extends StatelessComponent {
  const ProjectCard({required this.project, super.key});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    return Link(
      to: RoutePaths.projectDetail(project.slug),
      classes: 'card reveal group flex flex-col',
      children: [
        ProjectCover(project: project),
        div(
          classes: 'flex flex-1 flex-col p-7',
          [
            div(
              classes: 'flex items-baseline justify-between gap-4',
              [
                h3(
                  classes: 'font-display text-lg font-bold tracking-tight '
                      'text-ink-100',
                  [Component.text(project.name)],
                ),
                span(
                  classes: 'font-mono text-[11px] text-ink-500',
                  [Component.text(project.year)],
                ),
              ],
            ),
            p(
              classes: 'mt-2.5 text-sm leading-relaxed text-ink-400',
              [Component.text(project.tagline)],
            ),
            // Pushes the footer down so a row of cards with different tagline
            // lengths still lines its baselines up.
            const div(classes: 'flex-1 min-h-8', []),
            div(
              classes: 'mt-6 flex items-center justify-between border-t '
                  'border-ink-700 pt-5',
              [
                p(
                  classes: 'font-mono text-[11px] text-ink-500',
                  [Component.text(project.stack.take(3).join('  ·  '))],
                ),
                span(
                  classes: 'text-ink-300 transition-transform duration-500 '
                      'ease-soft group-hover:translate-x-1',
                  [AppIcons.arrowUpRight(classes: 'h-4 w-4')],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
