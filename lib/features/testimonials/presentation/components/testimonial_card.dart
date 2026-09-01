import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../domain/model/testimonial_model.dart';
import 'person_chips.dart';
import 'testimonial_overlay.dart';

/// One quote as a card, for the grid on `/testimonials`.
///
/// The quote is clamped to four lines by CSS, never by cutting the string —
/// the full text stays in the markup so a crawler reads all of it, and the
/// "Read in full" anchor opens the matching [TestimonialOverlay]. Truncating
/// in Dart would have removed content from the pre-rendered HTML, which is the
/// one thing CLAUDE.md §0 does not allow.
///
/// The affordance only appears when there is something hidden to reveal. A
/// "read in full" under a quote already showing in full is a control that lies.
class TestimonialCard extends StatelessComponent {
  const TestimonialCard({required this.testimonial, super.key});

  final TestimonialModel testimonial;

  @override
  Component build(BuildContext context) {
    final t = testimonial;

    // The clamp is four lines; roughly forty words fills that at this size.
    // Below it there is nothing to reveal, so no control is offered.
    final clamped = t.wordCount > 40;

    return figure(
      id: t.slug,
      classes: 'card reveal group relative flex scroll-mt-28 flex-col p-7 '
          'sm:p-8',
      [
        const div(
          classes: 'font-display text-4xl font-extrabold leading-[0.5] '
              'text-iris-500/35',
          attributes: {'aria-hidden': 'true'},
          [Component.text('“')],
        ),

        blockquote(
          classes: '${clamped ? 'quote-clamp ' : ''}mt-5 '
              'text-[0.9375rem] leading-relaxed text-ink-300',
          [Component.text(t.quote)],
        ),

        if (clamped)
          a(
            // `RoutePaths.anchor`, never a bare `#id`. The document carries
            // `<base href="/">`, so a bare fragment resolves against the site
            // root and this link navigated to the *home page* instead of
            // opening the overlay a few pixels away.
            href: RoutePaths.anchor(
              RoutePaths.testimonials,
              testimonialAnchor(t.slug),
            ),
            classes: 'link-line mt-4 self-start font-mono text-[11px] '
                'uppercase tracking-[0.14em] text-ink-400 transition-colors '
                'hover:text-iris-300',
            attributes: {'aria-label': 'Read ${t.name}\'s note in full'},
            [const Component.text('Read in full')],
          ),

        const div(classes: 'flex-1 min-h-8', []),

        figcaption(
          classes: 'mt-7 border-t border-ink-700 pt-6',
          [
            div(
              classes: 'flex items-center gap-4',
              [
                // A monogram rather than a stock face. An invented photograph
                // beside a real quote undermines the quote.
                if (t.avatar case final src?)
                  img(
                    src: '/$src',
                    alt: '',
                    classes: 'h-11 w-11 shrink-0 rounded-full object-cover',
                    attributes: const {
                      'loading': 'lazy',
                      'decoding': 'async',
                    },
                  )
                else
                  div(
                    classes: 'flex h-11 w-11 shrink-0 items-center '
                        'justify-center rounded-full border border-ink-700 '
                        'font-display text-sm font-bold text-ink-400',
                    attributes: const {'aria-hidden': 'true'},
                    [Component.text(t.initial)],
                  ),

                div(
                  classes: 'min-w-0',
                  [
                    if (t.source case final href?)
                      a(
                        href: href,
                        target: Target.blank,
                        attributes: const {'rel': 'noopener'},
                        classes: 'link-line font-display text-sm font-bold '
                            'text-ink-100',
                        [Component.text(t.name)],
                      )
                    else
                      p(
                        classes: 'font-display text-sm font-bold text-ink-100',
                        [Component.text(t.name)],
                      ),
                    p(
                      classes: 'mt-0.5 font-mono text-[11px] text-ink-500',
                      [Component.text(t.attribution)],
                    ),
                  ],
                ),

                if (t.projectSlug case final slug?)
                  Link(
                    to: RoutePaths.projectDetail(slug),
                    classes: 'link-line type-eyebrow ml-auto shrink-0 '
                        'font-mono text-ink-400',
                    children: const [Component.text('The work →')],
                  ),
              ],
            ),

            PersonChips(links: t.links, name: t.name, classes: 'mt-5'),
          ],
        ),
      ],
    );
  }
}
