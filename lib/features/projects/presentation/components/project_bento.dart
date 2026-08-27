import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/project_model.dart';
import 'project_card.dart';

/// A staggered grid of project cards.
///
/// Every card is identical in size — that is [ProjectCard]'s rule, not this
/// component's choice. What varies here is **position**: cards take a repeating
/// three-step vertical offset so the row reads as a wave rather than a ruler.
///
/// The offsets form a wave (`0 → down → half-up`) rather than a staircase
/// deliberately: a staircase leaves a growing gap under the shallowest column,
/// while a wave closes back on itself and keeps the rows evenly spaced.
///
/// Offsets are literal utility strings because Tailwind's scanner reads `.dart`
/// source — a class assembled by interpolation would be purged.
class ProjectBento extends StatelessComponent {
  const ProjectBento({required this.projects, super.key});

  final List<ProjectModel> projects;

  @override
  Component build(BuildContext context) {
    return div(
      // `stagger` on the container rather than `reveal` on each card: the
      // children enter over successive slices of one view timeline, so the
      // cascade tracks the scroll instead of running on fixed delays. Stopping
      // mid-grid stops the cascade with you.
      classes: 'stagger grid grid-cols-1 items-start gap-6 sm:grid-cols-2 '
          'lg:grid-cols-3 lg:gap-7',
      [
        for (final (i, project) in projects.indexed)
          ProjectCard(
            project: project,
            classes: _offsets[i % _offsets.length],
          ),
      ],
    );
  }

  static const List<String> _offsets = ['', 'lg:mt-14', 'lg:mt-7'];
}
