// Contact form handler — receives a submission and sends it on via Resend.
//
// A Cloudflare Pages Function: the file path is the route, so this serves
// POST /api/contact. It lives here rather than in the Dart app because the
// Resend API key must never reach the browser, and a static site has nowhere
// else to keep a secret.
//
// Runs on Workers, not Node — no `process`, no Node built-ins. Everything below
// is Web-standard (`fetch`, `Response`, `URLSearchParams`), and secrets arrive
// on `context.env` rather than `process.env`.
//
// Accepts two content types, because the form works without JavaScript:
//   * application/json                  — enhanced path, answers JSON
//   * application/x-www-form-urlencoded — native form post, answers a 303 to
//     /thanks so the browser lands on a real page
//
// Environment variables (Pages → Settings → Environment variables; mark the
// key as encrypted, and set them for Production *and* Preview):
//   RESEND_API_KEY   from resend.com/api-keys
//   CONTACT_TO       where enquiries are delivered
//   CONTACT_FROM     a sender on a verified Resend domain

const RESEND_ENDPOINT = 'https://api.resend.com/emails';

const MAX = { name: 120, email: 200, service: 120, message: 5000 };

// Everything a visitor typed is untrusted and ends up inside an HTML email.
// Escaping here means a submission cannot inject markup into the message body.
function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

// Header-injection guard: a newline in the reply-to would let a submission
// append arbitrary headers.
function singleLine(value) {
  return String(value).replace(/[\r\n]+/g, ' ').trim();
}

function validate(fields) {
  const errors = [];
  const name = singleLine(fields.name ?? '');
  const email = singleLine(fields.email ?? '');
  const service = singleLine(fields.service ?? '');
  const message = String(fields.message ?? '').trim();

  if (name.length < 2) errors.push('Tell me your name.');
  if (name.length > MAX.name) errors.push('That name is too long.');
  // Deliberately permissive: the only real test of an address is whether mail
  // to it lands, and strict patterns reject valid addresses.
  if (!/^[^@\s]+@[^@\s.]+\.[^@\s]+$/.test(email)) {
    errors.push('That email address does not look right.');
  }
  if (email.length > MAX.email) errors.push('That email address is too long.');
  if (message.length < 10) errors.push('Add a little more detail.');
  if (message.length > MAX.message) errors.push('That message is too long.');
  if (service.length > MAX.service) errors.push('Unknown service.');

  return { errors, clean: { name, email, service, message } };
}

function buildEmail({ name, email, service, message }) {
  const subject = service
    ? `Portfolio enquiry — ${service}`
    : 'Portfolio enquiry';

  const rows = [
    ['Name', name],
    ['Email', email],
    ['Service', service || '—'],
  ]
    .map(
      ([label, value]) =>
        `<tr>
           <td style="padding:6px 16px 6px 0;color:#8a8ea8;font:500 12px/1.5 ui-sans-serif,system-ui;text-transform:uppercase;letter-spacing:.08em;vertical-align:top">${escapeHtml(label)}</td>
           <td style="padding:6px 0;color:#e9ebf7;font:400 15px/1.6 ui-sans-serif,system-ui">${escapeHtml(value)}</td>
         </tr>`,
    )
    .join('');

  const body = escapeHtml(message).replaceAll('\n', '<br>');

  const html = `<div style="background:#282739;padding:32px">
  <div style="max-width:560px;margin:0 auto;background:#35364a;border:1px solid #434659;padding:28px">
    <p style="margin:0 0 20px;color:#a5a8ff;font:600 11px/1 ui-monospace,monospace;text-transform:uppercase;letter-spacing:.18em">New enquiry</p>
    <table style="border-collapse:collapse;width:100%">${rows}</table>
    <div style="height:1px;background:#434659;margin:22px 0"></div>
    <div style="color:#d0d4ed;font:400 15px/1.65 ui-sans-serif,system-ui">${body}</div>
  </div>
</div>`;

  const text =
    `New enquiry\n\n` +
    `Name: ${name}\nEmail: ${email}\nService: ${service || '—'}\n\n${message}\n`;

  return { subject, html, text };
}

export async function onRequestPost(context) {
  const { request, env } = context;

  const contentType = request.headers.get('content-type') ?? '';
  const wantsJson = contentType.includes('application/json');

  // A native form post gets a redirect; the enhanced path gets JSON.
  const fail = (status, messageText) =>
    wantsJson
      ? Response.json({ ok: false, error: messageText }, { status })
      : Response.redirect(
          new URL(
            `/thanks?error=${encodeURIComponent(messageText)}`,
            request.url,
          ),
          303,
        );

  const succeed = () =>
    wantsJson
      ? Response.json({ ok: true })
      : Response.redirect(new URL('/thanks', request.url), 303);

  let fields;
  try {
    if (wantsJson) {
      fields = await request.json();
    } else {
      fields = Object.fromEntries(new URLSearchParams(await request.text()));
    }
  } catch {
    return fail(400, 'That submission could not be read.');
  }

  // Honeypot: hidden from people, filled in by naive bots. Answer as success so
  // a bot cannot tell it was caught and retry with the field cleared.
  if (String(fields.company ?? '').trim() !== '') return succeed();

  const { errors, clean } = validate(fields);
  if (errors.length) return fail(422, errors[0]);

  const apiKey = env.RESEND_API_KEY;
  const to = env.CONTACT_TO;
  const from = env.CONTACT_FROM;

  if (!apiKey || !to || !from) {
    // Naming the absent variables is deliberate. They are declared in a public
    // repository, so the names are not a secret, and knowing one is unset gives
    // an attacker nothing they can act on — while a generic message turns every
    // misconfiguration into a guessing game against a live deploy. Values are
    // of course never included.
    const absent = [
      !apiKey && 'RESEND_API_KEY',
      !to && 'CONTACT_TO',
      !from && 'CONTACT_FROM',
    ].filter(Boolean);

    console.error('contact: unset ->', absent.join(', '));
    return fail(
      500,
      `The contact form is not configured yet (unset: ${absent.join(', ')}). ` +
        'Email me directly.',
    );
  }

  const { subject, html, text } = buildEmail(clean);

  try {
    const res = await fetch(RESEND_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from,
        to: [to],
        subject,
        html,
        text,
        // So replying goes to the sender, not to the site's own address.
        reply_to: `${clean.name} <${clean.email}>`,
      }),
    });

    if (!res.ok) {
      console.error('contact: resend rejected', res.status, await res.text());
      return fail(502, 'That did not send. Try again, or email me directly.');
    }
  } catch (err) {
    console.error('contact: resend request failed', err);
    return fail(502, 'That did not send. Try again, or email me directly.');
  }

  return succeed();
}

// Everything that is not a POST — a crawler following the form's action, a
// probe. Cloudflare gives the method-specific `onRequestPost` precedence, so
// this never sees a POST and must not try to handle one: delegating here would
// drop `context.env` and the handler would read the API key as undefined.
export async function onRequest() {
  return new Response('Method not allowed', {
    status: 405,
    headers: { Allow: 'POST' },
  });
}
