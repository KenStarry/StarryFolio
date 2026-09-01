import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../routing/route_paths.dart';

/// The back-to-top control, pinned bottom-right.
///
/// A plain `<a href="#top">`, not a button with a scroll handler. Three things
/// follow from that, and all three are the reason it is built this way:
///
/// * It works with JavaScript disabled, and it works for a crawler.
/// * `html { scroll-behavior: smooth }` already animates the jump, so the
///   smoothness is free and matches every other in-page anchor on the site.
/// * Its *appearance* is driven by a scroll timeline in the stylesheet rather
///   than a scroll listener, so there is nothing to throttle, nothing to
///   hydrate, and no way for it to desync from the real scroll position.
///
/// `#top` is the id already carried by `AppLayout`'s root element, so this
/// introduces no new anchor to keep in sync — but the href has to name the
/// **current path** as well as the fragment. The document carries
/// `<base href="/">`, which is load-bearing for hydration, and a consequence
/// is that a bare `#top` resolves against the site root: on every page except
/// the home page this button navigated *to the home page* rather than
/// scrolling up. See [RoutePaths.anchor].
///
/// It is deliberately below the nav in the stacking order (`z-40` against the
/// nav's `z-50`) — the two never overlap, but if a future sheet does, the
/// navigation should win.
class BackToTop extends StatelessComponent {
  const BackToTop({this.path = RoutePaths.home, super.key});

  /// Current route location, so the anchor targets *this* page's `#top`.
  final String path;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'to-top pointer-events-none fixed bottom-6 right-6 z-40 '
          'sm:bottom-8 sm:right-8',
      [
        a(
          href: RoutePaths.anchor(path, 'top'),
          classes: 'to-top-btn press pointer-events-auto flex h-11 w-11 '
              'items-center justify-center rounded-full border '
              'border-ink-700 bg-ink-900/90 text-ink-400 backdrop-blur-sm',
          // The visible content is an arrow, so the accessible name has to be
          // supplied — and `title` gives sighted mouse users the same label.
          attributes: const {
            'aria-label': 'Back to top',
            'title': 'Back to top',
          },
          [
            _arrow(),
          ],
        ),
      ],
    );
  }

  /// Stroked, following the UI-glyph rule — the filled treatment in `AppIcons`
  /// is reserved for brand marks.
  static Component _arrow() => const RawText(
        '<svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" '
        'stroke="currentColor" stroke-width="1.75" stroke-linecap="round" '
        'stroke-linejoin="round" aria-hidden="true">'
        '<path d="M12 19V5"/><path d="m5 12 7-7 7 7"/>'
        '</svg>',
      );
}
