import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/page_meta.dart';
import '../components/project_card.dart';
import '../components/section.dart';
import '../data/profile.dart';
import '../data/projects.dart';

class ProjectsPage extends StatelessComponent {
  const ProjectsPage({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      const PageMeta(
        path: '/projects',
        title: 'Projects — ${Profile.name}',
        description: 'Case studies from the mobile products I have designed and '
            'shipped — what each one does, what was hard, and what I would '
            'redo given another pass.',
      ),
      Section(
        eyebrow: 'Work',
        heading: 'Projects',
        lead: 'Everything worth showing, newest first. Each one has a short case '
            'study — what it does, what was hard, what I would do differently.',
        children: [
          div(
            classes: 'grid gap-6 sm:grid-cols-2 lg:grid-cols-3',
            [
              for (final project in projects) ProjectCard(project: project),
            ],
          ),
        ],
      ),
    ]);
  }
}
