import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../config/site_config.dart';
import '../../routing/route_paths.dart';
import 'app_icons.dart';

/// Carries every page, including the one the nav bar does not.
///
/// `/writing` has no tab — seven of them read as a site map rather than a
/// navigation — but a page with no inbound link is orphaned for readers and
/// for crawlers alike. The footer is where it stays reachable.
const _footerLinks = <({String label, String href})>[
  (label: 'Services', href: RoutePaths.services),
  (label: 'Works', href: RoutePaths.projects),
  (label: 'Writing', href: RoutePaths.writing),
  (label: 'About', href: RoutePaths.about),
  (label: 'Testimonials', href: RoutePaths.testimonials),
  (label: 'Documents', href: RoutePaths.documents),
  (label: 'Contact', href: RoutePaths.contact),
];

/// Page footer, on the deepest tone so the page closes darker than it opened.
///
/// **This is back matter, not a third call to action.** Every page already
/// closes on one — the home page's contact band, an inner page's `_Close` —
/// and a footer that pitches again after either of them is the same sentence
/// said three times. So this is built as a *colophon*: the identity, the index,
/// the ways to reach a human, and the facts about the artefact itself. Dense,
/// ordered, and quiet.
///
/// Three things carry it:
///
/// * **The wordmark, enormous**, clipped by the footer's own bottom edge. The
///   ghost motif at its largest scale on the site (see CLAUDE.md) — texture,
///   `aria-hidden`, and the last thing the page says.
/// * **The index**, as ruled rows with an arrow that arrives on hover, and the
///   page you are currently on lit rather than repeated as a dead link.
/// * **A live availability marker**, sharing the breathing dot with the hero,
///   so "available" means the same thing at both ends of the page.
///
/// It deliberately carries **no back-to-top link**. [BackToTop] is pinned
/// bottom-right on every page, is a real anchor, and is in the tab order — a
/// second one here would be the same control twice, six inches apart.
class SiteFooter extends StatelessComponent {
  const SiteFooter({this.path = RoutePaths.home, super.key});

  /// Current route location.
  ///
  /// Used to mark this page in the footer index rather than to build a
  /// back-to-top anchor. A footer that shows you where you are is doing
  /// something a sitemap cannot; a footer linking to the page you are already
  /// reading is offering a dead end.
  final String path;

  /// Whether [href] is the page being viewed. Project and post detail pages
  /// keep their section lit, since that is where they belong.
  bool _isHere(String href) =>
      path == href || path.startsWith('$href/');

