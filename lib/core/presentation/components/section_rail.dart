import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../routing/route_paths.dart';

/// One stop on the [SectionRail].
typedef RailStop = ({String anchor, String label});

/// A fixed column of dots down the right edge that tracks which band is on
/// screen and lets you hop between them.
///
/// The active highlight is pure CSS — each band declares a named
/// `view-timeline`, an ancestor publishes those names with `timeline-scope`,
/// and each dot animates on its band's timeline. No scroll listener, no
/// `IntersectionObserver`, nothing to hydrate, and it cannot drift out of sync
/// with the actual scroll position. See `.rail-*` in `web/styles.tw.css`.
///
/// Hidden below `xl`. On a narrow window it would either overlap the content or
/// crowd the edge, and the jump pills at the top of the page already cover the
/// same need.
///
/// It is `aria-hidden`: every stop here is a duplicate of a link already in the
/// jump nav, so exposing it would make a screen reader read the whole section
/// list twice.
class SectionRail extends StatelessComponent {
  const SectionRail({
    required this.stops,
    required this.path,
    super.key,
  });

  final List<RailStop> stops;

  /// Path of the page these anchors live on. Required because `<base href="/">`
  /// makes a bare fragment resolve against the site root — see
  /// [RoutePaths.anchor].
  final String path;

  /// Matches the timeline-name pool in the stylesheet. A page with more bands
  /// than this still renders them — the extras just do not self-highlight.
  static const int maxTracked = 8;

  @override
  Component build(BuildContext context) {
    if (stops.length < 2) return const div([]);

    return div(
      classes: 'pointer-events-none fixed right-8 top-1/2 z-40 hidden '
          '-translate-y-1/2 xl:block',
      attributes: const {'aria-hidden': 'true'},
      [
        div(
          classes: 'flex flex-col items-end gap-5',
          [
            for (final (i, stop) in stops.indexed)
              a(
                href: RoutePaths.anchor(path, stop.anchor),
                classes: 'rail-item pointer-events-auto relative flex '
                    'items-center justify-end py-1 '
                    '${i < maxTracked ? 'rail-${i + 1}' : ''}',
                attributes: const {'tabindex': '-1'},
                [
                  span(classes: 'rail-label', [Component.text(stop.label)]),
                  const span(classes: 'rail-dot', []),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
