import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/service_model.dart';

/// Every service as one ruled row, at the top of `/services`.
///
/// ## What it replaced
///
/// The jump pills. Those carried a label and nothing else, so a reader had to
/// scroll six full-width bands to find out what any of them actually meant.
/// These rows carry the blurb that was already written, which means the whole
/// offering is legible before a single band has been reached — and the page
/// still has somewhere to send you.
///
/// ## Why an index rather than a grid
///
/// A grid of six cards would give every service equal weight and no order,
/// which is exactly what the six alternating bands did wrong. An index has a
/// reading direction and a first line, and it scans downward in one pass the
/// way a contents page does.
///
/// Each row anchors to its band. The href carries the path because
/// `<base href="/">` makes a bare fragment resolve against the site root — see
/// [RoutePaths.anchor].
class ServiceIndex extends StatelessComponent {
  const ServiceIndex({required this.services, super.key});

  final List<ServiceModel> services;

  @override
  Component build(BuildContext context) {
    if (services.isEmpty) return const div([]);

    return nav(
      classes: 'stagger',
      attributes: const {'aria-label': 'Services'},
      [
        for (final (i, service) in services.indexed)
          a(
            href: RoutePaths.anchor(RoutePaths.services, service.slug),
            classes: 'svc-row',
            [
              span(
                classes: 'svc-row-num',
                attributes: const {'aria-hidden': 'true'},
                [Component.text((i + 1).toString().padLeft(2, '0'))],
              ),
              span(
                classes: 'svc-row-title',
                [Component.text(service.plainTitle)],
              ),
              span(
                classes: 'svc-row-blurb',
                [Component.text(service.blurb)],
              ),
              span(
                classes: 'svc-row-mark',
                attributes: const {'aria-hidden': 'true'},
                [AppIcons.arrow(classes: 'h-4 w-4')],
              ),
            ],
          ),
      ],
    );
  }
}
