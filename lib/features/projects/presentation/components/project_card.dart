import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/project_model.dart';
import 'project_cover.dart';

/// A large, boxy, floating case-study card.
///
/// Anatomy deliberately mirrors the hero's portrait card: a big flat cover with
/// a solid caption panel beneath it, divided by a hairline. A gradient scrim
/// over the image would be the conventional move, but this design is flat by
/// rule — a solid panel keeps the card in the same family as everything else on
/// the page.
///
/// **Every card is the same size, everywhere.** The cover ratio and the caption
/// scale are fixed here rather than exposed as parameters, so no caller can
/// reintroduce the size variation that made the grid read as inconsistent. What
/// varies between layouts is position — [classes] takes grid placement and
/// stagger offsets, and nothing else.
class ProjectCard extends StatelessComponent {
  const ProjectCard({
    required this.project,
    this.classes = '',
    super.key,
  });

  final ProjectModel project;

  /// Placement only — grid column, stagger offset, reveal. Never sizing.
  final String classes;

  /// The one cover ratio on the site. 4:3 rather than the 4:5 it was: with a
  /// caption panel underneath, a portrait cover made the whole card elongated.
  static const String _coverAspect = 'aspect-[4/3]';

  @override
  Component build(BuildContext context) {
    return Link(
      to: RoutePaths.projectDetail(project.slug),
      classes: 'float-card group relative flex flex-col overflow-hidden '
          'border border-ink-700 bg-ink-800 $classes',
      // Always emitted, not just when filterable: it is inert markup off the
      // filter page and keeps the card usable in any grid that wants to filter.
      attributes: {'data-cat': project.category.slug},
      children: [
        // ── Cover ──
        div(
          classes: 'relative w-full overflow-hidden $_coverAspect',
          [
            ProjectCover(project: project, fill: true),

            // Status, top-left. Sits on the cover so the caption panel stays
            // reserved for identity.
            span(
              classes: 'absolute left-4 top-4 z-10 border bg-ink-900/70 '
                  'px-2.5 py-1 font-mono text-[10px] uppercase tracking-wider '
                  'backdrop-blur-sm ${project.status.classes}',
              [Component.text(project.status.label)],
            ),

            // Arrow, top-right. Fades and slides in on hover rather than
            // sitting there permanently — it is an affordance, not decoration.
            const div(
              classes: 'absolute right-4 top-4 z-10 flex h-9 w-9 items-center '
                  'justify-center border border-iris-400/40 bg-ink-900/70 '
                  'text-iris-300 opacity-0 backdrop-blur-sm transition-all '
                  'duration-500 ease-soft group-hover:translate-x-0 '
                  'group-hover:opacity-100 translate-x-2',
              [_arrow],
            ),
          ],
        ),

        // ── Caption panel ──
        div(
          classes: 'flex flex-1 flex-col border-t border-ink-700 p-6 sm:p-7',
          [
            div(
              classes: 'flex items-center gap-3',
              [
                span(
                  classes: 'type-eyebrow font-mono text-iris-400',
                  [Component.text(project.category.label)],
                ),
                const span(classes: 'h-px flex-1 bg-ink-700', []),
                span(
                  classes: 'font-mono text-[11px] text-ink-500',
                  [Component.text(project.year)],
                ),
              ],
            ),

            h3(
              classes: 'mt-4 font-display text-xl font-extrabold '
                  'tracking-tight text-ink-100 transition-colors duration-300 '
                  'group-hover:text-iris-300 sm:text-2xl',
              [Component.text(project.name)],
            ),

            p(
              classes: 'mt-2.5 text-sm leading-relaxed text-ink-400',
              [Component.text(project.tagline)],
            ),

            // Holds the stack row on the card's floor so a row of cards with
            // different tagline lengths still shares one baseline.
            const div(classes: 'flex-1 min-h-6', []),

            p(
              classes: 'mt-6 font-mono text-[11px] text-ink-500',
              [Component.text(project.stack.take(3).join('  ·  '))],
            ),
          ],
        ),
      ],
    );
  }

  static const Component _arrow = _Arrow();
}

/// Extracted so the surrounding card chrome can stay a `const` subtree —
/// `AppIcons.arrowUpRight` is a method call and cannot appear in one.
class _Arrow extends StatelessComponent {
  const _Arrow();

  @override
  Component build(BuildContext context) =>
      AppIcons.arrowUpRight(classes: 'h-4 w-4');
}
