/// Where a contact submission has got to.
enum ContactStatus {
  /// Nothing sent yet, or the form was reset.
  idle,

  /// Request in flight — the submit button is disabled while this holds.
  sending,

  /// Accepted by the function. The form is replaced by a confirmation.
  sent,

  /// Rejected, with a reason in [ContactFormState.error] worth showing.
  failed,
}

/// Immutable state for the contact form island.
class ContactFormState {
  const ContactFormState({this.status = ContactStatus.idle, this.error});

  final ContactStatus status;

  /// Human-readable failure, ready to render. The function is written to
  /// return messages that can be shown verbatim, so nothing here needs
  /// translating from an error code.
  final String? error;

  bool get isSending => status == ContactStatus.sending;
  bool get isSent => status == ContactStatus.sent;

  ContactFormState copyWith({ContactStatus? status, String? error}) =>
      ContactFormState(
        status: status ?? this.status,
        // Deliberately not `error ?? this.error`: moving to any new status must
        // clear a stale message, and callers pass the error explicitly.
        error: error,
      );
}
