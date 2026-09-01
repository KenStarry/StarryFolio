import 'role_stint.dart';

/// One **company**, and every title held there.
///
/// ## The shape changed, and the reason matters
///
/// This used to be one role at one company, which made a promotion
/// indistinguishable from a new job: both rendered as sibling rows on the same
/// timeline. That throws away the more flattering of the two facts. Staying
/// somewhere and moving up is a different thing from leaving, and the model
/// now says so — the entry is the employer, and [roles] is the progression
/// inside it.
///
/// [period] and [kind] are derived from the stints rather than stored, so the
/// company header cannot claim a range its own roles do not cover. Everything
/// else about the company is carried here because it does not change when a
/// title does: where the office is, which mark goes on the spine.
///
/// `fromMap` parses defensively so this content can move behind a CMS without
/// the page learning anything new.
class ExperienceModel {
  const ExperienceModel({
    required this.slug,
    required this.company,
    required this.roles,
    this.location = '',
    this.kind = '',
    this.logo,
    this.blurb = '',
    this.draft = false,
  });

  final String slug;

  final String company;

  /// Titles held here, **newest first**. One entry is an ordinary job; two or
  /// more is a progression, and the surface renders it as one.
  final List<RoleStint> roles;

  final String location;

  /// `Full-time`, `Contract`, `Freelance`.
  final String kind;

  /// Path under `web/` to a monochrome company mark.
  ///
  /// Null renders a drawn monogram plate instead, which is deliberate rather
  /// than a placeholder: a logo nobody has the rights to is worse than a
  /// letter, and the two occupy the same box so dropping a file in later
  /// changes nothing else on the page.
  final String? logo;

  /// One line on what the company does, for readers who do not know it.
  final String blurb;

  /// Company-level detail is authored rather than confirmed.
  final bool draft;

  /// The full range across every stint — the earliest start to the latest end.
  ///
  /// Derived rather than stored. A company period held as its own field is a
  /// second place for the same fact to live, and the first time a stint was
  /// edited without it the header would have been quietly wrong. Roles are
  /// newest first, so the range runs from the last one's start to the first
  /// one's end.
  String get period {
    if (roles.isEmpty) return '';
    if (roles.length == 1) return roles.first.period;
    return '${roles.last.start} - ${roles.first.end}';
  }

  /// Total months across the whole tenure, or null when the dates cannot be
  /// read. See [RoleStint.months] for why null beats a guess.
  int? get months {
    if (roles.isEmpty) return null;
    return RoleStint(title: '', period: period).months;
  }

  /// `2 yrs 4 mos`, or null.
  String? get duration =>
      roles.isEmpty ? null : RoleStint(title: '', period: period).duration;

  /// Whether this is where the work happens today.
  bool get current => roles.any((role) => role.current);

  /// Whether anything under this company still carries authored dates.
  bool get hasDraft => draft || roles.any((role) => role.draft);

  /// More than one title held here.
  bool get isProgression => roles.length > 1;

  /// Every case study produced here, across all titles, in order and without
  /// repeats — a project worked on under two titles is still one project.
  List<String> get projects {
    final seen = <String>{};
    return [
      for (final role in roles)
        for (final slug in role.projects)
          if (seen.add(slug)) slug,
    ];
  }

  /// The company's initial, for the monogram plate.
  String get initial =>
      company.isEmpty ? '·' : company.substring(0, 1).toUpperCase();

  factory ExperienceModel.fromMap(Map<String, dynamic> map) => ExperienceModel(
        slug: map['slug']?.toString() ?? '',
        company: map['company']?.toString() ?? '',
        location: map['location']?.toString() ?? '',
        kind: map['kind']?.toString() ?? '',
        logo: map['logo']?.toString(),
        blurb: map['blurb']?.toString() ?? '',
        draft: map['draft'] == true,
        roles: map['roles'] is List
            ? (map['roles'] as List)
                .whereType<Map<String, dynamic>>()
                .map(RoleStint.fromMap)
                .toList(growable: false)
            : const [],
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'company': company,
        'location': location,
        'kind': kind,
        if (logo != null) 'logo': logo,
        'blurb': blurb,
        'draft': draft,
        'roles': [for (final role in roles) role.toMap()],
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ExperienceModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
