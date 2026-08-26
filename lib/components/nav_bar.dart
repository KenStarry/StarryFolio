import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/profile.dart';
import 'icons.dart';
import 'theme_toggle.dart';

const _links = <({String label, String href})>[
  (label: 'Work', href: '/projects'),
  (label: 'About', href: '/#about'),
  (label: 'Contact', href: '/#contact'),
];

/// Sticky top navigation. `@client` so the mobile menu can open and close.
@client
class NavBar extends StatefulComponent {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool _open = false;

  @override
  Component build(BuildContext context) {
    return header(
      classes: 'sticky top-0 z-50 border-b border-ink-200/60 '
          'bg-ink-50/80 backdrop-blur-xl '
          'dark:border-ink-800/80 dark:bg-ink-950/70',
      [
        nav(
          classes: 'mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8',
          [
            a(
              href: '/',
              classes: 'group flex items-center gap-2 font-display text-base font-semibold '
                  'tracking-tight text-ink-900 dark:text-ink-50',
              [
                span(
                  classes: 'text-star-400 transition-transform duration-500 '
                      'ease-expo group-hover:rotate-180',
                  [Icons.star()],
                ),
                Component.text(Profile.shortName.toLowerCase()),
              ],
            ),
            div(
              classes: 'hidden items-center gap-8 md:flex',
              [
                for (final l in _links)
                  a(
                    href: l.href,
                    classes: 'text-sm text-ink-500 transition-colors hover:text-ink-900 '
                        'dark:text-ink-300 dark:hover:text-star-300',
                    [Component.text(l.label)],
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
                    'aria-label': _open ? 'Close menu' : 'Open menu',
                    'aria-expanded': '$_open',
                    'type': 'button',
                  },
                  onClick: () => setState(() => _open = !_open),
                  [_open ? Icons.close() : Icons.menu()],
                ),
              ],
            ),
          ],
        ),
        if (_open)
          div(
            classes: 'border-t border-ink-200/60 px-5 pb-4 md:hidden '
                'dark:border-ink-800/80',
            [
              for (final l in _links)
                a(
                  href: l.href,
                  classes: 'block py-3 text-sm text-ink-600 dark:text-ink-200',
                  [Component.text(l.label)],
                ),
            ],
          ),
      ],
    );
  }
}
