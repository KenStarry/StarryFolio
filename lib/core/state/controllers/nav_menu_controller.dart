import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_menu_controller.g.dart';

/// Open/closed state of the mobile nav drawer.
///
/// Lives in a provider rather than component state so the menu can be closed
/// from anywhere — a nav link, a route change, an escape handler — without
/// threading callbacks through the tree.
@riverpod
class NavMenuController extends _$NavMenuController {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void close() => state = false;
}
