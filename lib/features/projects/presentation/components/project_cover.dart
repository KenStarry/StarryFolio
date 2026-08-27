import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/project_model.dart';

/// The visual half of a project card.
///
/// Three fallbacks, in order:
///
/// 1. **`coverImage`** — a real screenshot, cropped to fill the box.
/// 2. **`mockupImage`** — the transparent device render, presented as a
///    miniature showcase: contained rather than cropped, anchored to the
///    bottom, slightly overscaled so it fills the frame, with the accent bloom
///    behind it. Cropping a two-device mockup to fill would cut one of the
///    phones off entirely.
/// 3. **The initial**, set large — honest about being a placeholder in a way a
///    fake device mock is not.
class ProjectCover extends StatelessComponent {
  const ProjectCover({required this.project, this.fill = false, super.key});

  final ProjectModel project;

  /// Fills its parent instead of holding a 16:10 box. Used by layouts that set
  /// their own height from the copy column beside them.
  final bool fill;

  @override
  Component build(BuildContext context) {
    final cover = project.coverImage;
    final mockup = project.mockupImage;

    return div(
      classes: 'reveal-media overflow-hidden bg-ink-900 '
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
        else if (mockup != null) ...[
          const div(
            classes: 'bloom pointer-events-none absolute inset-0 -m-4',
            attributes: {'aria-hidden': 'true'},
            [],
          ),
          div(
            classes: 'absolute inset-0 flex items-end justify-center '
                'overflow-hidden',
            [
              img(
                src: '/$mockup',
                alt: '${project.name} — ${project.tagline}',
                attributes: const {'loading': 'lazy', 'decoding': 'async'},
                // Overscaled past the box height and bottom-anchored, so the
                // devices read large and the frame crops their base rather
                // than letterboxing them into a small centred thumbnail.
                classes: 'h-[126%] w-full translate-y-[6%] object-contain '
                    'object-bottom transition-transform duration-700 '
                    'ease-soft group-hover:translate-y-[2%]',
              ),
            ],
          ),
        ] else
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
