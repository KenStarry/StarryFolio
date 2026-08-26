import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';

/// The avatar, presented as a dossier card rather than the hero's fanned
/// stack.
///
/// Deliberately a different object from `PortraitFrame`. The hero's stack is
/// the site's opening flourish and repeating it here would spend the same
/// trick twice; this is the same artwork treated as a record — one card, a
/// caption strip, and ruled fact rows underneath. Sitting beside the `<h1>` it
/// answers *who, what, where and when* before a word of prose is read.
///
/// The rows are a real `<dl>`. A visitor sees a grid; a screen reader gets
/// labelled term/definition pairs, which is what this content actually is.
class AboutDossier extends StatelessComponent {
  const AboutDossier({this.currentCompany = '', super.key});

  /// Company from the current role, so the card never hard-codes an employer
  /// that could go stale.
  final String currentCompany;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'relative mx-auto w-full max-w-sm lg:mx-0 lg:max-w-none',
      [
        // One soft bloom to seat the card in the ground. The only glow on the
        // page, as it is the only one on every other page.
        const div(
          classes: 'bloom pointer-events-none absolute -inset-16 -z-10',
          attributes: {'aria-hidden': 'true'},
          [],
        ),

        div(
          classes: 'float-card relative border border-ink-700 bg-ink-850',
          [
            const div(
              classes: 'relative aspect-square w-full overflow-hidden',
              [
                img(
                  src: '/${SiteConfig.portrait}',
                  alt: SiteConfig.portraitAlt,
                  // The largest element above the fold on this page, so it is
                  // fetched eagerly and at priority. Intrinsic size reserves
                  // the box, which is what stops the facts below it shifting.
                  attributes: {
                    'decoding': 'async',
                    'fetchpriority': 'high',
                    'width': '768',
                    'height': '768',
                  },
                  classes: 'h-full w-full object-contain object-bottom',
                ),

                div(
                  classes: 'absolute inset-x-0 bottom-0 flex items-center '
                      'justify-between border-t border-ink-700/80 '
                      'bg-ink-900/90 px-4 py-3 backdrop-blur-sm',
                  [
                    span(
                      classes: 'type-eyebrow font-mono text-ink-300',
                      [Component.text(SiteConfig.name)],
                    ),
                    span(
                      classes: 'type-eyebrow font-mono text-iris-400',
                      [Component.text('UTC+3')],
                    ),
                  ],
                ),
              ],
            ),

            dl(
              classes: 'px-6 pb-6 pt-2 sm:px-7',
              [
                _row('Role', SiteConfig.role),
                _row('Based', SiteConfig.location),
                if (currentCompany.isNotEmpty) _row('Currently', currentCompany),
                _row(
                  'Building',
                  '${SiteConfig.currentSideProject}, on the side',
                ),
                _status(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Component _row(String label, String value) => div(
        classes: 'meta-row',
        [
          dt(
            classes: 'type-eyebrow self-center font-mono text-ink-500',
            [Component.text(label)],
          ),
          dd(
            classes: 'self-center text-sm text-ink-200',
            [Component.text(value)],
          ),
        ],
      );

  /// The availability row carries the live dot — the same signal the hero
  /// uses, so "available" means the same thing in both places.
  static Component _status() => const div(
        classes: 'meta-row',
        [
          dt(
            classes: 'type-eyebrow self-center font-mono text-ink-500',
            [Component.text('Status')],
          ),
          dd(
            classes: 'flex items-center gap-2.5 self-center text-sm '
                'text-ink-200',
            [
              if (SiteConfig.available)
                span(
                  classes: 'h-1.5 w-1.5 shrink-0 rounded-full bg-iris-400 '
                      'dot-live',
                  [],
                ),
              Component.text(
                SiteConfig.available
                    ? SiteConfig.availabilityLabel
                    : 'Booked for now',
              ),
            ],
          ),
        ],
      );
}
