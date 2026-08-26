import 'package:fpdart/fpdart.dart';

import '../../domain/model/project_model.dart';
import '../../domain/repository/projects_repository.dart';
import '../datasource/projects_local_datasource.dart';

/// Reads case studies from the bundled [ProjectsLocalDatasource].
///
/// The methods are `async` even though the source is synchronous: that keeps
/// the contract identical to what an HTTP-backed implementation would expose,
/// so pages never have to change when the data moves. They resolve on the
/// first microtask, which is what lets the static build await them and still
/// emit fully populated HTML.
class ProjectsRepositoryImpl implements ProjectsRepository {
  const ProjectsRepositoryImpl();

  @override
  Future<Either<String, List<ProjectModel>>> getProjects() async {
    try {
      return const Right(ProjectsLocalDatasource.projects);
    } catch (e) {
      return const Left('Could not load the project list.');
    }
  }

  @override
  Future<Either<String, ProjectModel>> getProject(String slug) async {
    final match = ProjectsLocalDatasource.projects
        .where((project) => project.slug == slug)
        .firstOrNull;

    if (match == null) {
      return Left('No project found for "$slug".');
    }
    return Right(match);
  }

  @override
  Future<Either<String, List<ProjectModel>>> getFeaturedProjects({
    int limit = 3,
  }) async {
    final all = ProjectsLocalDatasource.projects;
    return Right(all.take(limit).toList(growable: false));
  }
}
