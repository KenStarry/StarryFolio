import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../state/controllers/theme_controller.dart';
import '../app_icons.dart';

/// Light/dark switch.
///
/// Reads [themeControllerProvider] rather than holding local state, so any
/// other component can observe or change the theme later without this one
/// having to expose a callback.
///
/// Has no `@client` annotation of its own — it hydrates as part of the [NavBar]
/// island it lives in. Annotating it would make Jaspr try to hydrate it as a
/// second, independent root outside the NavBar's `ProviderScope`.
class ThemeToggle extends StatelessComponent {
  const ThemeToggle({super.key});

  @override
  Component build(BuildContext context) {
    final isDark = context.watch(themeControllerProvider) == AppTheme.dark;

    return button(
      classes: 'inline-flex h-9 w-9 items-center justify-center rounded-full '
          'border border-ink-200 text-ink-500 transition-colors duration-200 '
          'hover:border-star-400 hover:text-star-500 '
          'dark:border-ink-700 dark:text-ink-300 dark:hover:border-star-400 '
          'dark:hover:text-star-300',
      attributes: {
        'aria-label': isDark ? 'Switch to light mode' : 'Switch to dark mode',
        'type': 'button',
      },
      onClick: () => context.read(themeControllerProvider.notifier).toggle(),
      [isDark ? AppIcons.sun() : AppIcons.moon()],
    );
  }
}
