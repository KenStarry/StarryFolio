import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/testimonial_model.dart';

/// What other people said, as a band on the home page.
///
/// ## It renders nothing when there is nothing
///
/// No heading, no empty state, no "testimonials coming soon". A section that
/// announces it has no social proof is worse than no section — it draws
/// attention to the absence and dates the site. While
/// `TestimonialsLocalDatasource` is empty this component is invisible, and the
/// page reads as though it was never planned.
///
/// ## Shape
///
/// One featured quote set large, then the rest as cards. That is the same
/// featured-plus-grid rhythm the projects index and the writing index use, so
/// the page does not acquire a third idea of how a collection looks.
///
/// The quotation mark is a real glyph set enormous and faint rather than an
/// icon: it is the ghost motif applied at component scale — texture that
/// repeats something already present, never content. It is `aria-hidden`, and
/// the quote itself is a `<blockquote>` so the relationship between the words
/// and their author survives into the accessibility tree.
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
    final rest = [
      for (final t in testimonials)
        if (t != featured) t,
    ];

    // If any entry is still a stand-in, the band says so on the page. Relying
    // on somebody remembering to strip placeholders before a deploy is not a
    // safeguard; this is.
    final hasDraft = testimonials.any((t) => t.draft);

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
                // Placeholder entries label themselves on the page rather
                // than relying on somebody remembering to remove them.
                if (hasDraft)
                  const span(
                    classes: 'border border-ink-600 px-2.5 py-1 font-mono '
                        'text-[10px] uppercase tracking-wider text-ink-400',
                    [Component.text('Sample content')],
                  ),
              ],
            ),

            const h2(
              classes: 'type-section mt-5 max-w-xl font-display font-bold '
                  'text-ink-100',
              [Component.text('What it is like on the other side')],
            ),

            _Featured(testimonial: featured),

            if (rest.isNotEmpty)
              div(
                classes: 'stagger mt-8 grid gap-6 sm:grid-cols-2 '
                    'lg:grid-cols-3',
                [for (final t in rest) _Card(testimonial: t)],
              ),
          ],
        ),
      ],
    );
  }
}

/// The lead quote, set as an editorial spread.
///
/// **Not a card, and deliberately not `.card-invert`.** The site permits
/// exactly one inverted element per screen and the home page already spends it
/// on the featured service card; a second inversion cancels the first
/// (CLAUDE.md §8). Flat is the better answer anyway — it is how `/projects`
/// presents its featured work, and putting a panel around the most important
/// thing in a band makes it *one of* the things in the band.
///
/// The composition is a magazine pull-quote: an oversized opening mark, the
/// quote at display scale, and the byline in its own column behind a vertical
/// hairline. Three devices carry it, and none of them is a box:
///
/// * **The mark is a real typographic element, not ghost texture.** The band
///   already carries a ghost (`Said`); a second faint mark inside it would be
///   two whispers where one statement is wanted. So this one is `iris` at
///   readable strength and it anchors the quote the way a drop cap anchors a
///   paragraph.
/// * **The quote is two-tone**, the site's headline device applied to running
///   text — [TestimonialModel.emphasis] bright against the rest in `ink-300`.
///   A narrower tonal gap than `TwoToneTitle` uses, because a quote has to
///   stay readable across four lines where a headline does not.
/// * **The byline is a column, not a footer row.** Set beside the quote behind
///   a rule, it reads as attribution the way a masthead does — and it gives
///   the monogram, the role and the link to the work somewhere to sit
///   together instead of strung along one line.
class _Featured extends StatelessComponent {
  const _Featured({required this.testimonial});

  final TestimonialModel testimonial;

