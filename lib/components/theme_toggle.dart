import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import 'icons.dart';

/// Light/dark switch.
///
/// Hydrated as part of the `@client` [NavBar] it lives in — no annotation of
/// its own, or Jaspr would try to hydrate it as a second independent root.
/// Browser APIs are guarded with [kIsWeb] because this same code also runs
/// during the static build.
class ThemeToggle extends StatefulComponent {
  const ThemeToggle({super.key});

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> {
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _isDark = web.document.documentElement?.classList.contains('dark') ?? true;
    }
  }

  void _toggle() {
    setState(() => _isDark = !_isDark);
    if (!kIsWeb) return;

    final root = web.document.documentElement;
    if (root == null) return;

    if (_isDark) {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
    web.window.localStorage.setItem('theme', _isDark ? 'dark' : 'light');
  }

  @override
  Component build(BuildContext context) {
    return button(
      classes: 'inline-flex h-9 w-9 items-center justify-center rounded-full '
          'border border-ink-200 text-ink-500 transition-colors duration-200 '
          'hover:border-star-400 hover:text-star-500 '
          'dark:border-ink-700 dark:text-ink-300 dark:hover:border-star-400 '
          'dark:hover:text-star-300',
      attributes: {
        'aria-label': _isDark ? 'Switch to light mode' : 'Switch to dark mode',
        'type': 'button',
      },
      onClick: _toggle,
      [_isDark ? Icons.sun() : Icons.moon()],
    );
  }
}
