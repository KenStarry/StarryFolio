import '../enum/app_link_type.dart';

/// One outbound action — a store listing, a web app, a repository.
///
/// Content-agnostic and therefore in `core/`: nothing here knows what a project
/// is, so any feature that needs to point somewhere can reuse it.
///
/// `fromMap` parses defensively so that when this content moves behind a CMS a
/// malformed entry degrades rather than throwing.
class AppLink {
  const AppLink({
    required this.type,
    required this.url,
    this.label,
  });

  final AppLinkType type;
  final String url;

  /// Overrides [AppLinkType.title] where the destination has its own name —
  /// HealthX's `Customer Portal`, for instance, rather than a generic
  /// `Web app`.
  final String? label;

  String get title => label ?? type.title;
  String get overline => type.overline;
  bool get isStore => type.isStore;

  /// Accessible name. Store badges set their visible text in two stacked lines,
  /// which reads poorly to a screen reader, so the anchor carries this instead.
  String accessibleLabel(String product) =>
      '${type.verb} $product on $title';

  factory AppLink.fromMap(Map<String, dynamic> map) => AppLink(
        type: AppLinkType.fromName(map['type']?.toString()),
        url: map['url']?.toString() ?? '',
        label: map['label']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'url': url,
        if (label != null) 'label': label,
      };
}
