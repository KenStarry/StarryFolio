import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../projects/domain/model/project_model.dart';
import '../../../projects/presentation/components/project_card.dart';

/// Featured-work teaser.
///
/// Receives already-resolved projects rather than fetching: the home page owns
/// the single await, so the whole page renders in one pass.
class WorkSection extends StatelessComponent {
  const WorkSection({required this.projects, super.key});

  final List<ProjectModel> projects;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'work',
      eyebrow: 'Selected work',
      heading: 'Things I have shipped',
      lead: 'A few products where I owned the whole surface — design system, '
          'architecture, release.',
      children: [
        div(
          classes: 'grid gap-6 sm:grid-cols-2 lg:grid-cols-3',
          [for (final project in projects) ProjectCard(project: project)],
        ),
        div(
          classes: 'mt-10',
          [
            Link(
              to: RoutePaths.projects,
              classes: 'inline-flex items-center gap-1.5 text-sm font-medium '
                  'text-star-500 hover:underline dark:text-star-400',
              children: [
                const Component.text('All projects'),
                AppIcons.arrow(),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
