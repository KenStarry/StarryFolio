import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/state/controllers/testimonial_form_controller.dart';

/// The form for sending in a testimonial.
///
/// ## It is a publishing form, and it says so
///
/// Every other form on the site sends a private message. This one asks for
/// words that will appear on a public page under somebody's real name, next to
/// links to their real profiles. That difference is stated in the form itself
/// rather than buried in a privacy page: [_Consent] sits directly above the
/// submit button, in the reading path, and names exactly what becomes public
/// and what does not.
///
/// The email address is the one field that stays private, and the form says
/// that too — asking for it without explaining why reads as harvesting.
///
/// ## Nothing published here publishes itself
///
/// A submission sends an email. Ken reads it and adds the quote to
/// `TestimonialsLocalDatasource` by hand, which is a `git push`. That is not a
/// limitation of a static site being worked around — it is the correct shape:
/// an endorsement that appears on somebody's portfolio without them having
/// read it is a review site, and a public "say something nice" endpoint that
/// writes straight to the page is a defacement waiting to happen.
///
/// The copy says so plainly, because a visitor who submits and then reloads
/// looking for their words deserves to know why they are not there yet.
///
/// ## Works with JavaScript disabled
///
/// The markup is a real `<form>` with an `action` and `method`, so a browser
/// that never runs the island still posts to the same endpoint and lands on
/// `/thanks`. The island intercepts and posts the same fields as JSON.
@client
class TestimonialForm extends StatelessComponent {
  const TestimonialForm({super.key});

  @override
  Component build(BuildContext context) {
    return const ProviderScope(child: _TestimonialFormView());
  }
}

class _TestimonialFormView extends StatelessComponent {
  const _TestimonialFormView();

