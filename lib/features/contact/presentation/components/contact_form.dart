import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/state/controllers/contact_form_controller.dart';

/// The contact form.
///
/// **Works with JavaScript disabled.** The markup is a real `<form>` with an
/// `action` and `method`, so a browser that never runs the island still posts
/// to the same endpoint and lands on `/thanks`. The island is an enhancement
/// on top: it intercepts the submit, posts the same fields as JSON, and swaps
/// in inline status rather than navigating away.
///
/// That ordering matters for a contact form more than anywhere else on the
/// site — it is the one control whose failure costs an actual enquiry.
@client
class ContactForm extends StatelessComponent {
  const ContactForm({this.service = '', super.key});

  /// Pre-selects a service when the form is reached from a specific band.
  final String service;

  @override
  Component build(BuildContext context) {
    return ProviderScope(child: _ContactFormView(service: service));
  }
}

class _ContactFormView extends StatelessComponent {
  const _ContactFormView({required this.service});

  final String service;

  @override
  Component build(BuildContext context) {
    final state = context.watch(contactFormControllerProvider);

    if (state.isSent) return const _Sent();

    return form(
      // Both attributes are what make the no-JavaScript path work. The island
      // calls `preventDefault` when it is running, so they are only ever used
      // as the fallback.
      action: ContactFormController.endpoint,
      method: FormMethod.post,
      classes: 'grid gap-5',
      events: {
        'submit': (event) {
          if (!kIsWeb) return;

          // `is` on a JS interop type is always true and checks nothing —
          // `isA` is what actually interrogates the underlying JS object.
          final target = event.target;
          if (target == null || !target.isA<web.HTMLFormElement>()) return;
          final element = target as web.HTMLFormElement;

          // Read the fields *before* taking over the submit. If anything here
          // throws, returning without calling `preventDefault` lets the browser
          // perform its native POST — the enquiry still arrives and the visitor
          // lands on /thanks. Calling `preventDefault` first, as this did
          // originally, meant a failure here swallowed the submit entirely: the
          // button appeared to do nothing and no mail was ever sent.
          final Map<String, String> fields;
          try {
            fields = _readFields(element);
          } catch (_) {
            return;
          }

          event.preventDefault();
          context.read(contactFormControllerProvider.notifier).submit(fields);
        },
      },
      [
        div(
          classes: 'grid gap-5 sm:grid-cols-2',
          [
            _field(
              name: 'name',
              label: 'Your name',
              type: InputType.text,
              autocomplete: 'name',
            ),
            _field(
              name: 'email',
              label: 'Email',
              type: InputType.email,
              autocomplete: 'email',
            ),
          ],
        ),

        _select(service),
        _textarea(),

        // Honeypot. Hidden from people, filled in by naive bots. `aria-hidden`
        // plus `tabindex=-1` keeps it away from screen readers and the tab
        // order, so it never reaches a real user to be confused by.
        const div(
          classes: 'hidden',
          attributes: {'aria-hidden': 'true'},
          [
            input(
              type: InputType.text,
              name: 'company',
              id: 'cf-company',
              attributes: {'tabindex': '-1', 'autocomplete': 'off'},
            ),
          ],
        ),

        if (state.error != null)
          div(
            classes: 'border border-ink-600 bg-ink-850 px-5 py-4',
            attributes: const {'role': 'alert'},
            [
              p(
                classes: 'text-sm leading-relaxed text-ink-200',
                [Component.text(state.error!)],
              ),
            ],
          ),

        div(
          classes: 'flex flex-wrap items-center gap-5 pt-1',
          [
            button(
              classes: 'group inline-flex items-center justify-center gap-2.5 '
                  'bg-ink-200 px-7 py-3.5 text-sm font-medium text-ink-900 '
                  'transition-colors duration-400 ease-soft hover:bg-ink-100 '
                  'disabled:cursor-not-allowed disabled:opacity-55',
              attributes: {
                'type': 'submit',
                if (state.isSending) 'disabled': 'disabled',
              },
              [
                Component.text(state.isSending ? 'Sending…' : 'Send message'),
                if (!state.isSending)
                  span(
                    classes: 'transition-transform duration-500 ease-soft '
                        'group-hover:translate-x-1',
                    [AppIcons.arrow(classes: 'h-4 w-4')],
                  ),
              ],
            ),
            const p(
              classes: 'text-xs text-ink-500',
              [Component.text('Usually replies within a day.')],
            ),
          ],
        ),
      ],
    );
  }

