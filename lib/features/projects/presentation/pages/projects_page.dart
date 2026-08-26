import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../components/project_card.dart';

/// The projects index.
///
/// An [AsyncStatelessComponent] so the repository is awaited *during*
/// pre-rendering — the generated HTML contains every card. Reaching for a
/// Riverpod async provider here instead would ship a loading state to crawlers.
class ProjectsPage extends AsyncStatelessComponent {
  const ProjectsPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.projects.getProjects();

    return result.fold(
      (error) => Component.fragment([
        const _Meta(),
        SectionBlock(
          eyebrow: 'Work',
          heading: 'Projects',
          isPageHeading: true,
          children: [ErrorNotice(message: error)],
        ),
      ]),
      (projects) => Component.fragment([
        const _Meta(),
        StructuredData(
          id: 'ld-projects',
          SchemaOrg.itemList(
            items: [for (final p in projects) (name: p.name, slug: p.slug)],
          ),
        ),
        StructuredData(
          id: 'ld-breadcrumbs',
          SchemaOrg.breadcrumbs(const [
            (label: 'Home', path: RoutePaths.home),
            (label: 'Projects', path: RoutePaths.projects),
          ]),
        ),
        SectionBlock(
          eyebrow: 'Work',
          heading: 'Projects',
          isPageHeading: true,
          lead: 'Everything worth showing, newest first. Each one has a short '
              'case study — what it does, what was hard, what I would do '
              'differently.',
          children: [
            div(
              classes: 'grid gap-6 sm:grid-cols-2 lg:grid-cols-3',
              [for (final project in projects) ProjectCard(project: project)],
            ),
          ],
        ),
      ]),
    );
  }
}

class _Meta extends StatelessComponent {
  const _Meta();

  @override
  Component build(BuildContext context) => const PageMeta(
        path: RoutePaths.projects,
        title: 'Projects — ${SiteConfig.name}',
        description: 'Case studies from the mobile products I have designed and '
            'shipped — what each one does, what was hard, and what I would redo '
            'given another pass.',
      );
}
