/// Every route path in one place.
///
/// Pages, the nav bar, the sitemap and the canonical URLs all read from here,
/// so a path can never drift out of sync with the link that points at it —
/// which for a static site would mean a silently broken canonical tag.
class RoutePaths {
  const RoutePaths._();

  static const String home = '/';
  static const String projects = '/projects';
  static const String notFound = '/404';

  static String projectDetail(String slug) => '$projects/$slug';
}