  /// Pulls the form's values out of a `FormData`.
  ///
  /// `FormData.get` is typed as `JSAny?` — the DOM union of `File` and string —
  /// so `toString()` on it is not the field's text and cannot be relied on.
  /// Narrowing to `JSString` and converting is the only correct read.
  static Map<String, String> _readFields(web.HTMLFormElement element) {
    final data = web.FormData(element);
    return {
      for (final key in ['name', 'email', 'service', 'message', 'company'])
        key: _text(data.get(key)),
    };
  }

  static String _text(JSAny? value) =>
      value != null && value.isA<JSString>()
          ? (value as JSString).toDart.trim()
          : '';

  static Component _field({
    required String name,
    required String label,
    required InputType type,
    required String autocomplete,
  }) =>
      div([
        label_(name: name, text: label),
        input(
          type: type,
          name: name,
          id: 'cf-$name',
          classes: _inputClasses,
          attributes: {'required': 'required', 'autocomplete': autocomplete},
        ),
      ]);

  static Component _select(String service) => div([
        label_(name: 'service', text: 'What do you need?'),

        // `appearance-none` strips the native dropdown chevron, which left this
        // looking identical to the text inputs above it — nothing signalled it
        // could be opened, so it silently went out on its default value. The
        // chevron is drawn back in, and `pr-11` keeps the longest option from
        // running underneath it.
        div(
          classes: 'relative',
          [
            const span(
              classes: 'pointer-events-none absolute right-4 top-1/2 mt-1 '
                  '-translate-y-1/2 text-ink-400',
              attributes: {'aria-hidden': 'true'},
              [_chevron],
            ),
            select(
              name: 'service',
              id: 'cf-service',
              classes: '$_inputClasses cursor-pointer appearance-none pr-11',
              [
                for (final option in _serviceOptions)
                  // `selected` rather than a client-side default, so the choice
                  // is already correct in the server-rendered markup.
                  Component.element(
                    tag: 'option',
                    attributes: {
                      'value': option,
                      if (option == service && service.isNotEmpty)
                        'selected': 'selected',
                    },
                    children: [
                      Component.text(
                        option.isEmpty ? 'Not sure yet' : option,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ]);

  /// Extracted so the surrounding markup stays a `const` subtree —
  /// `AppIcons.chevronDown` is a method call and cannot appear in one.
  static const Component _chevron = _Chevron();

  static Component _textarea() => div([
        label_(name: 'message', text: 'What are you building?'),
        const textarea(
          name: 'message',
          id: 'cf-message',
          rows: 5,
          classes: '$_inputClasses resize-y',
          attributes: {'required': 'required', 'minlength': '10'},
          [],
        ),
      ]);

  static const List<String> _serviceOptions = [
    '',
    'Mobile development',
    'UI/UX design',
    'Web development',
    'Desktop applications',
    'Ship & operate',
    'Consultancy & review',
  ];

  static const String _inputClasses =
      'mt-2.5 w-full border border-ink-600 bg-ink-900 px-4 py-3 text-sm '
      'text-ink-100 outline-none transition-colors duration-300 '
      'placeholder:text-ink-500 focus:border-iris-400';
}

/// Field label. Named with a trailing underscore because `label` is the DOM
/// element helper and would shadow it.
Component label_({required String name, required String text}) => label(
      htmlFor: 'cf-$name',
      classes: 'type-eyebrow font-mono text-ink-500',
      [Component.text(text)],
    );

/// Replaces the form once a message is accepted.
class _Sent extends StatelessComponent {
  const _Sent();

  @override
  Component build(BuildContext context) {
    return const div(
      classes: 'border border-ink-600 bg-ink-850 px-7 py-10',
      attributes: {'role': 'status'},
      [
        div(
          classes: 'flex items-center gap-3',
          [
            span(
              classes: 'h-1.5 w-1.5 rounded-full bg-iris-400 dot-live',
              [],
            ),
            span(
              classes: 'type-eyebrow font-mono text-iris-400',
              [Component.text('Message sent')],
            ),
          ],
        ),
        p(
          classes: 'mt-6 font-display text-2xl font-bold tracking-tight '
              'text-ink-100',
          [Component.text('Got it — thank you.')],
        ),
        p(
          classes: 'mt-3 max-w-sm text-sm leading-relaxed text-ink-400',
          [
            Component.text(
              'It has landed in my inbox and I usually reply within a day. '
              'If it is urgent, the reply address on that email works too.',
            ),
          ],
        ),
      ],
    );
  }
}

/// The dropdown chevron. A component rather than an inline call so the select's
/// markup can stay `const`.
class _Chevron extends StatelessComponent {
  const _Chevron();

  @override
  Component build(BuildContext context) =>
      AppIcons.chevronDown(classes: 'h-4 w-4');
}
