import 'dart:convert';

import 'package:jaspr/jaspr.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// `universal_web` rather than `dart:js_interop` directly: an island's Dart is
// compiled for **both** targets — the server renders its initial markup — and
// `dart:js_interop` does not exist on the VM, so importing it breaks the
// server build outright.
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../../features/contact/domain/model/contact_form_state.dart';

part 'testimonial_form_controller.g.dart';

/// Drives the testimonial submission island.
///
/// Reuses [ContactFormState] rather than declaring a near-identical enum and
/// class beside it: the two forms have exactly the same lifecycle — idle,
/// sending, sent, failed with a message — and a second copy would be two
/// things to keep in step for no gain. If they ever diverge, that is the point
/// to split them, not before.
///
/// Client-side only, like every controller here. It calls `fetch`, which does
/// not exist during the static build; the `kIsWeb` guard is what keeps a
/// server-side render from reaching it.
@riverpod
class TestimonialFormController extends _$TestimonialFormController {
  /// Where the serverless function is mounted. `functions/api/testimonial.js`
  /// serves this path, and the form's own `action` points at the same URL so
  /// the no-JavaScript path posts to exactly one place.
  static const String endpoint = '/api/testimonial';

  @override
  ContactFormState build() => const ContactFormState();

  /// Posts [fields] as JSON and maps the reply onto a status.
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

      // `response.ok` is not sufficient on its own.
      //
      // `jaspr serve` has no Worker runtime: it answers `/api/*` with the
      // site's own 404 **page**, at status 200. That is a 2xx carrying HTML,
      // so a bare `ok` check reported a cheerful "sent" for every local
      // submission while nothing was ever delivered — the worst failure mode
      // a form can have, because it looks exactly like success.
      //
      // The function always answers JSON. Anything else is not the function,
      // whatever its status says.
      final contentType = response.headers.get('content-type') ?? '';
      if (!contentType.contains('application/json')) {
        state = const ContactFormState(
          status: ContactStatus.failed,
          error: 'That did not reach the mail service. If you are running '
              'this locally, the API only exists in a deployed build.',
        );
        return;
      }

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
