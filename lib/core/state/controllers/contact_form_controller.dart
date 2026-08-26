import 'dart:convert';

import 'package:jaspr/jaspr.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// `universal_web` rather than `dart:js_interop` directly: an island's Dart is
// compiled for **both** targets — the server renders its initial markup — and
// `dart:js_interop` does not exist on the VM, so importing it breaks the
// server build outright. These shims conditionally export the real library on
// web and throwing stubs elsewhere, which the `kIsWeb` guard below never
// reaches.
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../../features/contact/domain/model/contact_form_state.dart';

part 'contact_form_controller.g.dart';

/// Drives the contact form island.
///
/// Client-side only, like every controller here — it calls `fetch`, which does
/// not exist during the static build. The `kIsWeb` guard means a server-side
/// render can never reach that code path.
@riverpod
class ContactFormController extends _$ContactFormController {
  /// Where the serverless function is mounted. Declared by `config.path` in
  /// `netlify/functions/contact.mjs`; the form's own `action` points at the
  /// same URL so the no-JavaScript path posts to exactly one place.
  static const String endpoint = '/api/contact';

  @override
  ContactFormState build() => const ContactFormState();

  /// Posts [fields] as JSON and maps the reply onto a status.
  ///
  /// The function answers JSON for this content type and a 303 redirect for a
  /// native form post, which is what lets one endpoint serve both paths.
  Future<void> submit(Map<String, String> fields) async {
    if (!kIsWeb || state.isSending) return;

    state = const ContactFormState(status: ContactStatus.sending);

    try {
      final response = await web.window
          .fetch(
            endpoint.toJS,
            web.RequestInit(
              method: 'POST',
              headers: {'Content-Type': 'application/json'}.jsify()
                  as web.HeadersInit,
              body: jsonEncode(fields).toJS,
            ),
          )
          .toDart;

      final raw = (await response.text().toDart).toDart;

      if (response.ok) {
        state = const ContactFormState(status: ContactStatus.sent);
        return;
      }

      // The function returns `{ok:false,error:"…"}` with a message written to
      // be shown verbatim. Anything else — a proxy error page, an HTML 502 —
      // would not parse, so fall back rather than surfacing markup.
      String message = 'That did not send. Try again, or email me directly.';
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {
        // Keep the fallback.
      }

      state = ContactFormState(status: ContactStatus.failed, error: message);
    } catch (_) {
      // Offline, DNS failure, request blocked — never a server message.
      state = const ContactFormState(
        status: ContactStatus.failed,
        error: 'Could not reach the server. Check your connection, or email '
            'me directly.',
      );
    }
  }

  /// Returns the form to its editable state after a failure.
  void reset() => state = const ContactFormState();
}
