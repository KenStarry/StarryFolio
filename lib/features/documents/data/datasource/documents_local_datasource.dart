import '../../domain/enum/document_access.dart';
import '../../domain/model/document_model.dart';

/// The documents, as compile-time constants.
///
/// `const` and synchronous for the same reason as every other source here: the
/// static build resolves it during pre-render, and the repository on top exists
/// so the page never learns where the data came from.
///
/// **The page renders are generated, not authored.** `web/images/cv-page-*.webp`
/// come straight out of the PDF:
///
/// ```bash
/// pdftoppm -png -r 150 -f 1 -l 3 web/cv.pdf out
/// cwebp -q 88 -resize 900 0 out-1.png -o web/images/cv-page-1.webp
/// ```
///
/// Regenerate them whenever `cv.pdf` changes, or the preview will show a
/// layout the download does not have.
abstract final class DocumentsLocalDatasource {
  static const List<DocumentModel> documents = [_cv, _degree];

  /// Only what can actually be handed over. Drives the header's count, so a
  /// gated record is never advertised as a download.
  static List<DocumentModel> get downloadable =>
      [for (final d in documents) if (d.canDownload) d];

  static const DocumentModel _cv = DocumentModel(
    slug: 'cv',
    title: 'Curriculum Vitae',
    tagline: 'Four years of shipping, on three pages.',
    access: DocumentAccess.open,
    file: '/cv.pdf',
    format: 'PDF',
    pageCount: 3,
    sizeLabel: '81 KB',
    updated: 'Aug 2026',
    pages: [
      'images/cv-page-1.webp',
      'images/cv-page-2.webp',
      'images/cv-page-3.webp',
    ],
    summary: [
      'The document version — the one that goes into an application form or '
          'an applicant tracking system. Same facts as the record further down '
          'this page, laid out for a reader who has ninety seconds and a '
          'shortlist to cut.',
      'Kept current by hand rather than exported from anything, because a CV '
          'that reads like a database dump is a CV nobody finishes.',
    ],
    contains: [
      'Three roles: HealthX Africa, Dentsu Kenya, Podii Consultants',
      'Project highlights with the numbers attached',
      'Full technical stack, grouped',
      'BSc Computer Science, First Class Honours',
    ],
  );

  static const DocumentModel _degree = DocumentModel(
    slug: 'degree',
    title: 'Degree certificate',
    tagline: 'BSc Computer Science — First Class Honours.',
    access: DocumentAccess.onRequest,
    issuer: 'Masinde Muliro University of Science and Technology',
    format: 'Scan',
    updated: '2024',
    summary: [
      'The certificate itself carries a full legal name, a registration '
          'number and a signature. None of that needs to sit on a public URL '
          'waiting to be scraped, so it is not published here.',
      'The claim, though, is not a secret — it is on the CV, in the JSON-LD '
          'and stated in full below. Ask and the scan comes back the same day.',
    ],
    contains: [
      'BSc Computer Science',
      'First Class Honours',
      'Masinde Muliro University of Science and Technology',
      'Conferred 2024',
    ],
    requestNote: 'Verification requests from employers and recruiters are '
        'answered the same day, usually within the hour.',
  );
}
