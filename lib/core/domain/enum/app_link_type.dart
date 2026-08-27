/// A kind of outbound action a product can offer.
///
/// Each case carries the two lines a store badge sets — a small overline and
/// the destination name — plus the key its glyph is resolved by. Keeping the
/// copy here rather than at each call site means a badge can never be built
/// with the wrong wording, and `Download on the App Store` stays spelled the
/// way Apple spells it everywhere it appears.
enum AppLinkType {
  playStore(
    overline: 'Get it on',
    title: 'Google Play',
    icon: 'play',
    verb: 'Download',
  ),
  appStore(
    overline: 'Download on the',
    title: 'App Store',
    icon: 'apple',
    verb: 'Download',
  ),
  web(
    overline: 'Visit the',
    title: 'Web app',
    icon: 'globe',
    verb: 'Open',
  ),
  repo(
    overline: 'Read the',
    title: 'Source',
    icon: 'github',
    verb: 'View',
  ),
  pubDev(
    overline: 'Get it on',
    title: 'pub.dev',
    icon: 'dart',
    verb: 'Install',
  );

  const AppLinkType({
    required this.overline,
    required this.title,
    required this.icon,
    required this.verb,
  });

  /// Small line above the destination title.
  final String overline;

  /// Destination title, set larger. Deliberately not called `name` — that
  /// would shadow the enum's own `name`, which serialization relies on.
  final String title;

  /// Key into `AppIcons.byName`.
  final String icon;

  /// Used to build the accessible label, e.g. `Download HealthX on Google Play`.
  final String verb;

  /// The two store cases, which get the prominent badge treatment. `web` and
  /// `repo` are ordinary links and are styled down.
  bool get isStore => this == playStore || this == appStore;

  /// Resolves a wire value defensively, so an unknown type from a future API
  /// degrades to a plain web link instead of throwing.
  static AppLinkType fromName(String? value) => values.firstWhere(
        (t) => t.name == value,
        orElse: () => AppLinkType.web,
      );
}
