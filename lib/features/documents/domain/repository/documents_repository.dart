import 'package:fpdart/fpdart.dart';

import '../model/document_model.dart';

/// Contract for reading the document hub.
///
/// `Left` carries a human-readable message ready to render; `Right` carries the
/// data. Presentation depends on this interface only — never on an
/// implementation.
abstract class DocumentsRepository {
  Future<Either<String, List<DocumentModel>>> getDocuments();
}
