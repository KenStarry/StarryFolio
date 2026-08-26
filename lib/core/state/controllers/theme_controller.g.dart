// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the light/dark preference for the whole client bundle.
///
/// The `<html class="dark">` toggle is applied by an inline script in
/// `main.server.dart` *before first paint*, so there is no flash — this
/// controller adopts whatever that script decided, then becomes the source of
/// truth for any component that wants to react to the theme.
///
/// `keepAlive` because the preference must outlive any single component.

@ProviderFor(ThemeController)
final themeControllerProvider = ThemeControllerProvider._();

/// Owns the light/dark preference for the whole client bundle.
///
/// The `<html class="dark">` toggle is applied by an inline script in
/// `main.server.dart` *before first paint*, so there is no flash — this
/// controller adopts whatever that script decided, then becomes the source of
/// truth for any component that wants to react to the theme.
///
/// `keepAlive` because the preference must outlive any single component.
final class ThemeControllerProvider
    extends $NotifierProvider<ThemeController, AppTheme> {
  /// Owns the light/dark preference for the whole client bundle.
  ///
  /// The `<html class="dark">` toggle is applied by an inline script in
  /// `main.server.dart` *before first paint*, so there is no flash — this
  /// controller adopts whatever that script decided, then becomes the source of
  /// truth for any component that wants to react to the theme.
  ///
  /// `keepAlive` because the preference must outlive any single component.
  ThemeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeControllerHash();

  @$internal
  @override
  ThemeController create() => ThemeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppTheme value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppTheme>(value),
    );
  }
}

String _$themeControllerHash() => r'056ee4bc5d324edb4d7d219ab3f37b5afce68f9b';

/// Owns the light/dark preference for the whole client bundle.
///
/// The `<html class="dark">` toggle is applied by an inline script in
/// `main.server.dart` *before first paint*, so there is no flash — this
/// controller adopts whatever that script decided, then becomes the source of
/// truth for any component that wants to react to the theme.
///
/// `keepAlive` because the preference must outlive any single component.

abstract class _$ThemeController extends $Notifier<AppTheme> {
  AppTheme build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppTheme, AppTheme>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AppTheme, AppTheme>, AppTheme, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
