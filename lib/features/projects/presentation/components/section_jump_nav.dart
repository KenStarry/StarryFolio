import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/routing/route_paths.dart';
import '../../domain/enum/project_category.dart';
import '../../domain/model/project_model.dart';

/// Pills that jump to a band rather than filtering it.
///
/// These replaced a CSS-only radio filter. With every category given its own
/// titled section, filtering and jumping did the same job — and a plain anchor
/// is better at it: it is a real link, so it is keyboard operable, shareable,
/// and leaves the whole page in the document rather than hiding two thirds of
/// it behind `display:none`.
///
/// Smooth scrolling and clearance under the sticky nav come from
/// `scroll-behavior` and `scroll-padding-top` on `<html>` — no script.
class SectionJumpNav extends StatelessComponent {
  const SectionJumpNav({
    required this.projects,
    required this.featured,
    required this.path,
    super.key,
  });

  /// Path of the page these anchors live on. Required because `<base href="/">`
  /// makes a bare fragment resolve against the site root — see
  /// [RoutePaths.anchor].
  final String path;

  /// Projects grouped into category bands.
  final List<ProjectModel> projects;

  /// Featured projects, each of which has its own band anchored on its slug.
  final List<ProjectModel> featured;

  @override
  Component build(BuildContext context) {
    final counts = <ProjectCategory, int>{};
    for (final item in projects) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }

    // Declaration order, and only categories that actually have a band — a
    // pill pointing at an anchor the page never rendered is a dead link.
    final present =
        ProjectCategory.values.where(counts.containsKey).toList(growable: false);

    return nav(
      classes: 'reveal flex flex-wrap items-center gap-2.5',
      attributes: const {'aria-label': 'Jump to a section'},
      [
        // Flagships lead, since they are what the page is built around.
        for (final item in featured)
          _pill(path, item.slug, item.name, 1),
        for (final cat in present)
          _pill(path, cat.slug, cat.title, counts[cat]!),
      ],
    );
  }

  static Component _pill(String path, String anchor, String text, int count) => a(
        href: RoutePaths.anchor(path, anchor),
        classes: 'jump-pill',
        [
          span([Component.text(text)]),
          span(
            classes: 'jump-count',
            [Component.text(count.toString().padLeft(2, '0'))],
          ),
        ],
      );
}
