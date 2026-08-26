import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/app_icons.dart';
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
        classes: 'mx-auto max-w-3xl px-5 py-20 sm:px-8 sm:py-28',
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
      classes: 'mx-auto max-w-3xl px-5 py-20 sm:px-8 sm:py-28',
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
          classes: 'inline-flex items-center gap-1.5 font-mono text-xs uppercase '
              'tracking-[0.18em] text-ink-400 transition-colors hover:text-star-500 '
              'dark:hover:text-star-300',
          children: [Component.text('← All projects')],
        ),
        div(
          classes: 'mt-8 flex flex-wrap items-center gap-3',
          [
            h1(
              classes: 'font-display text-4xl font-semibold tracking-tight '
                  'text-ink-900 sm:text-5xl dark:text-ink-50',
              [Component.text(project.name)],
            ),
            span(
              classes: 'rounded-full px-2.5 py-1 font-mono text-[10px] uppercase '
                  'tracking-wider ${project.status.classes}',
              [Component.text(project.status.label)],
            ),
          ],
        ),
        p(
          classes: 'mt-4 text-lg text-ink-500 dark:text-ink-300',
          [Component.text(project.tagline)],
        ),
        const div(
          classes: 'mt-8 h-px w-full bg-gradient-to-r from-star-400/60 to-transparent',
          [],
        ),
        dl(
          classes: 'mt-8 grid grid-cols-2 gap-6 sm:grid-cols-3',
          [
            _meta('Year', project.year),
            _meta('Stack', project.stack.join(' · ')),
            _meta('Role', 'Design + Flutter'),
          ],
        ),
        div(
          classes: 'mt-12 space-y-5',
          [
            for (final para in project.summary)
              p(
                classes: 'text-base leading-relaxed text-ink-600 dark:text-ink-300',
                [Component.text(para)],
              ),
          ],
        ),
        if (project.highlights.isNotEmpty)
          div(
            classes: 'mt-12',
            [
              const h2(
                classes: 'font-display text-xl font-semibold text-ink-900 dark:text-ink-50',
                [Component.text('Highlights')],
              ),
              ul(
                classes: 'mt-4 space-y-3',
                [
                  for (final point in project.highlights)
                    li(
                      classes: 'flex gap-3 text-base leading-relaxed text-ink-600 '
                          'dark:text-ink-300',
                      [
                        const span(
                          classes: 'mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-star-400',
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
          classes: 'mt-12 flex flex-wrap gap-3',
          [
            if (project.liveUrl != null)
              _linkButton('Visit site', project.liveUrl!, primary: true),
            if (project.storeUrl != null)
              _linkButton('Get the app', project.storeUrl!, primary: true),
            if (project.repoUrl != null) _linkButton('Source', project.repoUrl!),
          ],
        ),
      ],
    );
  }

  Component _meta(String label, String value) => div([
        dt(
          classes: 'font-mono text-[11px] uppercase tracking-[0.18em] text-ink-400',
          [Component.text(label)],
        ),
        dd(
          classes: 'mt-1 text-sm text-ink-700 dark:text-ink-200',
          [Component.text(value)],
        ),
      ]);

  Component _linkButton(String label, String href, {bool primary = false}) => a(
        href: href,
        target: Target.blank,
        attributes: const {'rel': 'noopener'},
        classes: primary
            ? 'inline-flex items-center gap-2 rounded-full bg-ink-900 px-5 py-2.5 '
                'text-sm font-medium text-ink-50 transition-transform duration-300 '
                'ease-expo hover:-translate-y-0.5 dark:bg-star-400 dark:text-ink-950'
            : 'inline-flex items-center gap-2 rounded-full border border-ink-200 '
                'px-5 py-2.5 text-sm font-medium text-ink-700 transition-colors '
                'hover:border-star-400 hover:text-star-500 dark:border-ink-700 '
                'dark:text-ink-200 dark:hover:text-star-300',
        [Component.text(label), AppIcons.arrow()],
      );
}
