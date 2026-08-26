import 'package:fpdart/fpdart.dart';

import '../../domain/enum/project_category.dart';
import '../../domain/enum/project_status.dart';
import '../../domain/model/project_model.dart';
import '../../domain/repository/projects_repository.dart';

/// Canned data behind an artificial delay, for exercising loading and error
/// states without touching the real source.
///
/// Not wired up by default — swap it in at the composition root in
/// `projects_providers.dart`.
class ProjectsMockRepository implements ProjectsRepository {
  const ProjectsMockRepository({this.delay = const Duration(milliseconds: 800)});

  final Duration delay;

  static const _projects = <ProjectModel>[
    ProjectModel(
      slug: 'placeholder',
      name: 'Placeholder',
      tagline: 'Canned data for UI work.',
      year: '2026',
      status: ProjectStatus.building,
      category: ProjectCategory.personal,
      stack: ['Flutter'],
      summary: ['Stand-in copy so layouts can be checked without real content.'],
    ),
  ];

  @override
  Future<Either<String, List<ProjectModel>>> getProjects() async {
    await Future<void>.delayed(delay);
    return const Right(_projects);
  }

  @override
  Future<Either<String, ProjectModel>> getProject(String slug) async {
    await Future<void>.delayed(delay);
    final match = _projects.where((p) => p.slug == slug).firstOrNull;
    return match == null ? Left('No project found for "$slug".') : Right(match);
  }

  @override
  Future<Either<String, List<ProjectModel>>> getFeaturedProjects({
    int limit = 3,
  }) async {
    await Future<void>.delayed(delay);
    return Right(_projects.take(limit).toList(growable: false));
  }
}
