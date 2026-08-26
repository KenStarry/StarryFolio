import 'package:fpdart/fpdart.dart';

import '../../domain/model/post_model.dart';
import '../../domain/repository/writing_repository.dart';

/// Canned data behind an artificial delay, for exercising loading and error
/// states without touching the real source.
///
/// Not wired up by default — swap it in at the composition root in
/// `core/di/locator.dart`.
class WritingMockRepository implements WritingRepository {
  const WritingMockRepository({this.delay = const Duration(milliseconds: 800)});

  final Duration delay;

  static const _posts = <PostModel>[
    PostModel(
      slug: 'placeholder',
      title: 'Placeholder post',
      excerpt: 'Stand-in copy so the section can be checked without real '
          'content.',
      date: 'Jan 2026',
      readMinutes: 3,
    ),
  ];

  @override
  Future<Either<String, List<PostModel>>> getPosts({int limit = 3}) async {
    await Future<void>.delayed(delay);
    return Right(_posts.take(limit).toList(growable: false));
  }
}
