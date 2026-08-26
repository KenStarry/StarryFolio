import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/icons.dart';
import '../components/page_meta.dart';
import '../components/project_card.dart';
import '../components/section.dart';
import '../data/profile.dart';
import '../data/projects.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Component build(BuildContext context) {
    return const div([
      PageMeta(
        path: '/',
        title: '${Profile.name} — ${Profile.role}',
        description: Profile.tagline,
      ),
      _Hero(),
      _About(),
      _Work(),
      _Contact(),
    ]);
  }
}

class _Hero extends StatelessComponent {
  const _Hero();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'relative overflow-hidden',
      [
        // Ambient glow + starfield, purely decorative.
        const div(
          classes: 'pointer-events-none absolute inset-0 '
              'bg-[radial-gradient(60%_50%_at_50%_0%,rgba(246,200,90,0.14),transparent_70%)]',
          [],
        ),
        const div(classes: 'starfield pointer-events-none absolute inset-0 opacity-0 dark:opacity-100', []),
        div(
          classes: 'relative mx-auto max-w-6xl px-5 pt-24 pb-20 sm:px-8 sm:pt-32 sm:pb-28',
          [
            p(
              classes: 'flex items-center gap-2 font-mono text-xs uppercase '
                  'tracking-[0.2em] text-star-500 dark:text-star-400',
              [
                Icons.star(classes: 'h-3.5 w-3.5'),
                const Component.text('${Profile.role} · ${Profile.location}'),
              ],
            ),
            const h1(
              classes: 'mt-6 max-w-4xl font-display text-4xl font-semibold leading-[1.1] '
                  'tracking-tight text-ink-900 sm:text-6xl lg:text-7xl dark:text-ink-50',
              [
                Component.text('Apps people '),
                span(
                  classes: 'bg-gradient-to-r from-star-500 to-star-300 bg-clip-text text-transparent',
                  [Component.text('actually reopen')],
                ),
                Component.text('.'),
              ],
            ),
            const p(
              classes: 'mt-6 max-w-2xl text-lg leading-relaxed text-ink-500 dark:text-ink-300',
              [Component.text(Profile.tagline)],
            ),
            div(
              classes: 'mt-10 flex flex-wrap items-center gap-3',
              [
                Link(
                  to: '/projects',
                  classes: 'inline-flex items-center gap-2 rounded-full bg-ink-900 px-6 py-3 '
                      'text-sm font-medium text-ink-50 transition-transform duration-300 '
                      'ease-expo hover:-translate-y-0.5 '
                      'dark:bg-star-400 dark:text-ink-950',
                  children: [
                    const Component.text('See the work'),
                    Icons.arrow(),
                  ],
                ),
                const a(
                  href: 'mailto:${Profile.email}',
                  classes: 'inline-flex items-center gap-2 rounded-full border '
                      'border-ink-200 px-6 py-3 text-sm font-medium text-ink-700 '
                      'transition-colors hover:border-star-400 hover:text-star-500 '
                      'dark:border-ink-700 dark:text-ink-200 dark:hover:text-star-300',
                  [Component.text('Start a project')],
                ),
              ],
            ),
            dl(
              classes: 'mt-16 grid max-w-2xl grid-cols-3 gap-6 border-t '
                  'border-ink-200/70 pt-8 dark:border-ink-800',
              [
                for (final stat in Profile.stats) ...[
                  div([
                    dt(
                      classes: 'font-display text-3xl font-semibold text-ink-900 dark:text-ink-50',
                      [Component.text(stat.value)],
                    ),
                    dd(
                      classes: 'mt-1 text-xs text-ink-400 sm:text-sm',
                      [Component.text(stat.label)],
                    ),
                  ]),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _About extends StatelessComponent {
  const _About();

  @override
  Component build(BuildContext context) {
    return Section(
      id: 'about',
      eyebrow: 'About',
      heading: 'The short version',
      children: [
        div(
          classes: 'grid gap-12 lg:grid-cols-[1.2fr_1fr]',
          [
            div(
              classes: 'space-y-5',
              [
                for (final para in Profile.bio)
                  p(
                    classes: 'text-base leading-relaxed text-ink-500 dark:text-ink-300',
                    [Component.text(para)],
                  ),
              ],
            ),
            div(
              classes: 'space-y-6',
              [
                for (final group in Profile.toolkit)
                  div([
                    h3(
                      classes: 'font-mono text-xs uppercase tracking-[0.18em] '
                          'text-ink-400 dark:text-ink-400',
                      [Component.text(group.group)],
                    ),
                    div(
                      classes: 'mt-2 flex flex-wrap gap-2',
                      [
                        for (final item in group.items)
                          span(
                            classes: 'rounded-md bg-ink-100 px-2.5 py-1 text-xs '
                                'text-ink-600 dark:bg-ink-800 dark:text-ink-200',
                            [Component.text(item)],
                          ),
                      ],
                    ),
                  ]),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Work extends StatelessComponent {
  const _Work();

  @override
  Component build(BuildContext context) {
    return Section(
      id: 'work',
      eyebrow: 'Selected work',
      heading: 'Things I have shipped',
      lead: 'A few products where I owned the whole surface — design system, '
          'architecture, release.',
      children: [
        div(
          classes: 'grid gap-6 sm:grid-cols-2 lg:grid-cols-3',
          [
            for (final project in featuredProjects) ProjectCard(project: project),
          ],
        ),
        div(
          classes: 'mt-10',
          [
            Link(
              to: '/projects',
              classes: 'inline-flex items-center gap-1.5 text-sm font-medium '
                  'text-star-500 hover:underline dark:text-star-400',
              children: [
                const Component.text('All projects'),
                Icons.arrow(),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Contact extends StatelessComponent {
  const _Contact();

  @override
  Component build(BuildContext context) {
    return Section(
      id: 'contact',
      eyebrow: 'Contact',
      heading: 'Got something worth building?',
      lead: 'Tell me what your users keep coming back for. If an app makes that '
          'easier, I would like to hear about it.',
      children: [
        div(
          classes: 'flex flex-col gap-8 sm:flex-row sm:items-center sm:justify-between',
          [
            const a(
              href: 'mailto:${Profile.email}',
              classes: 'font-display text-2xl font-semibold tracking-tight '
                  'text-ink-900 underline decoration-star-400 decoration-2 '
                  'underline-offset-8 transition-colors hover:text-star-500 '
                  'sm:text-3xl dark:text-ink-50 dark:hover:text-star-300',
              [Component.text(Profile.email)],
            ),
            div(
              classes: 'flex flex-wrap gap-3',
              [
                for (final s in Profile.socials)
                  a(
                    href: s.url,
                    target: Target.blank,
                    classes: 'rounded-full border border-ink-200 px-4 py-2 text-sm '
                        'text-ink-600 transition-colors hover:border-star-400 '
                        'hover:text-star-500 dark:border-ink-700 dark:text-ink-200 '
                        'dark:hover:text-star-300',
                    [Component.text(s.label)],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
