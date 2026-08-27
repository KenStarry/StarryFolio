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
      classes: 'relative overflow-hidden bg-ink-900 pb-14 pt-16 sm:pb-16 '
          'sm:pt-24',
      [
        // The motif, at page scale. Texture rather than content, so it is
        // hidden from assistive tech and unselectable — it repeats a word the
        // heading beside it already says.
        div(
          classes: 'pointer-events-none absolute -right-8 top-1/2 '
              '-translate-y-1/2 select-none',
          attributes: {'aria-hidden': 'true'},
          [
            span(
              classes: 'showcase-ghost font-display font-extrabold '
                  'text-ink-100/[0.035]',
              [Component.text('Talk')],
            ),
          ],
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
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
      id: 'message',
      classes: 'relative bg-ink-800 py-20 sm:py-28',
      [
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            _BandHead(
              index: '01',
              eyebrow: 'Send a message',
              title: 'Start with the detail.',
              lead: 'The more you can say about what you are building, the more '
                  'useful my first reply will be.',
            ),

            div(
              classes: 'mt-14 grid gap-14 lg:grid-cols-[1.08fr_0.92fr] '
                  'lg:gap-16',
              [
                div(classes: 'reveal', [ContactForm()]),

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
                          'text-ink-400',
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

/// Buy Me a Coffee, on its own band.
///
/// Given the same numbered treatment as the message band rather than tucked
/// into a corner — it is a real thing being offered, not an afterthought — but
/// placed last and on the deepest tone, so the page reads as offering before it
/// reads as asking.
class _Support extends StatelessComponent {
  const _Support();

  @override
  Component build(BuildContext context) {
    return section(
      id: 'support',
      classes: 'relative overflow-hidden bg-ink-950 py-20 sm:py-28',
      [
        const div(
          classes: 'pointer-events-none absolute -right-10 top-1/2 '
              '-translate-y-1/2 select-none',
          attributes: {'aria-hidden': 'true'},
          [
            span(
              classes: 'showcase-ghost font-display font-extrabold '
                  'text-ink-100/[0.03]',
              [Component.text('Thanks')],
            ),
          ],
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const _BandHead(
              index: '02',
              eyebrow: 'Support the work',
              title: 'Buy me a coffee.',
              lead: 'Some of what I build is open and free to use. If it saved '
                  'you an afternoon, this is the tip jar — entirely optional, '
                  'and it never changes what I publish.',
            ),

            div(
              classes: 'reveal mt-12 grid gap-6 sm:grid-cols-3',
              [
                _note(
                  'coffee',
                  'No account needed',
                  'A one-off, in whatever amount makes sense. No sign-up, no '
                  'subscription.',
                ),
                _note(
                  'github',
                  'It funds the open work',
                  'Packages, write-ups and the things I give away rather than '
                  'invoice for.',
                ),
                _note(
                  'mail',
                  'Not a substitute for hiring me',
                  'If you actually need something built, the form above is the '
                  'better door.',
                ),
              ],
            ),

            div(
              classes: 'reveal mt-12',
              [
                CtaButton(
                  label: 'Buy me a coffee',
                  href: SiteConfig.buyMeACoffeeUrl,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Component _note(String icon, String title, String body) => div(
        classes: 'border-t border-ink-800 pt-6',
        [
          span(
            classes: 'text-iris-400',
            [AppIcons.social(icon, classes: 'h-5 w-5')],
          ),
          p(
            classes: 'mt-5 font-display text-base font-bold tracking-tight '
                'text-ink-100',
            [Component.text(title)],
          ),
          p(
            classes: 'mt-2.5 text-sm leading-relaxed text-ink-400',
            [Component.text(body)],
          ),
        ],
      );
}

/// Numbered band heading, matching the pattern `/projects` and `/services`
/// use — an oversized ghosted numeral, the title, and a fading divider.
///
/// Kept local rather than lifted into `core/`: the two other pages build theirs
/// from repository data with live counts, and a shared component would end up
/// carrying parameters that only one caller ever uses.
class _BandHead extends StatelessComponent {
  const _BandHead({
    required this.index,
    required this.eyebrow,
    required this.title,
    required this.lead,
  });

  final String index;
  final String eyebrow;
  final String title;
  final String lead;

  @override
  Component build(BuildContext context) {
    return div([
      div(
        classes: 'reveal relative',
        [
          // Texture, never content — hidden from the accessibility tree and
          // unselectable, sitting behind the words it echoes.
          div(
            classes: 'pointer-events-none absolute -left-3 -top-20 -z-10 '
                'select-none font-display font-extrabold leading-none '
                'tracking-tighter text-ink-100/[0.035] '
                'text-[clamp(6rem,13vw,10rem)]',
            attributes: const {'aria-hidden': 'true'},
            [Component.text(index)],
          ),

          div(
            classes: 'flex items-center gap-3',
            [
              const span(classes: 'h-px w-6 bg-iris-500', []),
              span(
                classes: 'type-eyebrow font-mono text-ink-400',
                [Component.text(eyebrow)],
              ),
            ],
          ),

          h2(
            classes: 'type-section mt-5 font-display font-bold text-ink-100',
            [Component.text(title)],
          ),

          p(
            classes: 'mt-5 max-w-lg text-sm leading-relaxed text-ink-400',
            [Component.text(lead)],
          ),
        ],
      ),
      const div(classes: 'divider mt-10', []),
    ]);
  }
}

