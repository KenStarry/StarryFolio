/// One role held, for the experience timeline on `/about`.
///
/// [projectSlug] is the join between a job and the case study that came out of
/// it. Where it is set the entry links straight through to
/// `/projects/<slug>` — a CV line that can be clicked into a real build is
/// worth more than the line on its own, and it keeps the two pages feeding
/// each other rather than repeating each other.
///
/// [draft] exists because a wrong date on a live portfolio is worse than an
/// admitted one. While it is `true` the entry renders a quiet
/// "dates to confirm" marker beside the period; clearing the flag removes it.
/// It is the only content field that changes what the component says about
/// itself, and it is meant to be temporary.
///
/// `fromMap` parses defensively so this content can move behind a CMS without
/// the page learning anything new.
class ExperienceModel {
  const ExperienceModel({
    required this.slug,
    required this.role,
    required this.company,
    required this.period,
    required this.summary,
    this.location = '',
    this.kind = '',
    this.highlights = const [],
    this.stack = const [],
    this.projectSlug,
    this.current = false,
    this.draft = false,
  });

  final String slug;

  /// Job title, as it would read on a contract.
  final String role;

  final String company;

  /// Human range — `2023 — Present`. A string rather than two dates because it
  /// is display copy: some roles overlap, some are open-ended, and a formatter
  /// that has to model both ends up lying about one.
  final String period;

  /// Two or three sentences on what the job actually was.
  final String summary;

  final String location;

  /// `Full-time`, `Contract`, `Freelance`. Rendered as a small marker beside
  /// the period.
  final String kind;

  /// What changed because of the work. Verbs, not responsibilities — a
  /// responsibility list describes a job description, an outcome list
  /// describes a person.
  final List<String> highlights;

  final List<String> stack;

  /// Slug of the case study this role produced, if there is one.
  final String? projectSlug;

  /// The role held today. Lights the live dot and keeps the entry first.
  final bool current;

  /// The period is authored, not verified. See the class doc.
  final bool draft;

  factory ExperienceModel.fromMap(Map<String, dynamic> map) => ExperienceModel(
        slug: map['slug']?.toString() ?? '',
        role: map['role']?.toString() ?? '',
        company: map['company']?.toString() ?? '',
        period: map['period']?.toString() ?? '',
        summary: map['summary']?.toString() ?? '',
        location: map['location']?.toString() ?? '',
        kind: map['kind']?.toString() ?? '',
        highlights: _stringList(map['highlights']),
        stack: _stringList(map['stack']),
        projectSlug: map['projectSlug']?.toString(),
        current: map['current'] == true,
        draft: map['draft'] == true,
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'role': role,
        'company': company,
        'period': period,
        'summary': summary,
        'location': location,
        'kind': kind,
        'highlights': highlights,
        'stack': stack,
        if (projectSlug != null) 'projectSlug': projectSlug,
        'current': current,
        'draft': draft,
      };

  static List<String> _stringList(Object? value) => value is List
      ? value.map((e) => e.toString()).toList(growable: false)
      : const [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ExperienceModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
