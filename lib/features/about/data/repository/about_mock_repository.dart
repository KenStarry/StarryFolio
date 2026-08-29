import 'package:fpdart/fpdart.dart';

import '../../domain/enum/skill_level.dart';
import '../../domain/model/about_profile.dart';
import '../../domain/model/education_model.dart';
import '../../domain/model/experience_model.dart';
import '../../domain/model/milestone_model.dart';
import '../../domain/model/skill_group_model.dart';
import '../../domain/model/skill_model.dart';
import '../../domain/repository/about_repository.dart';

/// Canned data behind an artificial delay, for exercising the page's layout
/// against sparse content — one role, one qualification, one group — without
/// touching the real profile.
///
/// Not wired up by default — swap it in at the composition root in
/// `core/di/locator.dart`.
class AboutMockRepository implements AboutRepository {
  const AboutMockRepository({this.delay = const Duration(milliseconds: 800)});

  final Duration delay;

  static const _profile = AboutProfile(
    experience: [
      ExperienceModel(
        slug: 'placeholder',
        role: 'Placeholder Engineer',
        company: 'Placeholder Co.',
        period: '2024 - Present',
        current: true,
        summary: 'Stand-in copy so the timeline can be checked without real '
            'content.',
        highlights: ['One outcome', 'Another outcome'],
        stack: ['Flutter'],
      ),
    ],
    education: [
      EducationModel(
        slug: 'placeholder',
        qualification: 'BSc, Placeholder',
        institution: 'Placeholder University',
        period: '2016 - 2020',
      ),
    ],
    skillGroups: [
      SkillGroupModel(
        slug: 'core',
        name: 'Core',
        skills: [SkillModel('Dart', SkillLevel.core)],
      ),
    ],
    milestones: [
      MilestoneModel(year: '2020', title: 'Placeholder milestone'),
    ],
  );

  @override
  Future<Either<String, AboutProfile>> getProfile() async {
    await Future<void>.delayed(delay);
    return const Right(_profile);
  }
}
