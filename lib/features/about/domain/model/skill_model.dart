import '../enum/skill_level.dart';

/// One tool, with an honest depth against it.
class SkillModel {
  const SkillModel(this.name, this.level);

  final String name;
  final SkillLevel level;

  factory SkillModel.fromMap(Map<String, dynamic> map) => SkillModel(
        map['name']?.toString() ?? '',
        SkillLevel.fromName(map['level']?.toString()),
      );

  Map<String, dynamic> toMap() => {'name': name, 'level': level.name};
}
