import 'skill_model.dart';

/// A column of the skills matrix — `Core`, `Architecture`, `Craft`, `Ship`.
///
/// The [note] is what turns a tag cloud into a statement: naming *why* these
/// four sit together says more about how someone works than the tools do.
class SkillGroupModel {
  const SkillGroupModel({
    required this.slug,
    required this.name,
    required this.skills,
    this.note = '',
  });

  final String slug;
  final String name;
  final List<SkillModel> skills;

  /// One line on what this group is for.
  final String note;

  factory SkillGroupModel.fromMap(Map<String, dynamic> map) => SkillGroupModel(
        slug: map['slug']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        note: map['note']?.toString() ?? '',
        skills: map['skills'] is List
            ? (map['skills'] as List)
                .whereType<Map<String, dynamic>>()
                .map(SkillModel.fromMap)
                .toList(growable: false)
            : const [],
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'name': name,
        'note': note,
        'skills': [for (final skill in skills) skill.toMap()],
      };

  /// Bare names, for `knowsAbout` in the Person JSON-LD.
  List<String> get names => [for (final skill in skills) skill.name];
}
