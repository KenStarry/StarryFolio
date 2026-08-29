/// What sort of thing a project *is*.
///
/// Deliberately a separate axis from [ProjectCategory] and [ProjectPlatform],
/// because those answer different questions and collapsing them produces an
/// enum with no coherent meaning:
///
/// | Axis | Question | Values |
/// |---|---|---|
/// | [ProjectKind] | what is it? | product · package |
/// | `ProjectCategory` | who was it for? | enterprise · client · personal |
/// | `ProjectPlatform` | where does it run? | android · iOS · web · desktop |
///
/// "Open source" is none of these — it is a licence and a public repo, a
/// *property* rather than a category. A mobile app can be open source too,
/// which is exactly how a grouping axis breaks. What actually separates
/// `flutter_extend` from everything else on the index is that it is not an
/// application: no screens, no store listing, no users. Developers depend on
/// it. That is a difference of kind, so it is modelled as one.
///
/// Like `ProjectCategory`, each case carries the copy its band renders with, so
/// the wording cannot drift between the card badge and the section heading.
enum ProjectKind {
  /// Something a person opens and uses — an app, a portal.
  product(
    label: 'Product',
    slug: 'products',
    title: 'Products',
    lead: 'Things people open. Shipped end to end, and still running.',
  ),

  /// Something a developer builds with — a package, a library, tooling.
  package(
    label: 'Open source',
    slug: 'open-source',
    title: 'Open source & tooling',
    lead: 'Code other developers depend on. Published, versioned, tested and '
        'maintained in the open, which is a different discipline from '
        'shipping an app, and a harder one to fake.',
  );

  const ProjectKind({
    required this.label,
    required this.slug,
    required this.title,
    required this.lead,
  });

  /// Short badge text.
  final String label;

  /// Anchor for the band and its jump-nav stop.
  final String slug;

  /// The band's heading.
  final String title;

  /// The band's standfirst.
  final String lead;

  /// Resolves a wire value defensively, so an unknown kind from a future API
  /// degrades to the common case rather than throwing.
  static ProjectKind fromName(String? value) => values.firstWhere(
        (k) => k.name == value || k.slug == value,
        orElse: () => ProjectKind.product,
      );
}