  @override
  Component build(BuildContext context) {
    final t = testimonial;
    final runs = t.runs;

    // Display type does not survive length. `type-quote` tops out at 2rem,
    // which is right for a line somebody will read in one breath and wrong
    // for a paragraph: a hundred words at that size runs past twenty lines
    // and stops being a pull-quote at all.
    //
    // So the scale steps down as the quote grows. The band keeps its
    // emphasis, its mark and its byline either way, and a long quote reads as
    // considered rather than as a layout that gave up. Classes are literals
    // because the Tailwind scanner reads this source (CLAUDE.md §8).
    final words = t.quote.split(RegExp(r'\s+')).length;
    final scale = words <= 45
        ? 'type-quote'
        : words <= 80
            ? 'text-xl leading-relaxed sm:text-2xl sm:leading-snug'
            : 'text-lg leading-relaxed sm:text-xl sm:leading-relaxed';

    return figure(
      classes: 'reveal mt-14 grid gap-10 lg:grid-cols-[1fr_15rem] lg:gap-16',
      [
        div([
          // The opening mark, on its own line. Sized against the quote rather
          // than the section, so it scales with what it introduces.
          const div(
            classes: 'font-display text-7xl font-extrabold leading-[0.6] '
                'text-iris-500/45 sm:text-8xl',
            attributes: {'aria-hidden': 'true'},
            [Component.text('“')],
          ),

          // Emitted as one escaped string rather than as sibling nodes.
          //
          // Jaspr indents child components onto their own lines, and that
          // whitespace collapses to a *rendered space* between inline
          // siblings — so a `<span>` ending mid-sentence produced
          // `product .` with a gap before the full stop. One node has no
          // siblings to be separated from.
          //
          // Everything interpolated goes through [_esc] first, so authored
          // content still cannot inject markup.
          blockquote(
            classes: '$scale mt-6 font-display font-bold tracking-tight '
                'text-ink-300',
            [
              RawText(
                '${_esc(runs.before)}'
                '<span class="text-ink-100">${_esc(runs.highlight)}</span>'
                '${_esc(runs.after)}'
                // Normal-size close against the oversized open — the
                // asymmetry is the editorial convention, and a matching
                // giant mark at the end would fight the byline for the
                // corner.
                '<span class="text-ink-500">\u{201D}</span>',
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

            if (t.projectSlug case final slug?)
              Link(
                to: RoutePaths.projectDetail(slug),
                classes: 'link-line type-eyebrow mt-7 inline-flex '
                    'items-center font-mono text-ink-300 transition-colors '
                    'hover:text-ink-100',
                children: const [Component.text('The work →')],
              ),
          ],
        ),
      ],
    );
  }
}

/// Escapes text for interpolation into [RawText].
///
/// The quote runs come from the datasource rather than from a visitor, but
/// escaping is not conditional on trusting the source — the moment this
/// content moves behind a CMS the trust boundary moves with it, and a helper
/// that only works for trusted input is a helper that will be misused.
String _esc(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

class _Card extends StatelessComponent {
  const _Card({required this.testimonial});

  final TestimonialModel testimonial;

  @override
  Component build(BuildContext context) {
    return figure(
      classes: 'card flex flex-col p-7 sm:p-8',
      [
        blockquote(
          classes: 'text-[0.9375rem] leading-relaxed text-ink-300',
          [Component.text('“${testimonial.quote}”')],
        ),
        const div(classes: 'flex-1 min-h-8', []),
        _Attribution(testimonial: testimonial),
      ],
    );
  }
}

/// Who said it, and where that can be checked.
///
/// Always rendered — [TestimonialModel] requires a name and a role for exactly
/// this reason. Where a [TestimonialModel.source] exists the name becomes a
/// link, because a verifiable quote is worth several unverifiable ones.
class _Attribution extends StatelessComponent {
  const _Attribution({required this.testimonial});

  final TestimonialModel testimonial;

  @override
  Component build(BuildContext context) {
    final t = testimonial;

    final name = t.source == null
        ? span(
            classes: 'font-display text-sm font-bold '
                'text-ink-100',
            [Component.text(t.name)],
          )
        : a(
            href: t.source!,
            target: Target.blank,
            attributes: const {'rel': 'noopener'},
            classes: 'link-line font-display text-sm font-bold '
                'text-ink-100',
            [Component.text(t.name)],
          );

    return figcaption(
      classes: 'relative mt-8 flex items-center gap-4 border-t pt-6 '
          'border-ink-700',
      [
        // A monogram rather than a stock face. An invented photograph beside a
        // real quote undermines the quote.
        if (t.avatar case final src?)
          img(
            src: '/$src',
            alt: '',
            classes: 'h-11 w-11 shrink-0 rounded-full object-cover',
            attributes: const {'loading': 'lazy', 'decoding': 'async'},
          )
        else
          div(
            classes: 'flex h-11 w-11 shrink-0 items-center justify-center '
                'rounded-full border font-display text-sm font-bold '
                'border-ink-700 text-ink-400',
            attributes: const {'aria-hidden': 'true'},
            [Component.text(t.initial)],
          ),

        div(
          classes: 'min-w-0',
          [
            name,
            p(
              classes: 'mt-0.5 font-mono text-[11px] '
                  'text-ink-500',
              [Component.text(t.attribution)],
            ),
          ],
        ),

        // The build the quote came out of — the difference between a claim and
        // a claim you can go and check.
        if (t.projectSlug case final slug?)
          Link(
            to: RoutePaths.projectDetail(slug),
            classes: 'link-line type-eyebrow ml-auto shrink-0 font-mono '
                'text-ink-400',
            children: const [Component.text('The work →')],
          ),
      ],
    );
  }
}
