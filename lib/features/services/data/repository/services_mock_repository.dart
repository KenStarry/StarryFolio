import 'package:fpdart/fpdart.dart';

import '../../domain/model/service_model.dart';
import '../../domain/repository/services_repository.dart';

/// Canned data behind an artificial delay, for exercising loading and error
/// states without touching the real source.
///
/// Not wired up by default — swap it in at the composition root in
/// `core/di/locator.dart`.
class ServicesMockRepository implements ServicesRepository {
  const ServicesMockRepository({this.delay = const Duration(milliseconds: 800)});

  final Duration delay;

  static const _services = <ServiceModel>[
    ServiceModel(
      slug: 'placeholder',
      title: 'Placeholder\nservice',
      blurb: 'Stand-in copy so the row can be checked without real content.',
      icon: 'sparkle',
      tags: ['Flutter'],
      featured: true,
    ),
  ];

  @override
  Future<Either<String, List<ServiceModel>>> getServices() async {
    await Future<void>.delayed(delay);
    return const Right(_services);
  }
}
