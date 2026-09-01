/// One credential, for the education band on `/about`.
///
/// Separate from `ExperienceModel` rather than a `kind` on it: an education
/// entry has no metrics, no progression and no shipped work, and branching one
/// model on a discriminator would leave half its fields dead in every
/// instance. They are also *presented* differently on purpose — a job is a
/// band of evidence, a credential is a plate.
///
/// [draft] behaves as it does everywhere on this site: while it is set, the
/// surface admits in place that the details are authored rather than
/// confirmed.
class EducationModel {
  const EducationModel({
    required this.slug,
    required this.qualification,
    required this.institution,
    required this.period,
    this.kind = '',
    this.honours = '',
    this.location = '',
    this.note = '',
    this.focus = const [],
    this.crest,
    this.crestWidth = 512,
    this.crestHeight = 464,
    this.draft = false,
  });

  final String slug;

  /// `BSc Computer Science`. **Without the honours** — see [honours].
  final String qualification;

  final String institution;

  /// Human range — `2016 - 2019`, or a single award year.
  final String period;

  /// What sort of credential this is: `Degree`, `Secondary`. Rendered as the
  /// plate's eyebrow, so a reader placing two credentials side by side does
  /// not have to infer which is which from the institution's name.
  final String kind;

  /// `First Class Honours`, and only that.
  ///
  /// Split out of [qualification] because the two are typographically
  /// different things: the qualification is the credential and the honours is
  /// a grade on it. Run together on one line they read as an unusually long
  /// degree title, and the distinction a reader actually cares about is lost
  /// in the middle of it.
  final String honours;

  final String location;

  /// One line on what it was for. Optional: a credential that needs a
  /// paragraph of justification is being asked to carry too much.
  final String note;

  /// Subjects worth naming.
  final List<String> focus;

  /// Path under `web/` to a **stencil** of the institution's mark — an image
  /// carrying alpha only, no colour, so `currentColor` can be painted through
  /// it. See the crest note in CLAUDE.md: that is the only way a two-colour
  /// third-party logo can enter a palette of two tones and no accent hue.
  ///
  /// Null draws a seal from the institution's initial instead. That is a
  /// deliberate fallback rather than a placeholder — a mark nobody has cleared
  /// for use is worse than a letter, and the two occupy the same box.
  final String? crest;

  /// Intrinsic shape of [crest], driving the box that holds it.
  ///
  /// **Shape is a field, not an assumption** — the same rule
  /// `ProjectModel.mockupWidth/Height` follows, and for the same reason. The
  /// defaults are the MMUST lockup (512x464, landscape at 1.10) because it was
  /// the only crest for a while; Starehe's is a portrait shield at 0.84, and
  /// forcing it into a landscape box would letterbox it to two-thirds the size
  /// every other mark is drawn at.
  ///
  /// Only the ratio is used. The seal and the watermark each fix a height and
  /// derive their width from it, so two crests of different proportions sit on
  /// a shared baseline the way seals on a page do.
  final int crestWidth;
  final int crestHeight;

  /// Width of the crest's box at a given height, in the same unit.
  ///
  /// Rounded to two decimals: the raw ratio prints fifteen digits of precision
  /// into an inline style for a difference no display can resolve.
  String crestBoxWidth(double height) {
    if (crestHeight == 0) return height.toStringAsFixed(2);
    return (height * crestWidth / crestHeight).toStringAsFixed(2);
  }

  /// The details are authored, not verified.
  final bool draft;

  /// The institution's initial, for the drawn seal.
  String get initial =>
      institution.isEmpty ? '·' : institution.substring(0, 1).toUpperCase();

  factory EducationModel.fromMap(Map<String, dynamic> map) => EducationModel(
        slug: map['slug']?.toString() ?? '',
        qualification: map['qualification']?.toString() ?? '',
        institution: map['institution']?.toString() ?? '',
        period: map['period']?.toString() ?? '',
        kind: map['kind']?.toString() ?? '',
        honours: map['honours']?.toString() ?? '',
        location: map['location']?.toString() ?? '',
        note: map['note']?.toString() ?? '',
        crest: map['crest']?.toString(),
        crestWidth: int.tryParse(map['crestWidth']?.toString() ?? '') ?? 512,
        crestHeight: int.tryParse(map['crestHeight']?.toString() ?? '') ?? 464,
        focus: map['focus'] is List
            ? (map['focus'] as List)
                .map((e) => e.toString())
                .toList(growable: false)
            : const [],
        draft: map['draft'] == true,
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'qualification': qualification,
        'institution': institution,
        'period': period,
        'kind': kind,
        'honours': honours,
        'location': location,
        'note': note,
        if (crest != null) ...{
          'crest': crest,
          'crestWidth': crestWidth,
          'crestHeight': crestHeight,
        },
        'focus': focus,
        'draft': draft,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is EducationModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
