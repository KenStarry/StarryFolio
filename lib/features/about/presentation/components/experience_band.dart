import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../projects/domain/model/project_model.dart';
import '../../domain/model/experience_model.dart';
import 'role_work_card.dart';

/// One company, given a full band.
///
/// ## Why this is not a timeline any more
///
/// The first version was: a spine, nodes, nested rows. It was accurate and it
/// read as a CV with better spacing — a rule running down three screens with
/// paragraphs hanging off it. The sequence-and-duration job that spine did is
/// now handled in one strip by `CareerSpan`, which freed each company to be
/// presented the way this site presents everything else it thinks is
/// important: a full-width band, alternating ground, ghost wordmark behind.
///
/// A company is treated exactly as a flagship project is, because on a
/// portfolio it is the same kind of claim.
///
/// ## Figures carry it, not prose
///
/// The band's centre of gravity is a row of [RoleStint.metrics] at stat scale.
/// `3.1 → 4.1` over `Play Store rating` is the same fact that used to be a
/// bullet, and it survives being scanned in a way the sentence never did. What
/// is left in [RoleStint.highlights] is only what a figure cannot carry.
///
/// ## A promotion is one line
///
/// Two titles sit inline with an arrow between them, rather than as two rows
/// on a nested rule. It says the same thing more plainly and costs a line
/// instead of a structure.
class ExperienceBand extends StatelessComponent {
  const ExperienceBand({
    required this.experience,
    required this.projects,
    required this.index,
    required this.raised,
    super.key,
  });

  final ExperienceModel experience;

  /// Every project, for resolving the slugs a role names. Passed in rather
  /// than fetched: the page owns its awaits so the whole thing renders in one
  /// pass, which is what keeps it in the pre-rendered HTML.
  final List<ProjectModel> projects;

  /// One-based position, rendered as the `01` marker.
  final int index;

  /// Alternates the ground so consecutive bands read as stacked rather than as
  /// one continuous sheet.
  final bool raised;

