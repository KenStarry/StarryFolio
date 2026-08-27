import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../../core/presentation/components/store_badge.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/model/project_feature.dart';
import '../../domain/model/project_model.dart';
import '../components/project_feature_spotlight.dart';
import '../components/project_module_band.dart';

/// A single case study, pre-rendered to `/projects/<slug>/index.html`.
///
/// Takes the slug rather than a resolved model so the route table stays free of
/// content, and this page owns the one read it needs. It also reads the full
/// list, which costs nothing from a local source and is what lets the page end
/// by handing the reader the next case study rather than a dead end.
class ProjectDetailPage extends AsyncStatelessComponent {
  const ProjectDetailPage({required this.slug, super.key});

  final String slug;

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.projects.getProject(slug);
    final all = await Locator.projects.getProjects();

    return result.fold(
      (error) => section(
        classes: 'bg-ink-900 py-28 sm:py-36',
        [
          PageMeta(
            path: RoutePaths.projectDetail(slug),
            title: 'Project not found — ${SiteConfig.name}',
            description: error,
            noIndex: true,
          ),
          div(
            classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
            [ErrorNotice(message: error)],
          ),
        ],
      ),
      (project) {
        // Only projects that actually have a page. Walking the full list here
        // sent HealthX to CribLynk and Flow to EduFlow — routes that are no
        // longer generated, so the handoff was a 404.
        final list = all
            .getOrElse((_) => const [])
            .where((item) => item.hasCaseStudy)
            .toList(growable: false);
        final index = list.indexWhere((item) => item.slug == project.slug);
        // Wraps, so the last case study leads back to the first instead of
        // ending the journey.
        final next = list.length > 1 && index >= 0
            ? list[(index + 1) % list.length]
            : null;
        return _CaseStudy(project: project, next: next);
      },
    );
  }
}

class _CaseStudy extends StatelessComponent {
  const _CaseStudy({required this.project, this.next});

  final ProjectModel project;
  final ProjectModel? next;

  @override
  Component build(BuildContext context) {
    return article([
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

      _Hero(project: project),
      if (project.summary.isNotEmpty) _Overview(project: project),

      // Modules take precedence: a product described as two worlds should not
      // also present a flattened feature list.
      if (project.modules.isNotEmpty) ...[
        _ModulesIntro(project: project),
        for (final (i, module) in project.modules.indexed)
          ProjectModuleBand(
            module: module,
            index: i,
            // Alternates, and starts raised so it separates from the intro
            // band above it.
            raised: i.isEven,
          ),
      ] else if (project.features.isNotEmpty)
        _Features(project: project),

      if (project.highlights.isNotEmpty) _UnderTheHood(project: project),
      if (next != null) _NextUp(project: next!),
    ]);
  }
}

/// Opening band: identity, meta and the store CTAs, beside the device.
class _Hero extends StatelessComponent {
  const _Hero({required this.project});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    final mockup = project.mockupImage;

