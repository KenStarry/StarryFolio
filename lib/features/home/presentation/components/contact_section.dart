import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/presentation/components/cta_button.dart';

/// The closing call to action.
///
/// A full-width band on the raised tone rather than a floating panel — after a
/// page of stacked bands, ending on another band is what keeps the rhythm.
class ContactSection extends StatelessComponent {
  const ContactSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(
      id: 'contact',
      classes: 'bg-ink-800 py-24 sm:py-32 lg:py-40',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid gap-14 lg:grid-cols-[1fr_0.9fr] lg:gap-20',
              [
                const div(
                  classes: 'reveal',
                  [
                    Eyebrow('Contact'),
                    h2(
                      classes: 'type-section mt-5 font-display font-bold '
                          'text-ink-100',
                      [
                        Component.text('Got something'),
                        br(),
                        Component.text('worth building?'),
                      ],
                    ),
                    p(
                      classes: 'mt-6 max-w-md text-sm leading-relaxed '
                          'text-ink-400',
                      [
                        Component.text(
                          'Tell me what your users keep coming back for. If '
                          'an app would make that easier, I am already halfway '
                          'to sketching it.',
                        ),
                      ],
                    ),
                  ],
                ),

                div(
                  classes: 'reveal flex flex-col justify-end',
                  [
                    a(
                      href: 'mailto:${SiteConfig.email}',
                      classes: 'link-line group inline-flex w-fit items-center '
                          'gap-3 font-display text-lg font-bold tracking-tight '
                          'text-ink-100 transition-colors duration-300',
                      [
                        AppIcons.mail(classes: 'h-5 w-5 text-iris-400'),
                        const span(
                          classes: 'break-all',
                          [Component.text(SiteConfig.email)],
                        ),
                      ],
                    ),

                    // The form itself lives on /contact, which has the room
                    // for it alongside every other channel. Two copies of the
                    // same island would leave a visitor wondering which is the
                    // real one.
                    const div(
                      classes: 'mt-10 flex flex-wrap items-center gap-4',
                      [
                        CtaButton(
                          label: 'Start a conversation',
                          href: RoutePaths.contact,
                        ),
                      ],
                    ),

                    div(
                      classes: 'mt-12 flex items-center gap-5 border-t '
                          'border-ink-700 pt-8',
                      [
                        for (final social in SiteConfig.socials)
                          a(
                            href: social.url,
                            target: Target.blank,
                            attributes: {
                              'rel': 'me noopener',
                              'aria-label': '${social.label}, ${social.handle}',
                            },
                            classes: 'text-ink-400 transition-colors '
                                'duration-300 hover:text-iris-400',
                            [AppIcons.social(social.label,
                                classes: 'h-[1.15rem] w-[1.15rem]')],
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
