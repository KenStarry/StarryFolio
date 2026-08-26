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
      location: 'Nairobi, Kenya',
      current: true,
      draft: true,
      projectSlug: 'healthx',
      summary: 'I own the full mobile lifecycle of a Kenyan telehealth '
          'platform — brand and design system through architecture, QA and '
          'release to both stores. Health data is unforgiving: every screen '
          'has to degrade honestly when the network does not cooperate, and '
          'no failure is allowed to look like success.',
      highlights: [
        'Took the app from a single feature to seven modules on one shell, '
            'without a rewrite',
        'Set the design system — tokens, type ramp, motion — and built '
            'against it rather than beside it',
        'Shipped to the App Store and Play Store on a repeatable, signed, '
            'staged pipeline',
        'Made offline behaviour a design constraint from screen one instead '
            'of a patch after the complaints',
      ],
      stack: [
        'Flutter',
        'Riverpod 3',
        'Clean Architecture',
        'Dio',
        'Firebase',
        'Fastlane',
      ],
    ),
    ExperienceModel(
      slug: 'dentsu',
      role: 'Mobile Engineer',
      company: 'Dentsu',
      period: '2022 — 2023',
      kind: 'Contract',
      location: 'Nairobi, Kenya',
      draft: true,
      summary: 'Digital product work for brand clients, on deadlines that do '
          'not move. Agency work teaches a specific discipline: the polish has '
          'to be in the system, because there is never time to add it '
          'afterwards.',
      highlights: [
        'Built client-facing Flutter products against fixed campaign dates',
        'Translated finished brand guidelines into component libraries that '
            'held up past the launch',
        'Worked directly with designers, which is where the habit of building '
            'the system first came from',
      ],
      stack: ['Flutter', 'BLoC', 'Figma', 'REST'],
    ),
    ExperienceModel(
      slug: 'britam',
      role: 'Flutter Developer',
      company: 'Britam',
      period: '2021 — 2022',
      kind: 'Full-time',
      location: 'Nairobi, Kenya',
      draft: true,
      summary: 'Insurance, on mobile. Long forms, legal copy, money moving, '
          'and users who will only ever open the app on the day something has '
          'gone wrong for them. The clarity of an empty state matters more '
          'here than anywhere else I have worked.',
      highlights: [
        'Shipped customer-facing flows where a mis-typed field has a real '
            'financial consequence',
        'Learned to treat validation, retries and receipts as product '
            'surfaces rather than plumbing',
        'Worked inside an enterprise release process — approvals, audits, '
            'staged rollouts',
      ],
      stack: ['Flutter', 'Provider', 'REST', 'Play Console'],
    ),
    ExperienceModel(
      slug: 'podii',
      role: 'Software Engineer',
      company: 'Podii',
      period: '2020 — 2021',
      kind: 'Full-time',
      location: 'Nairobi, Kenya',
      draft: true,
      summary: 'Product engineering across several client builds, and where '
          'Dart stopped being a language I was reading about and became the '
          'one I reached for. Small team, wide surface, everything visible.',
      highlights: [
        'Delivered features end to end — data layer, UI, review, release',
        'Sat close enough to product decisions to see which ones survive '
            'contact with users',
        'Wrote the first Flutter code I would still defend today',
      ],
      stack: ['Dart', 'Flutter', 'Git', 'Agile'],
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
      note: 'The fundamentals that do not expire — data structures, systems, '
          'and how to read a specification. Everything framework-shaped I '
          'learned after, and keep relearning.',
      focus: [
        'Algorithms & data structures',
        'Software engineering',
        'Databases',
        'Human–computer interaction',
      ],
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
      artefact: 'A one-page scope, and the list of what we are not building',
      blurb: 'Before a single screen: what has to be true for this to have '
          'been worth building? Most projects arrive as a feature list. The '
          'first job is turning it back into an outcome, then cutting '
          'everything that does not serve it.',
    ),
    ProcessStepModel(
      slug: 'systemise',
      title: 'Systemise it',
      icon: 'layers',
      artefact: 'Tokens, a component library, and the motion spec',
      blurb: 'Type ramp, spacing, colour, motion curves and every state a '
          'component can be in — decided once, in code, before screen one. '
          'This is why screen forty still looks like screen one, and why a '
          'new feature takes days rather than a redesign.',
    ),
    ProcessStepModel(
      slug: 'build',
      title: 'Build it',
      icon: 'device',
      artefact: 'A codebase your next engineer can read without a handover',
      blurb: 'Clean Architecture, a real state layer, and offline behaviour '
          'designed in rather than bolted on. Built to hold up on a mid-range '
          'Android phone with two bars of signal, because that is what most '
          'users actually have.',
    ),
    ProcessStepModel(
      slug: 'ship',
      title: 'Ship it',
      icon: 'rocket',
      artefact: 'Signed builds, staged rollouts, and a listing that converts',
      blurb: 'Release is a feature. Automated builds and signing, staged '
          'rollouts, crash reporting wired before launch rather than after '
          'the first bad review — and store copy and screenshots treated as '
          'part of the product, not paperwork.',
    ),
  ];

  // ── Milestones ───────────────────────────────────────────────────────────
  //
  // Chronological. The spine reads downward as time moves forward.

  static const List<MilestoneModel> milestones = [
    MilestoneModel(
      year: '2019',
      title: 'First widget tree',
      note: 'Swapped a screenful of Android XML for a widget tree and never '
          'went back.',
    ),
    MilestoneModel(
      year: '2021',
      title: 'First app on a store',
      note: 'A real listing, a real download count, and the specific dread of '
            'a rejected build.',
    ),
    MilestoneModel(
      year: '2023',
      title: 'Took the whole lifecycle',
      note: 'Design system through release, at a telehealth platform — the '
          'first time every part of it was mine.',
    ),
    MilestoneModel(
      year: '2025',
      title: 'Both stores, one codebase',
      note: 'iOS and Android shipping from the same source, on a pipeline '
          'that runs itself.',
    ),
    MilestoneModel(
      year: '2026',
      title: 'This site, in Dart',
      note: 'Rebuilt in Jaspr and pre-rendered — the same language as the '
          'apps, all the way down.',
    ),
  ];

  // ── Beyond the code ──────────────────────────────────────────────────────

  static const List<FacetModel> facets = [
    FacetModel(
      title: 'A side project I actually use',
      icon: 'device',
      marker: 'CribLynk',
      blurb: 'Building it is how I keep the tools honest — every framework '
          'opinion gets tested against something I have to live with.',
    ),
    FacetModel(
      title: 'A camera roll full of UI',
      icon: 'layers',
      marker: 'Screenshots',
      blurb: 'Sheet easings, empty states, a transition that landed just '
          'right. Most of what I know about polish came from stealing '
          'carefully.',
    ),
    FacetModel(
      title: 'Teaching what I just learned',
      icon: 'compass',
      marker: 'Community',
      blurb: 'Explaining a thing badly is how you find out you did not '
          'understand it. Most of my best decisions started as a bad '
          'explanation.',
    ),
    FacetModel(
      title: 'Nairobi, and the light here',
      icon: 'globe',
      marker: 'UTC+3',
      blurb: 'Building for a market where a mid-range phone and two bars of '
          'signal is the default, not the edge case. It makes you a better '
          'engineer.',
    ),
  ];
}
