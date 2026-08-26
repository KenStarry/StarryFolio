/// One marker on the road, for the spine at the foot of `/about`.
///
/// Deliberately thinner than [ExperienceModel]: a year, a short title and one
/// line. The experience band is the argument; this is the shape of the story,
/// and it only works if each entry can be read in a glance.
class MilestoneModel {
  const MilestoneModel({
    required this.year,
    required this.title,
    this.note = '',
  });

  /// Set large and ghosted behind the entry as well as read as a label, so the
  /// spine has depth without a second element to keep in sync.
  final String year;

  final String title;

  /// One sentence. Two is a paragraph and belongs in the experience band.
  final String note;

  factory MilestoneModel.fromMap(Map<String, dynamic> map) => MilestoneModel(
        year: map['year']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        note: map['note']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'year': year,
        'title': title,
        'note': note,
      };
}
