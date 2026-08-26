import 'package:fpdart/fpdart.dart';

import '../../domain/model/post_model.dart';
import '../../domain/repository/writing_repository.dart';
import '../datasource/writing_local_datasource.dart';

/// Reads posts from the bundled [WritingLocalDatasource].
///
/// `async` even though the source is synchronous: that keeps the contract
/// identical to what an HTTP-backed implementation would expose, so the page
/// never has to change when the data moves. It resolves on the first
/// microtask, which is what lets the static build await it and still emit
/// fully populated HTML.
class WritingRepositoryImpl implements WritingRepository {
  const WritingRepositoryImpl();

  @override
  Future<Either<String, List<PostModel>>> getPosts({int limit = 3}) async {
    try {
      final all = WritingLocalDatasource.posts;
      return Right(all.take(limit).toList(growable: false));
    } catch (e) {
      return const Left('Could not load the writing list.');
    }
  }
}
