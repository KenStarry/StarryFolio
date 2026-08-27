import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'core/config/site_config.dart';
import 'core/presentation/components/app_layout.dart';
import 'core/routing/route_paths.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/about/presentation/pages/about_page.dart';
import 'features/contact/presentation/pages/contact_page.dart';
import 'features/contact/presentation/pages/thanks_page.dart';
import 'features/not_found/presentation/pages/not_found_page.dart';
import 'features/projects/data/datasource/projects_local_datasource.dart';
import 'features/projects/presentation/pages/project_detail_page.dart';
import 'features/projects/presentation/pages/projects_page.dart';
import 'features/services/presentation/pages/services_page.dart';
import 'features/writing/data/datasource/writing_local_datasource.dart';
import 'features/writing/presentation/pages/post_detail_page.dart';
import 'features/writing/presentation/pages/writing_page.dart';

/// Route table. In `static` mode every path listed here is pre-rendered to its
/// own HTML file at build time.
///
/// Project routes are enumerated straight from
/// [ProjectsLocalDatasource.caseStudySlugs] rather than the repository: static
/// generation needs the full list of pages *synchronously*, before any async
/// work can run. The pages themselves still go through the repository — this
/// only decides which URLs exist.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(
          path: RoutePaths.home,
          title: '${SiteConfig.name} — ${SiteConfig.role}',
          builder: (context, state) =>
              AppLayout(path: state.location, child: const HomePage()),
        ),
        Route(
          path: RoutePaths.projects,
          title: 'Projects — ${SiteConfig.name}',
          builder: (context, state) =>
              AppLayout(path: state.location, child: const ProjectsPage()),
        ),
        Route(
          path: RoutePaths.writing,
          title: 'Writing — ${SiteConfig.name}',
          builder: (context, state) =>
              AppLayout(path: state.location, child: const WritingPage()),
        ),
        Route(
          path: RoutePaths.about,
          title: 'About — ${SiteConfig.name}',
          builder: (context, state) =>
              AppLayout(path: state.location, child: const AboutPage()),
        ),
        Route(
          path: RoutePaths.services,
          title: 'Services — ${SiteConfig.name}',
          builder: (context, state) =>
              AppLayout(path: state.location, child: const ServicesPage()),
        ),
        Route(
          path: RoutePaths.contact,
          title: 'Contact — ${SiteConfig.name}',
          builder: (context, state) =>
              AppLayout(path: state.location, child: const ContactPage()),
        ),
        for (final slug in ProjectsLocalDatasource.caseStudySlugs)
          Route(
            path: RoutePaths.projectDetail(slug),
            builder: (context, state) => AppLayout(
              path: state.location,
              child: ProjectDetailPage(slug: slug),
            ),
          ),
        // Same rule as the projects above, with one addition: the datasource
        // filters on `hasBody`, so a planned piece listed on the index does not
        // generate a page it has no content for.
        for (final slug in WritingLocalDatasource.slugs)
          Route(
            path: RoutePaths.post(slug),
            builder: (context, state) => AppLayout(
              path: state.location,
              child: PostDetailPage(slug: slug),
            ),
          ),
        Route(
          path: RoutePaths.thanks,
          title: 'Message sent — ${SiteConfig.name}',
          builder: (context, state) =>
              AppLayout(path: state.location, child: const ThanksPage()),
        ),
        Route(
          path: RoutePaths.notFound,
          title: 'Not found — ${SiteConfig.name}',
          builder: (context, state) =>
              AppLayout(path: state.location, child: const NotFoundPage()),
        ),
      ],
    );
  }
}
