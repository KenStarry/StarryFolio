import '../../features/projects/data/repository/projects_repository_impl.dart';
import '../../features/projects/domain/repository/projects_repository.dart';
import '../../features/services/data/repository/services_repository_impl.dart';
import '../../features/services/domain/repository/services_repository.dart';

/// Composition root — the single place implementations are chosen.
///
/// Riverpod would normally own this, but the SEO-critical content path cannot
/// use it: provider reads are only legal inside a synchronous `build`, and the
/// pages that fetch content are `AsyncStatelessComponent`s. See CLAUDE.md.
/// So repositories are resolved here instead, and Riverpod is reserved for
/// client-side interaction state.
///
/// Fields are mutable so a test — or a temporary UI session against a mock
/// repository — can swap an implementation in one line.
abstract final class Locator {
  static ProjectsRepository projects = const ProjectsRepositoryImpl();
  static ServicesRepository services = const ServicesRepositoryImpl();

  /// Restores the default wiring. Call from `tearDown` in tests.
  static void reset() {
    projects = const ProjectsRepositoryImpl();
    services = const ServicesRepositoryImpl();
  }
}
