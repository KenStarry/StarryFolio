import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../config/site_config.dart';
import '../../../routing/route_paths.dart';
import '../../../state/controllers/nav_menu_controller.dart';
import '../app_icons.dart';
import 'theme_toggle.dart';

const _links = <({String label, String href})>[
  (label: 'Work', href: RoutePaths.projects),
  (label: 'About', href: '${RoutePaths.home}#about'),
  (label: 'Contact', href: '${RoutePaths.home}#contact'),
];

/// Sticky top navigation.
///
/// This is the site's only `@client` island: everything else is static HTML.
/// It owns the [ProviderScope], which is why the theme and menu controllers are
/// reachable from here down but nowhere else — the content pages are rendered
/// on the server, where provider reads are not available.
@client
class NavBar extends StatelessComponent {
  const NavBar({super.key});

  @override
  Component build(BuildContext context) {
    return const ProviderScope(child: _NavBarView());
  }
}

class _NavBarView extends StatelessComponent {
  const _NavBarView();

  @override
  Component build(BuildContext context) {
    final isOpen = context.watch(navMenuControllerProvider);

    return header(
      classes: 'sticky top-0 z-50 border-b border-ink-200/60 '
          'bg-ink-50/80 backdrop-blur-xl '
          'dark:border-ink-800/80 dark:bg-ink-950/70',
      [
        nav(
          classes: 'mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8',
          [
            a(
              href: RoutePaths.home,
              classes: 'group flex items-center gap-2 font-display text-base font-semibold '
                  'tracking-tight text-ink-900 dark:text-ink-50',
              [
                span(
                  classes: 'text-star-400 transition-transform duration-500 '
                      'ease-expo group-hover:rotate-180',
                  [AppIcons.star()],
                ),
                Component.text(SiteConfig.shortName.toLowerCase()),
              ],
            ),
            div(
              classes: 'hidden items-center gap-8 md:flex',
              [
                for (final link in _links)
                  a(
                    href: link.href,
                    classes: 'text-sm text-ink-500 transition-colors hover:text-ink-900 '
                        'dark:text-ink-300 dark:hover:text-star-300',
                    [Component.text(link.label)],
                  ),
                const ThemeToggle(),
              ],
            ),
            div(
              classes: 'flex items-center gap-2 md:hidden',
              [
                const ThemeToggle(),
                button(
                  classes: 'inline-flex h-9 w-9 items-center justify-center rounded-full '
                      'border border-ink-200 text-ink-600 dark:border-ink-700 dark:text-ink-200',
                  attributes: {
                    'aria-label': isOpen ? 'Close menu' : 'Open menu',
                    'aria-expanded': '$isOpen',
                    'aria-controls': 'mobile-menu',
                    'type': 'button',
                  },
                  onClick: () =>
                      context.read(navMenuControllerProvider.notifier).toggle(),
                  [isOpen ? AppIcons.close() : AppIcons.menu()],
                ),
              ],
            ),
          ],
        ),
        if (isOpen)
          div(
            id: 'mobile-menu',
            classes: 'border-t border-ink-200/60 px-5 pb-4 md:hidden '
                'dark:border-ink-800/80',
            [
              for (final link in _links)
                a(
                  href: link.href,
                  classes: 'block py-3 text-sm text-ink-600 dark:text-ink-200',
                  onClick: () =>
                      context.read(navMenuControllerProvider.notifier).close(),
                  [Component.text(link.label)],
                ),
            ],
          ),
      ],
    );
  }
}
