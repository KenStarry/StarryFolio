import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../domain/model/testimonial_model.dart';
import 'person_chips.dart';

/// Builds the `#t-<slug>` id an overlay answers to.
///
/// Shared by the trigger and the panel so the two cannot drift — a
/// "read in full" pointing at an id nothing carries would silently do
/// nothing, which is the worst kind of broken.
String testimonialAnchor(String slug) => 't-$slug';

/// One quote, read in full, with no JavaScript.
///
/// Driven entirely by `:target` — see `.t-overlay` in `web/styles.tw.css` for
/// the mechanism and the reasoning behind choosing it over a scripted modal.
///
/// The panel is a `<dialog>`-shaped composition without being a `<dialog>`:
/// the real element requires `showModal()` to behave, and calling that needs
/// an island. Instead this is an `aria-labelledby` region whose first focusable
/// child is its own close control, with the scrim behind it acting as a second
/// one. A keyboard user can always tab straight to an exit, and Back closes it
/// because it is navigation rather than state.
///
/// Every overlay on the page renders its quote in full into the static HTML
/// regardless of whether it is open, which is what keeps the truncation on the
/// cards purely presentational.
class TestimonialOverlay extends StatelessComponent {
  const TestimonialOverlay({
    required this.testimonial,
    required this.closeHref,
    super.key,
  });

  final TestimonialModel testimonial;

  /// Where the close controls point — the current page without a fragment, so
  /// dismissing does not scroll the reader somewhere else.
  final String closeHref;

  @override
  Component build(BuildContext context) {
    final t = testimonial;
    final labelId = 'tl-${t.slug}';
    final runs = t.runs;

    return div(
      id: testimonialAnchor(t.slug),
      classes: 't-overlay',
      attributes: {'role': 'dialog', 'aria-labelledby': labelId},
      [
        // The scrim is itself a close link, so clicking anywhere outside the
        // panel dismisses. `aria-hidden` because the close control inside the
        // panel is the one that should be announced.
        a(
          href: closeHref,
          classes: 't-scrim',
          attributes: const {'aria-hidden': 'true', 'tabindex': '-1'},
          [],
        ),

        div(
          classes: 't-panel',
          [
            a(
              href: closeHref,
              classes: 't-close',
              attributes: const {'aria-label': 'Close'},
              [_cross()],
            ),

            const p(
              classes: 'type-eyebrow font-mono text-ink-500',
              [Component.text('In full')],
            ),

            // The two-tone device, applied to running text: the emphasised
            // clause bright against the rest in `ink-300`. A narrower tonal
            // gap than `TwoToneTitle` uses, because a quote has to stay
            // readable across a dozen lines where a headline does not.
            //
            // This is where that treatment belongs now. It used to sit on the
            // home band, where the whole quote was printed — but the band
            // shows only the emphasised clause today, and highlighting a
            // clause inside itself highlights nothing. Here there is a full
            // quote for it to stand out from again.
            //
            // Emitted as one escaped string rather than as sibling nodes:
            // Jaspr indents children onto their own lines, and that
            // whitespace collapses to a *rendered space* between inline
            // siblings — a `<span>` ending mid-sentence produced `love .`
            // with a gap before the full stop. One node has no siblings to be
            // separated from. Everything interpolated goes through [_esc], so
            // authored content still cannot inject markup.
            blockquote(
              classes: 'mt-6 font-display text-lg font-bold leading-relaxed '
                  'tracking-tight text-ink-300 sm:text-xl',
              [
                RawText(
                  '\u{201C}'
                  '${_esc(runs.before)}'
                  '<span class="text-ink-100">${_esc(runs.highlight)}</span>'
                  '${_esc(runs.after)}'
                  '\u{201D}',
                ),
              ],
            ),

            const div(classes: 'divider-quiet mt-8', []),

            div(
              classes: 'mt-7 flex flex-wrap items-end justify-between gap-6',
              [
                div([
                  p(
                    id: labelId,
                    classes: 'font-display text-base font-bold text-ink-100',
                    [Component.text(t.name)],
                  ),
                  p(
                    classes: 'mt-1.5 font-mono text-[11px] leading-relaxed '
                        'text-ink-500',
                    [Component.text(t.attribution)],
                  ),
                ]),

                if (t.projectSlug case final slug?)
                  Link(
                    to: RoutePaths.projectDetail(slug),
                    classes: 'link-line type-eyebrow font-mono text-ink-300 '
                        'transition-colors hover:text-ink-100',
                    children: const [Component.text('The work →')],
                  ),
              ],
            ),

            PersonChips(links: t.links, name: t.name, classes: 'mt-6'),
          ],
        ),
      ],
    );
  }

  static Component _cross() => const RawText(
        '<svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" '
        'stroke="currentColor" stroke-width="1.75" stroke-linecap="round" '
        'stroke-linejoin="round" aria-hidden="true">'
        '<path d="M6 6l12 12M18 6L6 18"/></svg>',
      );
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
