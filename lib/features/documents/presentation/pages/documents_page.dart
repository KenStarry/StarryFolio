import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/ghost_text.dart';
import '../../../../core/presentation/components/page_header.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../../about/domain/model/about_profile.dart';
import '../../domain/enum/document_access.dart';
import '../../domain/model/document_model.dart';
import '../components/paper_stack.dart';
import '../components/sealed_document.dart';

/// The documents hub.
///
/// Everything a recruiter might need to file, in one place: the CV as a real
/// downloadable artefact, the portfolio as something you can put on paper, and
/// the degree — stated in full, with the scan held back for a reply.
///
/// ## Why one page and not three
///
/// These are the same errand. Someone who wants the CV usually wants the
/// credential too, and both requests arrive at the same moment in a hiring
/// process. Splitting them across routes would mean a person who found `/cv`
/// never learns the certificate exists.
///
/// ## The bands
///
/// Each document gets a full showcase band rather than a row in a list, on the
/// same reasoning as CLAUDE.md's rule against vertical project lists: a
/// document with a real page render beside it reads as an artefact, and the
/// same document as a line of text reads as a footnote.
///
/// | | |
/// |---|---|
/// | `#cv` | the file, with its own pages fanned beside it |
/// | `#degree` | the credential, sealed |
///
/// Two bands, and deliberately only two. Everything here has to be a document
/// somebody would actually file; a page that pads itself out with
/// nice-to-haves stops reading as a records desk and starts reading as a
/// features list.
class DocumentsPage extends AsyncStatelessComponent {
  const DocumentsPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final docs = await Locator.documents.getDocuments();
    final about = await Locator.about.getProfile();

    return docs.fold(
      (error) => Component.fragment([
        const _Meta(),
        section(
          classes: 'bg-ink-900 py-28 sm:py-36',
          [
            div(
              classes: 'mx-auto w-full max-w-3xl px-6 sm:px-8',
              [ErrorNotice(message: error)],
            ),
          ],
        ),
      ]),
      (documents) {
        final profile = about.getOrElse((_) => const AboutProfile());

        final cv = documents.where((d) => d.slug == 'cv').firstOrNull;
        final degree = documents.where((d) => d.slug == 'degree').firstOrNull;
        final openCount = documents.where((d) => d.canDownload).length;
        final gated =
            documents.where((d) => d.access == DocumentAccess.onRequest).length;

        // Numbered in render order, so the band numerals stay contiguous even
        // if a document is removed from the datasource.
        var n = 1;

        return Component.fragment([
          const _Meta(),
          StructuredData(
            id: 'ld-documents',
            SchemaOrg.profilePage(
              path: RoutePaths.documents,
              employers: [
                for (final role in profile.experience)
                  (name: role.company, role: role.role),
              ],
              education: [
                for (final school in profile.education) school.institution,
              ],
            ),
          ),
          StructuredData(
            id: 'ld-breadcrumbs',
            SchemaOrg.breadcrumbs(const [
              (label: 'Home', path: RoutePaths.home),
              (label: 'Documents', path: RoutePaths.documents),
            ]),
          ),

          _Header(
            documents: documents.length,
            open: openCount,
            gated: gated,
          ),

          if (cv != null) _DocumentBand(document: cv, index: n++, raised: true),
          if (degree != null)
            _DocumentBand(document: degree, index: n++, raised: false),
        ]);
      },
    );
  }
}

class _Header extends StatelessComponent {
  const _Header({
    required this.documents,
    required this.open,
    required this.gated,
  });

  final int documents;
  final int open;
  final int gated;

