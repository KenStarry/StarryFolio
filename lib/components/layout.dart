import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'footer.dart';
import 'nav_bar.dart';

/// Page shell: nav on top, content in the middle, footer at the bottom.
/// Every route wraps its page in this.
class Layout extends StatelessComponent {
  const Layout({required this.child, super.key});

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
