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
        if (noIndex)
          const meta(id: 'robots', name: 'robots', content: 'noindex, follow')
        else
          link(id: 'canonical', rel: 'canonical', href: url),
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
        // Twitter reads og:* for everything except the alt text, which it
        // wants under its own namespace.
        meta(id: 'tw-title', name: 'twitter:title', content: title),
        meta(id: 'tw-description', name: 'twitter:description', content: description),
        meta(id: 'tw-image', name: 'twitter:image', content: SiteConfig.absolute(image)),
      ],
    );
  }
}