  @override
  Component build(BuildContext context) {
    final xp = experience;
    final lead = xp.roles.isEmpty ? null : xp.roles.first;
    final work = [
      for (final slug in xp.projects)
        for (final project in projects)
          if (project.slug == slug) project,
    ];
    final meta = <String>[
      xp.period,
      if (xp.duration case final span_?) span_,
      if (xp.kind.isNotEmpty) xp.kind,
      if (xp.location.isNotEmpty) xp.location,
    ];

    return section(
      id: xp.slug,
      classes: 'xp-band group scroll-mt-24 '
          '${raised ? 'bg-ink-800' : 'bg-ink-900'}',
      [
        GhostText(
          xp.company.split(' ').first,
          faint: true,
          classes: 'pointer-events-none absolute -bottom-5 -left-4 sm:-left-8',
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'reveal grid gap-10 lg:grid-cols-[1fr_1.05fr] lg:gap-16',
              [
                // ── Who, and when ──
                div([
                  div(
                    classes: 'flex items-center gap-4',
                    [
                      div(
                        classes: 'xp-mark',
                        attributes: const {'aria-hidden': 'true'},
                        [
                          if (xp.logo case final logo?)
                            img(
                              src: '/$logo',
                              alt: '',
                              classes: 'h-7 w-7 object-contain',
                              attributes: const {
                                'loading': 'lazy',
                                'decoding': 'async',
                              },
                            )
                          else
                            span(
                              classes: 'xp-monogram',
                              [Component.text(xp.initial)],
                            ),
                        ],
                      ),
                      span(
                        classes: 'type-eyebrow font-mono text-ink-500',
                        [Component.text(index.toString().padLeft(2, '0'))],
                      ),
                      if (xp.current)
                        const span(
                          classes: 'inline-flex items-center gap-2',
                          [
                            span(
                              classes: 'h-1.5 w-1.5 rounded-full bg-iris-400 '
                                  'dot-live',
                              [],
                            ),
                            span(
                              classes: 'type-eyebrow font-mono text-iris-400',
                              [Component.text('Now')],
                            ),
                          ],
                        ),
                    ],
                  ),

                  h3(
                    classes: 'type-section mt-7 font-display font-extrabold '
                        'text-ink-100',
                    [Component.text(xp.company)],
                  ),

                  if (xp.blurb.isNotEmpty)
                    p(
                      classes: 'mt-3 max-w-md text-sm leading-relaxed '
                          'text-ink-500',
                      [Component.text(xp.blurb)],
                    ),

                  p(
                    classes: 'mt-5 font-mono text-[11px] leading-relaxed '
                        'text-ink-400',
                    [Component.text(meta.join('  ·  '))],
                  ),

                  // ── The progression, as one line ──
                  div(classes: 'mt-7', [_track(xp)]),

                  if (xp.hasDraft)
                    const p(
                      classes: 'mt-4 font-mono text-[10px] uppercase '
                          'tracking-[0.14em] text-ink-600',
                      [Component.text('dates to confirm')],
                    ),
                ]),

                // ── What came of it ──
                div([
                  if (lead != null && lead.summary.isNotEmpty)
                    p(
                      classes: 'max-w-lg text-base leading-relaxed text-ink-300',
                      [Component.text(lead.summary)],
                    ),

                  if (lead != null && lead.metrics.isNotEmpty)
                    div(
                      classes: 'mt-9 grid gap-x-8 gap-y-7 sm:grid-cols-3',
                      [
                        for (final metric in lead.metrics)
                          div(
                            classes: 'xp-figure',
                            [
                              span(
                                classes: 'xp-figure-value',
                                [Component.text(metric.value)],
                              ),
                              span(
                                classes: 'xp-figure-label',
                                [Component.text(metric.label)],
                              ),
                            ],
                          ),
                      ],
                    ),

                  if (lead != null && lead.highlights.isNotEmpty)
                    ul(
                      classes: 'mt-9 max-w-lg',
                      [
                        for (final line in lead.highlights)
                          li(classes: 'outcome', [
                            span([Component.text(line)]),
                          ]),
                      ],
                    ),

                  if (lead != null && lead.stack.isNotEmpty)
                    p(
                      classes: 'mt-7 font-mono text-[11px] leading-relaxed '
                          'text-ink-500',
                      [Component.text(lead.stack.join('  ·  '))],
                    ),
                ]),
              ],
            ),

            // ── The builds ──
            if (work.isNotEmpty) ...[
              const div(classes: 'divider-quiet mt-14', []),
              div(
                classes: 'reveal mt-8',
                [
                  const p(
                    classes: 'type-eyebrow font-mono text-ink-500',
                    [Component.text('Shipped here')],
                  ),
                  div(
                    classes: 'mt-5 grid gap-3 sm:grid-cols-2 lg:grid-cols-3',
                    [
                      for (final project in work)
                        RoleWorkCard(project: project),
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

  /// Every title held here, oldest first, with the promotion drawn between.
  ///
  /// Roles are stored newest first because that is how they are read
  /// everywhere else; reversed here because a progression only makes sense
  /// left to right.
  static Component _track(ExperienceModel xp) {
    final ordered = xp.roles.reversed.toList(growable: false);

    return div(
      classes: 'xp-track',
      [
        for (final (i, role) in ordered.indexed) ...[
          if (i > 0)
            span(
              classes: 'xp-arrow',
              // The arrow *is* the promotion, so it needs a text equivalent:
              // read aloud without one, two titles in a row say nothing about
              // how one became the other.
              attributes: const {'aria-label': 'promoted to'},
              [AppIcons.arrow(classes: 'h-3.5 w-3.5')],
            ),
          span(
            classes: role.current ? 'xp-title xp-title-now' : 'xp-title',
            [Component.text(role.title)],
          ),
        ],
      ],
    );
  }
}
