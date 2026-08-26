import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/milestone_model.dart';

/// The road so far, as a spine that fills while you scroll it.
///
/// Deliberately lighter than the experience band above it — a year, a short
/// title, one line — so the two never read as the same list told twice. This
/// one is the shape of the story; that one is the argument.
///
/// The fill is a scroll-driven animation on an accent line laid over the
/// resting hairline, so where `animation-timeline` is unsupported the spine is
/// simply drawn complete, which is exactly how it should look at rest. No
/// observer, nothing to hydrate, and it cannot desync from the scroll
/// position. See `.spine-fill` in `web/styles.tw.css`.
class MilestoneSpine extends StatelessComponent {
  const MilestoneSpine({required this.milestones, super.key});

  final List<MilestoneModel> milestones;

  @override
  Component build(BuildContext context) {
    if (milestones.isEmpty) return const div([]);

    return div(
      classes: 'relative',
      [
        // ── The line ──
        //
        // Two hairlines in the same place: the resting one, and the accent
        // that grows over it. Both sit under the nodes, which carry the
        // section ground as their own fill so the line reads as passing
        // behind them.
        const div(
          classes: 'pointer-events-none absolute bottom-2 left-[0.3125rem] '
              'top-2 w-px bg-ink-700/70',
          attributes: {'aria-hidden': 'true'},
          [],
        ),
        const div(
          classes: 'spine-fill pointer-events-none absolute bottom-2 '
              'left-[0.3125rem] top-2 w-px',
          attributes: {'aria-hidden': 'true'},
          [],
        ),

        ol(
          classes: 'relative space-y-12',
          [
            for (final milestone in milestones) _entry(milestone),
          ],
        ),
      ],
    );
  }

  static Component _entry(MilestoneModel milestone) => li(
        classes: 'milestone reveal group relative flex gap-6 sm:gap-8',
        [
          const span(
            classes: 'spine-node mt-1.5',
            attributes: {'aria-hidden': 'true'},
            [],
          ),

          div(
            // `isolate` keeps the ghost year's `-z-10` inside this entry.
            classes: 'relative isolate min-w-0 flex-1 pb-1',
            [
              // The year, set enormous and faint behind its own entry. It
              // repeats the label below it, so it is texture rather than
              // content — and hidden from assistive tech accordingly.
              div(
                classes: 'ghost-year pointer-events-none absolute -top-6 '
                    'left-6 -z-10 select-none font-display font-extrabold '
                    'text-ink-100/[0.035]',
                attributes: const {'aria-hidden': 'true'},
                [Component.text(milestone.year)],
              ),

              p(
                classes: 'font-mono text-xs tracking-[0.14em] text-iris-400',
                [Component.text(milestone.year)],
              ),

              h3(
                classes: 'mt-3 font-display text-lg font-bold tracking-tight '
                    'text-ink-100 sm:text-xl',
                [Component.text(milestone.title)],
              ),

              if (milestone.note.isNotEmpty)
                p(
                  classes: 'mt-2.5 max-w-xl text-sm leading-relaxed '
                      'text-ink-400',
                  [Component.text(milestone.note)],
                ),
            ],
          ),
        ],
      );
}
