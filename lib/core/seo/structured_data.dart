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

  /// Stable identifier for the one person this site is about. Every graph that
  /// mentions him points here instead of describing him again.
  static String get personId => '${SiteConfig.siteUrl}/#person';

  /// The site owner. Rendered on the home page and on `/about`.
  ///
  /// Carries a stable `@id`, so the two pages describe *one* person rather
  /// than two identically-named ones — [profilePage] points its `mainEntity`
  /// at the same identifier and a crawler merges the nodes.
  ///
  /// [knowsAbout] is passed in rather than read from config: the skills matrix
  /// on `/about` is the source of truth for what is claimed, and a second copy
  /// here would be free to drift away from the one a human can actually read.
  static Map<String, Object?> person({List<String> knowsAbout = const []}) => {
        '@context': _context,
        '@type': 'Person',
        '@id': personId,
        'name': SiteConfig.name,
        // A list, not a string. `KenStarry`, `kenstarry` and `Ken` are all
        // forms in genuine use across the GitHub handle, the wordmark and the
        // domain, and stating them is how a crawler learns they resolve to one
        // person rather than to several who happen to look alike. It is the
        // single property that does most of the work for a brand-name query.
        'alternateName': SiteConfig.nameVariants,
        'knowsLanguage': 'en',
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
        if (knowsAbout.isNotEmpty) 'knowsAbout': knowsAbout,
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

  /// An app somebody can actually install.
  ///
  /// `MobileApplication` rather than the broader `SoftwareApplication`: the
  /// only projects that reach this are ones with a Play or App Store listing,
  /// so the narrower type is both true and more useful. It is what makes a
  /// case study answerable for *offline music player* instead of only for the
  /// product's own name — a `CreativeWork` describes a page about a thing,
  /// where this describes the thing.
  ///
  /// Emitted **alongside** [creativeWork] rather than instead of it. The two
  /// make different claims about the same project: one that it is a documented
  /// piece of work with an author, one that it is software with an install
  /// URL. Both are true, and a crawler picks whichever fits the query.
  ///
  /// Deliberately carries no `offers` and no `aggregateRating`. Both are
  /// required for Google's app rich result and neither can be sourced from
  /// anything here, so both would have to be invented. A fabricated rating is
  /// the fastest way to have every piece of structured data on a domain
  /// discounted at once, and a made-up price is a claim the visitor disproves
  /// the moment the store page loads. The entity is worth having without the
  /// stars.
  static Map<String, Object?> mobileApplication({
    required String name,
    required String description,
    required String slug,
    required List<String> operatingSystems,
    required List<String> installUrls,
    String? applicationCategory,
    String? image,
  }) =>
      {
        '@context': _context,
        '@type': 'MobileApplication',
        'name': name,
        'description': description,
        'url': SiteConfig.absolute(RoutePaths.projectDetail(slug)),
        if (applicationCategory != null)
          'applicationCategory': applicationCategory,
        if (operatingSystems.isNotEmpty)
          'operatingSystem': operatingSystems.join(', '),
        // `installUrl` is the store page; `downloadUrl` is a synonym Bing reads
        // where Google reads the former. Listing the first store keeps the
        // primary unambiguous, while `sameAs` carries the rest, so a product on
        // two stores is one app with two listings rather than two apps.
        if (installUrls.isNotEmpty) ...{
          'installUrl': installUrls.first,
          'downloadUrl': installUrls.first,
          if (installUrls.length > 1) 'sameAs': installUrls,
        },
        'image': SiteConfig.absolute(image ?? SiteConfig.defaultOgImage),
        'author': {'@id': personId},
        'publisher': {'@id': personId},
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

  /// The offerings, for the services index.
  ///
  /// Each entry is a `Service` rather than a bare `ListItem`, so a crawler can
  /// tell what is actually being offered and by whom — a plain list of names
  /// carries no meaning for a services page.
  static Map<String, Object?> serviceList({
    required List<({String name, String description, String slug})> items,
  }) =>
      {
        '@context': _context,
        '@type': 'ItemList',
        'itemListElement': [
          for (final (index, item) in items.indexed)
            {
              '@type': 'ListItem',
              'position': index + 1,
              'item': {
                '@type': 'Service',
                'name': item.name,
                'description': item.description,
                'url': '${SiteConfig.absolute(RoutePaths.services)}'
                    '#${item.slug}',
                'serviceType': item.name,
                'provider': {
                  '@type': 'Person',
                  'name': SiteConfig.name,
                  'url': SiteConfig.siteUrl,
                },
                'areaServed': SiteConfig.location,
              },
            },
        ],
      };

  /// The About page itself.
  ///
  /// `ProfilePage` is the type Google expects for a page *about* a person, as
  /// distinct from a page written *by* one. Its `mainEntity` is a reference to
  /// the [person] node by `@id` plus the employment and education facts that
  /// only this page carries — which is what lets a knowledge panel state where
  /// someone works without having to parse the prose.
  /// [path] exists because two pages describe this person — `/about` at
  /// reading pace and `/cv` at scanning pace. Both are legitimately a
  /// `ProfilePage`, and both point `mainEntity` at the same person `@id`, so
  /// a crawler reads them as one person documented twice rather than as two
  /// identically-named Kens. Hard-coding the URL here would have made the CV
  /// page claim to be the about page.
  static Map<String, Object?> profilePage({
    required List<({String name, String role})> employers,
    required List<String> education,
    String path = RoutePaths.about,
  }) =>
      {
        '@context': _context,
        '@type': 'ProfilePage',
        'url': SiteConfig.absolute(path),
        'name': 'About ${SiteConfig.name}',
        'mainEntity': {
          '@type': 'Person',
          '@id': personId,
          'name': SiteConfig.name,
          'url': SiteConfig.siteUrl,
          'jobTitle': SiteConfig.role,
          if (employers.isNotEmpty)
            'worksFor': {
              '@type': 'Organization',
              'name': employers.first.name,
            },
          if (employers.isNotEmpty)
            'hasOccupation': [
              for (final job in employers)
                {
                  '@type': 'Occupation',
                  'name': job.role,
                  'hiringOrganization': {
                    '@type': 'Organization',
                    'name': job.name,
                  },
                },
            ],
          if (education.isNotEmpty)
            'alumniOf': [
              for (final school in education)
                {'@type': 'EducationalOrganization', 'name': school},
            ],
          'sameAs': [for (final s in SiteConfig.socials) s.url],
        },
      };

  /// The contact page.
  ///
  /// `ContactPage` is the type search engines expect for a page whose purpose
  /// *is* getting in touch, and pointing `mainEntity` at the existing person
  /// `@id` keeps this from describing a second, identically-named Ken.
  static Map<String, Object?> contactPage() => {
        '@context': _context,
        '@type': 'ContactPage',
        'url': SiteConfig.absolute(RoutePaths.contact),
        'name': 'Contact ${SiteConfig.name}',
        'mainEntity': {
          '@type': 'Person',
          '@id': personId,
          'name': SiteConfig.name,
          'email': 'mailto:${SiteConfig.email}',
          'url': SiteConfig.siteUrl,
        },
      };

  /// Trail shown under the result title in search. [crumbs] is ordered
  /// root-first as `(label, path)`.
  /// One written piece.
  ///
  /// `BlogPosting` rather than a bare `Article`: it tells a crawler this is a
  /// dated entry in an ongoing publication, which is what earns the byline and
  /// date in a result — an `Article` on its own does not.
  ///
  /// `datePublished` is omitted entirely when the post carries no ISO date. A
  /// guessed date is worse than none: it is a machine-readable claim, and
  /// getting it wrong is the kind of error that outlives the correction.
  static Map<String, Object?> blogPosting({
    required String headline,
    required String description,
    required String slug,
    required List<String> keywords,
    String? datePublished,
    String? image,
  }) =>
      {
        '@context': _context,
        '@type': 'BlogPosting',
        'headline': headline,
        'description': description,
        'url': SiteConfig.absolute(RoutePaths.post(slug)),
        'mainEntityOfPage': {
          '@type': 'WebPage',
          '@id': SiteConfig.absolute(RoutePaths.post(slug)),
        },
        if (datePublished != null) 'datePublished': datePublished,
        'keywords': keywords.join(', '),
        'image': SiteConfig.absolute(image ?? SiteConfig.defaultOgImage),
        'author': {'@id': personId},
        'publisher': {'@id': personId},
      };

  /// The writing index.
  ///
  /// Only pieces that actually have a page are listed — pointing a crawler at
  /// a URL that does not exist spends crawl budget to earn a 404.
  static Map<String, Object?> blog({
    required List<({String name, String slug, String? date})> items,
  }) =>
      {
        '@context': _context,
        '@type': 'Blog',
        'name': 'Writing · ${SiteConfig.name}',
        'url': SiteConfig.absolute(RoutePaths.writing),
        'author': {'@id': personId},
        'blogPost': [
          for (final item in items)
            {
              '@type': 'BlogPosting',
              'headline': item.name,
              'url': SiteConfig.absolute(RoutePaths.post(item.slug)),
              if (item.date != null) 'datePublished': item.date,
            },
        ],
      };

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