  @override
  Component build(BuildContext context) {
    return footer(
      // `isolate` gives the ghost a stacking context of its own: at `-z-10`
      // without one it would paint behind the footer's background and never
      // be seen. `overflow-hidden` is what crops it at the bottom edge.
      classes: 'relative isolate overflow-hidden border-t border-ink-800 '
          'bg-ink-950',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 pt-20 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid gap-12 lg:grid-cols-[1.6fr_1fr_1fr] lg:gap-16',
              [
                _identity(),
                _index(),
                _reach(),
              ],
            ),

            _wordmark(),
            _baseline(),
          ],
        ),
      ],
    );
  }

  // ── Column one: who this is ───────────────────────────────────────────────

  static Component _identity() => div(
        classes: 'reveal',
        [
          const div(
            classes: 'flex items-center gap-3',
            [
              span(
                classes: 'flex h-9 w-9 shrink-0 overflow-hidden rounded-full '
                    'bg-ink-900 ring-1 ring-ink-800',
                attributes: {'aria-hidden': 'true'},
                [
                  img(
                    src: '/${SiteConfig.logoMark}',
                    alt: '',
                    attributes: {
                      'width': '256',
                      'height': '256',
                      'loading': 'lazy',
                      'decoding': 'async',
                    },
                    classes: 'h-full w-full object-cover',
                  ),
                ],
              ),
              span(
                classes: 'font-display text-sm font-semibold tracking-tight '
                    'text-ink-100',
                [Component.text(SiteConfig.wordmark)],
              ),
            ],
          ),

          const p(
            classes: 'mt-6 max-w-sm text-sm leading-relaxed text-ink-400',
            [Component.text(SiteConfig.tagline)],
          ),

          // The footer's one gesture: the address set at display size, because
          // it is the single thing on here anyone actually came looking for.
          a(
            href: 'mailto:${SiteConfig.email}',
            classes: 'link-line group mt-8 inline-flex items-baseline gap-3 '
                'font-display text-xl font-bold tracking-tight text-ink-100 '
                'transition-colors duration-300 hover:text-iris-300 sm:text-2xl',
            [
              const Component.text(SiteConfig.email),
              span(
                classes: 'transition-transform duration-500 ease-soft '
                    'group-hover:translate-x-1',
                [AppIcons.arrow(classes: 'h-4 w-4')],
              ),
            ],
          ),

          if (SiteConfig.available) _availability(),
        ],
      );

  /// Shares the breathing dot with the hero, so the claim reads the same at
  /// both ends of the page.
  static Component _availability() => const div(
        classes: 'mt-7 inline-flex items-center gap-2.5',
        [
          span(
            classes: 'h-1.5 w-1.5 shrink-0 rounded-full bg-iris-400 dot-live',
            [],
          ),
          span(
            classes: 'type-eyebrow font-mono text-ink-400',
            [Component.text(SiteConfig.availabilityLabel)],
          ),
        ],
      );

  // ── Column two: the index ─────────────────────────────────────────────────

  Component _index() => nav(
        classes: 'reveal',
        attributes: const {'aria-label': 'Footer'},
        [
          const p(
            classes: 'type-eyebrow font-mono text-ink-500',
            [Component.text('Index')],
          ),
          div(
            classes: 'mt-5 flex flex-col',
            [
              for (final link in _footerLinks) _row(link.label, link.href),
            ],
          ),
        ],
      );

  /// One row of the index. `aria-current` marks the page being viewed, so the
  /// lit state is announced rather than only seen.
  Component _row(String label, String href) {
    final here = _isHere(href);

    return Link(
      to: href,
      classes: here ? 'foot-link foot-link-here' : 'foot-link',
      attributes: here ? const {'aria-current': 'page'} : null,
      children: [
        span(
          classes: 'foot-link-mark',
          attributes: const {'aria-hidden': 'true'},
          [AppIcons.arrow(classes: 'h-3.5 w-3.5')],
        ),
        span([Component.text(label)]),
      ],
    );
  }

  // ── Column three: the ways to reach a human ───────────────────────────────

  static Component _reach() => div(
        classes: 'reveal',
        [
          const p(
            classes: 'type-eyebrow font-mono text-ink-500',
            [Component.text('Elsewhere')],
          ),

          div(
            classes: 'mt-5 flex flex-wrap gap-2.5',
            [
              for (final social in SiteConfig.socials)
                a(
                  href: social.url,
                  target: Target.blank,
                  // rel=me corroborates the `sameAs` entries in the Person
                  // JSON-LD, so the profiles verify back here.
                  attributes: {
                    'rel': 'me noopener',
                    'aria-label': '${social.label}, ${social.handle}',
                  },
                  classes: 'foot-social press',
                  [AppIcons.social(social.label)],
                ),
            ],
          ),

          const p(
            classes: 'type-eyebrow mt-10 font-mono text-ink-500',
            [Component.text('Direct')],
          ),
          div(
            classes: 'mt-5 flex flex-col gap-3',
            [
              if (SiteConfig.whatsappNumber.isNotEmpty)
                _direct(
                  label: 'WhatsApp',
                  href: SiteConfig.whatsappUrl,
                  icon: AppIcons.whatsapp(classes: 'h-4 w-4'),
                ),
              if (SiteConfig.buyMeACoffee.isNotEmpty)
                _direct(
                  label: 'Buy me a coffee',
                  href: SiteConfig.buyMeACoffeeUrl,
                  icon: AppIcons.coffee(classes: 'h-4 w-4'),
                ),
            ],
          ),
        ],
      );

  static Component _direct({
    required String label,
    required String href,
    required Component icon,
  }) =>
      a(
        href: href,
        target: Target.blank,
        attributes: const {'rel': 'noopener'},
        classes: 'group inline-flex items-center gap-2.5 text-sm text-ink-400 '
            'transition-colors duration-300 hover:text-ink-100',
        [
          span(
            classes: 'text-ink-600 transition-colors duration-300 '
                'group-hover:text-iris-400',
            [icon],
          ),
          Component.text(label),
        ],
      );

  // ── The wordmark ──────────────────────────────────────────────────────────

  /// The motif at page scale: the site's own name, set enormous, hung so its
  /// lower third is cropped by the footer's edge.
  ///
  /// `aria-hidden` and `select-none`, as every instance of this motif is — it
  /// repeats the wordmark printed at the top of this same footer, and a screen
  /// reader announcing it would be reading the name twice.
  static Component _wordmark() => const div(
        classes: 'pointer-events-none relative -z-10 mt-16 select-none',
        attributes: {'aria-hidden': 'true'},
        [
          // The negative margin lives on the *sized* element, not the wrapper:
          // `em` resolves against the element's own font size, so here it is a
          // real fraction of the clamped display size. On the wrapper it would
          // resolve against the inherited 16px and come out at three pixels —
          // a pull that does nothing at any viewport.
          //
          // What it buys: the baseline row rides up over the lower third of
          // the letterforms, and since the row paints above this (`-z-10`),
          // the word reads as set into the page rather than sitting on it.
          span(
            classes: 'ghost-footer -mb-[0.24em] block whitespace-nowrap '
                'font-display font-extrabold text-ink-100/[0.035]',
            [Component.text(SiteConfig.wordmark)],
          ),
        ],
      );

  // ── The baseline ──────────────────────────────────────────────────────────

  /// The colophon proper: what it is, what it was made with, and where from.
  static Component _baseline() => const div(
        classes: 'relative flex flex-col gap-3 border-t border-ink-800 py-7 '
            'sm:flex-row sm:items-center sm:justify-between',
        [
          p(
            classes: 'text-xs text-ink-500',
            [
              Component.text('© 2026 ${SiteConfig.name}'),
              span(classes: 'px-2 text-ink-700', [Component.text('·')]),
              Component.text('Written in Dart, rendered by Jaspr'),
            ],
          ),
          p(
            classes: 'font-mono text-[11px] uppercase tracking-[0.16em] '
                'text-ink-500',
            [
              Component.text(SiteConfig.location),
              span(classes: 'px-2 text-ink-700', [Component.text('·')]),
              span(classes: 'text-iris-400', [Component.text('UTC+3')]),
            ],
          ),
        ],
      );
}
