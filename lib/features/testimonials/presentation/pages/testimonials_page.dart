import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/page_header.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/model/testimonial_model.dart';
import '../components/featured_testimonial.dart';
import '../components/testimonial_card.dart';
import '../components/testimonial_form.dart';
import '../components/testimonial_overlay.dart';

/// Everything anyone has said, and the way to add to it.
///
/// An [AsyncStatelessComponent] so the repository is awaited *during*
/// pre-rendering: every quote is in the generated HTML in full, including the
/// ones a visitor sees clamped to four lines. That is the whole reason the
/// truncation is CSS — see [TestimonialCard].
///
/// The page is deliberately reachable at a top-level path even though it sits
/// under About in the navigation. A testimonial's value is that it can be
/// linked to, and every card carries its own anchor so a contributor can send
/// somebody straight to what they wrote.
///
/// ## Nothing here is a rating
///
/// No stars, no score, no "5.0 from 12 reviews". Nobody was asked for a
/// number, so inventing one to decorate the page would be fabricating data —
/// and an aggregate rating in the structured data is the classic rich-result
/// abuse. The `Review` schema this page emits carries authors and words only.
class TestimonialsPage extends AsyncStatelessComponent {
  const TestimonialsPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.testimonials.getTestimonials();

    return result.fold(
      (error) => Component.fragment([
        const _Meta(),
        SectionBlock(
          eyebrow: 'Testimonials',
          heading: 'In their words',
          isPageHeading: true,
          children: [ErrorNotice(message: error)],
        ),
      ]),
      (testimonials) {
        // Placeholders are kept out of the structured data entirely. A
        // labelled sample on the page is honest; the same text handed to a
        // crawler as a `Review` is not, because the label does not travel
        // with it.
        final real = [
          for (final t in testimonials)
            if (!t.draft) t,
        ];
        final hasDraft = testimonials.any((t) => t.draft);

        // At most one entry leads. If none is flagged, the first does — a page
        // whose largest element is missing reads as a layout bug. Resolved
        // once here rather than inside the tree, so the featured band and the
        // grid's exclusion cannot disagree about which one it is.
        final featured = testimonials.isEmpty
            ? null
            : testimonials.firstWhere(
                (t) => t.featured,
                orElse: () => testimonials.first,
              );
        final rest = [
          for (final t in testimonials)
            if (t != featured) t,
        ];

        return Component.fragment([
          const _Meta(),

          if (real.isNotEmpty)
            StructuredData(
              id: 'ld-reviews',
              SchemaOrg.reviews(
                items: [
                  for (final t in real)
                    (
                      quote: t.quote,
                      author: t.name,
                      role: t.attribution,
                      sameAs: [for (final l in t.links) l.url],
                    ),
                ],
              ),
            ),

          StructuredData(
            id: 'ld-breadcrumbs',
            SchemaOrg.breadcrumbs(const [
              (label: 'Home', path: RoutePaths.home),
              (label: 'Testimonials', path: RoutePaths.testimonials),
            ]),
          ),

          _Header(
            count: testimonials.length,
            named: testimonials.where((t) => t.name.isNotEmpty).length,
          ),

          if (featured == null)
            const _Empty()
          else ...[
            FeaturedTestimonial(testimonial: featured),

            // Renders nothing while the featured quote is the only one, rather
            // than printing a heading over an empty row.
            _Wall(testimonials: rest, hasDraft: hasDraft),
          ],

          const _Invite(),

          // Every overlay lives at the end of the document, outside the grid.
          //
          // `:target` shows whichever one the URL names, and a panel nested
          // inside its own card would be clipped by the card's bounds and
          // trapped under its stacking context. One flat list at the root is
          // the only arrangement where a fixed, centred panel can actually
          // cover the viewport.
          // `rest`, not every testimonial. The featured quote is already
          // printed in full further up the page, so an overlay for it would be
          // markup nothing can reach — and a "read in full" that reveals what
          // is visible two screens above is a control that lies.
          for (final t in rest)
            TestimonialOverlay(
              testimonial: t,
              closeHref: RoutePaths.testimonials,
            ),
        ]);
      },
    );
  }
}

class _Header extends StatelessComponent {
  const _Header({required this.count, required this.named});

  final int count;

  /// How many carry a real attribution. Always equal to [count] — the model
  /// requires a name and a role — which is exactly why it is worth stating.
  final int named;

