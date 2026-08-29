import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/model/post_block.dart';
import '../../domain/model/post_model.dart';
import '../components/post_body.dart';

/// A single article, pre-rendered to `/writing/<slug>/index.html`.
///
/// Takes the slug rather than a resolved model so the route table stays free of
/// content, mirroring `ProjectDetailPage`. It also reads the full list, which
/// costs nothing from a local source and is what lets the piece end by handing
/// the reader the next one instead of a dead end.
class PostDetailPage extends AsyncStatelessComponent {
  const PostDetailPage({required this.slug, super.key});

  final String slug;

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.writing.getPost(slug);
    final all = await Locator.writing.getPosts();

    return result.fold(
      (error) => section(
        classes: 'bg-ink-900 py-28 sm:py-36',
        [
          PageMeta(
            path: RoutePaths.post(slug),
            title: 'Piece not found · ${SiteConfig.name}',
            description: error,
            noIndex: true,
          ),
          div(
            classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
            [ErrorNotice(message: error)],
          ),
        ],
      ),
      (post) {
        // Only pieces that actually have a page can be offered as "next" — the
        // whole point of the closing card is to keep the reader moving, and a
        // card that lands on nothing does the opposite.
        final live = all
            .getOrElse((_) => const [])
            .where((item) => item.hasBody)
            .toList(growable: false);
        final index = live.indexWhere((item) => item.slug == post.slug);
        final next = live.length > 1 && index >= 0
            ? live[(index + 1) % live.length]
            : null;

        return _Article(post: post, next: next);
      },
    );
  }
}

class _Article extends StatelessComponent {
  const _Article({required this.post, this.next});

  final PostModel post;
  final PostModel? next;

  @override
  Component build(BuildContext context) {
    // The contents rail is built from the body itself, so it can never list a
    // section the article does not have.
    final headings = [
      for (final block in post.body)
        if (block is PostHeading && block.level <= 2) block,
    ];

    return article([
      PageMeta(
        path: RoutePaths.post(post.slug),
        title: '${post.title}, ${SiteConfig.name}',
        description: post.excerpt,
        image: post.coverImage == null
            ? SiteConfig.defaultOgImage
            : '/${post.coverImage}',
        type: 'article',
      ),
      StructuredData(
        id: 'ld-post',
        SchemaOrg.blogPosting(
          headline: post.title,
          description: post.excerpt,
          slug: post.slug,
          keywords: post.tags,
          datePublished: post.dateIso,
          image: post.coverImage == null ? null : '/${post.coverImage}',
        ),
      ),
      StructuredData(
        id: 'ld-breadcrumbs',
        SchemaOrg.breadcrumbs([
          const (label: 'Home', path: RoutePaths.home),
          const (label: 'Writing', path: RoutePaths.writing),
          (label: post.title, path: RoutePaths.post(post.slug)),
        ]),
      ),

      _Head(post: post),
      _Body(post: post, headings: headings),
      if (post.sourceUrl != null) _Source(post: post),
      if (next != null) _NextUp(post: next!),
    ]);
  }
}

/// The masthead: trail, title, standfirst, byline, then the cover.
class _Head extends StatelessComponent {
  const _Head({required this.post});

