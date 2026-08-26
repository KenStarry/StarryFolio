import '../../domain/enum/skill_level.dart';
import '../../domain/model/about_profile.dart';
import '../../domain/model/education_model.dart';
import '../../domain/model/experience_model.dart';
import '../../domain/model/facet_model.dart';
import '../../domain/model/milestone_model.dart';
import '../../domain/model/process_step_model.dart';
import '../../domain/model/skill_group_model.dart';
import '../../domain/model/skill_model.dart';

/// The profile, as compile-time constants.
///
/// `const` and synchronous for the same reason as the projects and services
/// sources: the static build resolves this during pre-render, and the
/// repository on top exists so the page never learns where it came from.
///
/// ─────────────────────────────────────────────────────────────────────────
/// **Before launch — the authored facts.**
///
/// The companies are real; the *date ranges* against them are not, and neither
/// is the education entry. Every affected record carries `draft: true`, which
/// renders a quiet `dates to confirm` marker in place rather than presenting a
/// guess as a fact. Correct the values, delete the flags, and the markers
/// disappear on their own.
///
/// - [experience] — confirm every `period`, `kind` and `location`.
/// - [education] — confirm the institution, the qualification and the years.
/// - [milestones] — confirm the years.
/// - [facets] — written from what the site already knows. Make them yours;
///   this band is the only part of the page that is not about work, and
///   borrowed personality reads worse than none.
/// ─────────────────────────────────────────────────────────────────────────
abstract final class AboutLocalDatasource {
  static const AboutProfile profile = AboutProfile(
    experience: experience,
    education: education,
    skillGroups: skillGroups,
    process: process,
    milestones: milestones,
    facets: facets,
  );

  // ── Experience ───────────────────────────────────────────────────────────
  //
  // Reverse-chronological: the current role first, because that is the one
  // question every visitor arrives with. `projectSlug` links a role to the
  // case study it produced.

  static const List<ExperienceModel> experience = [
    ExperienceModel(
      slug: 'healthx',
      role: 'Lead Mobile Engineer',
      company: 'HealthX Africa',
      period: '2023 — Present',
      kind: 'Full-time',
      location: 'Nairobi',
      current: true,
      draft: true,
      projectSlug: 'healthx',
      summary: 'I own the full mobile lifecycle of a Kenyan telehealth '
          'platform — design system through release.',
      highlights: [
        'Seven feature modules on one shell',
        'A design system built in, not bolted on',
        'Both stores, signed and staged',
      ],
      stack: ['Flutter', 'Riverpod 3', 'Clean Architecture', 'Firebase'],
    ),
    ExperienceModel(
      slug: 'dentsu',
      role: 'Mobile Engineer',
      company: 'Dentsu',
      period: '2022 — 2023',
      kind: 'Contract',
      location: 'Nairobi',
      draft: true,
      summary: 'Client products on campaign deadlines that do not move.',
      highlights: [
        'Brand guidelines turned into component libraries',
        'Shipped against fixed launch dates',
        'Designers in the room, daily',
      ],
      stack: ['Flutter', 'BLoC', 'Figma'],
    ),
    ExperienceModel(
      slug: 'britam',
      role: 'Flutter Developer',
      company: 'Britam',
      period: '2021 — 2022',
      kind: 'Full-time',
      location: 'Nairobi',
      draft: true,
      projectSlug: 'britam-app',
      summary: 'Insurance on mobile, where a mistyped field has a financial '
          'consequence.',
      highlights: [
        'Customer flows that move real money',
        'Validation and receipts as product surfaces',
        'An enterprise release process, learned properly',
      ],
      stack: ['Flutter', 'Provider', 'REST'],
    ),
    ExperienceModel(
      slug: 'podii',
      role: 'Software Engineer',
      company: 'Podii',
      period: '2020 — 2021',
      kind: 'Full-time',
      location: 'Nairobi',
      draft: true,
      summary: 'Product engineering across client builds — and where Dart '
          'became the language I reach for.',
      highlights: [
        'Features end to end, data layer to release',
        'Close enough to product to see what survives',
        'The first Flutter I would still defend',
      ],
      stack: ['Dart', 'Flutter', 'Git'],
    ),
  ];

  // ── Education ────────────────────────────────────────────────────────────

  static const List<EducationModel> education = [
    EducationModel(
      slug: 'degree',
      qualification: 'BSc, Computer Science',
      institution: 'University of Nairobi',
      period: '2016 — 2020',
      draft: true,
      note: 'The fundamentals that do not expire. Everything framework-shaped '
          'came after — and keeps coming.',
      focus: ['Algorithms', 'Systems', 'Databases', 'HCI'],
    ),
  ];

  // ── Skills ───────────────────────────────────────────────────────────────
  //
  // Four groups, in the order the work happens: the language, the shape you
  // give it, the finish, and getting it out. Levels are honest bands, not
  // percentages — see [SkillLevel].

