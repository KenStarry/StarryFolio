import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/experience_model.dart';

/// One role: a station on a line, with the role itself sitting on it as a card.
///
/// The first pass set each role as loose prose against the rule — a paragraph,
/// four ruled outcome rows, a stack line. Truthful, and far too much to read
/// four times over. This is the same information as an object: one sentence,
/// three fragments as chips, and the stack in mono along the bottom edge.
///
/// The company's initial is ghosted across the card at display size — the
/// wordmark motif at card scale, anchored to the company name printed directly
/// beneath it. It is what gives an entry with barely thirty words in it enough
/// weight to hold a full band.
///
/// The rail still does the work it did: the hairline, the node and the chips
/// light together on hover *and* `focus-within`, so a keyboard user tabbing to
/// the case-study link gets the same acknowledgement a pointer does.
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
      classes: 'entry reveal group pb-10 pl-6 last:pb-0 sm:pl-10',
      [
        const span(classes: 'entry-node', attributes: {'aria-hidden': 'true'}, []),

        div(
          classes: 'grid gap-5 lg:grid-cols-[10rem_1fr] lg:gap-10',
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
                    classes: 'mt-2.5 inline-flex items-center gap-2',
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
                    classes: 'mt-2.5 font-mono text-[11px] text-ink-500',
                    [Component.text(meta.join('  ·  '))],
                  ),

                // Says out loud that the dates are authored rather than
                // verified. Removing `draft` from the datasource removes it.
                if (experience.draft)
                  const p(
                    classes: 'mt-2.5 font-mono text-[10px] uppercase '
                        'tracking-[0.14em] text-ink-600',
                    [Component.text('dates to confirm')],
                  ),
              ],
            ),

            // ── What ──
            div(
              classes: 'card relative isolate overflow-hidden p-6 sm:p-7',
              [
                _monogram(experience.company),

                h3(
                  classes: 'font-display text-xl font-bold leading-tight '
                      'tracking-tight text-ink-100 sm:text-2xl',
                  [Component.text(experience.role)],
                ),

                p(
                  classes: 'mt-1.5 text-sm text-ink-200',
                  [Component.text(experience.company)],
                ),

                p(
                  classes: 'mt-4 max-w-xl text-sm leading-relaxed text-ink-400',
                  [Component.text(experience.summary)],
                ),

                if (experience.highlights.isNotEmpty)
                  ul(
                    classes: 'mt-6 flex flex-wrap gap-2',
                    [
                      for (final outcome in experience.highlights)
                        li(classes: 'pill', [Component.text(outcome)]),
                    ],
                  ),

                const div(classes: 'divider-quiet mt-7', []),

                div(
                  classes: 'mt-5 flex flex-wrap items-center justify-between '
                      'gap-4',
                  [
                    if (experience.stack.isNotEmpty)
                      p(
                        classes: 'font-mono text-[11px] text-ink-500',
                        [Component.text(experience.stack.join('  ·  '))],
                      ),

                    if (experience.projectSlug case final slug?)
                      Link(
                        to: RoutePaths.projectDetail(slug),
                        classes: 'link-line group/link inline-flex items-center '
                            'gap-2.5 text-sm font-medium text-ink-200 '
                            'transition-colors duration-300 hover:text-ink-100',
                        children: [
                          const Component.text('Case study'),
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
          ],
        ),
      ],
    );
  }

  /// The company's initial, ghosted across the card.
  ///
  /// `isolate` on the card is what keeps this at `-z-10` *inside* the card
  /// rather than behind the section's background, and the letter is texture:
  /// `aria-hidden`, never read, always repeating the real company name a few
  /// lines below it.
  static Component _monogram(String company) => span(
        classes: 'ghost-mono pointer-events-none absolute -right-3 -top-6 -z-10 '
            'select-none font-display font-extrabold text-ink-100/[0.05]',
        attributes: const {'aria-hidden': 'true'},
        [Component.text(company.isEmpty ? '' : company.substring(0, 1))],
      );
}
