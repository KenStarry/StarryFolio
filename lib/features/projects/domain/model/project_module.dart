import 'project_feature.dart';

/// A distinct half of a product, given its own band on the case study.
///
/// Exists because some products are not one thing. HealthX is two: a
/// transactional *Clinical* world and a reflective *Bloom* world, sharing one
/// account. Flattening those into a single feature list would lose the very
/// thing that makes the product interesting, so a case study can carry modules
/// instead — each with its own framing, surfaces and spotlights.
///
/// A project with a single coherent feature set does not need this and can go
/// on using `ProjectModel.features` directly.
class ProjectModule {
  const ProjectModule({
    required this.name,
    required this.tagline,
    required this.blurb,
    this.kind = 'World',
    this.accent,
    this.badge,
    this.conceptual = false,
    this.surfaces = const [],
    this.features = const [],
  });

  final String name;

  /// What sort of thing this is, used as the band's marker — `World 01`.
  /// HealthX's two lenses are worlds; its web portal is a `Surface`, because
  /// calling a browser build a third world would misdescribe the product.
  final String kind;

  /// The module's own line — Clinical's *Care, delivered*.
  final String tagline;

  final String blurb;

  /// The product's real accent for this module, as a hex string, rendered as a
  /// small swatch.
  ///
  /// This is **content, not theming**: it documents what colour the module uses
  /// in the app. It is shown as a dot and a hex label, never applied to any
  /// control — the site stays two-tone plus iris, and a case study describing a
  /// green product must not turn the page green.
  final String? accent;

  /// Shipping state, e.g. `In build` or `Web`. Null means shipped.
  final String? badge;

  /// Designed but not shipped. Dials the spotlights back and adds a `Concept`
  /// chip.
  ///
  /// Deliberately separate from [badge]: a module can be badged because it runs
  /// somewhere different — the web portal is badged `Web` and is very much
  /// built — so inferring "unbuilt" from the presence of a badge would mute a
  /// shipped surface.
  final bool conceptual;

  /// The surfaces this module owns, shown as pills.
  final List<String> surfaces;

  /// Spotlights. Features carrying images render as full alternating bands;
  /// a module with no images at all renders them as a card grid instead.
  final List<ProjectFeature> features;

  /// Whether anything here has a device render to show.
  ///
  /// Drives presentation, not status. A module can be fully shipped and still
  /// have nothing to show — the web portal has no phone mockup and would be
  /// misrepresented by one — so it takes the card grid for the same reason an
  /// unbuilt module does.
  bool get hasRenders => features.any((f) => f.image != null);

  factory ProjectModule.fromMap(Map<String, dynamic> map) => ProjectModule(
        name: map['name']?.toString() ?? '',
        kind: map['kind']?.toString() ?? 'World',
        tagline: map['tagline']?.toString() ?? '',
        blurb: map['blurb']?.toString() ?? '',
        accent: map['accent']?.toString(),
        badge: map['badge']?.toString(),
        conceptual: map['conceptual'] == true,
        surfaces: switch (map['surfaces']) {
          final List<Object?> raw => [for (final s in raw) s.toString()],
          _ => const [],
        },
        features: switch (map['features']) {
          final List<Object?> raw => [
              for (final entry in raw)
                if (entry is Map<String, dynamic>) ProjectFeature.fromMap(entry),
            ],
          _ => const [],
        },
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'kind': kind,
        'tagline': tagline,
        'blurb': blurb,
        if (accent != null) 'accent': accent,
        if (badge != null) 'badge': badge,
        if (conceptual) 'conceptual': true,
        'surfaces': surfaces,
        'features': [for (final f in features) f.toMap()],
      };
}
