/// One title held at one company, for the progression inside an
/// [ExperienceModel].
///
/// ## Why a company has a list of these
///
/// A career is not a flat list of jobs. Staying somewhere and being promoted
/// is a different fact from leaving and starting again, and a timeline that
/// renders both as sibling rows throws away the more flattering of the two.
/// So the outer entry is the *company* and this is a stint within it: two
/// stints under one heading reads as progression, which is what it was.
///
/// [projects] is the join to the work. A role that can be clicked into the
/// thing it produced is worth more than the line on its own, and it is what
/// keeps `/about` and `/projects` feeding each other rather than restating
/// each other.
class RoleStint {
  const RoleStint({
    required this.title,
    required this.period,
    this.summary = '',
    this.metrics = const [],
    this.highlights = const [],
    this.stack = const [],
    this.projects = const [],
    this.current = false,
    this.draft = false,
  });

  /// Job title, as it would read on a contract.
  final String title;

  /// Human range — `Mar 2026 - Present`.
  ///
  /// A string rather than two dates because it is display copy, and because
  /// some ranges are open-ended. [months] parses it defensively for the
  /// duration badge and gives up rather than guessing.
  final String period;

  /// One or two sentences on what this title actually meant.
  final String summary;

  /// The figures worth reading if you read nothing else.
  ///
  /// **This exists because the bullets were doing a job they are bad at.**
  /// "Play Store rating from 3.1 to 4.1 through stability and UI/UX work" is a
  /// sentence carrying a number; a reader scanning three companies finds the
  /// sentence and skips the number. Split into `3.1 → 4.1` over
  /// `Play Store rating`, the same fact is read in a glance and remembered.
  ///
  /// Nothing here is new information — every value is lifted out of copy that
  /// was already on the page. Two or three per role: a wall of statistics is
  /// as unreadable as a wall of prose, and the fourth figure is always the
  /// weakest one.
  final List<({String value, String label})> metrics;

  /// What changed, for anything a figure cannot carry. Verbs, not
  /// responsibilities: a responsibility list describes a job description, an
  /// outcome list describes a person.
  final List<String> highlights;

  final List<String> stack;

  /// Slugs of the case studies produced under this title, newest first.
  final List<String> projects;

  /// The title held today. Lights the live dot.
  final bool current;

  /// The dates are authored rather than confirmed, and the surface says so.
  final bool draft;

  /// The start half of [period] — `Mar 2026` from `Mar 2026 - Present`.
  String get start => _halves.$1;

  /// The end half — `Present` from `Mar 2026 - Present`.
  String get end => _halves.$2;

  (String, String) get _halves {
    final at = period.indexOf(' - ');
    if (at < 0) return (period.trim(), period.trim());
    return (period.substring(0, at).trim(), period.substring(at + 3).trim());
  }

  /// How long this ran, in whole months, or null when [period] cannot be read.
  ///
  /// Returning null rather than a guess is the point: a duration is a number
  /// on a CV, and a wrong one is worse than an absent one. Anything the parser
  /// does not recognise simply renders no badge.
  ///
  /// `Present` resolves against the build date, so the badge is correct as of
  /// the last deploy rather than frozen at whenever it was written.
  int? get months {
    final from = _parse(start);
    if (from == null) return null;
    final to = end.toLowerCase() == 'present' ? DateTime.now() : _parse(end);
    if (to == null) return null;
    final span = (to.year - from.year) * 12 + (to.month - from.month);
    return span < 0 ? null : span + 1;
  }

  /// `1 yr 3 mos`, `4 mos`, or null. Written the way a CV writes it.
  String? get duration {
    final total = months;
    if (total == null || total < 1) return null;
    final years = total ~/ 12;
    final rest = total % 12;
    final parts = [
      if (years > 0) '$years yr${years == 1 ? '' : 's'}',
      if (rest > 0) '$rest mo${rest == 1 ? '' : 's'}',
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }

  static const _months = <String, int>{
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  /// Reads `Mar 2026`, `March 2026` or a bare `2026`. Anything else is null.
  static DateTime? _parse(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;

    if (parts.length == 1) {
      final year = int.tryParse(parts.first);
      return year == null ? null : DateTime(year);
    }

    final month = _months[parts.first.toLowerCase().substring(
          0,
          parts.first.length < 3 ? parts.first.length : 3,
        )];
    final year = int.tryParse(parts.last);
    if (month == null || year == null) return null;
    return DateTime(year, month);
  }

  factory RoleStint.fromMap(Map<String, dynamic> map) => RoleStint(
        title: map['title']?.toString() ?? '',
        period: map['period']?.toString() ?? '',
        summary: map['summary']?.toString() ?? '',
        metrics: map['metrics'] is List
            ? [
                for (final entry in (map['metrics'] as List))
                  if (entry is Map)
                    (
                      value: entry['value']?.toString() ?? '',
                      label: entry['label']?.toString() ?? '',
                    ),
              ]
            : const [],
        highlights: _stringList(map['highlights']),
        stack: _stringList(map['stack']),
        projects: _stringList(map['projects']),
        current: map['current'] == true,
        draft: map['draft'] == true,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'period': period,
        'summary': summary,
        'metrics': [
          for (final metric in metrics)
            {'value': metric.value, 'label': metric.label},
        ],
        'highlights': highlights,
        'stack': stack,
        'projects': projects,
        'current': current,
        'draft': draft,
      };

  static List<String> _stringList(Object? value) => value is List
      ? value.map((e) => e.toString()).toList(growable: false)
      : const [];
}