  @override
  Component build(BuildContext context) {
    return PageHeader(
      trail: 'Documents',
      ghost: 'Docs',
      path: RoutePaths.documents,
      meta: open == 1 ? '1 ready to download' : '$open ready to download',
      title: 'Everything you might',
      titleTail: 'need on file.',
      lead: 'The CV, the portfolio as paper, and the credential behind it. '
          'Most of it downloads on the spot; the one record that carries a '
          'signature comes by reply instead.',
      facts: [
        (value: documents.toString().padLeft(2, '0'), label: 'Documents'),
        (value: open.toString().padLeft(2, '0'), label: 'Immediate'),
        (value: gated.toString().padLeft(2, '0'), label: 'On request'),
        (value: '5+', label: 'Years covered'),
      ],
      jumpStops: const [
        (anchor: 'cv', label: 'Curriculum Vitae', count: 0),
        (anchor: 'degree', label: 'Credential', count: 0),
      ],
      jumpLabel: 'Jump to a document',
    );
  }
}

/// One document, as a showcase band.
///
/// The layout mirrors a project showcase — artefact on one side, the case for
/// it on the other — because a document deserves the same treatment as a
/// build. Which artefact renders depends on whether there is a file: real
/// pages fanned, or the sealed credential.
class _DocumentBand extends StatelessComponent {
  const _DocumentBand({
    required this.document,
    required this.index,
    required this.raised,
  });

  final DocumentModel document;
  final int index;
  final bool raised;

