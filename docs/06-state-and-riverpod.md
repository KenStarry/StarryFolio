# 6. State & Riverpod

## Where state is allowed to live

Almost none of this site is stateful. Two things are: the light/dark theme, and whether the
mobile nav is open. Both live in the **one** `@client` island, `NavBar`.

That is not an accident of scope — it is a hard boundary. From
[doc 2](./02-rendering-and-hydration.md):

```
Content path  (SEO-critical, server)      Interaction path  (client islands)
────────────────────────────────────      ─────────────────────────────────
AsyncStatelessComponent                   @client + ProviderScope
  await Locator.<repo>.method()             context.watch / context.read
  no providers, ever                        @riverpod controllers + codegen
```

Riverpod's async providers resolve *after* the HTML has been serialised. Using one in a
content page ships a spinner to crawlers while looking perfectly fine in a browser. So
Riverpod is confined to islands, where there is nothing to pre-render and its value is real.

## jaspr_riverpod vs flutter_riverpod

Same Riverpod 3 core, different consumer API. **There is no `ConsumerWidget` and no
`WidgetRef`.** You read providers straight off `BuildContext`:

```dart
// Flutter
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(myProvider);
  }
}

// Jaspr
class MyComponent extends StatelessComponent {
  Component build(BuildContext context) {
    final value = context.watch(myProvider);
  }
}
```

Available on any component's context: `context.watch`, `context.read`, `context.listen`,
`context.listenManual`, `context.invalidate`, `context.refresh`, `context.exists`.

To scope rebuilds to part of a tree, wrap that part in `Builder` — it supplies a fresh
context, so a `watch` inside only rebuilds from there down. That is the replacement for
`Consumer`.

## Controllers

Always codegen. Two lines of boilerplate at the top of every state file:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'nav_menu_controller.g.dart';
```

`@riverpod` gives an autoDispose provider (torn down when nothing listens).
`@Riverpod(keepAlive: true)` persists.

### The simple one

`core/state/controllers/nav_menu_controller.dart`:

```dart
@riverpod
class NavMenuController extends _$NavMenuController {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void close() => state = false;
}
```

The generator produces `navMenuControllerProvider` from the class name. Assigning to `state`
notifies listeners — there is no `setState`.

This could have been a local field. It is a provider so the menu can be closed from anywhere
— a nav link, a future route-change listener, an escape-key handler — without threading
callbacks down the tree.

### The one with side effects

`core/state/controllers/theme_controller.dart` is `keepAlive` because a preference must
outlive any single component:

```dart
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  static const String _storageKey = 'theme';

  @override
  AppTheme build() {
    if (!kIsWeb) return AppTheme.dark;         // pre-render: no document
    final isDark = web.document.documentElement?.classList.contains('dark') ?? true;
    return isDark ? AppTheme.dark : AppTheme.light;
  }

  bool get isDark => state == AppTheme.dark;

  void toggle() => _apply(isDark ? AppTheme.light : AppTheme.dark);

  void _apply(AppTheme theme) {
    state = theme;
    if (!kIsWeb) return;

    final root = web.document.documentElement;
    if (root == null) return;

    theme == AppTheme.dark ? root.classList.add('dark') : root.classList.remove('dark');
    web.window.localStorage.setItem(_storageKey, theme.name);
  }
}
```

Two things worth copying:

**`build()` adopts existing DOM state rather than deciding it.** The inline script in
`main.server.dart` already set `<html class="dark">` before first paint (see
[doc 4](./04-styling-with-tailwind.md)). If this controller picked its own default, the page
would flip on hydration.

**Every browser call is behind `kIsWeb`.** Island code also runs during the static build,
where `web.document` is a mock. Unguarded, the build fails.

## Wiring an island

The island owns the `ProviderScope`:

```dart
@client
class NavBar extends StatelessComponent {
  const NavBar({super.key});

  @override
  Component build(BuildContext context) {
    return const ProviderScope(child: _NavBarView());
  }
}
```

Children then read providers normally:

```dart
class _NavBarView extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final isOpen = context.watch(navMenuControllerProvider);

    return header(…, [
      button(
        attributes: {'aria-expanded': '$isOpen', 'aria-controls': 'mobile-menu'},
        onClick: () => context.read(navMenuControllerProvider.notifier).toggle(),
        [isOpen ? AppIcons.close() : AppIcons.menu()],
      ),
      if (isOpen) div(id: 'mobile-menu', …),
    ]);
  }
}
```

`watch` to read reactively; `read(…​.notifier)` to call a method. Reading `.notifier` inside
`build` instead of `watch` is the usual mistake — it will not rebuild.

### Never nest `@client`

`ThemeToggle` sits inside `NavBar` and has **no annotation**:

```dart
/// Has no `@client` annotation of its own — it hydrates as part of the [NavBar]
/// island it lives in. Annotating it would make Jaspr try to hydrate it as a
/// second, independent root outside the NavBar's `ProviderScope`.
class ThemeToggle extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final isDark = context.watch(themeControllerProvider) == AppTheme.dark;
    return button(
      attributes: {'aria-label': isDark ? 'Switch to light mode' : 'Switch to dark mode'},
      onClick: () => context.read(themeControllerProvider.notifier).toggle(),
      [isDark ? AppIcons.sun() : AppIcons.moon()],
    );
  }
}
```

Annotating it would create a second hydration root with no `ProviderScope` above it, and its
`context.watch` would throw at runtime.

## Codegen

After adding or renaming a controller:

```bash
dart run build_runner build --delete-conflicting-outputs
```

`*.g.dart` files are generated — never hand-edit, never commit fixes to them. `jaspr serve`
runs the generator in watch mode, so during normal development this is automatic.

## Adding interactive state

1. Write the controller in `core/state/controllers/` (or the feature's `state/` if it is
   feature-specific) with `@riverpod` + `part`.
2. Run build_runner.
3. Read it from a component **inside an existing island**.
4. If it needs a new island, annotate the outermost component `@client` and give it its own
   `ProviderScope`.
5. Guard browser APIs with `kIsWeb`.
6. Rebuild and confirm the *pre-rendered* markup still looks right — islands render on the
   server too, so a crash there breaks the build.

## Cost

Adding Riverpod took the client bundle from 141 KB to 176 KB. Worth it for a shared,
codegen-backed pattern that scales; worth knowing before adding it to a site whose entire
interactive surface is two booleans.

---

Next: [Architecture →](./07-architecture.md)
