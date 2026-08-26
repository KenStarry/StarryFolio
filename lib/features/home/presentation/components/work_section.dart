import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../projects/domain/model/project_model.dart';
import '../../../projects/presentation/components/project_card.dart';

/// Selected-work teaser.
///
/// Receives already-resolved projects rather than fetching: the home page owns
/// the awaits, so the whole page renders in one pass. An even grid here rather
/// than the previous feature-plus-pair split — with three case studies the
/// asymmetry was doing more work than the content justified.
class WorkSection extends StatelessComponent {
  const WorkSection({required this.projects, super.key});

  final List<ProjectModel> projects;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'work',
      eyebrow: 'Selected work',
      heading: 'All creative works,\nselected projects.',
      lead: 'Products where I owned the whole surface — design system, '
          'architecture, release.',
      children: [
        if (projects.isNotEmpty)
          div(
            classes: 'grid gap-5 sm:grid-cols-2 lg:grid-cols-3',
            [for (final project in projects) ProjectCard(project: project)],
          ),
        const div(
          classes: 'reveal mt-14',
          [
            CtaButton(
              label: 'Every project',
              href: RoutePaths.projects,
              variant: CtaVariant.outline,
            ),
          ],
        ),
      ],
    );
  }
}
