import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/store_badge.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/model/project_model.dart';

/// The featured project, presented **flat**.
///
/// Every other project on the site lives inside a bordered card. This one has
/// no card, no border and no panel: the device mockup stands directly on the
/// section ground beside its copy. That absence is the whole point — after a
/// page of boxes, the one thing without a box is unmistakably the headline.
///
/// Depth comes from three things instead of a frame: a `drop-shadow` that
/// follows the mockup's alpha silhouette, an oversized ghosted wordmark behind
/// it, and a soft accent bloom. See `.showcase-*` in `web/styles.tw.css`.
class ProjectShowcase extends StatelessComponent {
  const ProjectShowcase({
    required this.project,
    this.reversed = false,
    this.compact = false,
    super.key,
  });

  final ProjectModel project;

  /// Mirrors the layout — mockup on the left, copy on the right. Consecutive
  /// showcases alternate, so a page with several of them reads as a zig-zag
  /// rather than as the same block repeated.
  ///
  /// Done with CSS `order` rather than by swapping the markup: the copy stays
  /// first in the DOM either way, so the reading and tab order is always
  /// heading-then-image regardless of which side the image is on.
  final bool reversed;

  /// Teaser density, used on the home page.
  ///
  /// Drops the ruled meta table and trades that space for a larger mockup: the
  /// home section is an invitation, so it should be image-forward and let
  /// `/projects` carry the detail. Same object, two densities — not a second
  /// component to keep in sync.
  final bool compact;

  @override
  Component build(BuildContext context) {
    final mockup = project.mockupImage;

    return div(
      classes: 'grid items-center gap-14 lg:gap-16 '
          '${compact ? 'lg:grid-cols-[0.85fr_1.15fr]' : (reversed ? 'lg:grid-cols-[1.05fr_0.95fr]' : 'lg:grid-cols-[0.95fr_1.05fr]')}',
      [
        // ── Copy ──
        div(
          classes: 'reveal order-last '
              '${reversed ? 'lg:order-2' : 'lg:order-1'}',
          [
            div(
              classes: 'flex items-center gap-3',
              [
                span(
                  classes: 'type-eyebrow font-mono text-iris-400',
                  [Component.text(project.client ?? project.category.label)],
                ),
                const span(classes: 'h-px w-8 bg-ink-600', []),
                span(
                  classes: 'type-eyebrow font-mono text-ink-500',
                  [Component.text(project.status.label)],
                ),
              ],
            ),

            h3(
              classes: 'type-section mt-6 font-display font-extrabold '
                  'text-ink-100',
              [Component.text(project.name)],
            ),

            p(
              classes: 'mt-4 max-w-md text-lg leading-snug text-ink-200',
              [Component.text(project.tagline)],
            ),

            if (project.summary.isNotEmpty)
              p(
                classes: 'mt-6 max-w-md text-sm leading-relaxed text-ink-400',
                [Component.text(project.summary.first)],
              ),

            if (!compact)
              div(
                classes: 'mt-10 max-w-md border-b border-ink-700',
                [
                  if (project.year.isNotEmpty) _meta('Year', project.year),
                  if (project.platforms.isNotEmpty)
                    _meta(
                      'Platform',
                      project.platforms.map((e) => e.label).join('  ·  '),
                    ),
                  _meta('Role', 'Design system · Architecture · Release'),
                  if (project.stack.isNotEmpty)
                    _meta('Stack', project.stack.join('  ·  ')),
                ],
              )
            else
              div(
                classes: 'mt-8 flex flex-wrap gap-2',
                [
                  for (final tech in project.stack.take(4))
                    span(classes: 'pill', [Component.text(tech)]),
                ],
              ),

            if (project.links.isNotEmpty)
              StoreBadgeRow(
                links: project.links,
                product: project.name,
                classes: 'mt-10',
              ),

            div(
              classes: 'mt-10',
              [
                Link(
                  to: RoutePaths.projectDetail(project.slug),
                  classes: 'link-line group inline-flex items-center gap-3 '
                      'text-sm font-medium text-ink-100 transition-colors '
                      'duration-300 hover:text-iris-300',
                  children: [
                    const Component.text('Read the case study'),
                    span(
                      classes: 'transition-transform duration-500 ease-soft '
                          'group-hover:translate-x-1.5',
                      [AppIcons.arrow()],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // ── Mockup ──
        div(
          classes: 'reveal relative flex items-center justify-center '
              '${reversed ? 'lg:order-1' : 'lg:order-2'}',
          [
            // Accent bloom, sized larger than the device so its edge never
            // resolves into a visible circle.
            const div(
              classes: 'bloom pointer-events-none absolute inset-0 -m-12',
              attributes: {'aria-hidden': 'true'},
              [],
            ),

            // Ghosted wordmark. Texture, not a heading — hence aria-hidden and
            // no semantic element.
            div(
              classes: 'pointer-events-none absolute inset-0 flex items-center '
                  'justify-center overflow-hidden',
              attributes: const {'aria-hidden': 'true'},
              [
                span(
                  classes: 'showcase-ghost select-none font-display '
                      'font-extrabold text-ink-100/[0.035]',
                  [Component.text(project.name)],
                ),
              ],
            ),

            if (mockup != null)
              img(
                src: '/$mockup',
                alt: '${project.name} — ${project.tagline}',
                // The featured mockup is the largest paint on this page and
                // sits near the fold, so it is loaded eagerly and prioritised.
                // Intrinsic ratio only — the browser needs *a* ratio to
                // reserve space and avoid a layout shift, and every mockup is
                // authored to the same 4:5 crop.
                attributes: const {
                  'decoding': 'async',
                  'fetchpriority': 'high',
                  'width': '914',
                  'height': '1200',
                },
                classes: 'showcase-device relative w-full '
                    '${compact ? 'max-w-md lg:max-w-xl' : 'max-w-md lg:max-w-lg'}',
              ),
          ],
        ),
      ],
    );
  }

  static Component _meta(String label, String value) => div(
        classes: 'meta-row',
        [
          span(
            classes: 'type-eyebrow font-mono text-ink-500',
            [Component.text(label)],
          ),
          span(
            classes: 'text-sm text-ink-200',
            [Component.text(value)],
          ),
        ],
      );
}
