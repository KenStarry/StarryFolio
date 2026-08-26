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
  const AppLayout({required this.child, super.key});

  final Component child;

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
        const NavBar(),
        main_(classes: 'flex-1', [child]),
        const SiteFooter(),
      ],
    );
  }
}
