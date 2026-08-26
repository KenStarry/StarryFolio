/// A company or client whose work is worth naming.
///
/// [logo] is a path under `web/` to a mark that can sit on a dark ground —
/// ideally a monochrome or white SVG. While it is null the marquee sets the
/// name as a wordmark in the site's own display face, which reads as a
/// deliberate typographic treatment rather than a missing image. Adding the
/// file later changes nothing about the layout.
class Company {
  const Company({
    required this.name,
    this.role,
    this.logo,
    this.url,
  });

  final String name;

  /// What the work was, shown on hover.
  final String? role;

  final String? logo;
  final String? url;
}
