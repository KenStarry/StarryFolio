import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../domain/model/process_step_model.dart';

/// How the work runs, as four connected steps.
///
/// The services page says *what* is on offer; this says in what order it
/// happens, which is what a client is really asking when they ask what someone
/// is like to work with.
///
/// Each step names the artefact it hands over — a process that cannot say what
/// you are holding at the end of a stage is a diagram, not a process. The
/// hairline connector between steps is drawn with a pseudo-element (`.step` in
/// `web/styles.tw.css`) so it costs no markup and vanishes with the grid at
/// narrow widths, where a horizontal connector between stacked cards would be
/// a line pointing at nothing.
class ProcessArc extends StatelessComponent {
  const ProcessArc({required this.steps, super.key});

  final List<ProcessStepModel> steps;

  @override
  Component build(BuildContext context) {
    if (steps.isEmpty) return const div([]);

    return div(
      classes: 'grid gap-x-12 gap-y-14 sm:grid-cols-2 lg:grid-cols-4',
      [
        for (final (i, step) in steps.indexed) _step(step, i + 1),
      ],
    );
  }

  static Component _step(ProcessStepModel step, int index) {
    final number = index.toString().padLeft(2, '0');

    return div(
      // `isolate` contains the `-z-10` ghost numeral to this card, so it
      // paints over the section ground rather than under it.
      classes: 'step reveal group relative isolate',
      [
        // The ghost numeral — the motif at step scale. Texture, never content.
        div(
          classes: 'step-num pointer-events-none absolute -left-2 -top-8 -z-10 '
              'select-none font-display text-[5.5rem] font-extrabold '
              'leading-none tracking-tighter',
          attributes: const {'aria-hidden': 'true'},
          [Component.text(number)],
        ),

        div(
          classes: 'flex items-center gap-3',
          [
            span(
              classes: 'text-iris-400 transition-transform duration-500 '
                  'ease-spring group-hover:scale-110',
              [AppIcons.byName(step.icon, classes: 'h-6 w-6')],
            ),
            span(
              classes: 'type-eyebrow font-mono text-ink-500',
              [Component.text('Step $number')],
            ),
          ],
        ),

        h3(
          classes: 'mt-6 font-display text-xl font-bold tracking-tight '
              'text-ink-100',
          [Component.text(step.title)],
        ),

        p(
          classes: 'mt-4 text-sm leading-relaxed text-ink-400',
          [Component.text(step.blurb)],
        ),

        if (step.artefact.isNotEmpty) ...[
          const div(classes: 'divider-quiet mt-7', []),
          div(
            classes: 'mt-5',
            [
              const p(
                classes: 'type-eyebrow font-mono text-ink-500',
                [Component.text('You end up with')],
              ),
              p(
                classes: 'mt-2.5 text-sm leading-relaxed text-ink-200',
                [Component.text(step.artefact)],
              ),
            ],
          ),
        ],
      ],
    );
  }
}
