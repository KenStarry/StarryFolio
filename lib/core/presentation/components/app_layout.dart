import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'nav/nav_bar.dart';
import 'site_footer.dart';

/// Page shell: nav on top, content in the middle, footer at the bottom.
/// Every route wraps its page in this.
class AppLayout extends StatelessComponent {
  const AppLayout({required this.child, super.key});

  final Component child;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'flex min-h-screen flex-col',
      [
        const NavBar(),
        main_(classes: 'flex-1', [child]),
        const SiteFooter(),
      ],
    );
  }
}
