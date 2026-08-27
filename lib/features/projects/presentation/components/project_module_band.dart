import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/ghost_text.dart';
import '../../domain/model/project_feature.dart';
import '../../domain/model/project_module.dart';
import 'project_feature_spotlight.dart';

/// One half of a product, as a full band on a case study.
///
/// Every module gets the same visual structure — alternating spotlights — so an
/// unshipped half still reads as the same product. What changes is volume: a
/// module carrying a [ProjectModule.badge] renders its spotlights `muted`,
/// meaning a smaller device, a softer bloom and a `Concept` chip.
///
/// Features are split by whether they have a render:
///
/// * **With a render** — a full alternating spotlight.
/// * **Without one** — a wide note band after the spotlights. Some things are
///   not a screen at all; HealthX's world-switch morph is a *transition*, and
///   pinning a static device beside it would misrepresent it.
///
/// A module with no renders at all falls back to a card grid — which serves
/// both an unbuilt module and a shipped one that simply has no phone mockup,
/// such as a web surface.
class ProjectModuleBand extends StatelessComponent {
  const ProjectModuleBand({
    required this.module,
    required this.index,
    required this.raised,
    super.key,
  });

  final ProjectModule module;

  /// Zero-based position, rendered as the `World 01` marker.
  final int index;

  /// Alternates the ground so consecutive modules stay visually separate.
  final bool raised;

  /// Features with a render, shown as spotlights.
  List<ProjectFeature> get _shots =>
      module.features.where((f) => f.image != null).toList(growable: false);

  /// Features without one — things that are not a screen.
  List<ProjectFeature> get _notes =>
      module.features.where((f) => f.image == null).toList(growable: false);

  @override
  Component build(BuildContext context) {
    final accent = module.accent;

    return section(
      id: module.name.toLowerCase(),
      classes: 'relative overflow-hidden '
          '${raised ? 'bg-ink-800' : 'bg-ink-900'} py-20 sm:py-28 lg:py-32',
      [
        // The world's own name, ghosted behind its header and bleeding off the
        // right edge — the section's identity, felt rather than read.
        GhostText(
          module.name,
          classes: 'absolute -right-6 top-10 hidden sm:block lg:-right-10',
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            // ── Header ──
            div(
              classes: 'reveal max-w-2xl',
              [
                div(
                  classes: 'flex flex-wrap items-center gap-3',
                  [
                    span(
                      classes: 'type-eyebrow font-mono text-ink-500',
                      [
                        Component.text(
                          '${module.kind} '
                          '${(index + 1).toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                    const span(classes: 'h-px w-6 bg-ink-600', []),
                    span(
                      classes: 'type-eyebrow font-mono text-iris-400',
                      [Component.text(module.name)],
                    ),
                    if (module.badge != null)
                      span(
                        classes: 'border border-ink-600 px-2.5 py-1 font-mono '
                            'text-[10px] uppercase tracking-wider text-ink-400',
                        [Component.text(module.badge!)],
                      ),
                  ],
                ),

                h3(
                  classes: 'type-section mt-6 font-display font-bold '
                      'text-ink-100',
                  [Component.text(module.tagline)],
                ),

                p(
                  classes: 'mt-5 text-sm leading-relaxed text-ink-400 '
                      'sm:text-[0.9375rem]',
                  [Component.text(module.blurb)],
                ),

                div(
                  classes: 'mt-8 flex flex-wrap items-center gap-2',
                  [
                    for (final surface in module.surfaces)
                      span(classes: 'pill', [Component.text(surface)]),

                    // The product's own accent, as a documented swatch. Applied
                    // inline because the value is data — a Tailwind class built
                    // from it would be purged, and it must never become a token
                    // in this site's palette.
                    if (accent != null)
                      span(
                        classes: 'ml-1 inline-flex items-center gap-2 '
                            'font-mono text-[10px] uppercase tracking-wider '
                            'text-ink-500',
                        [
                          span(
                            classes: 'h-2.5 w-2.5 rounded-full ring-1 '
                                'ring-ink-600',
                            attributes: {'style': 'background:$accent'},
                            [],
                          ),
                          Component.text(accent),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const div(classes: 'divider mt-12', []),

            // ── Body ──
            if (!module.hasRenders)
              div(
                classes: 'mt-12 grid gap-px bg-ink-700/60 sm:grid-cols-2',
                [
                  for (final (i, feature) in module.features.indexed)
                    div(
                      classes: 'reveal flex flex-col '
                          '${raised ? 'bg-ink-800' : 'bg-ink-900'} p-7 sm:p-8',
                      [
                        div(
                          classes: 'flex items-center gap-3',
                          [
                            span(
                              classes: 'font-mono text-[11px] text-iris-400',
                              [
                                Component.text(
                                  (i + 1).toString().padLeft(2, '0'),
                                ),
                              ],
                            ),
                            span(
                              classes: 'type-eyebrow font-mono text-ink-500',
                              [Component.text(feature.label)],
                            ),
                          ],
                        ),
                        h4(
                          classes: 'mt-5 font-display text-xl font-bold '
                              'leading-snug tracking-tight text-ink-100',
                          [Component.text(feature.title)],
                        ),
                        p(
                          classes: 'mt-3 text-sm leading-relaxed text-ink-400',
                          [Component.text(feature.description)],
                        ),
                        if (feature.points.isNotEmpty)
                          ul(
                            classes: 'mt-6 space-y-2.5',
                            [
                              for (final point in feature.points)
                                li(
                                  classes: 'flex gap-3 text-sm leading-relaxed '
                                      'text-ink-300',
                                  [
                                    const span(
                                      classes: 'mt-2.5 h-px w-3.5 shrink-0 '
                                          'bg-iris-500',
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
              )
            else ...[
              div(
                classes: 'mt-16 space-y-24 sm:space-y-28 lg:space-y-32',
                [
                  for (final (i, feature) in _shots.indexed)
                    ProjectFeatureSpotlight(
                      feature: feature,
                      index: i,
                      muted: module.conceptual,
                    ),
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
                          const span(
                            classes: 'h-px w-8 bg-iris-500',
                            [],
                          ),
                          span(
                            classes: 'type-eyebrow font-mono text-iris-400',
                            [Component.text(note.label)],
                          ),
                        ],
                      ),
                      h4(
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
                          classes: 'max-w-xl text-sm leading-relaxed '
                              'text-ink-300 sm:text-base',
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
          ],
        ),
      ],
    );
  }
}
