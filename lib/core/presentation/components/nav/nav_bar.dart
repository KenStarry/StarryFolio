import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../config/site_config.dart';
import '../../../routing/route_paths.dart';
import '../../../state/controllers/nav_dropdown_controller.dart';
import '../../../state/controllers/nav_menu_controller.dart';
import '../app_icons.dart';
import '../ghost_text.dart';

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

  /// The label of the page currently being viewed, if the nav knows it.
  ///
  /// Feeds the overlay's second watermark. The motif's rule is that a ghost
  /// must echo something real nearby — this one echoes the single lit row in
  /// the list below it, which makes it the one piece of texture on the site
  /// that is also telling you where you are.
  String? get _currentLabel {
    for (final item in _links) {
      if (item.children.isEmpty) {
        if (_isActive(item.href)) return item.label;
      } else {
        final child = _activeChild(item);
        if (child != null) return child.label;
      }
    }
    return null;
  }

  /// The one child of [item] that should be lit, if any.
  ///
  /// **Most specific wins.** `_isActive` matches on prefix, so on
  /// `/projects/mobile` both `All work` (`/projects`) and `Mobile apps`
  /// (`/projects/mobile`) qualify — and lighting two entries in one menu tells
  /// a reader exactly as much as lighting none. Picking the longest matching
  /// href resolves it the way a router would: the collection page wins on its
  /// own URL, and `All work` keeps the highlight everywhere under `/projects`
  /// that no collection claims, which is every case study.
  NavChild? _activeChild(NavItem item) {
    NavChild? best;
    for (final child in item.children) {
      if (!_isActive(child.href)) continue;
      if (best == null || child.href.length > best.href.length) best = child;
    }
    return best;
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

        if (isOpen) _overlay(context),
      ],
    );
  }

  /// The mobile navigation, as a full-bleed contents page.
  ///
  /// Not a drawer. It covers the whole viewport — including the ground behind
  /// the nav, so there is no seam where a sheet would meet the header — sets
  /// its links at display scale with the same numbering the project bands use,
  /// and hangs the wordmark behind it like every other full surface on the
  /// site.
  ///
  /// It sits **below** the header in the stacking order, which is what lets
  /// the button that opened it stay put and become the button that closes it.
  /// Nothing is duplicated inside, and the close control never moves.
  ///
  /// The entrance is the time-based `.rise` stagger, never `.reveal`: this
  /// opens above the fold with nothing to scroll, the same reason the hero and
  /// the page headers use it.
  ///
  /// Every link closes it on the way out — otherwise tapping an in-page anchor
  /// would leave the overlay covering the section it just jumped to.
  Component _overlay(BuildContext context) {
    void close() => context.read(navMenuControllerProvider.notifier).close();

    /// Closes the overlay only for destinations that leave this page standing.
    ///
    /// **Closing on a real navigation breaks it.** `close()` drops the overlay
    /// out of the tree, which removes the very anchor that was clicked — and
    /// an element detached from the document during its own click handler
    /// takes the pending default action with it. The top-level rows survived
    /// it because they are direct children of the list; the nested ones go out
    /// as part of a whole subtree, and stopped navigating altogether.
    ///
    /// Nothing is lost by leaving them alone: every one of these is a full
    /// page load, and the overlay cannot outlive a document that is being
    /// replaced. Only `mailto:` and in-page fragments need the manual close,
    /// because those leave the page exactly where it is.
    void Function()? closeIfStaying(String href) =>
        href.startsWith('mailto:') || href.contains('#') ? close : null;

    // One running index across the whole sheet, so a nested group's rows keep
    // the cascade going rather than restarting it. `.d-N` tops out at 7; past
    // that a row arrives on the last delay rather than not at all.
    var step = 0;
    String delay() {
      step++;
      return 'rise d-${step > 7 ? 7 : step}';
    }

    return div(
      id: 'mobile-menu',
      classes: 'nav-overlay lg:hidden',
      // Escape closes. Focus is inside the overlay whenever it is open, so the
      // handler does not need to sit on the document — and a listener added
      // there would have nothing to remove it in a stateless component.
      events: {'keydown': (event) => close()},
      [
        // ── Two watermarks, at different scales and depths ──
        //
        // The wordmark anchors the sheet, bleeding off the bottom-left corner
        // the way the page headers and the footer do. Above it, the name of
        // the page you are on, smaller and fainter, hung off the opposite
        // corner — so the pair reads as *this site* and *you are here* rather
        // than as one word repeated.
        //
        // Both obey the motif's rules: `aria-hidden`, unselectable, and each
        // echoing something printed as real content a few rows away.
        const GhostText(
          SiteConfig.wordmark,
          size: GhostSize.band,
          faint: true,
          classes: 'pointer-events-none absolute -bottom-5 -left-3',
        ),
        if (_currentLabel case final label?)
          GhostText(
            label,
            size: GhostSize.small,
            faint: true,
            classes: 'pointer-events-none absolute -right-4 top-16 '
                'text-right',
          ),

        div(
          classes: 'relative mx-auto flex min-h-full w-full max-w-2xl '
              'flex-col px-6 pb-12 pt-6 sm:px-8',
          [
            // ── The overlay's own bar ──
            //
            // Not decoration. The overlay is a sibling of the nav inside the
            // sticky header, and a positioned element with a numeric z-index
            // paints above one with `z-auto` in the same stacking context —
            // so the sheet covers the button that opened it, leaving Escape
            // as the only way out. Its own mark and its own close fixes that,
            // and gives a full surface the chrome it should have had anyway.
            div(
              classes: 'rise flex h-14 items-center justify-between gap-4',
              [
                const div(
                  classes: 'flex items-center gap-3',
                  [
                    span(
                      classes: 'flex h-9 w-9 shrink-0 overflow-hidden '
                          'rounded-full bg-ink-800 ring-1 ring-ink-700',
                      attributes: {'aria-hidden': 'true'},
                      [
                        img(
                          src: '/${SiteConfig.logoMark}',
                          alt: '',
                          attributes: {
                            'width': '256',
                            'height': '256',
                            'loading': 'lazy',
                            'decoding': 'async',
                          },
                          classes: 'h-full w-full object-cover',
                        ),
                      ],
                    ),
                    span(
                      classes: 'type-eyebrow font-mono text-ink-500',
                      [Component.text('Menu')],
                    ),
                  ],
                ),

                button(
                  classes: 'nav-close press',
                  attributes: const {
                    'type': 'button',
                    'aria-label': 'Close menu',
                  },
                  onClick: close,
                  [AppIcons.close(classes: 'h-5 w-5')],
                ),
              ],
            ),

            const div(classes: 'divider mt-2 mb-6', []),

            nav(
              attributes: const {'aria-label': 'Primary'},
              [
                for (final (i, link) in _links.indexed)
                  if (link.children.isEmpty)
                    a(
                      href: link.href,
                      classes: '${delay()} nav-row '
                          '${_isActive(link.href) ? 'nav-row-here' : ''}',
                      attributes: _isActive(link.href)
                          ? {'aria-current': 'page'}
                          : null,
                      onClick: closeIfStaying(link.href),
                      [
                        span(
                          classes: 'nav-num',
                          attributes: const {'aria-hidden': 'true'},
                          [Component.text('0${i + 1}')],
                        ),
                        span(
                          classes: 'nav-item',
                          [Component.text(link.label)],
                        ),
                        span(
                          classes: 'nav-mark',
                          attributes: const {'aria-hidden': 'true'},
                          [AppIcons.arrowUpRight(classes: 'h-5 w-5')],
                        ),
                      ],
                    )
                  else
                    div(
                      classes: delay(),
                      [
                        // The parent labels its group rather than navigating.
                        // Its own page is the first child underneath, and a
                        // row that both navigates and heads a list is two
                        // affordances sharing one tap target.
                        div(
                          classes: 'nav-row',
                          [
                            span(
                              classes: 'nav-num',
                              attributes: const {'aria-hidden': 'true'},
                              [Component.text('0${i + 1}')],
                            ),
                            span(
                              classes: 'nav-item nav-item-parent',
                              [Component.text(link.label)],
                            ),
                          ],
                        ),

                        div(
                          classes: 'nav-group py-3',
                          [
                            for (final child in link.children)
                              a(
                                href: child.href,
                                // Resolved per child rather than hoisted: the
                                // list is six entries at most, and a local
                                // would need a Builder to scope it inside a
                                // collection-for.
                                classes: 'nav-sub '
                                    '${child == _activeChild(link) ? 'nav-sub-here' : ''}',
                                attributes: child == _activeChild(link)
                                    ? {'aria-current': 'page'}
                                    : null,
                                onClick: closeIfStaying(child.href),
                                [Component.text(child.label)],
                              ),
                          ],
                        ),
                      ],
                    ),
              ],
            ),

            // Pushes the close block to the floor on a tall screen, so the
            // overlay ends deliberately rather than trailing into empty ground.
            const div(classes: 'min-h-12 flex-1', []),

            div(
              classes: '${delay()} border-t border-ink-800 pt-8',
              [
                if (SiteConfig.available)
                  const div(
                    classes: 'inline-flex items-center gap-2.5',
                    [
                      span(
                        classes: 'h-1.5 w-1.5 shrink-0 rounded-full '
                            'bg-iris-400 dot-live',
                        [],
                      ),
                      span(
                        classes: 'type-eyebrow font-mono text-ink-400',
                        [Component.text(SiteConfig.availabilityLabel)],
                      ),
                    ],
                  ),

                a(
                  href: 'mailto:${SiteConfig.email}',
                  classes: 'group mt-5 flex items-center justify-between gap-4 '
                      'border border-ink-700 bg-ink-850 px-5 py-4 '
                      'transition-colors duration-300 hover:border-iris-500/50 '
                      'hover:bg-ink-800',
                  onClick: close,  // mailto: leaves this page standing.
                  [
                    const span(
                      classes: 'min-w-0',
                      [
                        span(
                          classes: 'type-eyebrow block font-mono text-ink-500',
                          [Component.text('Start something')],
                        ),
                        span(
                          classes: 'mt-1.5 block truncate font-display '
                              'text-base font-bold text-ink-100',
                          [Component.text(SiteConfig.email)],
                        ),
                      ],
                    ),
                    span(
                      classes: 'shrink-0 text-iris-400 transition-transform '
                          'duration-500 ease-soft group-hover:translate-x-1',
                      [AppIcons.arrow()],
                    ),
                  ],
                ),

                div(
                  classes: 'mt-6 flex items-center gap-2.5',
                  [
                    for (final social in SiteConfig.socials)
                      a(
                        href: social.url,
                        target: Target.blank,
                        // rel=me corroborates the `sameAs` entries in the
                        // Person JSON-LD, so the profiles verify back here.
                        attributes: {
                          'rel': 'me noopener',
                          'aria-label': social.label,
                        },
                        classes: 'foot-social press',
                        [AppIcons.social(social.label)],
                      ),
                  ],
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
    final here = _activeChild(item);
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
                      '${child == here ? 'bg-ink-800' : ''}',
                  attributes: child == here ? {'aria-current': 'page'} : null,
                  onClick: () => context
                      .read(navDropdownControllerProvider.notifier)
                      .close(),
                  [
                    span(
                      classes: 'flex items-center justify-between gap-3 '
                          'font-display text-sm font-bold '
                          '${child == here ? 'text-iris-300' : 'text-ink-100'}',
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
