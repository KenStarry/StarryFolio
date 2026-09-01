// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_dropdown_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which nav dropdown is open, keyed by its label. `null` is all closed.
///
/// A key rather than a bool: only one menu has children today, but a second
/// would otherwise need this rewritten *and* would introduce the bug where
/// opening one leaves the other open. Holding a single key makes "only one at
/// a time" a property of the state rather than something every trigger has to
/// remember to enforce.
///
/// Lives beside [NavMenuController] rather than inside it. The mobile drawer
/// and a desktop dropdown are never open at once — they exist at different
/// breakpoints — so folding them into one field would model a state that
/// cannot happen and force every read to disambiguate.

@ProviderFor(NavDropdownController)
final navDropdownControllerProvider = NavDropdownControllerProvider._();

/// Which nav dropdown is open, keyed by its label. `null` is all closed.
///
/// A key rather than a bool: only one menu has children today, but a second
/// would otherwise need this rewritten *and* would introduce the bug where
/// opening one leaves the other open. Holding a single key makes "only one at
/// a time" a property of the state rather than something every trigger has to
/// remember to enforce.
///
/// Lives beside [NavMenuController] rather than inside it. The mobile drawer
/// and a desktop dropdown are never open at once — they exist at different
/// breakpoints — so folding them into one field would model a state that
/// cannot happen and force every read to disambiguate.
final class NavDropdownControllerProvider
    extends $NotifierProvider<NavDropdownController, String?> {
  /// Which nav dropdown is open, keyed by its label. `null` is all closed.
  ///
  /// A key rather than a bool: only one menu has children today, but a second
  /// would otherwise need this rewritten *and* would introduce the bug where
  /// opening one leaves the other open. Holding a single key makes "only one at
  /// a time" a property of the state rather than something every trigger has to
  /// remember to enforce.
  ///
  /// Lives beside [NavMenuController] rather than inside it. The mobile drawer
  /// and a desktop dropdown are never open at once — they exist at different
  /// breakpoints — so folding them into one field would model a state that
  /// cannot happen and force every read to disambiguate.
  NavDropdownControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'navDropdownControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$navDropdownControllerHash();

  @$internal
  @override
  NavDropdownController create() => NavDropdownController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$navDropdownControllerHash() =>
    r'b826cae94452889c8470372f48a37171be448fcf';

/// Which nav dropdown is open, keyed by its label. `null` is all closed.
///
/// A key rather than a bool: only one menu has children today, but a second
/// would otherwise need this rewritten *and* would introduce the bug where
/// opening one leaves the other open. Holding a single key makes "only one at
/// a time" a property of the state rather than something every trigger has to
/// remember to enforce.
///
/// Lives beside [NavMenuController] rather than inside it. The mobile drawer
/// and a desktop dropdown are never open at once — they exist at different
/// breakpoints — so folding them into one field would model a state that
/// cannot happen and force every read to disambiguate.

abstract class _$NavDropdownController extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String?, String?>, String?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
