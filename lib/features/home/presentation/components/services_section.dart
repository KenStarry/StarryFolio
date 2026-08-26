import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../services/domain/model/service_model.dart';
import '../../../services/presentation/components/service_card.dart';

/// The three-card services row.
///
/// Receives already-resolved services rather than fetching: the home page owns
/// its awaits, so the whole page renders in one pass.
class ServicesSection extends StatelessComponent {
  const ServicesSection({
    required this.services,
    this.error,
    super.key,
  });

  final List<ServiceModel> services;

  /// Set when the repository returned a `Left`. Renders a real block instead of
  /// silently dropping the section out of the page.
  final String? error;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'services',
      eyebrow: 'Services',
      heading: 'What I do,\nand how deep.',
      tone: SectionTone.raised,
      lead: 'Three things I get hired for — usually all three at once, which '
          'is the point. One person across design, build and release is how '
          'the seams disappear.',
      children: [
        if (error != null)
          ErrorNotice(message: error!)
        else
          div(
            classes: 'grid gap-5 md:grid-cols-3',
            [
              for (final (i, service) in services.indexed)
                ServiceCard(service: service, index: i),
            ],
          ),
      ],
    );
  }
}
