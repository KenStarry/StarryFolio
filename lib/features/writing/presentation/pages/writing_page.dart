import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../../core/presentation/components/page_header.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/model/post_model.dart';
import '../components/post_card.dart';

/// The writing index.
///
/// An [AsyncStatelessComponent] so the repository is awaited *during*
/// pre-rendering — every card, excerpt and date is in the generated HTML.
///
/// The page leads with the newest published piece as a full-width feature and
/// puts the rest in a grid, which is the same shape as `/projects` for the same
/// reason: a vertical list of titles is a table of contents, not a page. What
/// differs is the feature — a post has a cover and a standfirst rather than a
/// device render, so it reads as an invitation to a piece of writing instead of
/// a product shot.
class WritingPage extends AsyncStatelessComponent {
  const WritingPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.writing.getPosts();

    return result.fold(
      (error) => Component.fragment([
        const _Meta(),
        SectionBlock(
          eyebrow: 'Writing',
          heading: 'Notes',
          isPageHeading: true,
          children: [ErrorNotice(message: error)],
        ),
      ]),
      (posts) {
        final live =
            posts.where((post) => post.hasBody).toList(growable: false);
        final planned =
            posts.where((post) => !post.isPublished).toList(growable: false);

        // The feature is the newest piece that actually has a page. Featuring a
        // planned one would put the page's largest, most confident element
        // behind a link that goes nowhere.
        final feature = live.firstOrNull;
        final rest = [
          for (final post in posts)
            if (post != feature) post,
        ];

        return Component.fragment([
          const _Meta(),
          StructuredData(
            id: 'ld-blog',
            SchemaOrg.blog(
              items: [
                for (final post in live)
                  (name: post.title, slug: post.slug, date: post.dateIso),
              ],
            ),
          ),
          StructuredData(
            id: 'ld-breadcrumbs',
            SchemaOrg.breadcrumbs(const [
              (label: 'Home', path: RoutePaths.home),
              (label: 'Writing', path: RoutePaths.writing),
            ]),
          ),

          _Header(published: live.length, planned: planned.length),
          if (feature != null) _Feature(post: feature),
          if (rest.isNotEmpty) _Grid(posts: rest, offset: feature == null ? 0 : 1),
        ]);
      },
    );
  }
}

class _Header extends StatelessComponent {
  const _Header({required this.published, required this.planned});

  final int published;
  final int planned;

  @override
  Component build(BuildContext context) {
    return PageHeader(
      trail: 'Writing',
      ghost: 'Notes',
      path: RoutePaths.writing,
      meta: published == 1 ? '1 piece up' : '$published pieces up',
      title: 'Notes from the build,',
      titleTail: 'and what they cost.',
      lead: 'Long-form pieces on Flutter, architecture and the parts of '
          'shipping nobody scopes. Written when something took me longer than '
          'it should have, so it takes you less.',
      facts: [
        (value: published.toString().padLeft(2, '0'), label: 'Published'),
        (value: planned.toString().padLeft(2, '0'), label: 'In the works'),
        (value: '5+', label: 'Years shipping'),
      ],
    );
  }
}

/// The lead piece: cover left, everything else right.
class _Feature extends StatelessComponent {
  const _Feature({required this.post});

  final PostModel post;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative overflow-hidden bg-ink-800 py-20 sm:py-28',
      [
        GhostText(
          post.topic,
          size: GhostSize.small,
          faint: true,
          classes: 'absolute -bottom-6 -right-4',
        ),
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const Eyebrow('Latest'),
            div(
              classes: 'mt-10 grid items-center gap-12 lg:grid-cols-2 lg:gap-16',
              [
                if (post.coverImage != null)
                  Link(
                    to: post.href!,
                    classes: 'float-card reveal block overflow-hidden '
                        'border border-ink-700 bg-ink-900',
                    children: [
                      img(
                        src: '/${post.coverImage}',
                        alt: post.coverAlt,
                        classes: 'reveal-media w-full',
                        attributes: const {
                          'loading': 'lazy',
                          'decoding': 'async',
                        },
                      ),
                    ],
                  ),
                div(
                  classes: 'reveal',
                  [
                    div(
                      classes: 'flex flex-wrap items-center gap-3',
                      [
                        span(
                          classes: 'type-eyebrow font-mono text-iris-400',
                          [Component.text(post.topic)],
                        ),
                        const span(classes: 'h-px w-8 bg-ink-600', []),
                        span(
                          classes: 'font-mono text-[11px] text-ink-500',
                          [
                            Component.text(
                              '${post.date}  ·  ${post.readMinutes} min read',
                            ),
                          ],
                        ),
                      ],
                    ),

                    h2(
                      classes: 'type-section mt-7 font-display font-extrabold '
                          'leading-[1.05] tracking-tight text-ink-100',
                      [
                        Link(
                          to: post.href!,
                          classes: 'transition-colors duration-300 '
                              'hover:text-iris-300',
                          children: [Component.text(post.title)],
                        ),
                      ],
                    ),

                    p(
                      classes: 'mt-6 max-w-lg text-[0.9375rem] leading-relaxed '
                          'text-ink-300',
                      [Component.text(post.dek ?? post.excerpt)],
                    ),

                    if (post.tags.isNotEmpty)
                      div(
                        classes: 'mt-8 flex flex-wrap gap-2',
                        [
                          for (final tag in post.tags)
                            span(
                              classes: 'border border-ink-700 px-2.5 py-1 '
                                  'font-mono text-[10px] uppercase '
                                  'tracking-wider text-ink-400',
                              [Component.text(tag)],
                            ),
                        ],
                      ),

                    div(
                      classes: 'mt-10',
                      [
                        Link(
                          to: post.href!,
                          classes: 'link-line type-eyebrow inline-flex '
                              'items-center font-mono text-ink-100',
                          children: [const Component.text('Read the piece →')],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Grid extends StatelessComponent {
  const _Grid({required this.posts, required this.offset});

  final List<PostModel> posts;

  /// Keeps the card numbering continuous with the feature above it, so the
  /// index reads as one sequence rather than restarting at 01.
  final int offset;

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      eyebrow: 'Everything else',
      heading: 'The rest of the shelf',
      lead: 'Some of these are written and some are still owed. The ones '
          'marked Soon are topics I keep explaining in DMs, which is usually '
          'the signal that they should be a post.',
      tone: SectionTone.base,
      children: [
        div(
          // `stagger`, not `reveal` per card — see ProjectBento.
          classes: 'stagger mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-3',
          [
            for (final (i, post) in posts.indexed)
              PostCard(post: post, index: i + offset),
          ],
        ),
      ],
    );
  }
}

class _Meta extends StatelessComponent {
  const _Meta();

  @override
  Component build(BuildContext context) {
    return const PageMeta(
      path: RoutePaths.writing,
      title: 'Writing — ${SiteConfig.name}',
      description: 'Long-form notes on Flutter, architecture and shipping '
          'mobile products — by ${SiteConfig.name}.',
    );
  }
}
