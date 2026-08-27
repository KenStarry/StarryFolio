/// How a document is obtained.
///
/// This is the axis the whole page turns on. Some documents are simply
/// published; others are personal records that should not sit on a public URL
/// waiting to be scraped — a scanned degree certificate carries a name, a
/// registration number and a signature, and there is no reason for any of that
/// to be crawlable.
///
/// Gating is therefore **content**, not a security mechanism. Nothing here
/// pretends to be an access control system: the file is not on the server at
/// all, and the request goes to a human. That is the honest shape for a static
/// site, and it is also the shape a recruiter expects — "available on request"
/// is a normal sentence on a CV.
enum DocumentAccess {
  /// Published. There is a file at a URL and the button downloads it.
  open(
    label: 'Download',
    badge: 'Public',
  ),

  /// Held back. The facts are stated in full; the artefact arrives by reply.
  onRequest(
    label: 'Request a copy',
    badge: 'On request',
  );

  const DocumentAccess({required this.label, required this.badge});

  /// The action's verb.
  final String label;

  /// The small marker on the card.
  final String badge;

  bool get isOpen => this == DocumentAccess.open;
}