  final PostModel post;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative overflow-hidden bg-ink-900 pb-16 pt-12 sm:pb-20 '
          'sm:pt-16',
      [
        GhostText(
          post.topic,
          faint: true,
          classes: 'absolute -bottom-10 -left-6',
        ),
        div(
          classes: 'relative mx-auto w-full max-w-3xl px-6 sm:px-8',
          [
            const Link(
              to: RoutePaths.writing,
              classes: 'link-line type-eyebrow inline-flex items-center '
                  'font-mono text-ink-400 transition-colors hover:text-ink-100',
              children: [Component.text('← All writing')],
            ),

            div(
              classes: 'rise mt-10 flex flex-wrap items-center gap-3',
              [
                span(
                  classes: 'type-eyebrow font-mono text-iris-400',
                  [Component.text(post.topic)],
                ),
                const span(classes: 'h-px w-8 bg-ink-600', []),
                // `<time>` carries the machine-readable date where there is
                // one; a plain span otherwise, rather than a `<time>` with a
                // fabricated `datetime`.
                if (post.dateIso case final iso?)
                  Component.element(
                    tag: 'time',
                    attributes: {'datetime': iso},
                    classes: 'font-mono text-[11px] text-ink-500',
                    children: [Component.text(post.date)],
                  )
                else
                  span(
                    classes: 'font-mono text-[11px] text-ink-500',
                    [Component.text(post.date)],
                  ),
                span(
                  classes: 'font-mono text-[11px] text-ink-500',
                  [Component.text('·  ${post.readMinutes} min read')],
                ),
              ],
            ),

            // The page's single `<h1>` (CLAUDE.md §4). Every heading in the
            // body below is an `h2` or lower.
            h1(
              classes: 'rise rise-1 type-page mt-7 font-display font-extrabold '
                  'leading-[1.03] tracking-tight text-ink-100',
              [Component.text(post.title)],
            ),

            if (post.dek case final dek?)
              p(
                classes: 'rise rise-2 mt-7 text-lg leading-relaxed text-ink-400',
                [Component.text(dek)],
              ),

            const div(
              classes: 'rise rise-3 mt-10 flex items-center gap-4 border-t '
                  'border-ink-700 pt-8',
              [
                img(
                  src: '/${SiteConfig.logoMark}',
                  alt: '',
                  classes: 'h-10 w-10 shrink-0 rounded-full border '
                      'border-ink-700 object-cover',
                  attributes: {'decoding': 'async', 'aria-hidden': 'true'},
                ),
                div([
                  p(
                    classes: 'font-display text-sm font-bold text-ink-100',
                    [Component.text(SiteConfig.name)],
                  ),
                  p(
                    classes: 'mt-0.5 font-mono text-[11px] text-ink-500',
                    [Component.text(SiteConfig.role)],
                  ),
                ]),
              ],
            ),
          ],
        ),

        if (post.coverImage case final cover?)
          div(
            classes: 'relative mx-auto mt-14 w-full max-w-4xl px-6 sm:px-8',
            [
              div(
                classes: 'float-card overflow-hidden border border-ink-700 '
                    'bg-ink-850',
                [
                  img(
                    src: '/$cover',
                    alt: post.coverAlt,
                    classes: 'w-full',
                    attributes: const {'decoding': 'async'},
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

/// The article column, with the contents rail alongside it on wide screens.
class _Body extends StatelessComponent {
  const _Body({required this.post, required this.headings});

  final PostModel post;
  final List<PostHeading> headings;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'bg-ink-900 pb-24 pt-16 sm:pb-32',
      [
        div(
          classes: 'mx-auto w-full max-w-3xl px-6 sm:px-8',
          [
            // Inline on narrow screens, where there is no room for a rail. It
            // is a `<nav>` either way, so the structure is the same for a
            // screen reader regardless of which one is showing.
            if (headings.length > 2) _Contents(headings: headings),
            PostBody(blocks: post.body),

            if (post.tags.isNotEmpty)
              div(
                classes: 'mt-16 flex flex-wrap gap-2 border-t border-ink-700 '
                    'pt-8',
                [
                  for (final tag in post.tags)
                    span(
                      classes: 'border border-ink-700 px-2.5 py-1 font-mono '
                          'text-[10px] uppercase tracking-wider text-ink-400',
                      [Component.text(tag)],
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// In-page contents.
///
/// A plain anchor list rather than a scroll-spy: highlighting the active
/// section would need JS on a page that is otherwise entirely static, and the
/// value of knowing *where you are* is small next to being able to jump.
class _Contents extends StatelessComponent {
  const _Contents({required this.headings});

  final List<PostHeading> headings;

  @override
  Component build(BuildContext context) {
    return nav(
      classes: 'rise mb-14 border-l border-ink-700 py-1 pl-6',
      attributes: const {'aria-label': 'On this page'},
      [
        const p(
          classes: 'type-eyebrow font-mono text-ink-500',
          [Component.text('On this page')],
        ),
        ul(
          classes: 'mt-4 space-y-2.5',
          [
            for (final heading in headings)
              li([
                a(
                  href: '#${heading.anchor}',
                  classes: 'link-line text-sm text-ink-400 transition-colors '
                      'hover:text-ink-100',
                  [Component.text(heading.text)],
                ),
              ]),
          ],
        ),
      ],
    );
  }
}

/// Credit line for a piece that appeared somewhere else first.
class _Source extends StatelessComponent {
  const _Source({required this.post});

  final PostModel post;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'bg-ink-800 py-14',
      [
        div(
          classes: 'mx-auto w-full max-w-3xl px-6 sm:px-8',
          [
            a(
              href: post.sourceUrl!,
              target: Target.blank,
              attributes: const {'rel': 'noopener'},
              classes: 'link-line type-eyebrow inline-flex items-center '
                  'font-mono text-ink-300 transition-colors hover:text-ink-100',
              [Component.text('${post.sourceLabel ?? 'Source'} ↗')],
            ),
          ],
        ),
      ],
    );
  }
}

/// The closing hand-off, so the article ends on a door rather than a wall.
class _NextUp extends StatelessComponent {
  const _NextUp({required this.post});

  final PostModel post;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative overflow-hidden bg-ink-800 py-20 sm:py-24',
      [
        const GhostText(
          'Next',
          size: GhostSize.small,
          faint: true,
          classes: 'absolute -bottom-6 right-0',
        ),
        div(
          classes: 'relative mx-auto w-full max-w-3xl px-6 sm:px-8',
          [
            const p(
              classes: 'type-eyebrow font-mono text-ink-500',
              [Component.text('Read next')],
            ),
            Link(
              to: post.href!,
              classes: 'group mt-6 block',
              children: [
                h2(
                  classes: 'type-section font-display font-extrabold '
                      'leading-tight tracking-tight text-ink-100 '
                      'transition-colors duration-300 group-hover:text-iris-300',
                  [Component.text(post.title)],
                ),
                p(
                  classes: 'mt-5 max-w-xl text-sm leading-relaxed text-ink-400',
                  [Component.text(post.excerpt)],
                ),
                const span(
                  classes: 'link-line type-eyebrow mt-8 inline-flex '
                      'items-center font-mono text-ink-100',
                  [Component.text('Read the piece →')],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
