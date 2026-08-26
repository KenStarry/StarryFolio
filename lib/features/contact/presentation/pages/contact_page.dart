import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../components/channel_grid.dart';
import '../components/contact_form.dart';

/// The contact page.
///
/// Two ways in, side by side: the form for anyone with a brief, and direct
/// channels for anyone who would rather message on something already open.
/// Neither is buried under the other — a page that only offers a form loses
/// the people who will not fill one in.
class ContactPage extends StatelessComponent {
  const ContactPage({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      const PageMeta(
        path: RoutePaths.contact,
        title: 'Contact — ${SiteConfig.name}',
        description: 'Start a project, ask a question, or just say hello — by '
            'form, email, WhatsApp or wherever you already are.',
      ),
      StructuredData(id: 'ld-contact', SchemaOrg.contactPage()),

      const _Header(),
      const _Body(),
      if (SiteConfig.buyMeACoffee.isNotEmpty) const _Support(),
    ]);
  }
}

class _Header extends StatelessComponent {
  const _Header();

  @override
  Component build(BuildContext context) {
    return const section(
      classes: 'bg-ink-900 pb-14 pt-16 sm:pb-16 sm:pt-24',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'reveal max-w-2xl',
              [
                Eyebrow('Contact'),
                h1(
                  classes: 'type-section mt-5 font-display font-extrabold '
                      'text-ink-100',
                  [
                    Component.text('Tell me what'),
                    br(),
                    Component.text('you are building.'),
                  ],
                ),
                p(
                  classes: 'mt-6 max-w-lg text-sm leading-relaxed text-ink-400 '
                      'sm:text-[0.9375rem]',
                  [
                    Component.text(
                      'A brief, a rough idea, or a question about something on '
                      'this site — all welcome. I read everything and usually '
                      'reply within a day.',
                    ),
                  ],
                ),
                div(
                  classes: 'mt-8 inline-flex items-center gap-2.5',
                  [
                    span(
                      classes: 'h-1.5 w-1.5 rounded-full bg-iris-400 dot-live',
                      [],
                    ),
                    span(
                      classes: 'type-eyebrow font-mono text-ink-400',
                      [Component.text(SiteConfig.availabilityLabel)],
                    ),
                  ],
                ),
              ],
            ),
            div(classes: 'divider mt-12', []),
          ],
        ),
      ],
    );
  }
}

/// Form on the left, channels on the right — equal billing.
class _Body extends StatelessComponent {
  const _Body();

  @override
  Component build(BuildContext context) {
    return const section(
      classes: 'bg-ink-900 pb-24 sm:pb-32',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid gap-14 lg:grid-cols-[1.08fr_0.92fr] lg:gap-16',
              [
                // ── Form ──
                div(
                  classes: 'reveal',
                  [
                    p(
                      classes: 'type-eyebrow font-mono text-ink-500',
                      [Component.text('Send a message')],
                    ),
                    div(classes: 'divider-quiet mt-5', []),
                    div(classes: 'mt-8', [ContactForm()]),
                  ],
                ),

                // ── Channels ──
                div(
                  classes: 'reveal',
                  [
                    p(
                      classes: 'type-eyebrow font-mono text-ink-500',
                      [Component.text('Or find me here')],
                    ),
                    div(classes: 'divider-quiet mt-5', []),
                    div(classes: 'mt-8', [ChannelGrid()]),
                    p(
                      classes: 'mt-8 max-w-sm text-xs leading-relaxed '
                          'text-ink-500',
                      [
                        Component.text(
                          'Based in ${SiteConfig.location}, working with teams '
                          'anywhere. If our hours do not overlap, leave the '
                          'detail in a message and I will pick it up.',
                        ),
                      ],
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
}

/// Buy Me a Coffee.
///
/// Deliberately last and deliberately quiet. It is an invitation, not an ask —
/// putting it above the contact channels would make the page read as soliciting
/// rather than offering.
class _Support extends StatelessComponent {
  const _Support();

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'bg-ink-950 py-20 sm:py-24',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'reveal flex flex-col items-start justify-between '
                  'gap-8 border border-ink-800 bg-ink-900 p-8 sm:p-10 '
                  'lg:flex-row lg:items-center',
              [
                div(
                  classes: 'max-w-lg',
                  [
                    div(
                      classes: 'flex items-center gap-3',
                      [
                        span(
                          classes: 'text-iris-400',
                          [AppIcons.coffee(classes: 'h-5 w-5')],
                        ),
                        const span(
                          classes: 'type-eyebrow font-mono text-ink-400',
                          [Component.text('If something here helped')],
                        ),
                      ],
                    ),
                    const p(
                      classes: 'mt-5 font-display text-xl font-bold '
                          'tracking-tight text-ink-100 sm:text-2xl',
                      [Component.text('Buy me a coffee.')],
                    ),
                    const p(
                      classes: 'mt-3 text-sm leading-relaxed text-ink-400',
                      [
                        Component.text(
                          'Some of what I build is open and free to use. If it '
                          'saved you an afternoon, this is the tip jar — '
                          'entirely optional, and it never changes what I '
                          'publish.',
                        ),
                      ],
                    ),
                  ],
                ),
                div(
                  classes: 'shrink-0',
                  [
                    CtaButton(
                      label: 'Buy me a coffee',
                      href: SiteConfig.buyMeACoffeeUrl,
                      variant: CtaVariant.outline,
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
}
