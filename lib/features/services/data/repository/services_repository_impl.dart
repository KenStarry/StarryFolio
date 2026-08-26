import 'package:fpdart/fpdart.dart';

import '../../domain/model/service_model.dart';
import '../../domain/repository/services_repository.dart';
import '../datasource/services_local_datasource.dart';

/// Reads services from the bundled [ServicesLocalDatasource].
///
/// `async` even though the source is synchronous: that keeps the contract
/// identical to what an HTTP-backed implementation would expose, so the page
/// never has to change when the data moves. It resolves on the first
/// microtask, which is what lets the static build await it and still emit
/// fully populated HTML.
class ServicesRepositoryImpl implements ServicesRepository {
  const ServicesRepositoryImpl();

  @override
  Future<Either<String, List<ServiceModel>>> getServices() async {
    try {
      return const Right(ServicesLocalDatasource.services);
    } catch (e) {
      return const Left('Could not load the services list.');
    }
  }
}
