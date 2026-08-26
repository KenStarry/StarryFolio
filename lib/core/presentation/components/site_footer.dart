import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../config/site_config.dart';
import '../../routing/route_paths.dart';
import 'app_icons.dart';

const _footerLinks = <({String label, String href})>[
  (label: 'Services', href: RoutePaths.services),
  (label: 'Works', href: RoutePaths.projects),
  (label: 'About', href: RoutePaths.about),
  (label: 'Contact', href: RoutePaths.contact),
];

/// Page footer, on the deepest tone so the page closes darker than it opened.
class SiteFooter extends StatelessComponent {
  const SiteFooter({this.path = RoutePaths.home, super.key});

  /// Current page path, so back-to-top targets *this* page's `#top` rather
  /// than the home page's — see [RoutePaths.anchor].
  final String path;

  @override
  Component build(BuildContext context) {
    return footer(
      classes: 'bg-ink-950',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 pt-20 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid gap-12 md:grid-cols-[1.5fr_1fr] md:gap-8',
              [
                div([
                  const div(
                    classes: 'flex items-center gap-3',
                    [
                      span(
                        classes: 'flex h-9 w-9 shrink-0 overflow-hidden '
                            'rounded-full bg-ink-800 ring-1 ring-ink-800',
                        attributes: {'aria-hidden': 'true'},
                        [
                          img(
                            src: '/${SiteConfig.logoMark}',
                            alt: '',
                            attributes: {
                              'width': '256',
                              'height': '256',
                              'loading': 'lazy',
                              'decoding': 'async',
                            },
                            classes: 'h-full w-full object-cover',
                          ),
                        ],
                      ),
                      span(
                        classes: 'font-display text-sm font-semibold '
                            'tracking-tight text-ink-100',
                        [Component.text(SiteConfig.wordmark)],
                      ),
                    ],
                  ),
                  const p(
                    classes: 'mt-6 max-w-sm text-sm leading-relaxed text-ink-400',
                    [Component.text(SiteConfig.tagline)],
                  ),
                  a(
                    href: 'mailto:${SiteConfig.email}',
                    classes: 'link-line mt-6 inline-flex items-center gap-2.5 '
                        'text-sm text-ink-200 transition-colors '
                        'hover:text-ink-100',
                    [
                      AppIcons.mail(classes: 'h-4 w-4 text-iris-400'),
                      const Component.text(SiteConfig.email),
                    ],
                  ),
                ]),

                div(
                  classes: 'grid grid-cols-2 gap-8',
                  [
                    div([
                      const p(
                        classes: 'type-eyebrow font-mono text-ink-500',
                        [Component.text('Sitemap')],
                      ),
                      div(
                        classes: 'mt-5 flex flex-col gap-3',
                        [
                          for (final link in _footerLinks)
                            if (link.href.contains('#'))
                              a(
                                href: link.href,
                                classes: _linkClasses,
                                [Component.text(link.label)],
                              )
                            else
                              Link(
                                to: link.href,
                                classes: _linkClasses,
                                children: [Component.text(link.label)],
                              ),
                        ],
                      ),
                    ]),
                    div([
                      const p(
                        classes: 'type-eyebrow font-mono text-ink-500',
                        [Component.text('Elsewhere')],
                      ),
                      div(
                        classes: 'mt-5 flex flex-col gap-3',
                        [
                          for (final social in SiteConfig.socials)
                            a(
                              href: social.url,
                              target: Target.blank,
                              // rel=me corroborates the `sameAs` entries in the
                              // Person JSON-LD, so the profiles verify back here.
                              attributes: const {'rel': 'me noopener'},
                              classes: 'group inline-flex items-center gap-2.5 '
                                  '$_linkClasses',
                              [
                                span(
                                  classes: 'text-ink-500 transition-colors '
                                      'group-hover:text-iris-400',
                                  [AppIcons.social(social.label)],
                                ),
                                Component.text(social.label),
                              ],
                            ),
                        ],
                      ),
                    ]),
                  ],
                ),
              ],
            ),

            div(
              classes: 'mt-20 flex flex-col gap-4 border-t border-ink-800 py-8 '
                  'sm:flex-row sm:items-center sm:justify-between',
              [
                const p(
                  classes: 'text-xs text-ink-500',
                  [
                    Component.text(
                      '© 2026 ${SiteConfig.name}. Built with Dart + Jaspr.',
                    ),
                  ],
                ),
                a(
                  href: RoutePaths.anchor(path, 'top'),
                  classes: 'group inline-flex items-center gap-2 text-xs '
                      'text-ink-500 transition-colors hover:text-ink-200',
                  [
                    const Component.text('Back to top'),
                    span(
                      classes: 'transition-transform duration-500 ease-soft '
                          'group-hover:-translate-y-0.5',
                      [AppIcons.arrowUpRight(classes: 'h-3.5 w-3.5')],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static const String _linkClasses =
      'text-sm text-ink-400 transition-colors hover:text-ink-100';
}
