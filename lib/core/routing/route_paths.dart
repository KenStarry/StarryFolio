/// Every route path in one place.
///
/// Pages, the nav bar, the sitemap and the canonical URLs all read from here,
/// so a path can never drift out of sync with the link that points at it —
/// which for a static site would mean a silently broken canonical tag.
class RoutePaths {
  const RoutePaths._();

  static const String home = '/';
  static const String projects = '/projects';
  static const String services = '/services';
  static const String contact = '/contact';
  static const String about = '/about';
  static const String writing = '/writing';
  /// The documents hub. Named for what it holds rather than for the CV
  /// alone — the CV is one band on it.
  static const String documents = '/documents';

  /// The old CV URL, kept because `/cv` is what a recruiter guesses. It is a
  /// 301 to [documents], declared in `web/_redirects` rather than as a route:
  /// a second route would be a duplicate page competing with the real one.
  static const String cvLegacy = '/cv';
  static const String thanks = '/thanks';
  static const String notFound = '/404';

  static String projectDetail(String slug) => '$projects/$slug';
  static String post(String slug) => '$writing/$slug';

  /// Builds an in-page anchor href.
  ///
  /// **Always use this instead of a bare `'#id'`.** The document carries
  /// `<base href="/">` — which is load-bearing, because Jaspr emits
  /// `main.client.dart.js` as a *relative* src and hydration would 404 on any
  /// nested route without it. A consequence is that a bare fragment resolves
  /// against the base rather than the current URL, so `#work` on `/projects`
  /// navigates to the **home page**, not down the page. Carrying the path
  /// makes the target unambiguous.
  static String anchor(String path, String id) => '$path#$id';
}
