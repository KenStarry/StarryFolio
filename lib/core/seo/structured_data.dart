import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../config/site_config.dart';
import '../routing/route_paths.dart';

/// Emits a JSON-LD `<script>` into the document head.
///
/// This is the machine-readable half of the page. Crawlers use it to build rich
/// results — the Person block is what lets Google associate the social profiles
/// and job title with this site rather than guessing from prose.
///
/// Rendered inside `Document.head` so it survives into the pre-rendered HTML;
/// a crawler that never runs JS still sees it.
class StructuredData extends StatelessComponent {
  const StructuredData(this.data, {required this.id, super.key});

  /// The JSON-LD graph for this page, built by one of the helpers below.
  final Map<String, Object?> data;

  /// Distinguishes this block from other `StructuredData` on the page, and lets
  /// a nested page override an outer one.
  final String id;

  @override
  Component build(BuildContext context) {
    return Document.head(
      children: [
        script(
          id: id,
          attributes: const {'type': 'application/ld+json'},
          // `script` renders content raw, so a literal `</script>` or `<!--`
          // inside a string value would close the tag early. JSON escapes are
          // valid anywhere in a string, so escaping `<` neutralises both.
          content: jsonEncode(data).replaceAll('<', r'\u003c'),
        ),
      ],
    );
  }
}

/// JSON-LD graph builders.
///
/// Kept as plain functions returning maps so they stay trivially testable and
/// free of any component or framework dependency.
class SchemaOrg {
  const SchemaOrg._();

  static const String _context = 'https://schema.org';

  /// The site owner. Rendered on the home page.
  static Map<String, Object?> person() => {
        '@context': _context,
        '@type': 'Person',
        'name': SiteConfig.name,
        'alternateName': SiteConfig.shortName,
        'url': SiteConfig.siteUrl,
        'email': 'mailto:${SiteConfig.email}',
        'jobTitle': SiteConfig.role,
        'description': SiteConfig.tagline,
        'image': SiteConfig.absolute(SiteConfig.defaultOgImage),
        'address': {
          '@type': 'PostalAddress',
          'addressLocality': SiteConfig.location.split(',').first.trim(),
          'addressCountry': SiteConfig.location.split(',').last.trim(),
        },
        'knowsAbout': [
          for (final group in SiteConfig.toolkit) ...group.items,
        ],
        // `sameAs` is the property that links these profiles to this identity.
        'sameAs': [for (final s in SiteConfig.socials) s.url],
      };

  /// The site itself. Paired with [person] on the home page.
  static Map<String, Object?> website() => {
        '@context': _context,
        '@type': 'WebSite',
        'name': SiteConfig.name,
        'url': SiteConfig.siteUrl,
        'description': SiteConfig.tagline,
        'inLanguage': 'en',
        'author': {'@type': 'Person', 'name': SiteConfig.name},
      };

  /// A single case study.
  static Map<String, Object?> creativeWork({
    required String name,
    required String description,
    required String slug,
    required String year,
    required List<String> keywords,
    String? image,
    String? repoUrl,
  }) =>
      {
        '@context': _context,
        '@type': 'CreativeWork',
        'name': name,
        'description': description,
        'url': SiteConfig.absolute(RoutePaths.projectDetail(slug)),
        'dateCreated': year,
        'keywords': keywords.join(', '),
        'image': SiteConfig.absolute(image ?? SiteConfig.defaultOgImage),
        'author': {
          '@type': 'Person',
          'name': SiteConfig.name,
          'url': SiteConfig.siteUrl,
        },
        if (repoUrl != null) 'codeRepository': repoUrl,
      };

  /// An ordered list of the case studies, for the projects index.
  static Map<String, Object?> itemList({
    required List<({String name, String slug})> items,
  }) =>
      {
        '@context': _context,
        '@type': 'ItemList',
        'itemListElement': [
          for (final (index, item) in items.indexed)
            {
              '@type': 'ListItem',
              'position': index + 1,
              'name': item.name,
              'url': SiteConfig.absolute(RoutePaths.projectDetail(item.slug)),
            },
        ],
      };

  /// Trail shown under the result title in search. [crumbs] is ordered
  /// root-first as `(label, path)`.
  static Map<String, Object?> breadcrumbs(
    List<({String label, String path})> crumbs,
  ) =>
      {
        '@context': _context,
        '@type': 'BreadcrumbList',
        'itemListElement': [
          for (final (index, crumb) in crumbs.indexed)
            {
              '@type': 'ListItem',
              'position': index + 1,
              'name': crumb.label,
              'item': SiteConfig.absolute(crumb.path),
            },
        ],
      };
}
