import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../domain/model/service_model.dart';

/// One service, given a full band on `/services`.
///
/// A service has no screenshot to show, so the visual anchor has to come from
/// somewhere else: an oversized ghosted numeral behind the copy, the icon at
/// display size, and a ruled deliverables panel. That is the deliberate
/// difference from `/projects`, where a device mockup does that work.
///
/// Each band closes with its own question — "Need an app?" — rather than
/// deferring every enquiry to one contact section at the foot of the page. A
/// reader who is sold on band three should not have to scroll past three more
/// to act on it, and the mail subject arrives pre-filled with the service, so
/// the first reply already knows what it is about.
class ServiceBand extends StatelessComponent {
  const ServiceBand({
    required this.service,
    required this.index,
    required this.reversed,
    required this.raised,
    required this.timeline,
    super.key,
  });

  final ServiceModel service;

  /// One-based position, rendered as the `01` marker and the ghost numeral.
  final int index;

  /// Mirrors the layout so consecutive bands zig-zag rather than repeat.
  ///
  /// Uses CSS `order`, not swapped markup — the copy stays first in the DOM
  /// either way, so reading and tab order never diverge from the visual.
  final bool reversed;

  final bool raised;

  /// `tl-N` utility naming this band's view-timeline, which the matching rail
  /// dot animates on.
  final String timeline;

  @override
  Component build(BuildContext context) {
    final number = index.toString().padLeft(2, '0');

    // Pre-fills the subject so the first reply already knows the topic.
    final mailto = 'mailto:${SiteConfig.email}'
        '?subject=${Uri.encodeComponent('${service.plainTitle} enquiry')}';

    return section(
      id: service.slug,
      classes: '$timeline relative overflow-hidden '
          '${raised ? 'bg-ink-800' : 'bg-ink-900'} py-20 sm:py-28',
      [
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid items-center gap-14 lg:gap-20 '
                  '${reversed ? 'lg:grid-cols-[0.9fr_1.1fr]' : 'lg:grid-cols-[1.1fr_0.9fr]'}',
              [
                // ── Copy ──
                div(
                  classes: 'reveal relative '
                      '${reversed ? 'lg:order-2' : 'lg:order-1'}',
                  [
                    // Ghost numeral — the motif, at band scale. Texture, never
                    // content, so it is hidden from assistive tech.
                    div(
                      classes: 'pointer-events-none absolute -left-4 -top-24 '
                          '-z-10 select-none font-display font-extrabold '
                          'leading-none tracking-tighter text-ink-100/[0.035] '
                          'text-[clamp(7rem,16vw,13rem)]',
                      attributes: const {'aria-hidden': 'true'},
                      [Component.text(number)],
                    ),

                    div(
                      classes: 'flex items-center gap-3',
                      [
                        span(
                          classes: 'text-iris-400',
                          [AppIcons.byName(service.icon, classes: 'h-6 w-6')],
                        ),
                        const span(classes: 'h-px w-8 bg-ink-600', []),
                        span(
                          classes: 'type-eyebrow font-mono text-ink-500',
                          [Component.text('Service $number')],
                        ),
                      ],
                    ),

                    h2(
                      classes: 'type-section mt-6 font-display font-extrabold '
                          'text-ink-100',
                      _titleLines(service.title),
                    ),

                    p(
                      classes: 'mt-6 max-w-lg text-base leading-relaxed '
                          'text-ink-300',
                      [
                        Component.text(
                          service.detail.isEmpty ? service.blurb : service.detail,
                        ),
                      ],
                    ),

                    if (service.tags.isNotEmpty)
                      div(
                        classes: 'mt-8 flex flex-wrap gap-2',
                        [
                          for (final tag in service.tags)
                            span(classes: 'pill', [Component.text(tag)]),
                        ],
                      ),
                  ],
                ),

                // ── Deliverables + CTA ──
                div(
                  classes: 'reveal '
                      '${reversed ? 'lg:order-1' : 'lg:order-2'}',
                  [
                    div(
                      classes: 'border border-ink-700 bg-ink-850 p-7 sm:p-8',
                      [
                        const p(
                          classes: 'type-eyebrow font-mono text-ink-500',
                          [Component.text("What you get")],
                        ),
                        const div(classes: 'divider mt-5', []),

                        ul(
                          classes: 'mt-6 space-y-4',
                          [
                            for (final item in service.deliverables)
                              li(
                                classes: 'flex gap-4 text-sm leading-relaxed '
                                    'text-ink-300',
                                [
                                  const span(
                                    classes: 'mt-2 h-px w-4 shrink-0 '
                                        'bg-iris-500',
                                    [],
                                  ),
                                  Component.text(item),
                                ],
                              ),
                          ],
                        ),

                        const div(classes: 'divider-quiet mt-8', []),

                        // The band's own close.
                        div(
                          classes: 'mt-7',
                          [
                            p(
                              classes: 'font-display text-xl font-bold '
                                  'tracking-tight text-ink-100',
                              [Component.text(service.ctaQuestion)],
                            ),
                            div(
                              classes: 'mt-5',
                              [
                                CtaButton(
                                  label: 'Start the conversation',
                                  href: mailto,
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
            ),
          ],
        ),
      ],
    );
  }

  /// Splits authored newlines into `<br>`-separated text, so a title sets as a
  /// deliberate block rather than wrapping wherever the container ends.
  static List<Component> _titleLines(String title) {
    final lines = title.split('\n');
    return [
      for (final (i, line) in lines.indexed) ...[
        if (i > 0) const br(),
        Component.text(line),
      ],
    ];
  }
}
