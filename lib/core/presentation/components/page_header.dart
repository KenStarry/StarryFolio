import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../routing/route_paths.dart';
import 'jump_nav.dart';
import 'two_tone_title.dart';

/// One number the page wants stated up front — `06 / services`.
typedef HeaderFact = ({String value, String label});

/// The opening of every page except the home page.
///
/// One component, so `/about`, `/services` and `/projects` cannot drift into
/// three slightly different ideas of what a page header is. Each of them used
/// to hand-roll the same block — eyebrow, two-line heading, standfirst,
/// divider, jump pills — and the three had already diverged on type scale,
/// spacing and whether the numbers came before or after the pills.
///
/// The composition, top to bottom:
///
/// 1. **A breadcrumb trail**, which replaces the eyebrow. It says the same
///    word an eyebrow would, and is also a real link home and a visible
///    counterpart to the `BreadcrumbList` JSON-LD each page emits.
/// 2. **The title**, at [`.type-page`] and in two tones via [TwoToneTitle] —
///    bigger than any heading further down the page, smaller than the home
///    hero, which stays the loudest thing on the site.
/// 3. **The standfirst** — one short paragraph on what the page is for. Set
///    larger and paler than body copy, the way a magazine sets a standfirst.
/// 4. **An optional aside**, for a page with something to show beside its
///    title. Only `/about` uses it today, for the dossier card.
/// 5. **The numbers**, as ruled cells. Facts, not decoration: they are the
///    part a skim-reader actually retains.
/// 6. **The jump pills**, when the page is a sequence of bands.
///
/// Under all of it sits the ghost title — the wordmark motif at page scale,
/// bleeding off the bottom-left corner of the section so the header reads as
/// standing on the word it repeats. It is anchored to the section rather than
/// to the headline: at this size it is a ground for the whole block, and
/// pinning it to the `<h1>` made it a decoration hung on one line of type.
///
/// Motion is the time-based `.rise` stagger rather than the scroll-driven
/// `.reveal` used everywhere else, for the same reason the hero uses it: a
/// header is above the fold, and there is nothing to scroll yet.
class PageHeader extends StatelessComponent {
  const PageHeader({
    required this.title,
    required this.lead,
    required this.path,
    required this.trail,
    this.ghost = '',
    this.titleTail = '',
    this.meta = '',
    this.facts = const [],
    this.actions = const [],
    this.aside,
    this.jumpStops = const [],
    this.jumpLabel = 'Jump to a section',
    super.key,
  });

  /// The `<h1>`. Newlines set deliberate line breaks — display type should
  /// break where the copy wants, not where the container happens to end.
  final String title;

  /// One or two sentences on what this page is for.
  final String lead;

  /// This page's path, for the trail and the jump anchors. Anchors must carry
  /// it because `<base href="/">` makes a bare fragment resolve against the
  /// site root — see [RoutePaths.anchor].
  final String path;

  /// This page's label in the breadcrumb trail — `About`, `Services`, `Work`.
  final String trail;

  /// The watermark behind the header. Defaults to [trail]; set it only when
  /// the trail word is not the word worth ghosting.
  final String ghost;

  /// A final title line, set muted by [TwoToneTitle]. Use it for the half of a
  /// headline that qualifies the first half rather than continuing it.
  final String titleTail;

  /// Small right-aligned note on the trail line — a place, a status, a count.
  final String meta;

  final List<HeaderFact> facts;

  /// Calls to action. Kept to two: a header with three buttons has no primary.
  final List<Component> actions;

  /// Optional visual beside the title.
  final Component? aside;

  final List<JumpStop> jumpStops;
  final String jumpLabel;

