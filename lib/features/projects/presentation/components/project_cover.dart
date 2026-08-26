import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/project_model.dart';

/// The visual half of a project card.
///
/// With a `coverImage` it renders the screenshot. Without one — which is every
/// project today — it renders the project's initial at display size on the
/// card's own tone. A flat monogram is honest about being a placeholder in a
/// way a fake device mock is not, and it costs nothing to look at.
class ProjectCover extends StatelessComponent {
  const ProjectCover({required this.project, this.fill = false, super.key});

  final ProjectModel project;

  /// Fills its parent instead of holding a 16:10 box. Used by the feature
  /// card, which sets its own height from the copy column beside it.
  final bool fill;

  @override
  Component build(BuildContext context) {
    final cover = project.coverImage;

    return div(
      classes: 'overflow-hidden bg-ink-900 '
          '${fill ? 'absolute inset-0' : 'relative aspect-[16/10] w-full'}',
      [
        if (cover != null)
          img(
            src: '/$cover',
            alt: '${project.name} — ${project.tagline}',
            // Cards sit below the fold on every page that uses them.
            attributes: const {'loading': 'lazy', 'decoding': 'async'},
            classes: 'h-full w-full object-cover transition-transform '
                'duration-700 ease-soft group-hover:scale-[1.03]',
          )
        else
          div(
            classes: 'flex h-full w-full items-center justify-center',
            attributes: const {'aria-hidden': 'true'},
            [
              span(
                classes: 'font-display font-extrabold tracking-tighter '
                    'text-ink-700 transition-colors duration-500 '
                    'group-hover:text-iris-500/40 '
                    '${fill ? 'text-8xl' : 'text-6xl'}',
                [Component.text(project.name.substring(0, 1))],
              ),
            ],
          ),
      ],
    );
  }
}