  static const List<SkillGroupModel> skillGroups = [
    SkillGroupModel(
      slug: 'core',
      name: 'Core',
      note: 'The language and the frameworks the work is actually made of.',
      skills: [
        SkillModel('Dart', SkillLevel.core),
        SkillModel('Flutter', SkillLevel.core),
        SkillModel('Jaspr', SkillLevel.fluent),
        SkillModel('Kotlin', SkillLevel.working),
        SkillModel('Swift', SkillLevel.working),
      ],
    ),
    SkillGroupModel(
      slug: 'architecture',
      name: 'Architecture',
      note: 'How a codebase stays readable at feature forty.',
      skills: [
        SkillModel('Clean Architecture', SkillLevel.core),
        SkillModel('Riverpod', SkillLevel.core),
        SkillModel('BLoC', SkillLevel.fluent),
        SkillModel('Isar / Drift', SkillLevel.fluent),
        SkillModel('Offline-first sync', SkillLevel.fluent),
      ],
    ),
    SkillGroupModel(
      slug: 'craft',
      name: 'Craft',
      note: 'The last 10% — where a build stops looking like a build.',
      skills: [
        SkillModel('Design systems', SkillLevel.core),
        SkillModel('Motion & easing', SkillLevel.core),
        SkillModel('Accessibility', SkillLevel.fluent),
        SkillModel('Figma', SkillLevel.fluent),
        SkillModel('Typography', SkillLevel.fluent),
      ],
    ),
    SkillGroupModel(
      slug: 'ship',
      name: 'Ship',
      note: 'The half of the job that happens after the code is written.',
      skills: [
        SkillModel('CI/CD', SkillLevel.core),
        SkillModel('Fastlane', SkillLevel.fluent),
        SkillModel('Firebase', SkillLevel.core),
        SkillModel('Play Console & App Store Connect', SkillLevel.core),
        SkillModel('Crash triage', SkillLevel.fluent),
      ],
    ),
  ];

  // ── Process ──────────────────────────────────────────────────────────────
  //
  // Four steps, each naming the artefact it hands over. A process that cannot
  // say what you are holding at the end of a stage is a diagram, not a
  // process.

  static const List<ProcessStepModel> process = [
    ProcessStepModel(
      slug: 'frame',
      title: 'Frame it',
      icon: 'compass',
      artefact: 'A one-page scope',
      blurb: 'What has to be true for this to have been worth building? Then '
          'cut everything that does not serve it.',
    ),
    ProcessStepModel(
      slug: 'systemise',
      title: 'Systemise it',
      icon: 'layers',
      artefact: 'Tokens and a component library',
      blurb: 'Type, spacing, colour, motion and every state — decided once, in '
          'code, before screen one.',
    ),
    ProcessStepModel(
      slug: 'build',
      title: 'Build it',
      icon: 'device',
      artefact: 'A codebase your next engineer can read',
      blurb: 'Clean Architecture, a real state layer, offline designed in. '
          'Built for a mid-range phone on two bars.',
    ),
    ProcessStepModel(
      slug: 'ship',
      title: 'Ship it',
      icon: 'rocket',
      artefact: 'Signed builds and a listing that converts',
      blurb: 'Release is a feature. Signing, rollouts and crash reporting '
          'wired before launch, not after the first bad review.',
    ),
  ];

  // ── Milestones ───────────────────────────────────────────────────────────
  //
  // Chronological. The spine reads downward as time moves forward.

  static const List<MilestoneModel> milestones = [
    MilestoneModel(
      year: '2019',
      title: 'First widget tree',
      note: 'Swapped a screenful of Android XML for it. Never went back.',
    ),
    MilestoneModel(
      year: '2021',
      title: 'First app on a store',
      note: 'A real listing, and the specific dread of a rejected build.',
    ),
    MilestoneModel(
      year: '2023',
      title: 'Took the whole lifecycle',
      note: 'Design system through release — the first time all of it was mine.',
    ),
    MilestoneModel(
      year: '2025',
      title: 'Both stores, one codebase',
      note: 'iOS and Android from one source, on a pipeline that runs itself.',
    ),
    MilestoneModel(
      year: '2026',
      title: 'This site, in Dart',
      note: 'Rebuilt in Jaspr. The same language as the apps, all the way down.',
    ),
  ];

  // ── Beyond the code ──────────────────────────────────────────────────────

  static const List<FacetModel> facets = [
    FacetModel(
      title: 'A side project I actually use',
      icon: 'device',
      marker: 'CribLynk',
      blurb: 'Where framework opinions get tested against something I have to '
          'live with.',
    ),
    FacetModel(
      title: 'A camera roll full of UI',
      icon: 'layers',
      marker: 'Screenshots',
      blurb: 'Sheet easings, empty states, transitions that landed. Polish is '
          'stolen carefully.',
    ),
    FacetModel(
      title: 'Teaching what I just learned',
      icon: 'compass',
      marker: 'Community',
      blurb: 'Explaining a thing badly is how you find out you did not '
          'understand it.',
    ),
    FacetModel(
      title: 'Nairobi, and the light here',
      icon: 'globe',
      marker: 'UTC+3',
      blurb: 'Building where a mid-range phone on two bars is the default, not '
          'the edge case.',
    ),
  ];
}
