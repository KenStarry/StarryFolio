import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../routing/route_paths.dart';

/// One pill in a [JumpNav].
typedef JumpStop = ({String anchor, String label, int count});

/// Pills that scroll to a band on the current page.
///
/// Generic over what the bands contain — `/projects` and `/services` both feed
/// it, rather than each keeping a near-identical copy.
///
/// These are plain anchors, not a filter. A real link is keyboard operable,
/// shareable as a URL, and leaves the whole page in the document instead of
/// hiding most of it behind `display:none`. Smooth scrolling and clearance
/// under the sticky nav come from `scroll-behavior` and `scroll-padding-top`
/// on `<html>` — no script.
class JumpNav extends StatelessComponent {
  const JumpNav({
    required this.stops,
    required this.path,
    this.label = 'Jump to a section',
    super.key,
  });

  final List<JumpStop> stops;

  /// Path of the page these anchors live on. Required because `<base href="/">`
  /// makes a bare fragment resolve against the site root — see
  /// [RoutePaths.anchor].
  final String path;

  final String label;

  @override
  Component build(BuildContext context) {
    if (stops.isEmpty) return const div([]);

    return nav(
      classes: 'reveal flex flex-wrap items-center gap-2.5',
      attributes: {'aria-label': label},
      [
        for (final stop in stops)
          a(
            href: RoutePaths.anchor(path, stop.anchor),
            classes: 'jump-pill',
            [
              span([Component.text(stop.label)]),
              if (stop.count > 0)
                span(
                  classes: 'jump-count',
                  [Component.text(stop.count.toString().padLeft(2, '0'))],
                ),
            ],
          ),
      ],
    );
  }
}
