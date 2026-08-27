import 'package:fpdart/fpdart.dart';

import '../../domain/model/document_model.dart';
import '../../domain/repository/documents_repository.dart';

/// Canned data behind an artificial delay, for exercising loading and error
/// states without touching the real source.
///
/// Not wired up by default — swap it in at the composition root in
/// `core/di/locator.dart`.
class DocumentsMockRepository implements DocumentsRepository {
  const DocumentsMockRepository({
    this.delay = const Duration(milliseconds: 800),
  });

  final Duration delay;

  @override
  Future<Either<String, List<DocumentModel>>> getDocuments() async {
    await Future<void>.delayed(delay);
    return const Right([
      DocumentModel(
        slug: 'placeholder',
        title: 'Placeholder document',
        tagline: 'Stand-in copy so the hub can be checked without real files.',
        summary: ['Nothing real here.'],
      ),
    ]);
  }
}
