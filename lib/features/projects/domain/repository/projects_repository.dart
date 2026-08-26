import 'package:fpdart/fpdart.dart';

import '../model/project_model.dart';

/// Contract for reading case studies.
///
/// `Left` carries a human-readable message ready to render; `Right` carries the
/// data. Presentation depends on this interface only — never on an
/// implementation — so swapping the local source for an HTTP one is a one-line
/// change at the composition root.
abstract class ProjectsRepository {
  Future<Either<String, List<ProjectModel>>> getProjects();

  Future<Either<String, ProjectModel>> getProject(String slug);

  /// The most recent [limit] projects, for the home page teaser.
  Future<Either<String, List<ProjectModel>>> getFeaturedProjects({int limit = 3});
}
