import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../about/domain/model/education_model.dart';

/// The degree, immediately under the hero.
///
/// ## Why it is a band and not a pill in the hero
///
/// The hero is a poster: a name, a statement, a portrait, three floating
/// stats. Adding a fourth claim inside it would not read as emphasis — it
/// would read as one more thing competing for the same glance, and the stat
/// pills would start looking like a list.
///
/// Giving it the next band instead buys the opposite: nothing shares the
/// space, so the eye has to land on it on the way down. And it lands at the
/// moment it is most useful — straight after the name, which is exactly where
/// a reader is deciding whether to keep going.
///
/// ## Why it looks like this
///
/// It borrows the certificate language from `SealedDocument` on `/documents` —
/// the drawn seal, the double hairline frame, the faint ruled ground — at
/// strip scale. Two reasons that is better than inventing a new treatment:
/// the page and the hub then read as the same claim seen twice rather than as
/// two designs, and a plate is the right *shape* for a conferral. Certificates
/// have embossed foil under the title; this is that, at 1/10th the size.
///
/// It is deliberately slim. A full section for one line of credential would
/// overplay it, and the restraint is what keeps it reading as a mark of record
/// rather than as a boast.
///
/// ## Where the words come from
///
/// [education] is the same `AboutLocalDatasource` entry that feeds `/about`,
/// `/documents` and the Person JSON-LD, so the four cannot disagree about
/// where the degree is from. The band renders nothing at all when there is no
/// education entry — an empty plate would be worse than no plate.
class HonoursBand extends StatelessComponent {
  const HonoursBand({required this.education, super.key});

  /// The qualification to display. Null renders nothing.
  final EducationModel? education;

  @override
  Component build(BuildContext context) {
    final degree = education;
    if (degree == null) return const div([]);

    // `qualification` is authored as `BSc Computer Science — First Class
    // Honours`. The honours half is the headline and the subject is the
    // qualifier, so the two are split rather than set as one long line — and
    // split here rather than stored apart, because every other surface wants
    // the whole string.
    final parts = degree.qualification.split('—');
    final subject = parts.first.trim();
    final honour = parts.length > 1 ? parts[1].trim() : degree.qualification;

    return section(
      classes: 'relative bg-ink-900 pb-20 sm:pb-24',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'honours-plate reveal relative overflow-hidden border '
                  'border-ink-700 bg-ink-850',
              [
                // The inset rules a certificate has and a card does not. Two,
                // because one reads as a border and two read as a document.
                const div(
                  classes: 'pointer-events-none absolute inset-2 border '
                      'border-ink-700/60',
                  [],
                ),
                const div(
                  classes: 'pointer-events-none absolute inset-[0.625rem] '
                      'border border-ink-700/30',
                  [],
                ),

                div(
                  classes: 'relative flex flex-col items-center gap-7 px-8 '
                      'py-9 text-center sm:px-12 md:flex-row md:gap-10 '
                      'md:text-left',
                  [
                    // The seal, at strip scale.
                    div(
                      classes: 'seal flex h-16 w-16 shrink-0 items-center '
                          'justify-center rounded-full border '
                          'border-iris-500/40 text-iris-400/80',
                      [AppIcons.byName('seal', classes: 'h-7 w-7')],
                    ),

                    div(
                      classes: 'min-w-0 flex-1',
                      [
                        const p(
                          classes: 'type-eyebrow font-mono text-ink-500',
                          [Component.text('Conferred 2024')],
                        ),
                        // Two-tone, following the site's headline rule: the
                        // clause that qualifies sits back a step in both
                        // colour and weight.
                        p(
                          classes: 'mt-3 font-display text-2xl font-extrabold '
                              'leading-tight tracking-tight text-ink-100 '
                              'sm:text-[1.75rem]',
                          [
                            Component.text(honour),
                            const Component.text(' '),
                            span(
                              classes: 'font-bold text-ink-400',
                              [Component.text(subject)],
                            ),
                          ],
                        ),
                        p(
                          classes: 'mt-3 text-sm leading-relaxed text-ink-400',
                          [Component.text(degree.institution)],
                        ),
                      ],
                    ),

                    // Points at the hub rather than restating the record —
                    // the plate makes the claim, the hub carries the proof.
                    Link(
                      to: RoutePaths.anchor(RoutePaths.documents, 'degree'),
                      classes: 'link-line type-eyebrow shrink-0 font-mono '
                          'text-ink-300 transition-colors hover:text-ink-100',
                      children: const [Component.text('Verify →')],
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
