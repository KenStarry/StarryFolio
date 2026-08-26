import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../projects/domain/model/project_model.dart';
import '../../../projects/presentation/components/project_card.dart';
import '../../../projects/presentation/components/project_showcase.dart';

/// Selected-work teaser — one flagship, then two supporting projects.
///
/// The flagship is presented **flat**, exactly like on `/projects`, just at
/// teaser density: no meta table, a larger mockup, store badges included. An
/// earlier pass enclosed it in a bordered card, which fought the flat language
/// the rest of the page is built on and forced the mockup to bleed awkwardly
/// past the card edge.
///
/// The two cards beside it are the **other flagships**. Everything on this
/// section is a featured project: the home page shows only flagships, and
/// elevating one of them to the flat treatment is what makes it the overall
/// feature. The rest of the catalogue lives behind the archive tile.
///
/// Supporting work sits in a three-column row — two cards and the call to
/// action occupying the third cell. Putting the CTA *in* the grid rather than
/// floating it underneath completes the row, and it is what lets the cards be
/// a third of the width rather than half, so they read as supporting rather
/// than competing with the flagship above.
class WorkSection extends StatelessComponent {
  const WorkSection({required this.projects, super.key});

  final List<ProjectModel> projects;

  @override
  Component build(BuildContext context) {
    // The flagship needs a mockup — the flat treatment is built around one.
    final feature = projects
        .where((item) => item.featured && item.mockupImage != null)
        .firstOrNull;

    // The other flagships lead, since this section is a showcase of featured
    // work. Non-featured projects only top the row up if there are fewer than
    // two other flagships, so the layout never renders a short row.
    final others = projects.where((item) => item != feature);
    final supporting = [
      ...others.where((item) => item.featured),
      ...others.where((item) => !item.featured),
    ].take(2).toList(growable: false);

    final shown = (feature == null ? 0 : 1) + supporting.length;
    final remaining = projects.length - shown;

    return SectionBlock(
      id: 'work',
      eyebrow: 'Selected work',
      heading: 'All creative works,\nselected projects.',
      lead: 'Products where I owned the whole surface — design system, '
          'architecture, release.',
      children: [
        if (feature != null)
          div(
            classes: 'reveal',
            [ProjectShowcase(project: feature, compact: true)],
          ),

        if (supporting.isNotEmpty)
          div(
            classes: 'mt-20 grid items-stretch gap-6 sm:grid-cols-2 '
                'lg:grid-cols-3',
            [
              for (final project in supporting)
                ProjectCard(project: project, classes: 'reveal'),
              _moreTile(remaining),
            ],
          ),
      ],
    );
  }

  /// The archive tile that closes the row.
  ///
  /// Sized by the grid rather than by its own content, so it matches the cards
  /// beside it without hard-coding their height.
  static Component _moreTile(int remaining) => Link(
        to: RoutePaths.projects,
        classes: 'reveal group flex flex-col justify-between border '
            'border-dashed border-ink-700 p-7 transition-colors duration-500 '
            'ease-soft hover:border-iris-500/50 hover:bg-ink-850',
        children: [
          div([
            const p(
              classes: 'type-eyebrow font-mono text-ink-500',
              [Component.text('The archive')],
            ),
            p(
              classes: 'mt-6 font-display text-5xl font-extrabold leading-none '
                  'text-ink-700 transition-colors duration-500 '
                  'group-hover:text-iris-500/60',
              [Component.text(remaining.toString().padLeft(2, '0'))],
            ),
            p(
              classes: 'mt-4 max-w-[14rem] text-sm leading-relaxed text-ink-400',
              [
                Component.text(
                  remaining == 1
                      ? 'One more project, with its full case study.'
                      : 'More projects, each with its own case study.',
                ),
              ],
            ),
          ]),
          div(
            classes: 'mt-8 flex items-center gap-2.5 text-sm font-medium '
                'text-ink-200 transition-colors duration-300 '
                'group-hover:text-iris-300',
            [
              const Component.text('Show more projects'),
              span(
                classes: 'transition-transform duration-500 ease-soft '
                    'group-hover:translate-x-1.5',
                [AppIcons.arrow()],
              ),
            ],
          ),
        ],
      );
}
