import 'package:fpdart/fpdart.dart';

import '../../domain/model/about_profile.dart';
import '../../domain/repository/about_repository.dart';
import '../datasource/about_local_datasource.dart';

/// Reads the profile from the bundled [AboutLocalDatasource].
///
/// `async` even though the source is synchronous: that keeps the contract
/// identical to what an HTTP-backed implementation would expose, so neither
/// page changes when the content moves. It resolves on the first microtask,
/// which is what lets the static build await it and still emit fully
/// populated HTML.
class AboutRepositoryImpl implements AboutRepository {
  const AboutRepositoryImpl();

  @override
  Future<Either<String, AboutProfile>> getProfile() async {
    try {
      return const Right(AboutLocalDatasource.profile);
    } catch (e) {
      return const Left('Could not load the profile.');
    }
  }
}
