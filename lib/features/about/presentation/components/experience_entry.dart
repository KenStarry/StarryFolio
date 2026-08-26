import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/experience_model.dart';

/// One role, drawn as a station on a line rather than a row in a table.
///
/// The left column carries the facts you scan for — when, where, what kind of
/// engagement — and the right column carries the argument. Splitting them is
/// what lets someone read only the years and still get something, which is how
/// a timeline is actually read.
///
/// The hairline, the node and the outcome markers all light together on hover
/// and on `focus-within` (see `.entry` in `web/styles.tw.css`), so the row you
/// are reading acknowledges you without anything on the page moving.
///
/// Where the role produced a case study, the entry links straight to it. That
/// link is the whole reason this page is not a PDF.
class ExperienceEntry extends StatelessComponent {
  const ExperienceEntry({required this.experience, super.key});

  final ExperienceModel experience;

  @override
  Component build(BuildContext context) {
    final meta = <String>[
      if (experience.kind.isNotEmpty) experience.kind,
      if (experience.location.isNotEmpty) experience.location,
    ];

    return article(
      classes: 'entry reveal group pb-14 pl-6 last:pb-0 sm:pl-10',
      [
        const span(classes: 'entry-node', attributes: {'aria-hidden': 'true'}, []),

        div(
          classes: 'grid gap-6 lg:grid-cols-[11rem_1fr] lg:gap-12',
          [
            // ── When ──
            div(
              classes: 'lg:pt-1',
              [
                p(
                  classes: 'font-mono text-sm tracking-tight '
                      '${experience.current ? 'text-ink-100' : 'text-ink-300'}',
                  [Component.text(experience.period)],
                ),

                if (experience.current)
                  const div(
                    classes: 'mt-3 inline-flex items-center gap-2',
                    [
                      span(
                        classes: 'h-1.5 w-1.5 rounded-full bg-iris-400 dot-live',
                        [],
                      ),
                      span(
                        classes: 'type-eyebrow font-mono text-iris-400',
                        [Component.text('Now')],
                      ),
                    ],
                  ),

                if (meta.isNotEmpty)
                  p(
                    classes: 'mt-3 font-mono text-[11px] leading-relaxed '
                        'text-ink-500',
                    [Component.text(meta.join('  ·  '))],
                  ),

                // Says out loud that the dates are authored rather than
                // verified. Removing `draft` from the datasource removes it.
                if (experience.draft)
                  const p(
                    classes: 'mt-3 font-mono text-[10px] uppercase '
                        'tracking-[0.14em] text-ink-600',
                    [Component.text('dates to confirm')],
                  ),
              ],
            ),

            // ── What ──
            div([
              h3(
                classes: 'font-display text-xl font-bold leading-tight '
                    'tracking-tight text-ink-100 sm:text-2xl',
                [Component.text(experience.role)],
              ),

              p(
                classes: 'mt-2 text-sm text-ink-400',
                [
                  span(
                    classes: 'text-ink-200',
                    [Component.text(experience.company)],
                  ),
                ],
              ),

              p(
                classes: 'mt-5 max-w-2xl text-sm leading-relaxed text-ink-400',
                [Component.text(experience.summary)],
              ),

              if (experience.highlights.isNotEmpty)
                ul(
                  classes: 'mt-7 max-w-2xl',
                  [
                    for (final outcome in experience.highlights)
                      li(classes: 'outcome', [
                        span([Component.text(outcome)]),
                      ]),
                  ],
                ),

              if (experience.stack.isNotEmpty)
                p(
                  classes: 'mt-7 font-mono text-[11px] leading-relaxed '
                      'text-ink-500',
                  [Component.text(experience.stack.join('  ·  '))],
                ),

              if (experience.projectSlug case final slug?)
                div(
                  classes: 'mt-7',
                  [
                    Link(
                      to: RoutePaths.projectDetail(slug),
                      classes: 'link-line group/link inline-flex items-center '
                          'gap-2.5 text-sm font-medium text-ink-200 '
                          'transition-colors duration-300 hover:text-ink-100',
                      children: [
                        const Component.text('Read the case study'),
                        span(
                          classes: 'transition-transform duration-500 '
                              'ease-soft group-hover/link:translate-x-1',
                          [AppIcons.arrow(classes: 'h-4 w-4')],
                        ),
                      ],
                    ),
                  ],
                ),
            ]),
          ],
        ),
      ],
    );
  }
}
