import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/two_tone_title.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../about/domain/model/about_profile.dart';
import '../../../about/presentation/components/role_card.dart';

/// The home page's About band — a door, not a chapter.
///
/// This used to be the longest block on the page: a pull quote, two bio
/// paragraphs, a "currently" panel, three stats and three ruled role rows. All
/// of it true, and all of it repeated somewhere better. The quote restated the
/// heading in longer words; the panel and the stats now sit in `/about`'s own
/// header, beside the dossier.
///
/// What is left is a heading, one sentence, and the career as four cards. Under
/// forty words, and it says more than the hundred and eighty did — because a
/// row of company names is read in a glance, where prose has to be read in
/// order.
///
/// Receives an already-resolved profile rather than fetching: the home page
/// owns its awaits, so the whole page renders in one pass.
class AboutSection extends StatelessComponent {
  const AboutSection({required this.profile, this.error, super.key});

  final AboutProfile profile;

  /// Set when the repository returned a `Left`. The heading and the door
  /// through to `/about` still render — they are static content that deserves
  /// to be indexed either way.
  final String? error;

  @override
  Component build(BuildContext context) {
    return section(
      id: 'about',
      classes: 'bg-ink-900 py-24 sm:py-32 lg:py-36',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            // ── Header: the statement, and the way through ──
            div(
              classes: 'reveal flex flex-wrap items-end justify-between gap-8',
              [
                const div(
                  classes: 'max-w-xl',
                  [
                    Eyebrow('About'),
                    TwoToneTitle(
                      lines: [
                        (text: 'The last 10%', muted: false),
                        (text: 'is the product.', muted: true),
                      ],
                      classes: 'type-section mt-5 font-display font-bold '
                          'text-ink-100',
                      isPageHeading: false,
                      mutedWeight: 'font-semibold',
                    ),
                  ],
                ),
                _storyLink(),
              ],
            ),

            const div(classes: 'divider mt-12', []),

            const p(
              classes: 'reveal mt-10 max-w-xl text-sm leading-relaxed '
                  'text-ink-400 sm:text-[0.9375rem]',
              [
                Component.text(
                  'Five years, four teams, and the same job every time: own '
                  'the whole surface — design system, architecture, release.',
                ),
              ],
            ),

            // ── The career, as objects ──
            if (error != null)
              div(classes: 'mt-10', [ErrorNotice(message: error!)])
            else
              div(
                classes: 'mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-4',
                [
                  for (final role in profile.experience.take(4))
                    RoleCard(role: role),
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
