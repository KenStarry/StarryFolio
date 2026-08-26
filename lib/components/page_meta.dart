import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/profile.dart';

/// Per-page `<head>` metadata.
///
/// Every route renders exactly one of these. The root [Document] in
/// `main.server.dart` deliberately does *not* carry canonical or Open Graph
/// tags: entries in its `head:` list are emitted verbatim and bypass Jaspr's
/// override system, so a default there would duplicate rather than be replaced.
///
/// The `id` on each element is what lets a nested `PageMeta` win over an outer
/// one — Jaspr dedupes `<meta>` by `name`, and Open Graph tags key off
/// `property` instead, which would otherwise never match.
class PageMeta extends StatelessComponent {
  const PageMeta({
    required this.path,
    required this.title,
    required this.description,
    this.image = '/images/og.png',
    this.type = 'website',
    this.noIndex = false,
    super.key,
  });

  /// Absolute path of this route, `/` for the home page.
  final String path;

  final String title;
  final String description;

  /// Path under `web/`, resolved against [Profile.siteUrl].
  final String image;

  /// Open Graph type — `website` for index pages, `article` for case studies.
  final String type;

  /// Keeps the page out of search results. Used by the 404 route.
  final bool noIndex;

  String get _url => path == '/' ? Profile.siteUrl : '${Profile.siteUrl}$path';

  @override
  Component build(BuildContext context) {
    return Document.head(
      title: title,
      meta: {'description': description},
      children: [
        if (noIndex)
          const meta(id: 'robots', name: 'robots', content: 'noindex, follow')
        else
          link(id: 'canonical', rel: 'canonical', href: _url),
        meta(id: 'og-type', attributes: {'property': 'og:type', 'content': type}),
        meta(id: 'og-url', attributes: {'property': 'og:url', 'content': _url}),
        meta(id: 'og-title', attributes: {'property': 'og:title', 'content': title}),
        meta(
          id: 'og-description',
          attributes: {'property': 'og:description', 'content': description},
        ),
        meta(
          id: 'og-image',
          attributes: {'property': 'og:image', 'content': '${Profile.siteUrl}$image'},
        ),
      ],
    );
  }
}
