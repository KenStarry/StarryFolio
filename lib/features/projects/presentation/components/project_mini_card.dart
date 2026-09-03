import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/project_model.dart';

/// A project at its smallest useful size: thumbnail, name, tagline, arrow.
///
/// Used wherever a *different* subject needs to point at real work — a role on
/// `/about`, a service on `/services`. It lives in the projects feature
/// because it renders a project, and both consumers pass one in rather than
/// each keeping a near-identical card of its own.
///
/// Deliberately small. The full `ProjectCard` leads with a 4:3 cover and would
/// out-weigh whatever it sits under, so the work would read as the point and
/// its host as the caption. Here the thumbnail is a strip, the name carries
/// the row, and the whole card is the target.
///
/// A project with no case study renders as a plain row rather than a link that
/// 404s — the same guard every other case-study link on this site carries.
class ProjectMiniCard extends StatelessComponent {
  const ProjectMiniCard({required this.project, super.key});

  final ProjectModel project;

  @override
  Component build(BuildContext context) {
    final art = project.mockupImage ?? project.coverImage;

    // A project with no case study has no page to open, so it renders as a
    // plain row rather than a link that 404s — the same guard every other
    // case-study link on the site carries.
    final body = [
      div(
        classes: 'xp-work-thumb',
        [
          if (art != null)
            img(
              src: '/$art',
              alt: '',
              attributes: const {'loading': 'lazy', 'decoding': 'async'},
            )
          else
            span(
              classes: 'font-display text-lg font-extrabold text-ink-600',
              attributes: const {'aria-hidden': 'true'},
              [Component.text(project.name.substring(0, 1))],
            ),
        ],
      ),

      div(
        classes: 'min-w-0 flex-1',
        [
          p(
            classes: 'truncate font-display text-sm font-bold text-ink-100',
            [Component.text(project.name)],
          ),
          p(
            classes: 'mt-1 line-clamp-2 text-xs leading-relaxed text-ink-400',
            [Component.text(project.tagline)],
          ),
        ],
      ),

      if (project.hasCaseStudy)
        span(
          classes: 'shrink-0 text-ink-600 transition-all duration-500 '
              'ease-soft group-hover/w:translate-x-0.5 '
              'group-hover/w:text-iris-400',
          attributes: const {'aria-hidden': 'true'},
          [AppIcons.arrow(classes: 'h-4 w-4')],
        ),
    ];

    if (!project.hasCaseStudy) {
      return div(classes: 'xp-work group/w', body);
    }

    return Link(
      to: RoutePaths.projectDetail(project.slug),
      classes: 'xp-work group/w',
      attributes: {'aria-label': '${project.name} case study'},
      children: body,
    );
  }
}
