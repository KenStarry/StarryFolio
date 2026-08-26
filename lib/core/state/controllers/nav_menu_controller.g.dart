// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_menu_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Open/closed state of the mobile nav drawer.
///
/// Lives in a provider rather than component state so the menu can be closed
/// from anywhere — a nav link, a route change, an escape handler — without
/// threading callbacks through the tree.

@ProviderFor(NavMenuController)
final navMenuControllerProvider = NavMenuControllerProvider._();

/// Open/closed state of the mobile nav drawer.
///
/// Lives in a provider rather than component state so the menu can be closed
/// from anywhere — a nav link, a route change, an escape handler — without
/// threading callbacks through the tree.
final class NavMenuControllerProvider
    extends $NotifierProvider<NavMenuController, bool> {
  /// Open/closed state of the mobile nav drawer.
  ///
  /// Lives in a provider rather than component state so the menu can be closed
  /// from anywhere — a nav link, a route change, an escape handler — without
  /// threading callbacks through the tree.
  NavMenuControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'navMenuControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$navMenuControllerHash();

  @$internal
  @override
  NavMenuController create() => NavMenuController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$navMenuControllerHash() => r'd86c7596a0a8a2a7fd4adde7da985f4381af09a5';

/// Open/closed state of the mobile nav drawer.
///
/// Lives in a provider rather than component state so the menu can be closed
/// from anywhere — a nav link, a route change, an escape handler — without
/// threading callbacks through the tree.

abstract class _$NavMenuController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