  @override
  Component build(BuildContext context) {
    return PageHeader(
      trail: 'Testimonials',
      ghost: 'Said',
      path: RoutePaths.testimonials,
      meta: count == 1 ? '1 so far' : '$count so far',
      title: 'What it is like',
      titleTail: 'on the other side.',
      lead: 'Unedited, and attributed. Every quote here is a real person who '
          'put their name next to it, which is the only thing that makes a '
          'testimonial worth reading.',
      // The same four ruled cells every other page opens with. Two of them
      // are 100% on purpose: "nobody is anonymous" and "nothing was reworded"
      // are the page's entire argument, and stating them as figures beside
      // the count is what stops the header being a heading and a paragraph.
      facts: [
        (value: count.toString().padLeft(2, '0'), label: 'Notes'),
        (
          value: named == count && count > 0 ? '100%' : '—',
          label: 'Named',
        ),
        (value: '100%', label: 'Unedited'),
        (value: '5+', label: 'Years covered'),
      ],
      actions: const [
        CtaButton(
          label: 'Add yours',
          href: '${RoutePaths.testimonials}#add-yours',
          anchor: true,
        ),
        CtaButton(
          label: 'See the work',
          href: RoutePaths.projects,
          variant: CtaVariant.outline,
        ),
      ],
    );
  }
}

/// The remaining quotes, as a grid.
class _Wall extends StatelessComponent {
  const _Wall({required this.testimonials, required this.hasDraft});

  final List<TestimonialModel> testimonials;
  final bool hasDraft;

  @override
  Component build(BuildContext context) {
    // Nothing left once the featured quote is lifted out. Renders away
    // entirely rather than showing a heading over an empty grid — the same
    // rule `TestimonialBand` follows on the home page.
    if (testimonials.isEmpty) return const div([]);

    return section(
      classes: 'bg-ink-900 py-20 sm:py-24',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            if (hasDraft)
              const div(
                classes: 'reveal mb-10 flex flex-wrap items-center gap-4',
                [
                  Eyebrow('Note'),
                  span(
                    classes: 'border border-ink-600 px-2.5 py-1 font-mono '
                        'text-[10px] uppercase tracking-wider text-ink-400',
                    [Component.text('Sample content')],
                  ),
                ],
              ),

            // A masonry-ish grid rather than a rigid one: quotes differ in
            // length by a factor of five, and forcing them to a common height
            // either truncates the long ones or pads the short ones with a
            // band of empty card.
            div(
              classes: 'stagger grid gap-6 sm:grid-cols-2 lg:grid-cols-3',
              [
                for (final t in testimonials)
                  TestimonialCard(testimonial: t),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Shown only when the repository succeeded and returned nothing.
///
/// The home band renders nothing at all in this case, which is right there —
/// a section announcing it has no social proof is worse than no section. Here
/// it is the opposite: this page *is* the section, and an empty page with no
/// explanation reads as broken rather than as new.
class _Empty extends StatelessComponent {
  const _Empty();

  @override
  Component build(BuildContext context) {
    return const section(
      classes: 'bg-ink-900 py-20 sm:py-24',
      [
        div(
          classes: 'mx-auto w-full max-w-2xl px-6 sm:px-8',
          [
            div(
              classes: 'reveal border border-dashed border-ink-700 px-7 py-12 '
                  'text-center',
              [
                p(
                  classes: 'font-display text-xl font-bold text-ink-100',
                  [Component.text('Nothing here yet.')],
                ),
                p(
                  classes: 'mx-auto mt-4 max-w-sm text-sm leading-relaxed '
                      'text-ink-400',
                  [
                    Component.text(
                      'This page fills up one note at a time. If we have '
                      'worked together, you could be the first.',
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

/// The submission band.
class _Invite extends StatelessComponent {
  const _Invite();

  @override
  Component build(BuildContext context) {
    return const section(
      id: 'add-yours',
      classes: 'scroll-mt-24 bg-ink-800 py-24 sm:py-32',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'grid gap-14 lg:grid-cols-[0.9fr_1.1fr] lg:gap-20',
              [
                div(
                  classes: 'reveal',
                  [
                    Eyebrow('Add yours'),
                    h2(
                      classes: 'type-section mt-5 font-display font-bold '
                          'text-ink-100',
                      [
                        Component.text('Worked with me?'),
                        br(),
                        span(
                          classes: 'font-semibold text-ink-400',
                          [Component.text('Say the thing.')],
                        ),
                      ],
                    ),
                    p(
                      classes: 'mt-6 max-w-md text-sm leading-relaxed '
                          'text-ink-400',
                      [
                        Component.text(
                          'Client, teammate, someone who watched me lose a '
                          'weekend to a sheet animation: if we have built '
                          'something together, I would love to hear how it '
                          'went. Specifics beat superlatives every time.',
                        ),
                      ],
                    ),
                    p(
                      classes: 'mt-6 max-w-md text-sm leading-relaxed '
                          'text-ink-500',
                      [
                        Component.text(
                          'Would rather just email it? '
                          '${SiteConfig.email} works too.',
                        ),
                      ],
                    ),
                  ],
                ),

                div(classes: 'reveal', [TestimonialForm()]),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Meta extends StatelessComponent {
  const _Meta();

  @override
  Component build(BuildContext context) => const PageMeta(
        path: RoutePaths.testimonials,
        title: 'Testimonials · What clients say about ${SiteConfig.name}',
        description: 'What clients and teammates say about working with '
            '${SiteConfig.name}: unedited, attributed, and linked back to the '
            'people who said it.',
      );
}