  @override
  Component build(BuildContext context) {
    final state = context.watch(testimonialFormControllerProvider);

    if (state.isSent) return const _Sent();

    return form(
      // Both attributes are what make the no-JavaScript path work. The island
      // calls `preventDefault` when it is running, so they are only ever the
      // fallback.
      action: TestimonialFormController.endpoint,
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
          // perform its native POST — the submission still arrives. Calling
          // `preventDefault` first would mean a failure here swallowed the
          // submit entirely and nothing was ever sent.
          final Map<String, String> fields;
          try {
            fields = _readFields(element);
          } catch (_) {
            return;
          }

          event.preventDefault();
          context
              .read(testimonialFormControllerProvider.notifier)
              .submit(fields);
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
              required: true,
            ),
            _field(
              name: 'email',
              label: 'Email (never published)',
              type: InputType.email,
              autocomplete: 'email',
              required: true,
              hint: 'So I can reply, and check before anything goes up.',
            ),
          ],
        ),

        div(
          classes: 'grid gap-5 sm:grid-cols-2',
          [
            _field(
              name: 'role',
              label: 'Your role',
              type: InputType.text,
              autocomplete: 'organization-title',
              required: true,
              placeholder: 'Product Lead',
              hint: 'What makes the words carry weight.',
            ),
            _field(
              name: 'company',
              label: 'Company (optional)',
              type: InputType.text,
              autocomplete: 'organization',
              required: false,
            ),
          ],
        ),

        _quote(),
        _links(),
        _consent(),

        // Honeypot. Hidden from people, filled in by naive bots. `aria-hidden`
        // plus `tabindex=-1` keeps it away from screen readers and the tab
        // order, so it never reaches a real user to be confused by.
        //
        // Named `website` rather than the contact form's `company`, because
        // `company` is a real field here — reusing that name would have
        // rejected every submission that named an employer.
        const div(
          classes: 'hidden',
          attributes: {'aria-hidden': 'true'},
          [
            input(
              type: InputType.text,
              name: 'website',
              id: 'tf-website',
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
                Component.text(state.isSending ? 'Sending…' : 'Send it over'),
                if (!state.isSending)
                  span(
                    classes: 'transition-transform duration-500 ease-soft '
                        'group-hover:translate-x-1',
                    [AppIcons.arrow(classes: 'h-4 w-4')],
                  ),
              ],
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
      for (final key in [
        'name',
        'email',
        'role',
        'company',
        'quote',
        'links',
        'website',
      ])
        key: _text(data.get(key)),
    };
  }

  static String _text(JSAny? value) =>
      value != null && value.isA<JSString>()
          ? (value as JSString).toDart.trim()
          : '';

  static Component _quote() => div([
        _label(name: 'quote', text: 'What you would say'),
        const textarea(
          name: 'quote',
          id: 'tf-quote',
          rows: 6,
          classes: '$_inputClasses resize-y',
          attributes: {
            'required': 'required',
            'minlength': '40',
            'maxlength': '1500',
            'placeholder': 'In your own words. Specifics beat superlatives.',
          },
          [],
        ),
        const p(
          classes: 'mt-2 text-xs leading-relaxed text-ink-500',
          [
            Component.text(
              'I will not reword what you write. If punctuation needs to '
              'match house style I will say so first.',
            ),
          ],
        ),
      ]);

  static Component _links() => div([
        _label(name: 'links', text: 'Where people can find you (optional)'),
        const textarea(
          name: 'links',
          id: 'tf-links',
          rows: 2,
          classes: '$_inputClasses resize-y',
          attributes: {
            'maxlength': '600',
            'placeholder':
                'https://linkedin.com/in/you\nhttps://github.com/you',
          },
          [],
        ),
        const p(
          classes: 'mt-2 text-xs leading-relaxed text-ink-500',
          [
            Component.text(
              'One per line. These get published as links beside your name, '
              'so the credit points somewhere.',
            ),
          ],
        ),
      ]);

  /// What actually becomes public. Directly above the submit button, in the
  /// reading path, because consent buried under a page is not consent.
  /// Set as a margin note, not a panel.
  ///
  /// This carried a border and a filled ground, which put it in the same
  /// visual family as every input above it — a bordered box on a form reads as
  /// something to type in, and a disclaimer that looks like a field is a
  /// disclaimer nobody reads. A hairline down the left side says *aside*
  /// instead, which is what it is.
  static Component _consent() => const div(
        classes: 'border-l border-ink-700 pl-5',
        [
          p(
            classes: 'type-eyebrow font-mono text-ink-500',
            [Component.text('Before you send')],
          ),
          p(
            classes: 'mt-3 max-w-lg text-sm leading-relaxed text-ink-400',
            [
              Component.text(
                'Sending this means your words, your name, your role and any '
                'links above may appear publicly on this page. Your email '
                'never does. Nothing goes up automatically: it reaches me as '
                'an email and I add it by hand, so give me a day or two. Want '
                'it taken down later? Say the word and it goes.',
              ),
            ],
          ),
        ],
      );

  static Component _field({
    required String name,
    required String label,
    required InputType type,
    required String autocomplete,
    required bool required,
    String placeholder = '',
    String hint = '',
  }) =>
      div([
        _label(name: name, text: label),
        input(
          type: type,
          name: name,
          id: 'tf-$name',
          classes: _inputClasses,
          attributes: {
            if (required) 'required': 'required',
            'autocomplete': autocomplete,
            if (placeholder.isNotEmpty) 'placeholder': placeholder,
          },
        ),
        if (hint.isNotEmpty)
          p(
            classes: 'mt-2 text-xs leading-relaxed text-ink-500',
            [Component.text(hint)],
          ),
      ]);

  /// Field label. Named with a leading underscore rather than reusing the
  /// contact form's `label_`: that one hard-codes the `cf-` id prefix, and two
  /// forms on one page sharing ids would break every `htmlFor` on it.
  static Component _label({required String name, required String text}) =>
      label(
        htmlFor: 'tf-$name',
        classes: 'type-eyebrow font-mono text-ink-500',
        [Component.text(text)],
      );

  static const String _inputClasses =
      'mt-2.5 w-full border border-ink-600 bg-ink-900 px-4 py-3 text-sm '
      'text-ink-100 outline-none transition-colors duration-300 '
      'placeholder:text-ink-500 focus:border-iris-400';
}

/// Replaces the form once a submission is accepted.
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
            span(classes: 'h-1.5 w-1.5 rounded-full bg-iris-400 dot-live', []),
            span(
              classes: 'type-eyebrow font-mono text-iris-400',
              [Component.text('That landed')],
            ),
          ],
        ),
        p(
          classes: 'mt-5 max-w-md text-sm leading-relaxed text-ink-300',
          [
            Component.text(
              'Thank you, genuinely. I read every one of these. Yours goes up '
              'once I have added it by hand, which usually takes a day or '
              'two, and I will mail you when it does.',
            ),
          ],
        ),
        p(
          classes: 'mt-4 text-xs text-ink-500',
          [
            Component.text(
              'Spotted a typo in what you sent? Reply to my mail at '
              '${SiteConfig.email} and I will fix it before it goes up.',
            ),
          ],
        ),
      ],
    );
  }
}
