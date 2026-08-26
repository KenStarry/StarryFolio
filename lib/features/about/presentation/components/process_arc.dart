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
/// you are holding at the end of a stage is a diagram, not a process. That
/// line is the only one set in `ink-200`, because it is the only part a client
/// is actually buying.
///
/// Cards rather than bare columns, so the four read as objects you receive in
/// sequence. The hairline connector between them is drawn with a
/// pseudo-element (`.step` in `web/styles.tw.css`) so it costs no markup and
/// vanishes with the grid at narrow widths, where a horizontal connector
/// between stacked cards would be a line pointing at nothing.
class ProcessArc extends StatelessComponent {
  const ProcessArc({required this.steps, super.key});

  final List<ProcessStepModel> steps;

  @override
  Component build(BuildContext context) {
    if (steps.isEmpty) return const div([]);

    return div(
      classes: 'grid gap-5 sm:grid-cols-2 lg:grid-cols-4',
      [
        for (final (i, step) in steps.indexed) _step(step, i + 1),
      ],
    );
  }

  static Component _step(ProcessStepModel step, int index) {
    final number = index.toString().padLeft(2, '0');

    return div(
      // `isolate` contains the ghost numeral's `-z-10` to this card, so it
      // paints over the card's own surface rather than under the section.
      classes: 'step card reveal group relative isolate overflow-hidden '
          'p-7 sm:p-8',
      [
        // The motif at step scale. Texture, never content.
        span(
          classes: 'step-num ghost-mono pointer-events-none absolute -right-2 '
              '-top-5 -z-10 select-none font-display font-extrabold',
          attributes: const {'aria-hidden': 'true'},
          [Component.text(number)],
        ),

        span(
          classes: 'inline-flex text-iris-400 transition-transform '
              'duration-500 ease-spring group-hover:scale-110',
          [AppIcons.byName(step.icon, classes: 'h-6 w-6')],
        ),

        h3(
          classes: 'mt-7 font-display text-xl font-bold tracking-tight '
              'text-ink-100',
          [Component.text(step.title)],
        ),

        p(
          classes: 'mt-3 text-sm leading-relaxed text-ink-400',
          [Component.text(step.blurb)],
        ),

        if (step.artefact.isNotEmpty) ...[
          const div(classes: 'divider-quiet mt-7', []),
          p(
            classes: 'mt-4 flex items-baseline gap-2.5 text-sm text-ink-200',
            [
              const span(
                classes: 'h-px w-3 shrink-0 translate-y-[-0.3rem] bg-iris-500',
                [],
              ),
              Component.text(step.artefact),
            ],
          ),
        ],
      ],
    );
  }
}