  @override
  Component build(BuildContext context) {
    final open = document.canDownload;

    return section(
      id: document.slug,
      classes: 'relative overflow-hidden scroll-mt-24 '
          '${raised ? 'bg-ink-800' : 'bg-ink-900'} py-20 sm:py-28',
      [
        GhostText(
          document.slug == 'degree' ? 'Honours' : 'CV',
          size: GhostSize.small,
          faint: true,
          classes: 'absolute -bottom-8 right-0',
        ),

        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            _BandHeading(
              index: index,
              eyebrow: document.access.badge,
              title: document.title,
              lead: document.tagline,
            ),

            div(
              classes: 'mt-14 grid items-center gap-14 lg:grid-cols-2 '
                  'lg:gap-20',
              [
                div(
                  classes: 'reveal order-2 lg:order-1',
                  [
                    for (final para in document.summary)
                      p(
                        classes: 'mt-5 text-[0.9375rem] leading-relaxed '
                            'text-ink-300 first:mt-0',
                        [Component.text(para)],
                      ),

                    if (document.contains.isNotEmpty) ...[
                      p(
                        classes: 'type-eyebrow mt-10 font-mono text-ink-500',
                        [
                          Component.text(
                            open ? "What's inside" : 'What it certifies',
                          ),
                        ],
                      ),
                      ul(
                        classes: 'mt-5 space-y-2.5',
                        [
                          for (final line in document.contains)
                            li(
                              classes: 'flex gap-3 text-sm leading-relaxed '
                                  'text-ink-400',
                              [
                                const span(
                                  classes: 'shrink-0 pt-1.5 font-mono '
                                      'text-iris-400',
                                  attributes: {'aria-hidden': 'true'},
                                  [Component.text('·')],
                                ),
                                span([Component.text(line)]),
                              ],
                            ),
                        ],
                      ),
                    ],

                    div(
                      classes: 'mt-10 flex flex-wrap items-center gap-4',
                      [
                        if (open)
                          a(
                            href: document.file!,
                            download: '${SiteConfig.shortName}-CV.pdf',
                            classes: 'press inline-flex items-center gap-2.5 '
                                'border border-ink-200 bg-ink-200 px-5 py-3 '
                                'font-mono text-[11px] uppercase '
                                'tracking-wider text-ink-900 '
                                'transition-colors duration-300 '
                                'hover:bg-ink-100',
                            [
                              AppIcons.byName('download', classes: 'h-4 w-4'),
                              Component.text(document.access.label),
                            ],
                          )
                        else
                          a(
                            href: _requestUrl(document),
                            classes: 'press inline-flex items-center gap-2.5 '
                                'border border-ink-200 bg-ink-200 px-5 py-3 '
                                'font-mono text-[11px] uppercase '
                                'tracking-wider text-ink-900 '
                                'transition-colors duration-300 '
                                'hover:bg-ink-100',
                            [
                              AppIcons.byName('mail', classes: 'h-4 w-4'),
                              Component.text(document.access.label),
                            ],
                          ),

                        if (open)
                          a(
                            href: document.file!,
                            target: Target.blank,
                            attributes: const {'rel': 'noopener'},
                            classes: 'link-line type-eyebrow font-mono '
                                'text-ink-300 transition-colors '
                                'hover:text-ink-100',
                            [const Component.text('Open in browser ↗')],
                          )
                        else
                          const Link(
                            to: RoutePaths.contact,
                            classes: 'link-line type-eyebrow font-mono '
                                'text-ink-300 transition-colors '
                                'hover:text-ink-100',
                            children: [
                              Component.text('Use the contact form →'),
                            ],
                          ),
                      ],
                    ),

                    if (document.requestNote.isNotEmpty)
                      p(
                        classes: 'mt-6 max-w-sm text-xs leading-relaxed '
                            'text-ink-500',
                        [Component.text(document.requestNote)],
                      ),

                    if (document.specs.isNotEmpty)
                      p(
                        classes: 'mt-8 border-t border-ink-700 pt-5 font-mono '
                            'text-[10px] uppercase tracking-wider '
                            'text-ink-500',
                        [Component.text(document.specs.join('  ·  '))],
                      ),
                  ],
                ),

                div(
                  classes: 'reveal order-1 lg:order-2',
                  [
                    if (open)
                      PaperStack(document: document)
                    else
                      SealedDocument(document: document),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// A pre-filled mail request.
  ///
  /// The subject and body are written for the person receiving it as much as
  /// the person sending it — an enquiry that already says which document and
  /// where it came from can be answered without a round trip.
  static String _requestUrl(DocumentModel document) {
    final subject = Uri.encodeComponent(
      'Document request, ${document.title}',
    );
    final body = Uri.encodeComponent(
      'Hi Ken,\n\n'
      "I'd like a copy of your ${document.title.toLowerCase()} "
      '(${document.tagline})\n\n'
      'Who I am:\nWhat it is for:\n\n'
      'Found via ${SiteConfig.domain}${RoutePaths.documents}',
    );
    return 'mailto:${SiteConfig.email}?subject=$subject&body=$body';
  }
}

/// The numbered heading every band shares, so the page reads as one sequence.
class _BandHeading extends StatelessComponent {
  const _BandHeading({
    required this.index,
    required this.eyebrow,
    required this.title,
    required this.lead,
  });

  final int index;
  final String eyebrow;
  final String title;
  final String lead;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'reveal flex items-start justify-between gap-8',
      [
        div(
          classes: 'max-w-xl',
          [
            Eyebrow(eyebrow),
            h2(
              classes: 'type-section mt-5 font-display font-bold text-ink-100',
              [Component.text(title)],
            ),
            p(
              classes: 'mt-5 text-sm leading-relaxed text-ink-400 '
                  'sm:text-[0.9375rem]',
              [Component.text(lead)],
            ),
          ],
        ),
        // Hidden on small screens, where it competes with the heading rather
        // than framing it.
        div(
          classes: 'hidden shrink-0 text-right sm:block',
          [
            span(
              classes: 'font-display text-5xl font-extrabold leading-none '
                  'text-ink-100/[0.07]',
              attributes: const {'aria-hidden': 'true'},
              [Component.text(index.toString().padLeft(2, '0'))],
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
        path: RoutePaths.documents,
        title: 'Documents & CV · ${SiteConfig.name}',
        description:
            'Download the CV of ${SiteConfig.name}, ${SiteConfig.role} in '
            '${SiteConfig.location}: plus the full record, a print-ready '
            'portfolio and degree verification on request.',
      );
}
