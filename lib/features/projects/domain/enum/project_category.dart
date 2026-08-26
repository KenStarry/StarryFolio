/// Broad grouping a project belongs to.
///
/// Each case carries the copy for its own section on the projects page — title,
/// lead and the short label used on cards. Keeping that here rather than in the
/// page means adding a category cannot leave a section unlabelled, and the
/// wording can never drift between the card badge and the section heading.
enum ProjectCategory {
  enterprise(
    label: 'Enterprise',
    slug: 'enterprise',
    title: 'Enterprise projects',
    lead: 'Systems that a team depends on every working day. Built for '
        'mid-range phones, patchy networks and people who cannot stop to '
        'troubleshoot.',
  ),
  commercial(
    label: 'Client work',
    slug: 'commercial',
    title: 'Client work',
    lead: 'Products for businesses that had outgrown a website. Shipped end to '
        'end — brand and design system through to the store listing.',
  ),
  personal(
    label: 'Pet project',
    slug: 'personal',
    title: 'Pet projects',
    lead: 'Things built to answer a question. Some shipped, some shelved, all '
        'of them fed something else later.',
  );

  const ProjectCategory({
    required this.label,
    required this.slug,
    required this.title,
    required this.lead,
  });

  /// Short form, shown on the card.
  final String label;

  /// URL- and attribute-safe form.
  final String slug;

  /// Section heading on the projects page.
  final String title;

  /// Section standfirst.
  final String lead;

  /// Resolves a wire value defensively, so an unknown category from a future
  /// API degrades to a sensible default instead of throwing.
  static ProjectCategory fromName(String? value) => values.firstWhere(
        (c) => c.name == value || c.slug == value,
        orElse: () => ProjectCategory.personal,
      );
}
