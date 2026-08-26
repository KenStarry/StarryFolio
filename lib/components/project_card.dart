import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../models/project.dart';
import 'icons.dart';

class ProjectCard extends StatelessComponent {
  const ProjectCard({required this.project, super.key});

  final Project project;

  @override
  Component build(BuildContext context) {
    return Link(
      to: '/projects/${project.slug}',
      classes: 'group relative flex flex-col overflow-hidden rounded-2xl border '
          'border-ink-200/70 bg-white/60 transition-all duration-500 ease-expo '
          'hover:-translate-y-1 hover:border-star-400/60 hover:shadow-xl '
          'hover:shadow-star-400/5 '
          'dark:border-ink-800 dark:bg-ink-900/50 dark:hover:border-star-400/40',
      children: [
        // Gradient header — swap for a real screenshot via project.coverImage.
        div(
          classes: 'relative h-36 w-full bg-gradient-to-br ${project.gradient}',
          [
            if (project.coverImage != null)
              img(
                src: '/${project.coverImage}',
                alt: '${project.name} screenshot',
                classes: 'h-full w-full object-cover',
              )
            else
              const div(
                classes: 'starfield absolute inset-0 opacity-70',
                [],
              ),
          ],
        ),
        div(
          classes: 'flex flex-1 flex-col p-6',
          [
            div(
              classes: 'flex items-center gap-3',
              [
                h3(
                  classes: 'font-display text-lg font-semibold tracking-tight '
                      'text-ink-900 dark:text-ink-50',
                  [Component.text(project.name)],
                ),
                span(
                  classes: 'rounded-full px-2 py-0.5 font-mono text-[10px] '
                      'uppercase tracking-wider ${project.status.classes}',
                  [Component.text(project.status.label)],
                ),
              ],
            ),
            p(
              classes: 'mt-2 text-sm leading-relaxed text-ink-500 dark:text-ink-300',
              [Component.text(project.tagline)],
            ),
            div(
              classes: 'mt-5 flex flex-wrap gap-2',
              [
                for (final tech in project.stack.take(4))
                  span(
                    classes: 'rounded-md bg-ink-100 px-2 py-1 font-mono text-[11px] '
                        'text-ink-500 dark:bg-ink-800 dark:text-ink-300',
                    [Component.text(tech)],
                  ),
              ],
            ),
            div(
              classes: 'mt-6 flex items-center gap-1.5 text-sm font-medium '
                  'text-star-500 dark:text-star-400',
              [
                const Component.text('Case study'),
                span(
                  classes: 'transition-transform duration-300 group-hover:translate-x-1',
                  [Icons.arrow()],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
