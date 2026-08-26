import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/project_model.dart';
import 'project_cover.dart';

/// The full-width hero card that opens the projects page.
///
/// A wide asymmetric split — cover on the larger column, copy on the smaller —
/// so it reads as a different *kind* of object from the bento cards below it
/// rather than just a bigger one. Same flat anatomy: solid panel, hairline
/// divider, no scrim.
class ProjectFeatureCard extends StatelessComponent {
  const ProjectFeatureCard({required this.project, super.key});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    return Link(
      to: RoutePaths.projectDetail(project.slug),
      classes: 'float-card group grid overflow-hidden border border-ink-700 '
          'bg-ink-800 lg:grid-cols-[1.35fr_1fr]',
      attributes: {'data-cat': project.category.slug},
      children: [
        div(
          classes: 'relative min-h-[18rem] lg:min-h-[32rem]',
          [
            ProjectCover(project: project, fill: true),
            span(
              classes: 'absolute left-5 top-5 z-10 border bg-ink-900/70 '
                  'px-2.5 py-1 font-mono text-[10px] uppercase tracking-wider '
                  'backdrop-blur-sm ${project.status.classes}',
              [Component.text(project.status.label)],
            ),
          ],
        ),

        div(
          classes: 'flex flex-col justify-center border-t border-ink-700 p-8 '
              'sm:p-11 lg:border-l lg:border-t-0 lg:p-14',
          [
            div(
              classes: 'flex items-center gap-3',
              [
                const span(
                  classes: 'type-eyebrow font-mono text-iris-400',
                  [Component.text('Featured')],
                ),
                const span(classes: 'h-px flex-1 bg-ink-700', []),
                span(
                  classes: 'font-mono text-[11px] text-ink-500',
                  [Component.text(project.category.label)],
                ),
              ],
            ),

            h2(
              classes: 'mt-7 font-display text-3xl font-extrabold '
                  'tracking-tight text-ink-100 transition-colors duration-300 '
                  'group-hover:text-iris-300 sm:text-5xl',
              [Component.text(project.name)],
            ),

            p(
              classes: 'mt-4 text-base leading-snug text-ink-200 sm:text-lg',
              [Component.text(project.tagline)],
            ),

            if (project.summary.isNotEmpty)
              p(
                classes: 'mt-6 max-w-md text-sm leading-relaxed text-ink-400',
                [Component.text(project.summary.first)],
              ),

            div(
              classes: 'mt-8 flex flex-wrap gap-2',
              [
                for (final tech in project.stack)
                  span(classes: 'pill', [Component.text(tech)]),
              ],
            ),

            div(
              classes: 'mt-10 flex items-center gap-2.5 text-sm font-medium '
                  'text-ink-200 transition-colors duration-300 '
                  'group-hover:text-iris-300',
              [
                const Component.text('Read the case study'),
                span(
                  classes: 'transition-transform duration-500 ease-soft '
                      'group-hover:translate-x-1.5',
                  [AppIcons.arrow()],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