  @override
  Component build(BuildContext context) {
    final word = ghost.isEmpty ? trail : ghost;

    return section(
      // `isolate` is load-bearing: the ghost sits at `-z-10`, and without a
      // stacking context here it would paint behind this section's own
      // background and never be seen at all.
      classes: 'relative isolate overflow-hidden bg-ink-900 pb-16 pt-14 '
          'sm:pb-20 sm:pt-20',
      [
        _ghost(word),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            // ── Trail ──
            div(
              classes: 'rise d-1 flex items-center justify-between gap-6',
              [
                _trail(),
                if (meta.isNotEmpty)
                  p(
                    classes: 'hidden font-mono text-[11px] uppercase '
                        'tracking-[0.16em] text-ink-500 sm:block',
                    [Component.text(meta)],
                  ),
              ],
            ),

            const div(classes: 'divider mt-5', []),

            // ── Title, standfirst, actions ──
            div(
              classes: aside == null
                  ? 'mt-12 sm:mt-16'
                  // `items-center`, not `items-end`: the aside is much taller
                  // than the title column, and aligning bottoms would push the
                  // title halfway down the header behind a band of empty space.
                  : 'mt-12 grid items-center gap-12 lg:mt-16 '
                      'lg:grid-cols-[1.1fr_0.9fr] lg:gap-16',
              [
                div([
                  TwoToneTitle(
                    lines: TwoToneTitle.tail(title, titleTail),
                    classes: 'rise d-2 type-page font-display font-extrabold '
                        'text-ink-100',
                  ),

                  p(
                    classes: 'rise d-3 mt-7 max-w-xl text-base leading-relaxed '
                        'text-ink-300 sm:text-[1.0625rem]',
                    [Component.text(lead)],
                  ),

                  if (actions.isNotEmpty)
                    div(
                      classes: 'rise d-4 mt-9 flex flex-wrap items-center '
                          'gap-3',
                      actions,
                    ),
                ]),

                if (aside case final panel?)
                  div(classes: 'rise d-4', [panel]),
              ],
            ),

            // ── The numbers ──
            if (facts.isNotEmpty)
              dl(
                classes: 'rise d-5 mt-16 grid grid-cols-2 gap-x-8 gap-y-8 '
                    'sm:mt-20 sm:grid-cols-4',
                [for (final fact in facts) _fact(fact)],
              ),

            // ── Jump pills ──
            if (jumpStops.isNotEmpty)
              div(
                classes: 'rise d-6 mt-14',
                [
                  JumpNav(path: path, label: jumpLabel, stops: jumpStops),
                ],
              ),
          ],
        ),
      ],
    );
  }

  /// The watermark, sitting on the section's bottom-left corner and bleeding
  /// past it. `overflow-hidden` on the section does the cropping, which is the
  /// effect: a word the page is standing on, not a word placed on the page.
  ///
  /// Deliberately **one** element rather than a positioned wrapper around a
  /// sized span, because `em` resolves against the element's *own* font size.
  /// With the clamp and the offset on the same box, `-left-[0.045em]` is a
  /// real correction that scales with the word — it pulls the glyph's left
  /// side bearing back so the stem sits flush to the edge rather than a hair
  /// inside it. Split across two elements the same class would resolve against
  /// the wrapper's inherited 16px and come out as three quarters of a pixel.
  ///
  /// Sized by word length rather than by one clamp for every page — see
  /// `.ghost-title` in `web/styles.tw.css`.
  static Component _ghost(String word) {
    final size = switch (word.length) {
      <= 5 => 'ghost-title-lg',
      <= 8 => 'ghost-title-md',
      _ => 'ghost-title-sm',
    };

    return span(
      classes: 'ghost-title $size pointer-events-none absolute bottom-0 '
          '-left-[0.045em] -z-10 select-none font-display font-extrabold '
          'text-ink-100/[0.032]',
      attributes: const {'aria-hidden': 'true'},
      [Component.text(word)],
    );
  }

  /// `Home / About`. A real `<nav>` with an ordered list, because that is what
  /// a trail is — and `aria-current` marks the end of it rather than leaving a
  /// screen reader to infer which crumb is this page.
  Component _trail() => nav(
        attributes: const {'aria-label': 'Breadcrumb'},
        [
          ol(
            classes: 'flex items-center gap-3 font-mono text-[11px] uppercase '
                'tracking-[0.16em] text-ink-500',
            [
              const li([
                Link(
                  to: RoutePaths.home,
                  classes: 'link-line transition-colors duration-300 '
                      'hover:text-ink-200',
                  children: [Component.text('Home')],
                ),
              ]),
              const li(
                classes: 'h-px w-4 bg-ink-700',
                attributes: {'aria-hidden': 'true'},
                [],
              ),
              li([
                span(
                  classes: 'text-ink-200',
                  attributes: const {'aria-current': 'page'},
                  [Component.text(trail)],
                ),
              ]),
            ],
          ),
        ],
      );

  /// One number, over its label, on a hairline. The value sets at display
  /// weight so the row can be read from across the room; the label stays in
  /// mono so it never competes.
  static Component _fact(HeaderFact fact) => div(
        classes: 'border-t border-ink-700/70 pt-5',
        [
          dt(
            classes: 'type-eyebrow font-mono text-ink-500',
            [Component.text(fact.label)],
          ),
          dd(
            classes: 'mt-3 font-display text-3xl font-extrabold tracking-tight '
                'text-ink-100 sm:text-4xl',
            [Component.text(fact.value)],
          ),
        ],
      );
}
