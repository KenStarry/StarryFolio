import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/project_model.dart';
import 'project_cover.dart';

/// One build, seen from the design side.
///
/// **Deliberately not a [ProjectCard].** The design collection shows the same
/// products as `/projects/mobile`, and if it showed them as the same cards it
/// would be the mobile page with a different heading — thin for a reader and
/// duplicate content for a crawler.
///
/// So this is a different object entirely: a band rather than a card, reading
/// problem → system → shipped, which is the order the work happens in. None of
/// the copy it renders exists anywhere else on the site, because a project is
/// only in this collection if it carries its own [ProjectDesign] block.
///
/// The cover is present but subordinate — design work is judged on decisions,
/// and leading with a screenshot invites the reader to judge it on taste
/// instead.
class DesignCase extends StatelessComponent {
  const DesignCase({
    required this.project,
    required this.index,
    required this.reversed,
    required this.raised,
    required this.timeline,
    super.key,
  });

  final ProjectModel project;

  /// One-based position, rendered as the `01` marker.
  final int index;

  /// Mirrors the layout so consecutive bands zig-zag rather than repeat.
  ///
  /// Uses CSS `order`, not swapped markup — the copy stays first in the DOM
  /// either way, so reading and tab order never diverge from the visual.
  final bool reversed;

  final bool raised;

  /// `tl-N` utility naming this band's view-timeline, for the section rail.
  final String timeline;

  /// Whether there is anything to show above the "what shipped" panel.
  bool get _hasArt =>
      project.coverImage != null || project.mockupImage != null;

  @override
  Component build(BuildContext context) {
    final design = project.design;
    if (design == null) return const div([]);

    final number = index.toString().padLeft(2, '0');

    return section(
      id: project.slug,
      classes: '$timeline relative isolate scroll-mt-24 overflow-hidden '
          '${raised ? 'bg-ink-800' : 'bg-ink-900'} py-20 sm:py-28',
      [
        GhostText(
          project.name,
          faint: true,
          classes: 'absolute -bottom-6 -left-4 sm:-left-8',
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid items-start gap-12 lg:gap-16 '
                  '${reversed ? 'lg:grid-cols-[0.85fr_1.15fr]' : 'lg:grid-cols-[1.15fr_0.85fr]'}',
              [
                // ── The decisions ──
                div(
                  classes: 'reveal '
                      '${reversed ? 'lg:order-2' : 'lg:order-1'}',
                  [
                    div(
                      classes: 'flex flex-wrap items-center gap-3',
                      [
                        span(
                          classes: 'type-eyebrow font-mono text-ink-500',
                          [Component.text('Case $number')],
                        ),
                        const span(classes: 'h-px w-8 bg-ink-600', []),
                        // Authored scaffolding says so, in place, rather than
                        // relying on somebody remembering it is not real.
                        if (design.draft)
                          const span(
                            classes: 'border border-ink-600 px-2.5 py-1 '
                                'font-mono text-[10px] uppercase '
                                'tracking-wider text-ink-400',
                            [Component.text('Draft copy')],
                          ),
                      ],
                    ),

                    h2(
                      classes: 'type-section mt-5 font-display font-extrabold '
                          'text-ink-100',
                      [Component.text(project.name)],
                    ),

                    // ── Problem ──
                    const p(
                      classes: 'type-eyebrow mt-8 font-mono text-ink-500',
                      [Component.text('The problem')],
                    ),
                    p(
                      classes: 'mt-3 max-w-xl text-base leading-relaxed '
                          'text-ink-300',
                      [Component.text(design.problem)],
                    ),

                    // ── System ──
                    if (design.system.isNotEmpty) ...[
                      const div(classes: 'divider-quiet mt-9', []),
                      const p(
                        classes: 'type-eyebrow mt-7 font-mono text-ink-500',
                        [Component.text('The system')],
                      ),
                      ul(
                        classes: 'mt-4 max-w-xl',
                        [
                          for (final line in design.system)
                            li(classes: 'outcome', [
                              span([Component.text(line)]),
                            ]),
                        ],
                      ),
                    ],

                    if (design.note.isNotEmpty)
                      p(
                        classes: 'mt-8 max-w-xl border-l border-ink-700 pl-5 '
                            'text-sm leading-relaxed text-ink-400',
                        [Component.text(design.note)],
                      ),

                    if (project.hasCaseStudy)
                      div(
                        classes: 'mt-9',
                        [
                          Link(
                            to: RoutePaths.projectDetail(project.slug),
                            classes: 'link-line group/link inline-flex '
                                'items-center gap-2.5 text-sm font-medium '
                                'text-ink-200 transition-colors duration-300 '
                                'hover:text-ink-100',
                            children: [
                              const Component.text('The build, in full'),
                              span(
                                classes: 'transition-transform duration-500 '
                                    'ease-soft group-hover/link:translate-x-1',
                                [AppIcons.arrow(classes: 'h-4 w-4')],
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),

                // ── What came out ──
                div(
                  classes: 'reveal '
                      '${reversed ? 'lg:order-1' : 'lg:order-2'}',
                  [
                    // `ProjectCover` already picks between the cover art and
                    // the device mockup and handles the reveal, so the band
                    // does not need to know which a project has.
                    if (project.coverImage != null ||
                        project.mockupImage != null)
                      div(
                        classes: 'overflow-hidden border border-ink-700',
                        [ProjectCover(project: project)],
                      ),

                    if (design.shipped.isNotEmpty)
                      div(
                        classes: 'border border-ink-700 bg-ink-850 p-7 '
                            '${_hasArt ? 'mt-6' : ''}',
                        [
                          const p(
                            classes: 'type-eyebrow font-mono text-ink-500',
                            [Component.text('What shipped')],
                          ),
                          const div(classes: 'divider mt-5', []),
                          ul(
                            classes: 'mt-6 space-y-4',
                            [
                              for (final item in design.shipped)
                                li(
                                  classes: 'flex gap-4 text-sm leading-relaxed '
                                      'text-ink-300',
                                  [
                                    const span(
                                      classes: 'mt-2 h-px w-4 shrink-0 '
                                          'bg-iris-500',
                                      [],
                                    ),
                                    Component.text(item),
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
        ),
      ],
    );
  }
}
