import '../../domain/enum/skill_level.dart';
import '../../domain/model/about_profile.dart';
import '../../domain/model/education_model.dart';
import '../../domain/model/experience_model.dart';
import '../../domain/model/role_stint.dart';
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
    // ── HealthX Africa ─────────────────────────────────────────────────────
    //
    // **The two stints are a scaffold.** The senior role's content is real;
    // what is authored is the *split* — the March boundary and the junior
    // stint under it. Both carry `draft: true`, so the page marks the dates
    // until you correct them.
    //
    // Note the shape of the copy here: figures first, one line of prose, then
    // only what a figure cannot carry. That is deliberate, and it is why this
    // section stopped reading as a CV.
    ExperienceModel(
      slug: 'healthx',
      company: 'HealthX Africa',
      kind: 'Full-time',
      location: 'Nairobi',
      blurb: "Kenya's most comprehensive telehealth platform.",
      roles: [
        RoleStint(
          title: 'Senior Flutter Engineer & UI/UX',
          period: 'Mar 2026 - Present',
          current: true,
          draft: true,
          projects: ['healthx', 'healthx-portal'],
          summary: 'Sole engineer and designer. Research, brand, architecture, '
              'QA and a dual-store release. If it shipped, it was me.',
          metrics: [
            (value: '10+', label: 'feature modules'),
            (value: '3 mos', label: 'zero to both stores'),
            (value: '100%', label: 'of it mine'),
          ],
          highlights: [
            'Set the company brand identity, now used company-wide',
            'Live video consults on LiveKit, e-pharmacy, biometric auth',
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
        // TODO: replace with the real first role. Everything here is authored.
        RoleStint(
          title: 'Flutter Developer',
          period: 'Jan 2026 - Mar 2026',
          draft: true,
          summary: 'Joined to build the mobile app, and ended up owning the '
              'design system that came with it.',
        ),
      ],
    ),

    // ── Dentsu Kenya ───────────────────────────────────────────────────────
    ExperienceModel(
      slug: 'dentsu',
      company: 'Dentsu Kenya',
      kind: 'Consultant',
      location: 'Nairobi',
      blurb: 'Global network agency, on the Britam Insurance account.',
      roles: [
        RoleStint(
          title: 'Flutter Developer',
          period: 'Apr 2024 - Sep 2025',
          projects: ['britam-app', 'britam-portal'],
          summary: 'A full architectural rebuild of the legacy MyBritam '
              'platform. Insurance is where a mistyped field has a financial '
              'consequence, which does wonders for your attention to detail.',
          metrics: [
            (value: '3.1 → 4.1', label: 'Play Store rating'),
            (value: '100%', label: 'parity across 3 platforms'),
            (value: '1', label: 'codebase for all of it'),
          ],
          highlights: [
            'CI/CD on GitHub Actions and Azure DevOps, synchronised across '
                'every platform',
            'Deep linking and real-time WebSocket updates',
          ],
          stack: [
            'Flutter',
            'Clean Architecture',
            'GitHub Actions',
            'Azure DevOps',
          ],
        ),
      ],
    ),

    // ── Podii Consultants ──────────────────────────────────────────────────
    ExperienceModel(
      slug: 'podii',
      company: 'Podii Consultants',
      kind: 'Full-time',
      location: 'Nairobi',
      blurb: 'Product engineering studio building for East African operators.',
      roles: [
        RoleStint(
          title: 'Flutter Developer',
          period: 'May 2023 - Mar 2024',
          projects: ['elvs'],
          summary: 'Internal tooling, and my first real fight with the offline '
              'problem. Building for people whose connectivity you cannot '
              'assume changes what finished means.',
          metrics: [
            (value: 'Offline', label: 'first, on SQLite'),
            (value: 'RBAC', label: 'role-based access control'),
          ],
          highlights: [
            'State restoration built for data integrity where the network '
                'drops mid-write',
          ],
          stack: ['Flutter', 'Dart', 'SQLite'],
        ),
      ],
    ),
  ];

  // ── Education ────────────────────────────────────────────────────────────

  static const List<EducationModel> education = [
    EducationModel(
      slug: 'degree',
      kind: 'Degree',
      qualification: 'BSc Computer Science',
      honours: 'First Class Honours',
      institution: 'Masinde Muliro University of Science and Technology',
      period: '2024',
      location: 'Kakamega',
      // The crest is a stencil: alpha only, no colour, so `currentColor` is
      // painted through it. See CLAUDE.md — it is the only way a two-colour
      // third-party logo can enter a palette of two tones and no accent hue.
      crest: 'images/mmust-crest.webp',
      crestWidth: 512,
      crestHeight: 464,
      // Kept straight. A credential is the one place on this site where
      // formality is the point, and a joke here would undercut the thing a
      // reader is being asked to take seriously.
      note: 'Four years of theory that still shows up in the work, usually at '
          'the least convenient moment.',
      focus: ['Algorithms', 'Systems', 'Databases', 'HCI'],
    ),
    EducationModel(
      slug: 'starehe',
      kind: 'Secondary',
      qualification: 'Kenya Certificate of Secondary Education',
      institution: "Starehe Boys' Centre and School",
      period: '2016 - 2019',
      location: 'Nairobi',
      // A portrait shield, where the MMUST lockup is landscape. Both are
      // stencils: alpha only, no colour, so `currentColor` paints through.
      crest: 'images/starehe-crest.webp',
      crestWidth: 430,
      crestHeight: 512,
      // No grade is claimed here on purpose. A result is a verifiable fact
      // and this file is not the place to guess one — add it when it is to
      // hand, or leave the credential to stand on the school's name.
      //
      // Nothing in this note is an achievement claim: Starehe's admissions
      // policy is a matter of public record, and what it says about the four
      // years is left for the reader to take or leave.
      note: 'A national school that admits on merit and means, which is a '
          'particular kind of company to keep at sixteen. Where the habit of '
          'taking things apart started.',
      focus: ['Mathematics', 'Physics', 'Computer Studies'],
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
      note: 'The languages and frameworks the work is actually made of.',
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
      note: 'Enough of the other side to design an API I will not curse at '
          'later.',
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
      note: 'The last 10%, where a build stops looking like a build.',
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
      note: 'The half of the job nobody puts on a CV, and the half that '
          'decides whether any of it reaches a phone.',
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
      blurb: 'Type, spacing, colour, motion and every state: decided once, in '
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
      note: 'Podii, and the offline problem, building for connectivity you '
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
      note: 'MyBritam on Android, iOS and Web, and a Play rating from 3.1 to '
          '4.1.',
    ),
    MilestoneModel(
      year: '2026',
      title: 'Zero to both stores in three months',
      note: 'HealthX, solo: research, brand, architecture, QA and release.',
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
