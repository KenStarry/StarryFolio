import 'package:fpdart/fpdart.dart';

import '../model/post_model.dart';

/// Contract for reading written pieces.
///
/// `Left` carries a human-readable message ready to render; `Right` carries the
/// data. Presentation depends on this interface only — never on an
/// implementation — so swapping the local source for an HTTP or CMS-backed one
/// is a one-line change at the composition root.
abstract class WritingRepository {
  Future<Either<String, List<PostModel>>> getPosts({int limit});
}
