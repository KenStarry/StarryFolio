import 'package:fpdart/fpdart.dart';

import '../model/service_model.dart';

/// Contract for reading the services list.
///
/// `Left` carries a human-readable message ready to render; `Right` carries the
/// data. Presentation depends on this interface only — never on an
/// implementation — so swapping the local source for an HTTP one is a one-line
/// change at the composition root.
abstract class ServicesRepository {
  Future<Either<String, List<ServiceModel>>> getServices();
}
