/// One formal qualification, for the education band on `/about`.
///
/// Separate from [ExperienceModel] rather than a `kind` on it: an education
/// entry has no stack, no outcomes and no case study, and branching one model
/// on a discriminator would leave half its fields dead in every instance.
///
/// [draft] behaves exactly as it does on [ExperienceModel] — while it is set,
/// the card admits in place that the details are placeholders.
class EducationModel {
  const EducationModel({
    required this.slug,
    required this.qualification,
    required this.institution,
    required this.period,
    this.note = '',
    this.focus = const [],
    this.draft = false,
  });

  final String slug;

  /// `BSc, Computer Science`.
  final String qualification;

  final String institution;

  /// Human range — `2016 — 2020`.
  final String period;

  /// One line on what it was actually for. Optional: a degree that needs a
  /// paragraph of justification is being asked to carry too much.
  final String note;

  /// Subjects worth naming, as pills.
  final List<String> focus;

  /// The details are authored, not verified.
  final bool draft;

  factory EducationModel.fromMap(Map<String, dynamic> map) => EducationModel(
        slug: map['slug']?.toString() ?? '',
        qualification: map['qualification']?.toString() ?? '',
        institution: map['institution']?.toString() ?? '',
        period: map['period']?.toString() ?? '',
        note: map['note']?.toString() ?? '',
        focus: map['focus'] is List
            ? (map['focus'] as List).map((e) => e.toString()).toList(growable: false)
            : const [],
        draft: map['draft'] == true,
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'qualification': qualification,
        'institution': institution,
        'period': period,
        'note': note,
        'focus': focus,
        'draft': draft,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is EducationModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
