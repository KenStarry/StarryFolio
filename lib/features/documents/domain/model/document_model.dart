import '../enum/document_access.dart';

/// One document in the hub.
///
/// Covers both halves of [DocumentAccess]: a published file with real page
/// renders, and a held-back credential with none. The difference is carried by
/// [access] and by whether [file] is null — a document with no file cannot be
/// downloaded however its access is set, so the two cannot contradict each
/// other on screen.
///
/// `fromMap` parses defensively so this can move behind a CMS without the page
/// learning anything new.
class DocumentModel {
  const DocumentModel({
    required this.slug,
    required this.title,
    required this.tagline,
    required this.summary,
    this.access = DocumentAccess.open,
    this.file,
    this.pages = const [],
    this.contains = const [],
    this.format = 'PDF',
    this.pageCount = 0,
    this.sizeLabel = '',
    this.updated = '',
    this.issuer = '',
    this.requestNote = '',
  });

  /// Anchor id for the band, and its jump-nav stop.
  final String slug;

  final String title;

  /// The one line under the title.
  final String tagline;

  /// Body copy. Each entry is a paragraph.
  final List<String> summary;

  final DocumentAccess access;

  /// Path to the downloadable file, site-absolute. Null for anything held
  /// back — and the reason [canDownload] is not simply `access.isOpen`.
  final String? file;

  /// Page renders, in order, as paths under `web/`. These are generated from
  /// the real file rather than mocked up, so the preview cannot show a layout
  /// the download does not have.
  final List<String> pages;

  /// What is inside, as short scannable lines.
  final List<String> contains;

  final String format;
  final int pageCount;
  final String sizeLabel;

  /// Display date, e.g. `Aug 2026`.
  final String updated;

  /// Who issued it. Empty for self-authored documents.
  final String issuer;

  /// Shown beside a gated document, explaining what happens when you ask.
  final String requestNote;

  /// Whether there is actually something to download.
  bool get canDownload => access.isOpen && file != null;

  /// The metadata strip — only the parts that exist.
  List<String> get specs => [
        format,
        if (pageCount > 0) '$pageCount ${pageCount == 1 ? 'page' : 'pages'}',
        if (sizeLabel.isNotEmpty) sizeLabel,
        if (updated.isNotEmpty) 'Updated $updated',
      ];

  factory DocumentModel.fromMap(Map<String, dynamic> map) => DocumentModel(
        slug: map['slug']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        tagline: map['tagline']?.toString() ?? '',
        access: DocumentAccess.values.firstWhere(
          (a) => a.name == map['access']?.toString(),
          orElse: () => DocumentAccess.open,
        ),
        file: map['file']?.toString(),
        format: map['format']?.toString() ?? 'PDF',
        pageCount: int.tryParse(map['pageCount']?.toString() ?? '') ?? 0,
        sizeLabel: map['sizeLabel']?.toString() ?? '',
        updated: map['updated']?.toString() ?? '',
        issuer: map['issuer']?.toString() ?? '',
        requestNote: map['requestNote']?.toString() ?? '',
        summary: switch (map['summary']) {
          final List<Object?> raw => [for (final s in raw) s.toString()],
          _ => const [],
        },
        pages: switch (map['pages']) {
          final List<Object?> raw => [for (final p in raw) p.toString()],
          _ => const [],
        },
        contains: switch (map['contains']) {
          final List<Object?> raw => [for (final c in raw) c.toString()],
          _ => const [],
        },
      );

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'title': title,
        'tagline': tagline,
        'summary': summary,
        'access': access.name,
        if (file != null) 'file': file,
        'pages': pages,
        'contains': contains,
        'format': format,
        'pageCount': pageCount,
        'sizeLabel': sizeLabel,
        'updated': updated,
        'issuer': issuer,
        'requestNote': requestNote,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DocumentModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}
