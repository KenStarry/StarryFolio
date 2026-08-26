import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'nav/nav_bar.dart';
import 'site_footer.dart';

/// Page shell: nav on top, content in the middle, footer at the bottom.
/// Every route wraps its page in this.
///
/// Carries `id="top"` so the footer's back-to-top link has a target that works
/// without JavaScript — a bare `href="#"` would need a click handler, and this
/// shell is server-rendered.
class AppLayout extends StatelessComponent {
  const AppLayout({required this.child, this.path = '/', super.key});

  final Component child;

  /// Current route location, taken from the router at build time and handed to
  /// the nav island.
  ///
  /// The island cannot work this out for itself: it hydrates client-side, so
  /// reading `window.location` there would leave the server-rendered markup
  /// with no active state and then change it after paint — a visible flash and
  /// a hydration mismatch. Passing it in means the correct tab is already
  /// highlighted in the static HTML.
  final String path;

  @override
  Component build(BuildContext context) {
    return div(
      id: 'top',
      classes: 'flex min-h-screen flex-col overflow-x-clip',
      [
        // Reading progress. Pinned above the nav's own stacking level, driven
        // by a scroll timeline so it can never desync from the real position
        // and costs no JavaScript.
        const div(
          classes: 'fixed inset-x-0 top-0 z-[60] h-0.5 scroll-progress',
          attributes: {'aria-hidden': 'true'},
          [],
        ),
        NavBar(path: path),
        main_(classes: 'flex-1', [child]),
        SiteFooter(path: path),
      ],
    );
  }
}
