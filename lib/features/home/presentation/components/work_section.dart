import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../projects/domain/model/project_model.dart';
import '../../../projects/presentation/components/project_card.dart';

/// Selected-work showcase — the page's centrepiece.
///
/// Three large cards at most, arranged as a **spotlight arch**: the centre card
/// sits higher than the two flanking it. A running stagger looked like a
/// mistake at this count, but a symmetrical arch reads as deliberate — it
/// points at the middle of the row and tells you this section is the highlight.
///
/// Implemented by pushing the *outer* cards down rather than pulling the centre
/// up, so the section's top edge stays where the grid put it and the heading
/// spacing above is unaffected.
///
/// Deliberately not a grid-plus-list: the home page shows a handful of things
/// properly and sends you to `/projects` for the whole catalogue.
class WorkSection extends StatelessComponent {
  const WorkSection({required this.projects, super.key});

  final List<ProjectModel> projects;

  @override
  Component build(BuildContext context) {
    // Three is the ceiling — a fourth breaks the stagger rhythm and makes the
    // section compete with the projects page.
    final shown = projects.take(3).toList(growable: false);

    return SectionBlock(
      id: 'work',
      eyebrow: 'Selected work',
      heading: 'All creative works,\nselected projects.',
      lead: 'Products where I owned the whole surface — design system, '
          'architecture, release.',
      children: [
        if (shown.isNotEmpty)
          div(
            classes: 'grid items-start gap-6 sm:grid-cols-2 lg:grid-cols-3 '
                'lg:gap-7',
            [
              for (final (i, project) in shown.indexed)
                ProjectCard(
                  project: project,
                  classes: 'reveal ${_archOffset(i, shown.length)}',
                ),
            ],
          ),

        div(
          classes: 'reveal mt-16 flex flex-wrap items-center gap-6',
          [
            const CtaButton(
              label: 'Show more projects',
              href: RoutePaths.projects,
            ),
            if (projects.length > shown.length)
              p(
                classes: 'font-mono text-[11px] text-ink-500',
                [
                  Component.text(
                    '${projects.length - shown.length} more in the archive',
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  /// Drops every card except the middle one of a three-card row. Any other
  /// count has no meaningful centre, so the row stays flat rather than
  /// guessing — two cards would give a lopsided arch and one would be absurd.
  ///
  /// The offset is a literal utility because Tailwind's scanner reads `.dart`
  /// source; a computed class would be purged.
  static String _archOffset(int index, int total) =>
      (total == 3 && index != 1) ? 'lg:mt-12' : '';
}
