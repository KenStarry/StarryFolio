import 'education_model.dart';
import 'experience_model.dart';
import 'process_step_model.dart';
import 'skill_group_model.dart';

/// Everything `/about` renders, resolved in one go.
///
/// An aggregate rather than six repository methods, because the page is a
/// single `AsyncStatelessComponent`: six awaits would be six chances for the
/// pre-render to half-fail and ship a page with three of its bands missing.
/// One `Either` means the page either has a profile or renders an honest
/// error — never something in between.
///
/// The home page takes the same object and shows a slice of it, so the teaser
/// and the full page can never describe two different people.
class AboutProfile {
  const AboutProfile({
    this.experience = const [],
    this.education = const [],
    this.skillGroups = const [],
    this.process = const [],
  });

  /// Reverse-chronological. The first entry is the current role.
  final List<ExperienceModel> experience;

  final List<EducationModel> education;
  final List<SkillGroupModel> skillGroups;
  final List<ProcessStepModel> process;



  /// The role held today, if one is marked current.
  ExperienceModel? get currentRole {
    for (final entry in experience) {
      if (entry.current) return entry;
    }
    return null;
  }

  /// The title held today, across every company.
  String? get currentTitle {
    for (final entry in experience) {
      for (final role in entry.roles) {
        if (role.current) return role.title;
      }
    }
    return null;
  }

  /// Every named skill, flattened — the `knowsAbout` list in the Person
  /// JSON-LD, so the machine-readable claim and the visible matrix are the
  /// same list rather than two that drift.
  List<String> get skillNames => [
        for (final group in skillGroups) ...group.names,
      ];

  /// Distinct employers, newest first. Used by the home teaser, which names
  /// where the work happened without repeating the whole timeline.
  List<String> get companies {
    final seen = <String>{};
    return [
      for (final role in experience)
        if (seen.add(role.company)) role.company,
    ];
  }

  bool get isEmpty =>
      experience.isEmpty && education.isEmpty && skillGroups.isEmpty;
}
