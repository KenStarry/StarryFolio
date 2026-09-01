import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/experience_model.dart';

/// The whole career as one proportional strip.
///
/// ## What it replaced, and why it is better
///
/// The experience section used to run a rule down three screens with the
/// companies hanging off it. The only thing that rule genuinely did well was
/// convey *sequence and duration* — and it spent three screens doing it. This
/// does the same job in one bar: each company holds its true share of the
/// total span, oldest at the left, so the shape of a career is legible before
/// a single word is read.
///
/// **The widths come from real parsed months.** A segment cannot flatter a
/// short stint, because the number it is drawn from is the same one printed
/// beside it. Any company whose dates cannot be parsed is dropped from the bar
/// rather than given a guessed width — see [RoleStint.months] for why an
/// absent figure beats a wrong one.
///
/// Widths are inline styles, not classes. Tailwind's scanner reads source
/// literals, so a computed `w-[37%]` would be purged; a percentage on the
/// element is the only correct way to size something from data.
class CareerSpan extends StatelessComponent {
  const CareerSpan({required this.experience, super.key});

  /// Companies, newest first, as the datasource holds them.
  final List<ExperienceModel> experience;

  @override
  Component build(BuildContext context) {
    // Oldest first: a span reads left to right as time moving forward.
    final entries = [
      for (final entry in experience.reversed)
        if (entry.months case final months?) (entry: entry, months: months),
    ];
    if (entries.length < 2) return const div([]);

    final total = entries.fold<int>(0, (sum, e) => sum + e.months);
    if (total <= 0) return const div([]);

    return div(
      classes: 'reveal',
      [
        div(
          classes: 'span-bar',
          attributes: const {'aria-hidden': 'true'},
          [
            for (final e in entries)
              div(
                classes:
                    e.entry.current ? 'span-seg span-seg-now' : 'span-seg',
                // Rounded to two decimals: the raw ratio prints seventeen
                // digits into the markup for a difference no display can
                // resolve.
                styles: Styles(
                  width: Unit.percent(
                    double.parse(
                      (e.months / total * 100).toStringAsFixed(2),
                    ),
                  ),
                ),
                [],
              ),
          ],
        ),

        // The key doubles as the accessible version of the bar, which is why
        // the bar itself is hidden: a screen reader gets the companies, their
        // periods and their durations as text, in order, instead of a row of
        // unlabelled boxes.
        div(
          classes: 'mt-5 flex flex-wrap gap-x-8 gap-y-3',
          [
            for (final e in entries)
              div(
                classes: 'span-key',
                [
                  span(
                    classes: e.entry.current
                        ? 'span-key-dot span-key-dot-now'
                        : 'span-key-dot',
                    attributes: const {'aria-hidden': 'true'},
                    [],
                  ),
                  span(
                    classes: 'text-xs text-ink-400',
                    [
                      span(
                        classes: 'text-ink-200',
                        [Component.text(e.entry.company)],
                      ),
                      span(
                        classes: 'ml-2 font-mono text-[11px] text-ink-500',
                        [
                          Component.text(
                            e.entry.duration ?? '',
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
