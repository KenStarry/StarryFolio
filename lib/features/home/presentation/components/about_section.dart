import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../../core/presentation/components/two_tone_title.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../about/domain/model/about_profile.dart';
import '../../../about/presentation/components/career_ledger.dart';

/// The home page's About band: a door, not a chapter.
///
/// ## What changed, and why
///
/// This was a heading, a paragraph and four cards in a row. Tidy, and flat —
/// four boxes of equal weight read as a grid, and a grid has no subject, so
/// the eye landed nowhere. It was also symmetrical, which is the one shape
/// this site avoids everywhere else.
///
/// It is now a split: the statement holds the left, the career holds the right
/// as a ledger, and the ledger has a subject — the row he is on now. The
/// asymmetry does what it does in the hero and on `/services`: it gives the
/// eye a place to start and a direction to travel.
///
/// ## It stays a doorway
///
/// Every ledger row links into `/about#experience`, so the band is a way
/// through rather than a heading with a link bolted to the corner. Nothing
/// here restates what that page says — the figures, the metrics and the
/// progressions all live there, and repeating them would make this a preview
/// rather than a door.
///
/// ## One breathing dot, and it is the ledger's
///
/// This band carried the availability line too, which put the same sentence on
/// the home page three times — hero, here, footer — and two breathing dots
/// within one band, six inches apart. The dot is a signal, and a signal
/// repeated beside itself is noise.
///
/// The ledger's lit `2026 - Now` row is the better present tense anyway: it is
/// specific, and it is the only thing here saying something the hero does not
/// already say.
///
/// Receives an already-resolved profile rather than fetching: the home page
/// owns its awaits, so the whole page renders in one pass.
class AboutSection extends StatelessComponent {
  const AboutSection({required this.profile, this.error, super.key});

  final AboutProfile profile;

  /// Set when the repository returned a `Left`. The heading, the statement and
  /// the door through to `/about` still render — they are static content that
  /// deserves to be indexed either way.
  final String? error;

  @override
  Component build(BuildContext context) {
    return section(
      id: 'about',
      // `isolate` gives the ghost a stacking context: at `-z-10` without one
      // it would paint behind this section's own background and never be seen.
      classes: 'relative isolate overflow-hidden bg-ink-900 py-24 sm:py-32 '
          'lg:py-36',
      [
        const GhostText(
          'About',
          faint: true,
          classes: GhostText.bandCorner,
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid gap-12 lg:grid-cols-[0.95fr_1.05fr] lg:gap-20',
              [
                // ── The statement ──
                div(
                  classes: 'reveal',
                  [
                    const Eyebrow('About'),

                    const TwoToneTitle(
                      lines: [
                        (text: 'The last 10%', muted: false),
                        (text: 'is the product.', muted: true),
                      ],
                      classes: 'type-section mt-5 font-display font-bold '
                          'text-ink-100',
                      isPageHeading: false,
                      mutedWeight: 'font-semibold',
                    ),

                    const p(
                      classes: 'mt-7 max-w-md text-sm leading-relaxed '
                          'text-ink-400 sm:text-[0.9375rem]',
                      [
                        Component.text(
                          'Five years, four teams, and one job description '
                          'that never really changes: do the whole thing. '
                          'Design system, architecture, release. Then poke at '
                          'the last 10% until it stops bothering me.',
                        ),
                      ],
                    ),

                    div(classes: 'mt-9', [_storyLink()]),
                  ],
                ),

                // ── The career ──
                div(
                  classes: 'reveal',
                  [
                    const p(
                      classes: 'type-eyebrow font-mono text-ink-500',
                      [Component.text('Where the work happened')],
                    ),
                    div(
                      classes: 'mt-2',
                      [
                        if (error != null)
                          div(
                            classes: 'mt-6',
                            [ErrorNotice(message: error!)],
                          )
                        else
                          CareerLedger(experience: profile.experience),
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

  /// The door through to `/about`.
  static Component _storyLink() => Link(
        to: RoutePaths.about,
        classes: 'link-line group inline-flex items-center gap-3 text-sm '
            'font-medium text-ink-200 transition-colors duration-300 '
            'hover:text-ink-100',
        children: [
          const Component.text('The full story'),
          span(
            classes: 'transition-transform duration-500 ease-soft '
                'group-hover:translate-x-1.5',
            [AppIcons.arrow(classes: 'h-4 w-4')],
          ),
        ],
      );
}
