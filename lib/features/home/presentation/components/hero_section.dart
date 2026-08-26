import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';

/// Above-the-fold hero. Owns the page's only `<h1>`.
class HeroSection extends StatelessComponent {
  const HeroSection({super.key});

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
        const div(
          classes: 'starfield pointer-events-none absolute inset-0 opacity-0 dark:opacity-100',
          [],
        ),
        div(
          classes: 'relative mx-auto max-w-6xl px-5 pt-24 pb-20 sm:px-8 sm:pt-32 sm:pb-28',
          [
            p(
              classes: 'flex items-center gap-2 font-mono text-xs uppercase '
                  'tracking-[0.2em] text-star-500 dark:text-star-400',
              [
                AppIcons.star(classes: 'h-3.5 w-3.5'),
                const Component.text('${SiteConfig.role} · ${SiteConfig.location}'),
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
              [Component.text(SiteConfig.tagline)],
            ),
            div(
              classes: 'mt-10 flex flex-wrap items-center gap-3',
              [
                Link(
                  to: RoutePaths.projects,
                  classes: 'inline-flex items-center gap-2 rounded-full bg-ink-900 px-6 py-3 '
                      'text-sm font-medium text-ink-50 transition-transform duration-300 '
                      'ease-expo hover:-translate-y-0.5 '
                      'dark:bg-star-400 dark:text-ink-950',
                  children: [
                    const Component.text('See the work'),
                    AppIcons.arrow(),
                  ],
                ),
                const a(
                  href: 'mailto:${SiteConfig.email}',
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
                for (final stat in SiteConfig.stats)
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
            ),
          ],
        ),
      ],
    );
  }
}
