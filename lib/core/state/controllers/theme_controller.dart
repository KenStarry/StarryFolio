import 'package:jaspr/jaspr.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_web/web.dart' as web;

part 'theme_controller.g.dart';

enum AppTheme { light, dark }

/// Owns the light/dark preference for the whole client bundle.
///
/// The `<html class="dark">` toggle is applied by an inline script in
/// `main.server.dart` *before first paint*, so there is no flash — this
/// controller adopts whatever that script decided, then becomes the source of
/// truth for any component that wants to react to the theme.
///
/// `keepAlive` because the preference must outlive any single component.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  static const String _storageKey = 'theme';

  @override
  AppTheme build() {
    // Runs during pre-rendering too, where there is no document — `kIsWeb`
    // guards every browser API. Dark is the site default.
    if (!kIsWeb) return AppTheme.dark;

    final isDark =
        web.document.documentElement?.classList.contains('dark') ?? true;
    return isDark ? AppTheme.dark : AppTheme.light;
  }

  bool get isDark => state == AppTheme.dark;

  void toggle() => _apply(isDark ? AppTheme.light : AppTheme.dark);

  void _apply(AppTheme theme) {
    state = theme;
    if (!kIsWeb) return;

    final root = web.document.documentElement;
    if (root == null) return;

    if (theme == AppTheme.dark) {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
    web.window.localStorage.setItem(_storageKey, theme.name);
  }
}
