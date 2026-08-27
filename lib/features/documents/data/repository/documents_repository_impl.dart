import 'package:fpdart/fpdart.dart';

import '../../domain/model/document_model.dart';
import '../../domain/repository/documents_repository.dart';
import '../datasource/documents_local_datasource.dart';

/// Reads from the bundled [DocumentsLocalDatasource].
///
/// `async` even though the source is synchronous: that keeps the contract
/// identical to what an HTTP-backed implementation would expose, so the page
/// never has to change when the data moves.
class DocumentsRepositoryImpl implements DocumentsRepository {
  const DocumentsRepositoryImpl();

  @override
  Future<Either<String, List<DocumentModel>>> getDocuments() async {
    try {
      return const Right(DocumentsLocalDatasource.documents);
    } catch (e) {
      return const Left('Could not load the documents.');
    }
  }
}
