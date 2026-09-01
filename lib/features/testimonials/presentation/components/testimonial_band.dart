import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/testimonial_model.dart';
import 'person_chips.dart';

/// What other people said, as a band on the home page.
///
/// ## It renders nothing when there is nothing
///
/// No heading, no empty state, no "testimonials coming soon". A section that
/// announces it has no social proof is worse than no section — it draws
/// attention to the absence and dates the site.
///
/// ## It is a doorway, not the room
///
/// This used to print the featured quote whole, stepping the type down as the
/// quote grew so a hundred-word paragraph would still fit. It fitted, and it
/// was the tallest thing on the home page: a wall of grey text between the
/// work and the contact band, at a size chosen by how much somebody happened
/// to write.
///
/// Now it does what every other home band does — Services teases `/services`,
/// Works teases `/projects` — and shows the one clause worth reading, set at
/// display scale, with the way through to the full note beneath it. The model
/// already carried that clause as [TestimonialModel.emphasis]; it just was not
/// being used as a lede.
///
/// The count is stated plainly rather than hidden behind "and others", because
/// three is a fact and "others" is a hedge.
class TestimonialBand extends StatelessComponent {
  const TestimonialBand({required this.testimonials, super.key});

  final List<TestimonialModel> testimonials;

  @override
  Component build(BuildContext context) {
    if (testimonials.isEmpty) return const div([]);

    // At most one entry leads. If none is flagged, the first does — a band
    // whose largest element is missing reads as a layout bug.
    final featured = testimonials.firstWhere(
      (t) => t.featured,
      orElse: () => testimonials.first,
    );

    // If any entry is still a stand-in, the band says so on the page. Relying
    // on somebody remembering to strip placeholders before a deploy is not a
    // safeguard; this is.
    final hasDraft = testimonials.any((t) => t.draft);
    final others = testimonials.length - 1;

    return section(
      classes: 'relative overflow-hidden bg-ink-800 py-24 sm:py-32',
      [
        const GhostText(
          'Said',
          size: GhostSize.small,
          faint: true,
          classes: 'absolute -bottom-8 right-0',
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'flex flex-wrap items-center gap-4',
              [
                const Eyebrow('In their words'),
                if (hasDraft)
                  const span(
                    classes: 'border border-ink-600 px-2.5 py-1 font-mono '
                        'text-[10px] uppercase tracking-wider text-ink-400',
                    [Component.text('Sample content')],
                  ),
              ],
            ),

            _Lede(testimonial: featured),
            _Footer(others: others),
          ],
        ),
      ],
    );
  }
}

/// The clause worth reading, set as a pull-quote.
///
/// Deliberately not a card and not `.card-invert`: the site permits exactly
/// one inverted element per screen and the home page already spends it on the
/// featured service card. Flat is the better answer anyway — it is how
/// `/projects` presents its featured work, and putting a panel around the most
/// important thing in a band makes it *one of* the things in the band.
class _Lede extends StatelessComponent {
  const _Lede({required this.testimonial});

  final TestimonialModel testimonial;

  @override
  Component build(BuildContext context) {
    final t = testimonial;

    // `lede` is the emphasis clause where one is set and the whole quote
    // otherwise — which is right, because a quote short enough to have no
    // emphasis is short enough to print. The type scale holds either way,
    // since the model gates length separately.
    final lede = t.lede;

    return figure(
      classes: 'reveal mt-12 grid gap-10 lg:grid-cols-[1fr_16rem] lg:gap-16',
      [
        div([
          const div(
            classes: 'font-display text-7xl font-extrabold leading-[0.6] '
                'text-iris-500/45 sm:text-8xl',
            attributes: {'aria-hidden': 'true'},
            [Component.text('“')],
          ),

          // No `emphasis` span here. The whole line *is* the emphasis now, so
          // splitting it into two tones would be highlighting a highlight.
          blockquote(
            classes: 'type-quote mt-6 max-w-3xl font-display font-bold '
                'tracking-tight text-ink-100',
            [Component.text('$lede”')],
          ),

          // Only offered when there is more to read. Where the lede *is* the
          // whole quote, this would open an overlay showing the same words.
          if (t.isLong)
            a(
              href: '${RoutePaths.testimonials}#${t.slug}',
              classes: 'link-line group mt-8 inline-flex items-center gap-2.5 '
                  'text-sm font-medium text-ink-200 transition-colors '
                  'duration-300 hover:text-ink-100',
              attributes: {'aria-label': 'Read ${t.name}\'s full note'},
              [
                const Component.text('Read the full note'),
                span(
                  classes: 'transition-transform duration-500 ease-soft '
                      'group-hover:translate-x-1',
                  [AppIcons.arrow(classes: 'h-4 w-4')],
                ),
              ],
            ),
        ]),

        // ── Byline column ──
        figcaption(
          classes: 'flex flex-col justify-end border-t border-ink-700 pt-8 '
              'lg:border-l lg:border-t-0 lg:pl-12 lg:pt-0',
          [
            if (t.avatar case final src?)
              img(
                src: '/$src',
                alt: '',
                classes: 'h-14 w-14 rounded-full object-cover',
                attributes: const {'loading': 'lazy', 'decoding': 'async'},
              )
            else
              div(
                classes: 'flex h-14 w-14 items-center justify-center '
                    'rounded-full border border-ink-700 font-display text-lg '
                    'font-bold text-ink-400',
                attributes: const {'aria-hidden': 'true'},
                [Component.text(t.initial)],
              ),

            div(
              classes: 'mt-6',
              [
                if (t.source case final href?)
                  a(
                    href: href,
                    target: Target.blank,
                    attributes: const {'rel': 'noopener'},
                    classes: 'link-line font-display text-base font-bold '
                        'text-ink-100',
                    [Component.text(t.name)],
                  )
                else
                  p(
                    classes: 'font-display text-base font-bold text-ink-100',
                    [Component.text(t.name)],
                  ),

                p(
                  classes: 'mt-2 font-mono text-[11px] leading-relaxed '
                      'text-ink-500',
                  [Component.text(t.role)],
                ),
                if (t.company.isNotEmpty)
                  p(
                    classes: 'font-mono text-[11px] leading-relaxed '
                        'text-ink-500',
                    [Component.text(t.company)],
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

/// The way through to the page, and the invitation to add to it.
class _Footer extends StatelessComponent {
  const _Footer({required this.others});

  /// How many quotes are not the featured one.
  final int others;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'reveal mt-14 flex flex-wrap items-center gap-x-8 gap-y-4 '
          'border-t border-ink-700 pt-8',
      [
        Link(
          to: RoutePaths.testimonials,
          classes: 'link-line group inline-flex items-center gap-2.5 text-sm '
              'font-medium text-ink-200 transition-colors duration-300 '
              'hover:text-ink-100',
          children: [
            Component.text(
              others > 0
                  ? 'Read all ${others + 1}'
                  : 'Everything people have said',
            ),
            span(
              classes: 'transition-transform duration-500 ease-soft '
                  'group-hover:translate-x-1.5',
              [AppIcons.arrow(classes: 'h-4 w-4')],
            ),
          ],
        ),

        const Link(
          to: '${RoutePaths.testimonials}#add-yours',
          classes: 'type-eyebrow font-mono text-ink-500 transition-colors '
              'duration-300 hover:text-iris-300',
          children: [Component.text('Worked with me? Add yours')],
        ),
      ],
    );
  }
}
