import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/layout.dart';
import 'data/profile.dart';
import 'data/projects.dart';
import 'pages/home.dart';
import 'pages/not_found.dart';
import 'pages/project_detail.dart';
import 'pages/projects_page.dart';

/// Route table. In `static` mode every path listed here is pre-rendered to
/// its own HTML file at build time — including the generated project routes.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(
          path: '/',
          title: '${Profile.name} — ${Profile.role}',
          builder: (context, state) => const Layout(child: HomePage()),
        ),
        Route(
          path: '/projects',
          title: 'Projects — ${Profile.name}',
          builder: (context, state) => const Layout(child: ProjectsPage()),
        ),
        for (final project in projects)
          Route(
            path: '/projects/${project.slug}',
            title: '${project.name} — ${Profile.name}',
            builder: (context, state) =>
                Layout(child: ProjectDetailPage(project: project)),
          ),
        Route(
          path: '/404',
          title: 'Not found — ${Profile.name}',
          builder: (context, state) => const Layout(child: NotFoundPage()),
        ),
      ],
    );
  }
}
