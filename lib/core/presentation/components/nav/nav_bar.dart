import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../config/site_config.dart';
import '../../../routing/route_paths.dart';
import '../../../state/controllers/nav_menu_controller.dart';
import '../app_icons.dart';

// `Home` earns a tab now that Services and Works are both standalone pages —
// without it there is no labelled way back from either.
const _links = <({String label, String href})>[
  (label: 'Home', href: RoutePaths.home),
  (label: 'Services', href: RoutePaths.services),
  (label: 'Works', href: RoutePaths.projects),
  (label: 'Writing', href: RoutePaths.writing),
  (label: 'About', href: RoutePaths.about),
  (label: 'Documents', href: RoutePaths.documents),
  (label: 'Contact', href: RoutePaths.contact),
];

/// Sticky top navigation.
///
/// This is the site's only `@client` island: everything else is static HTML.
/// It owns the [ProviderScope], which is why the menu controller is reachable
/// from here down but nowhere else — the content pages are rendered on the
/// server, where provider reads are not available.
///
/// Every link is a plain `<a>` rather than a router [Link]. An island hydrates
/// as its own root with no [Router] above it, so a `Link` here would look for
/// an ancestor that does not exist in the client tree.
@client
class NavBar extends StatelessComponent {
  const NavBar({this.path = '/', super.key});

  /// Current route location, passed down from `AppLayout`. Jaspr serialises
  /// `@client` parameters into the markup, so the island hydrates already
  /// knowing which tab is active — no post-paint correction, no flash.
  final String path;

  @override
  Component build(BuildContext context) {
    return ProviderScope(child: _NavBarView(path: path));
  }
}

class _NavBarView extends StatelessComponent {
  const _NavBarView({required this.path});

  final String path;

  /// Whether [href] represents the page currently being viewed.
  ///
  /// In-page anchors never count as active: `/#contact` points at the home
  /// page, and lighting two tabs at once tells the user nothing. Project
  /// detail pages keep `Works` lit, since that is the section they belong
  /// to.
  bool _isActive(String href) {
    if (href.contains('#')) return false;
    if (href == RoutePaths.home) return path == RoutePaths.home;
    return path == href || path.startsWith('$href/');
  }

  @override
  Component build(BuildContext context) {
    final isOpen = context.watch(navMenuControllerProvider);

    return header(
      classes: 'sticky top-0 z-50',
      [
        // Plate, faded in by a scroll timeline. Separated from the nav itself
        // so the bar floats clean over the hero at rest and gains a surface
        // only once content runs beneath it.
        const div(
          classes: 'nav-plate absolute inset-0 border-b border-ink-700/70 '
              'bg-ink-900/90 backdrop-blur-md',
          attributes: {'aria-hidden': 'true'},
          [],
        ),

        nav(
          classes: 'relative mx-auto flex h-20 max-w-6xl items-center '
              'justify-between px-6 sm:px-8 lg:px-12',
          [
            _logo(),

            div(
              classes: 'hidden items-center gap-7 lg:flex xl:gap-10',
              [
                for (final link in _links)
                  a(
                    href: link.href,
                    classes: _isActive(link.href)
                        ? 'nav-link nav-link-active text-sm'
                        : 'nav-link link-line text-sm',
                    attributes:
                        _isActive(link.href) ? {'aria-current': 'page'} : null,
                    [Component.text(link.label)],
                  ),
              ],
            ),

            div(
              classes: 'flex items-center gap-3',
              [
                const a(
                  href: 'mailto:${SiteConfig.email}',
                  classes: 'hidden bg-ink-200 px-5 py-2.5 text-sm font-medium '
                      'text-ink-900 transition-colors duration-300 '
                      'hover:bg-ink-100 lg:inline-flex',
                  [Component.text("Let's talk")],
                ),
                button(
                  classes: 'inline-flex h-10 w-10 items-center justify-center '
                      'border border-ink-600 text-ink-200 transition-colors '
                      'duration-300 hover:border-ink-400 lg:hidden',
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
            classes: 'relative border-t border-ink-700/70 bg-ink-900 px-6 '
                'pb-8 pt-2 lg:hidden',
            [
              for (final link in _links)
                a(
                  href: link.href,
                  classes: 'flex items-center justify-between border-b '
                      'border-ink-800 py-4 font-display text-lg font-semibold '
                      '${_isActive(link.href) ? 'text-iris-300' : 'text-ink-100'}',
                  attributes:
                      _isActive(link.href) ? {'aria-current': 'page'} : null,
                  onClick: () =>
                      context.read(navMenuControllerProvider.notifier).close(),
                  [
                    Component.text(link.label),
                    AppIcons.arrowUpRight(classes: 'h-4 w-4 text-iris-400'),
                  ],
                ),
              div(
                classes: 'mt-6 flex items-center gap-3',
                [
                  for (final social in SiteConfig.socials)
                    a(
                      href: social.url,
                      target: Target.blank,
                      attributes: {
                        'rel': 'me noopener',
                        'aria-label': social.label,
                      },
                      classes: 'inline-flex h-10 w-10 items-center '
                          'justify-center border border-ink-700 text-ink-400 '
                          'transition-colors hover:border-ink-500 '
                          'hover:text-ink-200',
                      [AppIcons.social(social.label)],
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  /// The brand mark — the avatar, clipped to a circle.
  ///
  /// `aria-hidden` on the image because the anchor already carries a label:
  /// without it a screen reader announces the alt text *and* the label, which
  /// reads as the name twice.
  Component _logo() => const a(
        href: RoutePaths.home,
        classes: 'group flex items-center gap-3',
        attributes: {'aria-label': '${SiteConfig.name} — home'},
        [
          span(
            classes: 'relative flex h-9 w-9 shrink-0 overflow-hidden '
                'rounded-full bg-ink-800 ring-1 ring-ink-700 '
                'transition-all duration-300 group-hover:ring-iris-400/60',
            attributes: {'aria-hidden': 'true'},
            [
              img(
                src: '/${SiteConfig.logoMark}',
                alt: '',
                attributes: {
                  'width': '256',
                  'height': '256',
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
      );
}
