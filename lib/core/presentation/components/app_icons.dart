import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Inline SVG icons. Kept as raw markup so they inherit `currentColor` and cost
/// zero extra network requests.
///
/// Deliberately a small set at one stroke weight. The previous pass had three
/// weights and a mix of filled and stroked glyphs, which is what made the icons
/// read as assembled from different sets.
class AppIcons {
  const AppIcons._();

  static const String _s =
      'fill="none" stroke="currentColor" stroke-width="1.5" '
      'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"';

  // ── Direction ────────────────────────────────────────────────────────────

  static Component arrow({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<path d="M4 12h15M13 6l6 6-6 6"/></svg>',
      );

  static Component arrowUpRight({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<path d="M7 17L17 7M8 7h9v9"/></svg>',
      );

  static Component chevronDown({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<path d="M6 9l6 6 6-6"/></svg>',
      );

  // ── Controls ─────────────────────────────────────────────────────────────

  static Component menu({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<path d="M4 8h16M4 16h11"/></svg>',
      );

  static Component close({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<path d="M6 6l12 12M18 6L6 18"/></svg>',
      );

  // ── Services ─────────────────────────────────────────────────────────────

  static Component device({String classes = 'h-6 w-6'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<rect x="6.5" y="2.5" width="11" height="19" rx="2.5"/>'
        '<path d="M10.5 18.5h3"/></svg>',
      );

  static Component layers({String classes = 'h-6 w-6'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<path d="M12 3l8.5 4.5L12 12 3.5 7.5z"/>'
        '<path d="M3.5 12L12 16.5 20.5 12"/>'
        '<path d="M3.5 16.5L12 21l8.5-4.5"/></svg>',
      );

  static Component rocket({String classes = 'h-6 w-6'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<path d="M12 2.5c3 2 4.7 5.2 4.7 8.9L14.4 14H9.6l-2.3-2.6c0-3.7 1.7-6.9 4.7-8.9z"/>'
        '<circle cx="12" cy="9.5" r="1.8"/>'
        '<path d="M9.6 14.2L8 18l2.4-1M14.4 14.2L16 18l-2.4-1"/></svg>',
      );

  /// Resolves a [ServiceModel.icon] key to its glyph. Falls back rather than
  /// throwing, so a service added with an unknown icon still renders a card.
  static Component byName(String name, {String classes = 'h-6 w-6'}) =>
      switch (name) {
        'device' => device(classes: classes),
        'layers' => layers(classes: classes),
        'rocket' => rocket(classes: classes),
        _ => layers(classes: classes),
      };

  // ── Brand marks ──────────────────────────────────────────────────────────
  //
  // Filled, because these are logos rather than UI glyphs and their published
  // forms are solid. They are the one deliberate exception to the stroke rule.

  static Component mail({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<rect x="2.5" y="4.5" width="19" height="15" rx="2"/>'
        '<path d="M3 7l8.1 5.4a1.6 1.6 0 001.8 0L21 7"/></svg>',
      );

  static Component github({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
        '<path d="M12 .8a11.2 11.2 0 00-3.54 21.83c.56.1.77-.24.77-.54v-2.1c-3.12.68-3.78-1.32-3.78-1.32-.51-1.3-1.25-1.65-1.25-1.65-1.02-.7.08-.68.08-.68 1.13.08 1.72 1.16 1.72 1.16 1 1.72 2.63 1.22 3.27.94.1-.73.39-1.22.71-1.5-2.49-.29-5.11-1.25-5.11-5.55 0-1.23.44-2.23 1.16-3.02-.12-.28-.5-1.42.11-2.96 0 0 .94-.3 3.1 1.16a10.7 10.7 0 015.64 0c2.15-1.46 3.1-1.16 3.1-1.16.61 1.54.22 2.68.11 2.96.72.79 1.15 1.79 1.15 3.02 0 4.31-2.62 5.26-5.12 5.54.4.35.76 1.03.76 2.08v3.09c0 .3.2.65.78.54A11.2 11.2 0 0012 .8z"/>'
        '</svg>',
      );

  static Component linkedin({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
        '<path d="M4.98 3.5a2.5 2.5 0 11-.02 5 2.5 2.5 0 01.02-5zM3 9h4v12H3zM10 9h3.8v1.65h.05c.53-.95 1.83-1.95 3.76-1.95 4.02 0 4.76 2.5 4.76 5.76V21h-4v-5.6c0-1.34-.03-3.06-1.9-3.06-1.9 0-2.19 1.45-2.19 2.96V21h-4z"/>'
        '</svg>',
      );

  static Component x({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
        '<path d="M17.53 3h3.05l-6.67 7.62L21.75 21h-6.13l-4.8-6.28L5.32 21H2.27l7.13-8.15L2.25 3h6.29l4.34 5.74zm-1.07 16.2h1.69L7.62 4.71H5.8z"/>'
        '</svg>',
      );

  /// Brand mark for a [SocialLink.label]. Falls back to an outbound arrow so an
  /// unrecognised network still renders a sensible affordance.
  static Component social(String label, {String classes = 'h-4 w-4'}) =>
      switch (label.toLowerCase()) {
        'github' => github(classes: classes),
        'linkedin' => linkedin(classes: classes),
        'x' || 'twitter' => x(classes: classes),
        _ => arrowUpRight(classes: classes),
      };
}
