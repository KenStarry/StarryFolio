import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../config/site_config.dart';
import '../../../routing/route_paths.dart';
import '../../../state/controllers/nav_dropdown_controller.dart';
import '../../../state/controllers/nav_menu_controller.dart';
import '../app_icons.dart';

/// One item in a dropdown, with a line saying what is behind it.
///
/// The blurb is what separates a menu from a list of words: three unlabelled
/// links under "About" force a reader to guess which one holds what, and
/// guessing wrong costs a page load.
typedef NavChild = ({String label, String href, String blurb});

/// A top-level tab. [children] non-empty makes it a dropdown trigger rather
/// than a link, and its own `href` is then never navigated to — the first
/// child carries that destination instead.
typedef NavItem = ({String label, String href, List<NavChild> children});

/// The bar.
///
/// **Five items, and it stays five.** Six was already at the edge of reading
/// as a site map rather than a navigation, and Testimonials would have been a
/// seventh. So About became a parent instead: it now holds the three pages
/// that are all, in the end, about the same person, and the bar got *shorter*
/// while gaining a page.
///
/// `/writing` lives under Works rather than as a tab of its own. A post is a
/// piece of work, the dropdown has room a top-level bar does not, and it stops
/// the section depending on the footer alone to be reachable.
const _links = <NavItem>[
  (label: 'Home', href: RoutePaths.home, children: []),
  (label: 'Services', href: RoutePaths.services, children: []),
  (
    label: 'Works',
    href: RoutePaths.projects,
    children: [
      (
        label: 'All work',
        href: RoutePaths.projects,
        blurb: 'Everything, with the flagships up front',
      ),
      (
        label: 'Mobile apps',
        href: '${RoutePaths.projects}/mobile',
        blurb: 'Flutter apps shipped to both stores',
      ),
      (
        label: 'Web',
        href: '${RoutePaths.projects}/web',
        blurb: 'Portals and sites, this one included',
      ),
      (
        label: 'Design',
        href: '${RoutePaths.projects}/design',
        blurb: 'Systems, motion and interface craft',
      ),
      (
        label: 'Packages',
        href: '${RoutePaths.projects}/packages',
        blurb: 'Code other developers build on',
      ),
      (
        label: 'Writing',
        href: RoutePaths.writing,
        blurb: 'Notes from the build, when they are worth keeping',
      ),
    ],
  ),
  (
    label: 'About',
    href: RoutePaths.about,
    children: [
      (
        label: 'About me',
        href: RoutePaths.about,
        blurb: 'The roles, the toolkit, and how the work runs',
      ),
      (
        label: 'Testimonials',
        href: RoutePaths.testimonials,
        blurb: 'What it is like on the other side',
      ),
      (
        label: 'Documents',
        href: RoutePaths.documents,
        blurb: 'The CV, on paper and on file',
      ),
    ],
  ),
  (label: 'Contact', href: RoutePaths.contact, children: []),
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

  /// Whether a tab should be lit — its own page, or any page beneath it.
  ///
  /// A parent lights when one of its children is current, so a reader on
  /// `/testimonials` can still see which part of the site they are in. Without
  /// this the bar would show nothing active on three of the site's pages,
  /// which is worse than the flat version it replaced.
  bool _isItemActive(NavItem item) =>
      item.children.isEmpty
          ? _isActive(item.href)
          : item.children.any((c) => _isActive(c.href));

  @override
  Component build(BuildContext context) {
    final isOpen = context.watch(navMenuControllerProvider);
    final openMenu = context.watch(navDropdownControllerProvider);

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
                  if (link.children.isEmpty)
                    a(
                      href: link.href,
                      classes: _isActive(link.href)
                          ? 'nav-link nav-link-active text-sm'
                          : 'nav-link link-line text-sm',
                      attributes: _isActive(link.href)
                          ? {'aria-current': 'page'}
                          : null,
                      [Component.text(link.label)],
                    )
                  else
                    _dropdown(context, link, openMenu),
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
              // The drawer flattens the tree rather than nesting a
              // collapsible inside an already-collapsible menu. There is
              // vertical room here that the bar does not have, and a
              // disclosure inside a disclosure is two taps to reach a link
              // that a heading and an indent reach in one.
              for (final link in _links)
                if (link.children.isEmpty)
                  a(
                    href: link.href,
                    classes: 'flex items-center justify-between border-b '
                        'border-ink-800 py-4 font-display text-lg '
                        'font-semibold '
                        '${_isActive(link.href) ? 'text-iris-300' : 'text-ink-100'}',
                    attributes:
                        _isActive(link.href) ? {'aria-current': 'page'} : null,
                    onClick: () => context
                        .read(navMenuControllerProvider.notifier)
                        .close(),
                    [
                      Component.text(link.label),
                      AppIcons.arrowUpRight(classes: 'h-4 w-4 text-iris-400'),
                    ],
                  )
                else ...[
                  p(
                    classes: 'type-eyebrow border-b border-ink-800 pb-3 pt-6 '
                        'font-mono text-ink-500',
                    [Component.text(link.label)],
                  ),
                  for (final child in link.children)
                    a(
                      href: child.href,
                      classes: 'flex items-center justify-between border-b '
                          'border-ink-800 py-4 pl-4 font-display text-lg '
                          'font-semibold '
                          '${_isActive(child.href) ? 'text-iris-300' : 'text-ink-100'}',
                      attributes: _isActive(child.href)
                          ? {'aria-current': 'page'}
                          : null,
                      onClick: () => context
                          .read(navMenuControllerProvider.notifier)
                          .close(),
                      [
                        Component.text(child.label),
                        AppIcons.arrowUpRight(
                          classes: 'h-4 w-4 text-iris-400',
                        ),
                      ],
                    ),
                ],
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

  /// A tab that opens a panel instead of navigating.
  ///
  /// ## No document listeners
  ///
  /// Click-outside is handled by a full-bleed transparent `<button>` rendered
  /// *behind* the panel while it is open, not by a listener on `document`.
  /// That matters because this component is stateless — there is no dispose
  /// hook to remove a global listener from, so one added here would accumulate
  /// on every rebuild and keep firing after the menu was gone.
  ///
  /// Escape is handled on the wrapper, which works because focus is inside it
  /// whenever the panel is open.
  ///
  /// ## Click, not hover
  ///
  /// A hover-opened menu has no equivalent on touch, opens by accident when
  /// the pointer crosses it on the way somewhere else, and needs a close delay
  /// tuned by feel. A click is unambiguous on every input, and the trigger
  /// carries `aria-expanded` so the state is announced rather than only seen.
  Component _dropdown(BuildContext context, NavItem item, String? openMenu) {
    final expanded = openMenu == item.label;
    final active = _isItemActive(item);
    final panelId = 'nav-panel-${item.label.toLowerCase()}';

    return div(
      classes: 'relative',
      events: {
        'keydown': (event) {
          // Only Escape. Everything else — arrows, typing — is left to the
          // browser, which already moves focus through a list of links
          // correctly.
          if (event.type != 'keydown') return;
          context.read(navDropdownControllerProvider.notifier).close();
        },
      },
      [
        button(
          classes: 'nav-link inline-flex items-center gap-1.5 text-sm '
              '${active ? 'nav-link-active' : 'link-line'}',
          attributes: {
            'type': 'button',
            'aria-expanded': '$expanded',
            'aria-haspopup': 'true',
            'aria-controls': panelId,
            if (active) 'aria-current': 'page',
          },
          onClick: () => context
              .read(navDropdownControllerProvider.notifier)
              .toggle(item.label),
          [
            Component.text(item.label),
            span(
              classes: 'transition-transform duration-300 ease-soft '
                  '${expanded ? 'rotate-180' : ''}',
              attributes: const {'aria-hidden': 'true'},
              [AppIcons.chevronDown(classes: 'h-3.5 w-3.5')],
            ),
          ],
        ),

        if (expanded) ...[
          // Catches a click anywhere else on the page. `aria-hidden` and
          // `tabindex=-1`: a keyboard user closes with Escape or by tabbing
          // past the panel, and a full-screen button in the tab order would
          // be a control nobody can see.
          button(
            classes: 'fixed inset-0 z-40 cursor-default',
            attributes: const {
              'type': 'button',
              'tabindex': '-1',
              'aria-hidden': 'true',
            },
            onClick: () =>
                context.read(navDropdownControllerProvider.notifier).close(),
            [],
          ),

          div(
            id: panelId,
            classes: 'nav-panel absolute left-1/2 top-[calc(100%+1.25rem)] '
                'z-50 w-72 -translate-x-1/2 border border-ink-700 '
                'bg-ink-850 p-2 shadow-2xl shadow-ink-950/70',
            [
              for (final child in item.children)
                a(
                  href: child.href,
                  classes: 'group block px-4 py-3 transition-colors '
                      'duration-300 hover:bg-ink-800 '
                      '${_isActive(child.href) ? 'bg-ink-800' : ''}',
                  attributes: _isActive(child.href)
                      ? {'aria-current': 'page'}
                      : null,
                  onClick: () => context
                      .read(navDropdownControllerProvider.notifier)
                      .close(),
                  [
                    span(
                      classes: 'flex items-center justify-between gap-3 '
                          'font-display text-sm font-bold '
                          '${_isActive(child.href) ? 'text-iris-300' : 'text-ink-100'}',
                      [
                        Component.text(child.label),
                        span(
                          classes: 'text-iris-400 opacity-0 transition-all '
                              'duration-300 ease-soft group-hover:opacity-100',
                          attributes: const {'aria-hidden': 'true'},
                          [AppIcons.arrow(classes: 'h-3.5 w-3.5')],
                        ),
                      ],
                    ),
                    span(
                      classes: 'mt-1 block text-xs leading-relaxed '
                          'text-ink-500',
                      [Component.text(child.blurb)],
                    ),
                  ],
                ),
            ],
          ),
        ],
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
        attributes: {'aria-label': '${SiteConfig.name}, home'},
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
