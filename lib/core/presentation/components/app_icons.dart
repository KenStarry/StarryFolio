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

  // ── Platform marks ───────────────────────────────────────────────────────
  //
  // Rendered in `currentColor` rather than in Apple's and Google's brand
  // colours. Google's Play mark is officially four-colour, but a 20px rainbow
  // glyph is the one thing that would break this page's two-tone discipline,
  // and the badge stays unmistakable on silhouette plus wordmark alone. Swap
  // these for the official coloured badge assets if store guidelines ever
  // need to be followed to the letter.

  static Component apple({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
        '<path d="M16.37 1.43c0 1.14-.42 2.2-1.25 3.03-1 1-2.2 1.57-3.32 1.48-.13-1.1.43-2.27 1.24-3.06.9-.9 2.35-1.53 3.33-1.45zM20.9 17.1c-.5 1.16-.74 1.68-1.39 2.7-.9 1.43-2.17 3.2-3.75 3.22-1.4.01-1.76-.91-3.66-.9-1.9.01-2.3.92-3.7.9-1.58-.02-2.78-1.62-3.68-3.04-2.52-3.98-2.79-8.65-1.23-11.13 1.1-1.76 2.85-2.79 4.49-2.79 1.67 0 2.72.92 4.1.92 1.34 0 2.16-.92 4.09-.92 1.46 0 3.01.8 4.11 2.17-3.61 1.98-3.03 7.14.62 8.87z"/>'
        '</svg>',
      );

  static Component play({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
        '<path d="M3.61 1.81a1.5 1.5 0 00-.36.99v18.4c0 .38.13.72.36.99l.06.06 10.3-10.3v-.24L3.67 1.75l-.06.06z" opacity=".95"/>'
        '<path d="M17.9 15.31l-3.43-3.43v-.25l3.44-3.43.08.04 4.07 2.32c1.16.66 1.16 1.74 0 2.4l-4.07 2.31-.09.04z" opacity=".8"/>'
        '<path d="M17.99 15.26L14.47 11.74 3.61 22.6c.38.4 1.01.45 1.72.05l12.66-7.39" opacity=".9"/>'
        '<path d="M17.99 8.24L5.33 1.02C4.62.62 3.99.67 3.61 1.07l10.86 10.86 3.52-3.69z" opacity=".7"/>'
        '</svg>',
      );

  static Component globe({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<circle cx="12" cy="12" r="9"/>'
        '<path d="M3.5 9h17M3.5 15h17"/>'
        '<path d="M12 3a15 15 0 010 18M12 3a15 15 0 000 18"/>'
        '</svg>',
      );

  static Component monitor({String classes = 'h-6 w-6'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<rect x="2.5" y="3.5" width="19" height="13" rx="2"/>'
        '<path d="M8.5 20.5h7M12 16.5v4"/></svg>',
      );

  static Component compass({String classes = 'h-6 w-6'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<circle cx="12" cy="12" r="9"/>'
        '<path d="M15.6 8.4l-2.05 5.15-5.15 2.05 2.05-5.15z"/></svg>',
      );

  /// Resolves an [AppLinkType.icon] or [ServiceModel.icon] key to its glyph. Falls back rather than
  /// throwing, so a service added with an unknown icon still renders a card.
  static Component byName(String name, {String classes = 'h-6 w-6'}) =>
      switch (name) {
        'device' => device(classes: classes),
        'layers' => layers(classes: classes),
        'rocket' => rocket(classes: classes),
        'monitor' => monitor(classes: classes),
        'compass' => compass(classes: classes),
        'apple' => apple(classes: classes),
        'play' => play(classes: classes),
        'globe' => globe(classes: classes),
        'github' => github(classes: classes),
        'dart' => dart(classes: classes),
        'download' => download(classes: classes),
        'lock' => lock(classes: classes),
        'mail' => mail(classes: classes),
        _ => layers(classes: classes),
      };

  static Component download({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="none" '
        'stroke="currentColor" stroke-width="1.75" stroke-linecap="round" '
        'stroke-linejoin="round" aria-hidden="true">'
        '<path d="M12 3v12"/><path d="m7 10 5 5 5-5"/>'
        '<path d="M4 20h16"/>'
        '</svg>',
      );

  static Component lock({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="none" '
        'stroke="currentColor" stroke-width="1.75" stroke-linecap="round" '
        'stroke-linejoin="round" aria-hidden="true">'
        '<rect x="4" y="10" width="16" height="11" rx="2"/>'
        '<path d="M8 10V7a4 4 0 0 1 8 0v3"/>'
        '</svg>',
      );

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

  /// The Dart wordmark's bird glyph, flattened to one colour. Dart's published
  /// mark is two blues; the palette has no second hue, so the badge takes the
  /// silhouette and lets `currentColor` do the rest — the same treatment the
  /// Apple and Play marks already get.
  static Component dart({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
        '<path d="M6.4 2.6 2.6 6.4v9.9l3.3 3.3h9.9l3.8-3.8V5.9L16 2.6H6.4zm.5 2h8.6l2.6 2.6v8.9l-2.6 2.6H6.9L4.6 15.4V6.9L6.9 4.6z"/>'
        '<path d="M8.4 7.2v7.1l1.9 1.9h5.2V9.1l-1.9-1.9H8.4z"/>'
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

  static Component whatsapp({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
        '<path d="M17.47 14.38c-.3-.15-1.76-.87-2.03-.97-.27-.1-.47-.15-.67.15-.2.3-.77.97-.94 1.17-.17.2-.35.22-.65.07-.3-.15-1.26-.46-2.4-1.48-.89-.79-1.49-1.77-1.66-2.07-.17-.3-.02-.46.13-.61.14-.13.3-.35.45-.52.15-.17.2-.3.3-.5.1-.2.05-.37-.02-.52-.08-.15-.67-1.61-.92-2.21-.24-.58-.49-.5-.67-.51h-.57c-.2 0-.52.07-.79.37-.27.3-1.04 1.01-1.04 2.470 1.46 1.06 2.87 1.21 3.07.15.2 2.09 3.2 5.07 4.49.71.3 1.26.49 1.69.63.71.22 1.36.19 1.87.12.57-.09 1.76-.72 2.01-1.41.25-.7.25-1.29.17-1.42-.07-.13-.27-.2-.57-.35z"/>'
        '<path d="M12.04 2C6.58 2 2.13 6.45 2.13 11.91c0 1.75.46 3.46 1.32 4.96L2 22l5.25-1.38a9.87 9.87 0 004.79 1.22h.01c5.46 0 9.91-4.45 9.91-9.91 0-2.65-1.03-5.14-2.9-7.01A9.82 9.82 0 0012.04 2zm0 18.02h-.01a8.2 8.2 0 01-4.18-1.15l-.3-.18-3.11.82.83-3.04-.2-.31a8.17 8.17 0 01-1.26-4.37c0-4.54 3.7-8.24 8.24-8.24 2.2 0 4.27.86 5.83 2.42a8.2 8.2 0 012.41 5.83c0 4.54-3.7 8.22-8.25 8.22z"/>'
        '</svg>',
      );

  static Component coffee({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" $_s>'
        '<path d="M3.5 8.5h13v6a4.5 4.5 0 01-4.5 4.5H8a4.5 4.5 0 01-4.5-4.5z"/>'
        '<path d="M16.5 10h1.75a2.75 2.75 0 010 5.5H16.5"/>'
        '<path d="M6.5 2.5v3M10 2.5v3M13.5 2.5v3"/>'
        '<path d="M2.5 21.5h15"/></svg>',
      );

  /// Brand mark for a [SocialLink.label]. Falls back to an outbound arrow so an
  /// unrecognised network still renders a sensible affordance.
  static Component social(String label, {String classes = 'h-4 w-4'}) =>
      switch (label.toLowerCase()) {
        'github' => github(classes: classes),
        'linkedin' => linkedin(classes: classes),
        'x' || 'twitter' => x(classes: classes),
        'whatsapp' => whatsapp(classes: classes),
        'mail' => mail(classes: classes),
        'coffee' => coffee(classes: classes),
        _ => arrowUpRight(classes: classes),
      };
}
