import '../../domain/model/service_model.dart';

/// The services, as compile-time constants.
///
/// Deliberately `const` and synchronous for the same reason as the projects
/// source: the static build has to resolve this during pre-render, and the
/// repository on top exists so the page never learns where the data came from.
abstract final class ServicesLocalDatasource {
  static const List<ServiceModel> services = [
    ServiceModel(
      slug: 'mobile-product-engineering',
      title: 'Mobile product\nengineering',
      blurb: 'Flutter apps built end to end — architecture, state, offline '
          'behaviour, and a release pipeline that does not need babysitting.',
      icon: 'device',
      tags: ['Flutter', 'Riverpod', 'Clean Architecture'],
      featured: true,
    ),
    ServiceModel(
      slug: 'design-systems',
      title: 'Design systems\n& interface',
      blurb: 'A token-driven system before the first screen — type, colour, '
          'motion and every state — so screen forty still looks like screen one.',
      icon: 'layers',
      tags: ['Figma', 'Motion', 'Accessibility'],
    ),
    ServiceModel(
      slug: 'ship-and-operate',
      title: 'Ship\n& operate',
      blurb: 'Store listings, CI/CD, staged rollouts, and the crash dashboards '
          'you actually want to open on a Monday morning.',
      icon: 'rocket',
      tags: ['CI/CD', 'Fastlane', 'Firebase'],
    ),
  ];
}
