import 'package:fpdart/fpdart.dart';

import '../model/post_model.dart';

/// Contract for reading written pieces.
///
/// `Left` carries a human-readable message ready to render; `Right` carries the
/// data. Presentation depends on this interface only — never on an
/// implementation — so swapping the local source for an HTTP or CMS-backed one
/// is a one-line change at the composition root.
abstract class WritingRepository {
  /// Newest first. [limit] of zero or less means every post — the index wants
  /// all of them, the home teaser wants three.
  Future<Either<String, List<PostModel>>> getPosts({int limit = 0});

  /// One piece by slug. `Left` when nothing matches, so a stale link renders a
  /// real message rather than an empty article.
  Future<Either<String, PostModel>> getPost(String slug);
}