    return section(
      classes: 'relative bg-ink-900 pb-20 pt-12 sm:pb-28 sm:pt-16',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const Link(
              to: RoutePaths.projects,
              classes: 'link-line type-eyebrow inline-flex items-center '
                  'font-mono text-ink-400 transition-colors hover:text-ink-100',
              children: [Component.text('← All projects')],
            ),

            div(
              classes: 'mt-10 grid items-center gap-14 lg:gap-16 '
                  '${mockup == null ? '' : 'lg:grid-cols-[1fr_0.9fr]'}',
              [
                div(
                  classes: 'reveal',
                  [
                    div(
                      classes: 'flex flex-wrap items-center gap-3',
                      [
                        span(
                          classes: 'type-eyebrow font-mono text-iris-400',
                          [Component.text(project.category.label)],
                        ),
                        const span(classes: 'h-px w-8 bg-ink-600', []),
                        span(
                          classes: 'border px-2.5 py-1 font-mono text-[10px] '
                              'uppercase tracking-wider '
                              '${project.status.classes}',
                          [Component.text(project.status.label)],
                        ),
                      ],
                    ),

                    h1(
                      classes: 'type-section mt-7 font-display font-extrabold '
                          'text-ink-100',
                      [Component.text(project.name)],
                    ),

                    p(
                      classes: 'mt-5 max-w-lg text-lg leading-snug '
                          'text-ink-200',
                      [Component.text(project.tagline)],
                    ),

                    dl(
                      classes: 'mt-10 grid max-w-lg grid-cols-2 gap-x-8 '
                          'border-t border-ink-700 sm:grid-cols-2',
                      [
                        if (project.year.isNotEmpty)
                          _meta('Year', project.year),
                        if (project.client != null)
                          _meta('Client', project.client!),
                        if (project.platforms.isNotEmpty)
                          _meta(
                            'Platform',
                            project.platforms
                                .map((e) => e.label)
                                .join('  ·  '),
                          ),
                        if (project.stack.isNotEmpty)
                          _meta('Stack', project.stack.join('  ·  ')),
                      ],
                    ),

                    if (project.links.isNotEmpty)
                      StoreBadgeRow(
                        links: project.links,
                        product: project.name,
                        classes: 'mt-10',
                      ),
                  ],
                ),

                if (mockup != null)
                  div(
                    classes: 'reveal relative flex items-center justify-center',
                    [
                      const div(
                        classes: 'bloom pointer-events-none absolute inset-0 '
                            '-m-12',
                        attributes: {'aria-hidden': 'true'},
                        [],
                      ),
                      div(
                        classes: 'pointer-events-none absolute inset-0 flex '
                            'items-center justify-center overflow-hidden',
                        [GhostText(project.name, size: GhostSize.hero)],
                      ),
                      img(
                        src: '/$mockup',
                        alt: '${project.name} — ${project.tagline}',
                        attributes: const {
                          'decoding': 'async',
                          'fetchpriority': 'high',
                          'width': '914',
                          'height': '1200',
                        },
                        classes: 'showcase-device relative w-full max-w-sm '
                            'lg:max-w-md',
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Component _meta(String label, String value) => div(
        classes: 'meta-row',
        [
          span(
            classes: 'type-eyebrow font-mono text-ink-500',
            [Component.text(label)],
          ),
          span(
            classes: 'text-sm text-ink-200',
            [Component.text(value)],
          ),
        ],
      );
}

/// The prose. Kept to one narrow measure — long lines are where a case study
/// stops being read.
class _Overview extends StatelessComponent {
  const _Overview({required this.project});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative overflow-hidden bg-ink-800 py-20 sm:py-28',
      [
        GhostText(
          project.year,
          classes: 'absolute -right-4 -top-4 hidden sm:block',
          faint: true,
        ),
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const div(
              classes: 'reveal',
              [Eyebrow('Overview')],
            ),
            const div(classes: 'divider mt-8', []),
            div(
              classes: 'reveal mt-10 max-w-2xl space-y-6',
              [
                for (final (i, para) in project.summary.indexed)
                  p(
                    // The opening paragraph is the standfirst and is set
                    // larger; the rest are body.
                    classes: i == 0
                        ? 'text-xl leading-relaxed text-ink-100 sm:text-2xl '
                            'sm:leading-relaxed'
                        : 'text-sm leading-relaxed text-ink-400 '
                            'sm:text-[0.9375rem]',
                    [Component.text(para)],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Frames a multi-module product before the bands that describe each half.
///
/// Without this the reader meets two unexplained sections; the point of the
/// product is the relationship between them, so it gets said once, up front.
class _ModulesIntro extends StatelessComponent {
  const _ModulesIntro({required this.project});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    return section(
      id: 'worlds',
      classes: 'bg-ink-900 pb-4 pt-20 sm:pb-6 sm:pt-28',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'reveal flex items-start justify-between gap-8',
              [
                const div(
                  classes: 'max-w-xl',
                  [
                    Eyebrow('Inside the app'),
                    h2(
                      classes: 'type-section mt-5 font-display font-bold '
                          'text-ink-100',
                      [Component.text('Two worlds, one you.')],
                    ),
                    p(
                      classes: 'mt-5 text-sm leading-relaxed text-ink-400 '
                          'sm:text-[0.9375rem]',
                      [
                        Component.text(
                          'One nav could not serve both a person buying '
                          'medicine and a person recording how their day felt '
                          'without compromising each. So the app re-skins '
                          'around whichever world you are in — colour, '
                          'navigation and home all change. Account, wallet and '
                          'identity never do. The clinical half runs again in '
                          'the browser, for the times a phone is the wrong '
                          'tool.',
                        ),
                      ],
                    ),
                  ],
                ),
                div(
                  classes: 'hidden shrink-0 text-right sm:block',
                  [
                    p(
                      classes: 'font-display text-5xl font-extrabold '
                          'leading-none text-ink-800',
                      [
                        Component.text(
                          project.modules.length.toString().padLeft(2, '0'),
                        ),
                      ],
                    ),
                    const p(
                      classes: 'type-eyebrow mt-3 font-mono text-ink-500',
                      [Component.text('surfaces')],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// The walkthrough — one band per capability, alternating sides.
///
/// Splits features the same way [ProjectModuleBand] does: those with a render
/// become spotlights, those without become wide note bands. Some things are
/// simply not a screen — a feature that is built but deliberately withheld, or
/// one that is still a spec, is better told than mocked up.
class _Features extends StatelessComponent {
  const _Features({required this.project});

  final ProjectModel project;

  List<ProjectFeature> get _shots => project.features
      .where((f) => f.image != null)
      .toList(growable: false);

  List<ProjectFeature> get _notes => project.features
      .where((f) => f.image == null)
      .toList(growable: false);

  @override
  Component build(BuildContext context) {
    return section(
      id: 'features',
      classes: 'bg-ink-900 py-20 sm:py-28 lg:py-32',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'reveal flex items-start justify-between gap-8',
              [
                const div(
                  classes: 'max-w-xl',
                  [
                    Eyebrow('Inside the app'),
                    h2(
                      classes: 'type-section mt-5 font-display font-bold '
                          'text-ink-100',
                      [Component.text('What it actually does.')],
                    ),
                  ],
                ),
                div(
                  classes: 'hidden shrink-0 text-right sm:block',
                  [
                    p(
                      classes: 'font-display text-5xl font-extrabold '
                          'leading-none text-ink-800',
                      [
                        Component.text(
                          project.features.length.toString().padLeft(2, '0'),
                        ),
                      ],
                    ),
                    const p(
                      classes: 'type-eyebrow mt-3 font-mono text-ink-500',
                      [Component.text('features')],
                    ),
                  ],
                ),
              ],
            ),
            const div(classes: 'divider mt-12', []),

            div(
              classes: 'mt-16 space-y-24 sm:space-y-28 lg:space-y-32',
              [
                for (final (i, feature) in _shots.indexed)
                  ProjectFeatureSpotlight(feature: feature, index: i),
              ],
            ),

            for (final note in _notes)
              div(
                classes: 'reveal mt-20 border-t border-ink-700 pt-10 '
                    'lg:grid lg:grid-cols-[0.8fr_1.2fr] lg:gap-16',
                [
                  div([
                    div(
                      classes: 'flex items-center gap-3',
                      [
                        const span(classes: 'h-px w-8 bg-iris-500', []),
                        span(
                          classes: 'type-eyebrow font-mono text-iris-400',
                          [Component.text(note.label)],
                        ),
                      ],
                    ),
                    h3(
                      classes: 'mt-5 font-display text-2xl font-bold '
                          'leading-tight tracking-tight text-ink-100 '
                          'sm:text-3xl',
                      [Component.text(note.title)],
                    ),
                  ]),
                  div(
                    classes: 'mt-6 lg:mt-0',
                    [
                      p(
                        classes: 'max-w-xl text-sm leading-relaxed text-ink-300 '
                            'sm:text-base',
                        [Component.text(note.description)],
                      ),
                      if (note.points.isNotEmpty)
                        ul(
                          classes: 'mt-7 grid gap-2.5 sm:grid-cols-2',
                          [
                            for (final point in note.points)
                              li(
                                classes: 'flex gap-3 text-sm leading-relaxed '
                                    'text-ink-400',
                                [
                                  const span(
                                    classes: 'mt-2.5 h-px w-3.5 shrink-0 '
                                        'bg-ink-600',
                                    [],
                                  ),
                                  span([Component.text(point)]),
                                ],
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// The engineering notes, as a grid rather than a bulleted list.
class _UnderTheHood extends StatelessComponent {
  const _UnderTheHood({required this.project});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative overflow-hidden bg-ink-800 py-20 sm:py-28',
      [
        GhostText(
          project.highlights.length.toString().padLeft(2, '0'),
          classes: 'absolute -right-2 top-8 hidden sm:block',
          faint: true,
        ),
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const div(
              classes: 'reveal max-w-xl',
              [
                Eyebrow('Under the hood'),
                h2(
                  classes: 'type-section mt-5 font-display font-bold '
                      'text-ink-100',
                  [Component.text('The parts worth naming.')],
                ),
              ],
            ),
            const div(classes: 'divider mt-12', []),
            div(
              classes: 'mt-12 grid gap-px bg-ink-700/60 sm:grid-cols-2',
              [
                for (final (i, point) in project.highlights.indexed)
                  div(
                    classes: 'reveal flex gap-5 bg-ink-800 p-7',
                    [
                      span(
                        classes: 'shrink-0 font-mono text-[11px] text-iris-400',
                        [Component.text((i + 1).toString().padLeft(2, '0'))],
                      ),
                      p(
                        classes: 'text-sm leading-relaxed text-ink-300',
                        [Component.text(point)],
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Hands the reader the next case study rather than ending on a footer.
class _NextUp extends StatelessComponent {
  const _NextUp({required this.project});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative overflow-hidden bg-ink-900 py-20 sm:py-24',
      [
        GhostText(
          project.name,
          size: GhostSize.small,
          classes: 'absolute -right-4 bottom-2 hidden sm:block',
        ),
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            Link(
              to: RoutePaths.projectDetail(project.slug),
              classes: 'group flex flex-col gap-6 border-t border-ink-700 '
                  'pt-10 sm:flex-row sm:items-end sm:justify-between',
              children: [
                div([
                  const p(
                    classes: 'type-eyebrow font-mono text-ink-500',
                    [Component.text('Next case study')],
                  ),
                  h2(
                    classes: 'mt-4 font-display text-3xl font-extrabold '
                        'tracking-tight text-ink-100 transition-colors '
                        'duration-300 group-hover:text-iris-300 sm:text-4xl',
                    [Component.text(project.name)],
                  ),
                  p(
                    classes: 'mt-2 text-sm text-ink-400',
                    [Component.text(project.tagline)],
                  ),
                ]),
                span(
                  classes: 'shrink-0 text-ink-500 transition-all duration-500 '
                      'ease-soft group-hover:translate-x-1.5 '
                      'group-hover:text-iris-300',
                  [AppIcons.arrow(classes: 'h-6 w-6')],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
