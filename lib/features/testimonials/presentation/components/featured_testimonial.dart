import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/testimonial_model.dart';
import 'person_chips.dart';

/// The lead quote on `/testimonials`, given a band of its own.
///
/// ## Why this exists separately from the card and the home band
///
/// The home band shows one clause and links here. The grid shows every quote
/// clamped to four lines. Neither of those ever prints a testimonial the way
/// its author wrote it, and on the page that exists to hold them that is the
/// wrong outcome — so this one is set in full, at scale, with nothing
/// competing for the row.
///
/// ## The person's own name is the ghost
///
/// Every other instance of the motif repeats the *site's* language: a section
/// name, a page title, a project's wordmark. Here it is the contributor's
/// name, set enormous behind their words.
///
/// That is the point of the whole page. Somebody took the trouble to write
/// something generous; the least the layout can do is make the moment theirs
/// rather than another slot in a portfolio. It stays texture — `aria-hidden`,
/// unreadable at 3.5% — because their name is already printed as real content
/// in the byline directly beneath it.
///
/// ## Flat, not a card
///
/// The site permits one inverted element per screen, and a panel around the
/// most important thing in a band makes it *one of* the things in the band.
/// This is how `/projects` presents its featured work too.
class FeaturedTestimonial extends StatelessComponent {
  const FeaturedTestimonial({required this.testimonial, super.key});

  final TestimonialModel testimonial;

  @override
  Component build(BuildContext context) {
    final t = testimonial;
    final runs = t.runs;

    // Display type does not survive length. `type-quote` tops out at 2rem,
    // which is right for a line read in one breath and wrong for a paragraph:
    // a hundred words at that size runs past twenty lines and stops being a
    // pull-quote at all. So the scale steps down as the quote grows, and the
    // band keeps its mark, its emphasis and its byline either way.
    //
    // Classes are literals because the Tailwind scanner reads this source.
    final scale = t.wordCount <= 45
        ? 'type-quote'
        : t.wordCount <= 80
            ? 'text-xl leading-relaxed sm:text-2xl sm:leading-snug'
            : 'text-lg leading-relaxed sm:text-xl sm:leading-relaxed';

    return section(
      id: t.slug,
      classes: 'relative isolate scroll-mt-24 overflow-hidden bg-ink-800 '
          'py-20 sm:py-28',
      [
        // Their name, not the site's. Hung to bleed off the left edge the way
        // the page headers' ghost does.
        GhostText(
          t.name,
          size: GhostSize.band,
          faint: true,
          classes: 'absolute -bottom-6 -left-4 sm:-left-8',
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const Eyebrow('The one to read first'),

            figure(
              classes: 'reveal mt-10 grid gap-10 lg:grid-cols-[1fr_16rem] '
                  'lg:gap-16',
              [
                div([
                  const div(
                    classes: 'font-display text-7xl font-extrabold '
                        'leading-[0.6] text-iris-500/45 sm:text-8xl',
                    attributes: {'aria-hidden': 'true'},
                    [Component.text('“')],
                  ),

                  // Emitted as one escaped string rather than as sibling
                  // nodes. Jaspr indents children onto their own lines, and
                  // that whitespace collapses to a *rendered space* between
                  // inline siblings — a `<span>` ending mid-sentence produced
                  // `love .` with a gap before the full stop. One node has no
                  // siblings to be separated from.
                  //
                  // Everything interpolated goes through [_esc], so authored
                  // content cannot inject markup.
                  blockquote(
                    classes: '$scale mt-6 max-w-3xl font-display font-bold '
                        'tracking-tight text-ink-300',
                    [
                      RawText(
                        '${_esc(runs.before)}'
                        '<span class="text-ink-100">'
                        '${_esc(runs.highlight)}</span>'
                        '${_esc(runs.after)}'
                        // Normal-size close against the oversized open: the
                        // asymmetry is the editorial convention, and a second
                        // giant mark would fight the byline for the corner.
                        '<span class="text-ink-500">\u{201D}</span>',
                      ),
                    ],
                  ),
                ]),

                // ── Byline column ──
                figcaption(
                  classes: 'flex flex-col justify-end border-t border-ink-700 '
                      'pt-8 lg:border-l lg:border-t-0 lg:pl-12 lg:pt-0',
                  [
                    if (t.avatar case final src?)
                      img(
                        src: '/$src',
                        alt: '',
                        classes: 'h-16 w-16 rounded-full object-cover',
                        attributes: const {
                          'loading': 'lazy',
                          'decoding': 'async',
                        },
                      )
                    else
                      div(
                        classes: 'flex h-16 w-16 items-center justify-center '
                            'rounded-full border border-ink-700 font-display '
                            'text-xl font-bold text-ink-400',
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
                            classes: 'link-line font-display text-lg '
                                'font-bold text-ink-100',
                            [Component.text(t.name)],
                          )
                        else
                          p(
                            classes: 'font-display text-lg font-bold '
                                'text-ink-100',
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

                    PersonChips(links: t.links, name: t.name, classes: 'mt-6'),

                    if (t.projectSlug case final slug?)
                      Link(
                        to: RoutePaths.projectDetail(slug),
                        classes: 'link-line type-eyebrow mt-7 inline-flex '
                            'items-center font-mono text-ink-300 '
                            'transition-colors hover:text-ink-100',
                        children: const [Component.text('The work →')],
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
