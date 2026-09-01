/// A profile belonging to *someone else* — the person who gave a testimonial.
///
/// ## Why this is not [SocialLink]
///
/// `SocialLink` describes Ken's own profiles and is emitted as `sameAs` in the
/// Person JSON-LD, with `rel="me"` on the rendered anchor. Both of those are
/// **identity assertions**: they say "this profile and this site are the same
/// person". Reusing that model for a contributor's LinkedIn would quietly
/// claim Ken owns it, corrupting his own identity graph in exchange for saving
/// one small class.
///
/// So this is a separate type, and the component that renders it uses plain
/// `rel="noopener"`. The distinction is the whole reason the class exists.
///
/// ## The platform is inferred, never typed
///
/// A contributor pastes a URL; nobody picks a platform from a list. [of]
/// works out which service it is from the host, so a link cannot be labelled
/// GitHub while pointing at LinkedIn — and an unrecognised host is a perfectly
/// good outcome, rendering as a plain website link rather than being rejected.
class PersonLink {
  const PersonLink._({
    required this.url,
    required this.label,
    required this.icon,
  });

  final String url;

  /// Display name of the service — `LinkedIn`, `GitHub`, `Website`.
  final String label;

  /// Key into `AppIcons.byName`.
  final String icon;

  /// Builds a link, inferring the platform from [url]'s host.
  ///
  /// Returns `null` for anything that is not an absolute `http(s)` URL. A
  /// contributor's submission reaches this after a human has reviewed it, but
  /// parsing defensively is what keeps a malformed paste from rendering an
  /// anchor that goes nowhere — or worse, a `javascript:` href.
  static PersonLink? of(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    // `www.` carries no meaning here and would defeat every match below.
    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');

    final (label, icon) = switch (host) {
      'linkedin.com' || 'lnkd.in' => ('LinkedIn', 'linkedin'),
      'x.com' || 'twitter.com' => ('X', 'x'),
      'github.com' => ('GitHub', 'github'),
      _ => ('Website', 'globe'),
    };

    return PersonLink._(url: trimmed, label: label, icon: icon);
  }

  /// Parses a stored list, dropping anything unusable rather than throwing.
  static List<PersonLink> listOf(Object? value) {
    if (value is! List) return const [];
    return [
      for (final entry in value)
        if (of(entry.toString()) case final link?) link,
    ];
  }
}
