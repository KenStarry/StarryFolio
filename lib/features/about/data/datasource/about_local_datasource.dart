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
/// **The CV is the source of truth for this file.**
///
/// [experience], [education], [skillGroups] and [milestones] are transcribed
/// from `Kenneth_Michuki_Resume.pdf` — the same document served at
/// `/cv.pdf` — so the page, the `/cv` route and the downloadable file cannot
/// state three different careers. When the CV changes, change it here first
/// and let both pages follow.
///
/// Every record once carried `draft: true`, which rendered a quiet
/// `dates to confirm` marker rather than presenting a guess as a fact. The
/// flags are gone because the dates are now real; the mechanism stays on the
/// models for the next time something is authored ahead of being confirmed.
///
/// [facets] is the exception — it is the one band that is not about work, and
/// the CV has nothing to say about it.
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
      role: 'Senior Flutter Engineer & UI/UX',
      company: 'HealthX Africa',
      period: 'Jan 2026 — Present',
      kind: 'Full-time',
      location: 'Nairobi',
      current: true,
      projectSlug: 'healthx',
      summary: 'Sole engineer and designer on Kenya\'s most comprehensive '
          'telehealth platform — research, brand, architecture, development, '
          'QA and a dual-store release, all of it owned end to end.',
      highlights: [
        'Zero to both stores in under three months',
        'Product UI/UX across 10+ feature modules, with no designer or PM',
        'Established the company brand identity — now used company-wide',
        'Feature-driven Clean Architecture on Riverpod 3',
        'Real-time video consultations on LiveKit, e-pharmacy, biometric auth',
        'Kenya DPA 2019 compliance, staged rollouts, TestFlight betas',
      ],
      stack: [
        'Flutter',
        'Riverpod 3',
        'LiveKit',
        'Clean Architecture',
        'Hive',
      ],
    ),
    ExperienceModel(
      slug: 'dentsu',
      role: 'Flutter Developer',
      company: 'Dentsu Kenya',
      period: 'Apr 2024 — Sep 2025',
      kind: 'Consultant',
      location: 'Nairobi',
      projectSlug: 'britam-app',
      summary: 'A full architectural rebuild of the legacy MyBritam insurance '
          'platform — the kind of work where a mistyped field has a financial '
          'consequence.',
      highlights: [
        'Play Store rating from 3.1 to 4.1 through stability and UI/UX work',
        '100% feature parity across Android, iOS and Web from one codebase',
        'CI/CD on GitHub Actions and Azure DevOps, synchronised across three '
            'platforms',
        'Deep linking and real-time WebSocket updates',
      ],
      stack: [
        'Flutter',
        'Clean Architecture',
        'GitHub Actions',
        'Azure DevOps',
      ],
    ),
    ExperienceModel(
      slug: 'podii',
      role: 'Flutter Developer',
      company: 'Podii Consultants',
      period: 'May 2023 — Mar 2024',
      kind: 'Full-time',
      location: 'Nairobi',
      projectSlug: 'elvs',
      summary: 'Internal tooling and the offline problem — building for people '
          'whose connectivity cannot be assumed.',
      highlights: [
        'ELVS Mobile: a business workflow app with role-based access control',
        'Offline sync and state restoration on SQLite, built for data integrity '
            'in low-connectivity environments',
      ],
      stack: ['Flutter', 'Dart', 'SQLite'],
    ),
  ];

  // ── Education ────────────────────────────────────────────────────────────

  static const List<EducationModel> education = [
    EducationModel(
      slug: 'degree',
      qualification: 'BSc Computer Science — First Class Honours',
      institution: 'Masinde Muliro University of Science and Technology',
      period: '2024',
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
        SkillModel('Kotlin', SkillLevel.fluent),
        SkillModel('Jetpack Compose', SkillLevel.fluent),
        SkillModel('Java', SkillLevel.working),
        SkillModel('Jaspr', SkillLevel.fluent),
      ],
    ),
    SkillGroupModel(
      slug: 'architecture',
      name: 'Architecture',
      note: 'How a codebase stays readable at feature forty.',
      skills: [
        SkillModel('Clean Architecture', SkillLevel.core),
        SkillModel('Riverpod', SkillLevel.core),
        SkillModel('BLoC / Cubit', SkillLevel.fluent),
        SkillModel('MVVM & SOLID', SkillLevel.core),
        SkillModel('Offline-first sync', SkillLevel.core),
        SkillModel('Hive / Isar / Room', SkillLevel.fluent),
        SkillModel('TDD', SkillLevel.fluent),
      ],
    ),
    SkillGroupModel(
      slug: 'backend',
      name: 'Backend & cloud',
      note: 'Enough of the other side to design an API I can actually consume.',
      skills: [
        SkillModel('Supabase', SkillLevel.core),
        SkillModel('Firebase', SkillLevel.core),
        SkillModel('PostgreSQL', SkillLevel.fluent),
        SkillModel('REST', SkillLevel.core),
        SkillModel('GraphQL', SkillLevel.working),
        SkillModel('Cloudflare R2', SkillLevel.fluent),
        SkillModel('OAuth2 / JWT', SkillLevel.fluent),
      ],
    ),
    SkillGroupModel(
      slug: 'craft',
      name: 'Craft',
      note: 'The last 10% — where a build stops looking like a build.',
      skills: [
        SkillModel('Design systems', SkillLevel.core),
        SkillModel('Motion & easing', SkillLevel.core),
        SkillModel('Figma', SkillLevel.core),
        SkillModel('Accessibility', SkillLevel.fluent),
        SkillModel('Typography', SkillLevel.fluent),
        SkillModel('Rive', SkillLevel.working),
      ],
    ),
    SkillGroupModel(
      slug: 'ship',
      name: 'Ship',
      note: 'The half of the job that happens after the code is written.',
      skills: [
        SkillModel('CI/CD', SkillLevel.core),
        SkillModel('GitHub Actions', SkillLevel.core),
        SkillModel('Azure DevOps', SkillLevel.fluent),
        SkillModel('Play Console & App Store Connect', SkillLevel.core),
        SkillModel('Sentry', SkillLevel.fluent),
        SkillModel('Amplitude', SkillLevel.working),
        SkillModel('Docker', SkillLevel.working),
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
      year: '2023',
      title: 'Paid to write Dart',
      note: 'Podii, and the offline problem — building for connectivity you '
          'cannot assume.',
    ),
    MilestoneModel(
      year: '2024',
      title: 'First Class Honours',
      note: 'BSc Computer Science, Masinde Muliro. Finished while shipping '
          'insurance software full-time.',
    ),
    MilestoneModel(
      year: '2025',
      title: 'Three platforms, one codebase',
      note: 'MyBritam on Android, iOS and Web — and a Play rating from 3.1 to '
          '4.1.',
    ),
    MilestoneModel(
      year: '2026',
      title: 'Zero to both stores in three months',
      note: 'HealthX, solo — research, brand, architecture, QA and release.',
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
