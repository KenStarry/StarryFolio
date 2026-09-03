import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../projects/domain/model/project_model.dart';
import '../../../projects/presentation/components/project_mini_card.dart';
import '../../domain/model/service_model.dart';

/// One service, given a band on `/services`.
///
/// ## The deliverables lead
///
/// They used to sit in a bordered panel off to one side — the most generic
/// container this site owns — while the copy took the wide column. That had it
/// backwards. "A replayable write queue" is what somebody is actually buying;
/// "mobile development" is the category it files under. So the deliverables
/// take the wide column, numbered and ruled, set like a specification, and the
/// prose narrows to a column beside them.
///
/// ## No zig-zag
///
/// Consecutive bands used to mirror. Alternation makes a page feel ordered but
/// it cannot make any part of it matter more than another, and six mirrored
/// bands read as a list that is trying hard. Every band now has the same
/// anatomy and the ground alternates alone, which is quieter and lets the
/// content differ instead of the layout.
///
/// ## It shows the work
///
/// Where a service has shipped examples, the band closes on two of them and a
/// way through to the collection page holding the rest. Where it has none —
/// nobody has a gallery of release engineering — the deliverables simply take
/// the band. That asymmetry is driven by real data rather than smoothed over.
///
/// ## It still closes itself
///
/// Each band keeps its own question — "Need an app?" — because a reader sold
/// on band three should not have to scroll past three more to act on it, and
/// the mail subject arrives pre-filled so the first reply already knows the
/// topic. What changed is the weight: six solid buttons down a page is six
/// demands, so it is a quiet link now and the page's one real button waits at
/// the end.
class ServiceBand extends StatelessComponent {
  const ServiceBand({
    required this.service,
    required this.index,
    required this.raised,
    required this.timeline,
    this.work = const [],
    this.collectionPath = '',
    this.collectionLabel = '',
    this.collectionCount = 0,
    super.key,
  });

  final ServiceModel service;

  /// Two shipped examples of this service, resolved by the page. Empty where
  /// the service has no gallery — nobody has a portfolio of release
  /// engineering, and inventing one would be worse than the gap.
  final List<ProjectModel> work;

  /// Where "view all" goes, and what it says. Passed in rather than derived
  /// so the band stays free of the projects *domain* while still linking into
  /// it — the page owns that resolution.
  final String collectionPath;
  final String collectionLabel;
  final int collectionCount;

  /// One-based position, rendered as the marker and the ghost numeral.
  final int index;

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
      classes: 'svc-band group relative isolate scroll-mt-24 overflow-hidden '
          '$timeline ${raised ? 'bg-ink-800' : 'bg-ink-900'} py-20 sm:py-24',
      [
        // The numeral, at band scale. Texture, never content — it repeats the
        // marker printed a few pixels above it.
        GhostText(
          number,
          faint: true,
          classes: GhostText.bandCorner,
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid gap-12 lg:grid-cols-[0.85fr_1.15fr] lg:gap-20',
              [
                // ── What it is ──
                div(
                  classes: 'reveal',
                  [
                    div(
                      classes: 'flex items-center gap-4',
                      [
                        span(
                          classes: 'svc-mark',
                          [AppIcons.byName(service.icon, classes: 'h-6 w-6')],
                        ),
                        span(
                          classes: 'type-eyebrow font-mono text-ink-500',
                          [Component.text(number)],
                        ),
                      ],
                    ),

                    h2(
                      classes: 'type-section mt-7 font-display font-extrabold '
                          'text-ink-100',
                      _titleLines(service.title),
                    ),

                    p(
                      classes: 'mt-6 max-w-md text-sm leading-relaxed '
                          'text-ink-400 sm:text-[0.9375rem]',
                      [
                        Component.text(
                          service.detail.isEmpty
                              ? service.blurb
                              : service.detail,
                        ),
                      ],
                    ),

                    // The stack as a mono line rather than pills. Six rows of
                    // pills down a page is a lot of capsules, and these are
                    // tools rather than categories — a list reads truer.
                    if (service.tags.isNotEmpty)
                      p(
                        classes: 'mt-7 font-mono text-[11px] leading-relaxed '
                            'text-ink-500',
                        [Component.text(service.tags.join('  ·  '))],
                      ),
                  ],
                ),

                // ── What you get ──
                div(
                  classes: 'reveal',
                  [
                    const p(
                      classes: 'type-eyebrow font-mono text-ink-500',
                      [Component.text('What you get')],
                    ),

                    div(
                      classes: 'mt-5',
                      [
                        for (final (i, item) in service.deliverables.indexed)
                          div(
                            classes: 'deliverable',
                            [
                              span(
                                classes: 'deliverable-num',
                                attributes: const {'aria-hidden': 'true'},
                                [
                                  Component.text(
                                    (i + 1).toString().padLeft(2, '0'),
                                  ),
                                ],
                              ),
                              span(
                                classes: 'deliverable-text',
                                [Component.text(item)],
                              ),
                            ],
                          ),
                      ],
                    ),

                    // The band's own close, set quiet.
                    div(
                      classes: 'mt-9 flex flex-wrap items-baseline gap-x-5 '
                          'gap-y-2',
                      [
                        p(
                          classes: 'font-display text-base font-bold '
                              'tracking-tight text-ink-100',
                          [Component.text(service.ctaQuestion)],
                        ),
                        a(
                          href: mailto,
                          classes: 'link-line group/cta inline-flex '
                              'items-center gap-2.5 text-sm font-medium '
                              'text-ink-300 transition-colors duration-300 '
                              'hover:text-iris-300',
                          [
                            const Component.text('Start there'),
                            span(
                              classes: 'transition-transform duration-500 '
                                  'ease-soft group-hover/cta:translate-x-1',
                              [AppIcons.arrow(classes: 'h-4 w-4')],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // ── What it looks like shipped ──
            //
            // The page had no images at all while the rest of the site is
            // full of device mockups, which is most of why it read as a
            // document rather than a portfolio.
            //
            // Two real builds per service, and a way through to the rest.
            //
            // These were briefly full device renders standing on the section
            // ground, on the theory that phones under `Mobile` and laptops
            // under `Web` would make each band feel like its own place. They
            // did not: at strip scale the renders read as loose clutter where
            // the cards read as a contained set, and the band lost the tidy
            // foot it closes on. Cards it is.
            if (work.isNotEmpty) ...[
              const div(classes: 'divider-quiet mt-14', []),
              div(
                classes: 'reveal mt-8',
                [
                  div(
                    classes: 'flex flex-wrap items-baseline justify-between '
                        'gap-4',
                    [
                      const p(
                        classes: 'type-eyebrow font-mono text-ink-500',
                        [Component.text('Shipped with this')],
                      ),
                      if (collectionPath.isNotEmpty)
                        Link(
                          to: collectionPath,
                          classes: 'link-line group/all inline-flex '
                              'items-center gap-2.5 text-sm text-ink-300 '
                              'transition-colors duration-300 '
                              'hover:text-iris-300',
                          children: [
                            Component.text(
                              collectionCount > work.length
                                  ? 'All $collectionCount $collectionLabel'
                                  : 'See the $collectionLabel',
                            ),
                            span(
                              classes: 'transition-transform duration-500 '
                                  'ease-soft group-hover/all:translate-x-1',
                              [AppIcons.arrow(classes: 'h-4 w-4')],
                            ),
                          ],
                        ),
                    ],
                  ),

                  div(
                    classes: 'mt-5 grid gap-3 sm:grid-cols-2',
                    [
                      for (final project in work)
                        ProjectMiniCard(project: project),
                    ],
                  ),
                ],
              ),
            ],
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
