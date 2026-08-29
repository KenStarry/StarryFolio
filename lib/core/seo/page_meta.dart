import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../config/site_config.dart';

/// Per-page `<head>` metadata. Every route renders exactly one.
///
/// The root [Document] in `main.server.dart` deliberately does *not* carry
/// canonical or Open Graph tags: entries in its `head:` list are emitted
/// verbatim and bypass Jaspr's override system, so a default there would
/// duplicate rather than be replaced by the page-level tag.
///
/// The `id` on each element is what lets a nested `PageMeta` win over an outer
/// one — Jaspr dedupes `<meta>` by `name`, and Open Graph tags key off
/// `property` instead, which would otherwise never match.
class PageMeta extends StatelessComponent {
  const PageMeta({
    required this.path,
    required this.title,
    required this.description,
    this.image = SiteConfig.defaultOgImage,
    this.type = 'website',
    this.noIndex = false,
    super.key,
  });

  /// Site-relative path of this route, from [RoutePaths].
  final String path;

  final String title;
  final String description;

  /// Path under `web/`, resolved against [SiteConfig.siteUrl].
  final String image;

  /// Open Graph type — `website` for index pages, `article` for case studies.
  final String type;

  /// Keeps the page out of search results. Used by the 404 route.
  final bool noIndex;

  @override
  Component build(BuildContext context) {
    final url = SiteConfig.absolute(path);

    return Document.head(
      title: title,
      meta: {'description': description},
      children: [
        // The robots directive is emitted *here*, not in `main.server.dart`'s
        // `head:` list, and it has to be. Entries there bypass the override
        // system, so a site-wide `index, follow` there plus a page-level
        // `noindex` shipped both tags on `/404` and `/thanks` — one page
        // carrying two contradictory directives. Google resolves a conflict to
        // the most restrictive, so the behaviour happened to be right, but
        // that is the crawler being forgiving rather than the page being
        // correct, and no other crawler owes us the same reading.
        if (noIndex)
          const meta(id: 'robots', name: 'robots', content: 'noindex, follow')
        else ...[
          const meta(
            id: 'robots',
            name: 'robots',
            // `max-snippet:-1` and `max-video-preview:-1` lift the default caps
            // on how much of a page a result may quote. Nothing here is worth
            // withholding from a search result, and a longer snippet is a
            // bigger target for a query to match against.
            content: 'index, follow, max-image-preview:large, '
                'max-snippet:-1, max-video-preview:-1',
          ),
          link(id: 'canonical', rel: 'canonical', href: url),
        ],
        meta(id: 'og-type', attributes: {'property': 'og:type', 'content': type}),
        meta(id: 'og-url', attributes: {'property': 'og:url', 'content': url}),
        meta(id: 'og-title', attributes: {'property': 'og:title', 'content': title}),
        meta(
          id: 'og-description',
          attributes: {'property': 'og:description', 'content': description},
        ),
        meta(
          id: 'og-image',
          attributes: {
            'property': 'og:image',
            'content': SiteConfig.absolute(image),
          },
        ),
        // Dimensions let a scraper reserve the right box before the image has
        // downloaded, so the preview does not reflow. `og:image:alt` is what
        // gets read aloud when the card is announced.
        const meta(
          id: 'og-image-w',
          attributes: {
            'property': 'og:image:width',
            'content': SiteConfig.ogImageWidth,
          },
        ),
        const meta(
          id: 'og-image-h',
          attributes: {
            'property': 'og:image:height',
            'content': SiteConfig.ogImageHeight,
          },
        ),
        const meta(
          id: 'og-image-alt',
          attributes: {
            'property': 'og:image:alt',
            'content': SiteConfig.ogImageAlt,
          },
        ),
        // Names the publication rather than the page. It is what a feed sets
        // as the small attribution line above a shared card, and without it a
        // scraper falls back to printing the bare domain.
        const meta(
          id: 'og-site-name',
          attributes: {
            'property': 'og:site_name',
            'content': SiteConfig.name,
          },
        ),
        const meta(
          id: 'og-locale',
          attributes: {
            'property': 'og:locale',
            'content': SiteConfig.ogLocale,
          },
        ),
        // Twitter reads og:* for everything except the alt text, which it
        // wants under its own namespace.
        meta(id: 'tw-title', name: 'twitter:title', content: title),
        meta(id: 'tw-description', name: 'twitter:description', content: description),
        meta(id: 'tw-image', name: 'twitter:image', content: SiteConfig.absolute(image)),
        const meta(
          id: 'tw-image-alt',
          name: 'twitter:image:alt',
          content: SiteConfig.ogImageAlt,
        ),
        // Attaches the card to an account. `site` is the publisher and
        // `creator` the author; on a one-person site they are the same handle,
        // and stating both is what turns an anonymous card in a timeline into
        // one with a byline that can be followed back here.
        const meta(id: 'tw-site', name: 'twitter:site', content: SiteConfig.xHandle),
        const meta(
          id: 'tw-creator',
          name: 'twitter:creator',
          content: SiteConfig.xHandle,
        ),
      ],
    );
  }
}
