import '../../domain/model/service_model.dart';

/// The services, as compile-time constants.
///
/// Order matters: it drives the numbering and the band sequence on
/// `/services`, and the first three are what the home overview shows.
///
/// Deliberately `const` and synchronous for the same reason as the projects
/// source — the static build has to resolve this during pre-render, and the
/// repository on top exists so the page never learns where the data came from.
abstract final class ServicesLocalDatasource {
  static const List<ServiceModel> services = [
    ServiceModel(
      slug: 'mobile-development',
      title: 'Mobile\ndevelopment',
      blurb: 'iOS and Android from one Flutter codebase: architecture, state, '
          'offline behaviour and a release pipeline that runs itself.',
      detail: 'The core of what I do. One Flutter codebase serving both stores, '
          'built to hold up on a mid-range Android phone with two bars of '
          'signal, because that is what most of your users actually have. '
          'Clean Architecture, a real state layer, and offline behaviour '
          'designed in from the first screen rather than bolted on when the '
          'complaints arrive.',
      icon: 'device',
      ctaQuestion: 'Need an app?',
      featured: true,
      tags: ['Flutter', 'Riverpod', 'BLoC', 'Clean Architecture'],
      deliverables: [
        'A single codebase shipping to the App Store and Play Store',
        'Offline-first data layer with a replayable write queue',
        'Architecture your next engineer can read without a handover',
        'Automated builds, signing and staged rollouts',
      ],
    ),
    ServiceModel(
      slug: 'ui-ux-design',
      title: 'UI/UX\ndesign',
      blurb: 'A token-driven system before the first screen: type, colour, '
          'motion and every state, so screen forty still looks like screen one.',
      detail: 'Design and build are the same job done twice when they are split '
          'between two people. I set the system first: tokens, type ramp, '
          'spacing, motion curves and every state a component can be in, then '
          'build against it. The result is a product that stays coherent as it '
          'grows, and a handoff that is a codebase rather than a folder of '
          'screens.',
      icon: 'layers',
      ctaQuestion: 'Need a design system?',
      tags: ['Figma', 'Design tokens', 'Motion', 'Accessibility'],
      deliverables: [
        'Design tokens wired into the code, not just the Figma file',
        'A component library with empty, loading and error states drawn',
        'Motion spec: durations, curves and what they signal',
        'Accessibility passes on contrast, target size and focus order',
      ],
    ),
    ServiceModel(
      slug: 'web-development',
      title: 'Web\ndevelopment',
      blurb: 'Marketing sites and web apps that load fast, rank well and are '
          'still readable with JavaScript switched off.',
      detail: 'Sites built to be found. Static rendering where the content is '
          'the point, so crawlers and social scrapers get real HTML instead of '
          'an empty shell waiting on a bundle. Where an app needs to be an app, '
          'Flutter Web or a hydrated island, but only where the interaction '
          'actually earns the JavaScript.',
      icon: 'globe',
      ctaQuestion: 'Need a web presence?',
      tags: ['Jaspr', 'Flutter Web', 'Static rendering', 'SEO'],
      deliverables: [
        'Pre-rendered pages that index without waiting on JavaScript',
        'Structured data, Open Graph and a sitemap wired in from day one',
        'A design system shared with the mobile product where it makes sense',
        'Deploys on push, with previews per branch',
      ],
    ),
    ServiceModel(
      slug: 'desktop-apps',
      title: 'Desktop\napplications',
      blurb: 'macOS, Windows and Linux from the same codebase, for tools that '
          'belong on a real machine rather than in a tab.',
      detail: 'Some work does not belong in a browser tab. Internal tools, '
          'operator consoles and anything that needs the filesystem, a serial '
          'port or hardware acceleration ships better as a desktop build, and '
          'with Flutter that is the same codebase you already have, not a '
          'second team.',
      icon: 'monitor',
      ctaQuestion: 'Need it on the desktop?',
      tags: ['Flutter Desktop', 'FFI', 'Platform channels'],
      deliverables: [
        'Signed, notarised builds for macOS, Windows and Linux',
        'Native integration through FFI or platform channels where needed',
        'Auto-update, so users are not chasing installers',
        'Shared UI with the mobile product where the interaction allows',
      ],
    ),
    ServiceModel(
      slug: 'ship-and-operate',
      title: 'Ship\n& operate',
      blurb: 'Store listings, CI/CD, staged rollouts and the crash dashboards '
          'you actually want to open on a Monday morning.',
      detail: 'The part that decides whether the work you paid for reaches '
          'anyone. Release pipelines that do not need a specific person '
          'awake, staged rollouts that let you stop a bad build at two percent '
          'instead of a hundred, and crash reporting that points at a line '
          'number rather than a vibe.',
      icon: 'rocket',
      ctaQuestion: 'Need to ship?',
      tags: ['CI/CD', 'Fastlane', 'Firebase', 'Shorebird'],
      deliverables: [
        'Automated build, sign and upload on every tagged release',
        'Staged rollouts with a rollback you have actually rehearsed',
        'Crash and ANR monitoring wired to somewhere you will see it',
        'Store listings, screenshots and review notes that pass first time',
      ],
    ),
    ServiceModel(
      slug: 'consultancy',
      title: 'Consultancy\n& review',
      blurb: 'A second pair of eyes on an architecture, a codebase or a team '
          'that has hit the wall, and a written route out.',
      detail: 'Sometimes the useful thing is not another pair of hands. I read '
          'the codebase, talk to the people building it, and write down what is '
          'actually slowing you down, with an order to fix it in. Equally '
          'useful before you start, when the decision is which architecture to '
          'commit to and how much it will cost you later.',
      icon: 'compass',
      ctaQuestion: 'Need a second opinion?',
      tags: ['Architecture review', 'Code audit', 'Mentoring'],
      deliverables: [
        'A written review you can hand to a board or an engineer',
        'A prioritised list: what to fix now, next and never',
        'Pairing sessions with the team who will own it afterwards',
        'Follow-up once the changes have had time to land',
      ],
    ),
  ];
}
