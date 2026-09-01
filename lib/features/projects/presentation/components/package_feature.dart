import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/project_model.dart';

/// One package, wide: artwork on the left, the record on the right.
///
/// Shared by the projects index and the `packages` collection page. It was
/// private to the index until the collection needed the same object, and a
/// second copy would have been two places for this layout to drift apart.
///
/// A library is judged on its maintenance record rather than its screenshots,
/// which is why this leads with `highlights` where a product card leads with a
/// cover.
class PackageFeature extends StatelessComponent {
  const PackageFeature({required this.project});

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
          classes: 'reveal-media group block overflow-hidden bg-ink-850',
          children: [
            if (project.coverImage case final cover?)
              img(
                src: '/$cover',
                alt: '${project.name}, ${project.tagline}',
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
                          [Component.text('·')],
                        ),
                        span([Component.text(line)]),
                      ],
                    ),
                ],
              ),

            div(
              classes: 'mt-9 flex flex-wrap items-center gap-6',
              [
                // Guarded, like every other case-study link on the site. A
                // package without `features` or `modules` generates no detail
                // route, and an unguarded link here would 404 — the index only
                // ever passed this a project that had one, which is exactly
                // how a latent break survives a refactor.
                if (project.hasCaseStudy)
                  Link(
                    to: href,
                    classes: 'link-line type-eyebrow inline-flex items-center '
                        'font-mono text-ink-100',
                    children: const [Component.text('Read the case study →')],
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
