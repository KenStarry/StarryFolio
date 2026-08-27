import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../domain/model/post_model.dart';

/// A written piece, styled deliberately unlike a [ProjectCard].
///
/// No cover, no fixed aspect — the card is sized by its own text and opens with
/// a large index number instead of an image. That contrast is the point: put a
/// project card and a post card side by side and you should know which is which
/// before reading a word.
///
/// The card renders one of three ways, following [PostModel.href]:
/// a `Link` for a piece that lives here, an `<a target=_blank>` for one
/// published elsewhere, and a plain `<div>` for one that is still planned. That
/// last case matters — a card that looks clickable and goes nowhere is worse
/// than one that plainly waits.
class PostCard extends StatelessComponent {
  const PostCard({required this.post, required this.index, super.key});

  final PostModel post;

  /// Zero-based position, rendered as the oversized `01` marker.
  final int index;

  @override
  Component build(BuildContext context) {
    final number = (index + 1).toString().padLeft(2, '0');
    final published = post.isPublished;

    final children = <Component>[
      div(
        classes: 'flex items-baseline justify-between gap-4',
        [
          span(
            classes: 'font-display text-4xl font-extrabold leading-none '
                'text-ink-700 transition-colors duration-500 '
                '${published ? 'group-hover:text-iris-500/60' : ''}',
            [Component.text(number)],
          ),
          span(
            classes: 'type-eyebrow font-mono text-iris-400',
            [Component.text(post.topic)],
          ),
        ],
      ),

      const div(classes: 'divider-quiet mt-6', []),

      h3(
        classes: 'mt-6 font-display text-lg font-bold leading-snug '
            'tracking-tight text-ink-100 transition-colors duration-300 '
            '${published ? 'group-hover:text-iris-300' : ''}',
        [Component.text(post.title)],
      ),

      p(
        classes: 'mt-3 text-sm leading-relaxed text-ink-400',
        [Component.text(post.excerpt)],
      ),

      const div(classes: 'flex-1 min-h-8', []),

      div(
        classes: 'mt-7 flex items-center justify-between gap-4',
        [
          p(
            classes: 'font-mono text-[11px] text-ink-500',
            [Component.text('${post.date}  ·  ${post.readMinutes} min read')],
          ),
          if (published)
            span(
              classes: 'text-ink-500 transition-all duration-500 ease-soft '
                  'group-hover:translate-x-1 group-hover:text-iris-300',
              [AppIcons.arrowUpRight(classes: 'h-4 w-4')],
            )
          else
            const span(
              classes: 'type-eyebrow font-mono text-ink-600',
              [Component.text('Soon')],
            ),
        ],
      ),
    ];

    const base = 'group flex flex-col border border-ink-700 bg-ink-900 '
        'p-7 transition-colors duration-500 ease-soft';

    if (!published) {
      return div(classes: '$base reveal', children);
    }

    const linked = '$base float-card reveal hover:bg-ink-850';

    // A `Link` for an internal destination, so the router handles it as a
    // client-side navigation once hydrated — and still emits a plain `<a href>`
    // into the static HTML, which is what a crawler follows.
    if (!post.isExternal) {
      return Link(
        to: post.href!,
        classes: linked,
        children: children,
      );
    }

    return a(
      href: post.href!,
      target: Target.blank,
      attributes: const {'rel': 'noopener'},
      classes: linked,
      children,
    );
  }
}
