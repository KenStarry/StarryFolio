import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/model/project_model.dart';

/// A single case study, pre-rendered to `/projects/<slug>/index.html`.
///
/// Takes the slug rather than a resolved model so the route table stays free of
/// content, and this page owns the one read it needs.
class ProjectDetailPage extends AsyncStatelessComponent {
  const ProjectDetailPage({required this.slug, super.key});

  final String slug;

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.projects.getProject(slug);

    return result.fold(
      (error) => article(
        classes: 'mx-auto max-w-3xl px-6 py-20 sm:px-8 sm:py-28',
        [
          PageMeta(
            path: RoutePaths.projectDetail(slug),
            title: 'Project not found — ${SiteConfig.name}',
            description: error,
            noIndex: true,
          ),
          ErrorNotice(message: error),
        ],
      ),
      (project) => _ProjectDetailView(project: project),
    );
  }
}

class _ProjectDetailView extends StatelessComponent {
  const _ProjectDetailView({required this.project});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    return article(
      classes: 'mx-auto max-w-3xl bg-ink-900 px-6 py-20 sm:px-8 sm:py-28',
      [
        PageMeta(
          path: RoutePaths.projectDetail(project.slug),
          title: '${project.name} — ${SiteConfig.name}',
          description: project.tagline,
          image: project.ogImage ?? SiteConfig.defaultOgImage,
          type: 'article',
        ),
        StructuredData(
          id: 'ld-project',
          SchemaOrg.creativeWork(
            name: project.name,
            description: project.tagline,
            slug: project.slug,
            year: project.year,
            keywords: project.stack,
            image: project.ogImage,
            repoUrl: project.repoUrl,
          ),
        ),
        StructuredData(
          id: 'ld-breadcrumbs',
          SchemaOrg.breadcrumbs([
            const (label: 'Home', path: RoutePaths.home),
            const (label: 'Projects', path: RoutePaths.projects),
            (label: project.name, path: RoutePaths.projectDetail(project.slug)),
          ]),
        ),
        const Link(
          to: RoutePaths.projects,
          classes: 'link-line type-eyebrow inline-flex items-center font-mono '
              'text-ink-400 transition-colors hover:text-ink-100',
          children: [Component.text('← All projects')],
        ),
        div(
          classes: 'mt-8 flex flex-wrap items-center gap-4',
          [
            h1(
              classes: 'type-section font-display font-extrabold text-ink-100',
              [Component.text(project.name)],
            ),
            span(
              classes: 'border px-2.5 py-1 font-mono text-[10px] uppercase '
                  'tracking-wider ${project.status.classes}',
              [Component.text(project.status.label)],
            ),
          ],
        ),
        p(
          classes: 'mt-5 max-w-xl text-base leading-relaxed text-ink-300',
          [Component.text(project.tagline)],
        ),
        dl(
          classes: 'mt-12 grid grid-cols-2 gap-6 border-t border-ink-700 pt-8 '
              'sm:grid-cols-3',
          [
            _meta('Year', project.year),
            _meta('Stack', project.stack.join('  ·  ')),
            _meta('Role', 'Design + Flutter'),
          ],
        ),
        div(
          classes: 'mt-14 space-y-5',
          [
            for (final para in project.summary)
              p(
                classes: 'text-base leading-relaxed text-ink-300',
                [Component.text(para)],
              ),
          ],
        ),
        if (project.highlights.isNotEmpty)
          div(
            classes: 'mt-14 border-t border-ink-700 pt-10',
            [
              const h2(
                classes: 'font-display text-xl font-bold text-ink-100',
                [Component.text('Highlights')],
              ),
              ul(
                classes: 'mt-6 space-y-4',
                [
                  for (final point in project.highlights)
                    li(
                      classes: 'flex gap-4 text-base leading-relaxed text-ink-300',
                      [
                        const span(
                          classes: 'mt-2.5 h-px w-5 shrink-0 bg-ink-500',
                          [],
                        ),
                        Component.text(point),
                      ],
                    ),
                ],
              ),
            ],
          ),
        div(
          classes: 'mt-14 flex flex-wrap gap-3',
          [
            if (project.liveUrl != null)
              CtaButton(label: 'Visit site', href: project.liveUrl!),
            if (project.storeUrl != null)
              CtaButton(label: 'Get the app', href: project.storeUrl!),
            if (project.repoUrl != null)
              CtaButton(
                label: 'Source',
                href: project.repoUrl!,
                variant: CtaVariant.outline,
              ),
          ],
        ),
      ],
    );
  }

  Component _meta(String label, String value) => div([
        dt(
          classes: 'type-eyebrow font-mono text-ink-500',
          [Component.text(label)],
        ),
        dd(
          classes: 'mt-2 text-sm text-ink-200',
          [Component.text(value)],
        ),
      ]);
}
