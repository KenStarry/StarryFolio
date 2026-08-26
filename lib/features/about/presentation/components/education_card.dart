import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/education_model.dart';

/// One qualification.
///
/// Set as a wide panel rather than a card in a grid: there is usually one of
/// these, and a lone card in a three-column grid looks like two are missing.
/// The years sit in the same left column the experience entries use, so the
/// two bands read as one continuous document even though they are built from
/// different models.
class EducationCard extends StatelessComponent {
  const EducationCard({required this.education, super.key});

  final EducationModel education;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'reveal group border border-ink-700 bg-ink-850 p-7 sm:p-9',
      [
        div(
          classes: 'grid gap-6 lg:grid-cols-[11rem_1fr] lg:gap-12',
          [
            // ── When ──
            div([
              p(
                classes: 'font-mono text-sm tracking-tight text-ink-300',
                [Component.text(education.period)],
              ),
              if (education.draft)
                const p(
                  classes: 'mt-3 font-mono text-[10px] uppercase '
                      'tracking-[0.14em] text-ink-600',
                  [Component.text('details to confirm')],
                ),
            ]),

            // ── What ──
            div([
              h3(
                classes: 'font-display text-xl font-bold leading-tight '
                    'tracking-tight text-ink-100 sm:text-2xl',
                [Component.text(education.qualification)],
              ),
              p(
                classes: 'mt-2 text-sm text-ink-200',
                [Component.text(education.institution)],
              ),

              if (education.note.isNotEmpty)
                p(
                  classes: 'mt-5 max-w-2xl text-sm leading-relaxed text-ink-400',
                  [Component.text(education.note)],
                ),

              if (education.focus.isNotEmpty) ...[
                const div(classes: 'divider-quiet mt-7', []),
                div(
                  classes: 'mt-6 flex flex-wrap gap-2',
                  [
                    for (final subject in education.focus)
                      span(classes: 'pill', [Component.text(subject)]),
                  ],
                ),
              ],
            ]),
          ],
        ),
      ],
    );
  }
}
