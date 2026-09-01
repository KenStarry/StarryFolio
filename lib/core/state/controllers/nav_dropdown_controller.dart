import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_dropdown_controller.g.dart';

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
@riverpod
class NavDropdownController extends _$NavDropdownController {
  @override
  String? build() => null;

  /// Opens [key], or closes it if it is already the open one.
  void toggle(String key) => state = state == key ? null : key;

  void close() => state = null;
}
