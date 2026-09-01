// Testimonial submission handler — receives a note and sends it on via Resend.
//
// A Cloudflare Pages Function: the file path is the route, so this serves
// POST /api/testimonial. A near-twin of `contact.js`, deliberately kept as a
// separate file rather than a shared handler with a `type` field — the two
// differ in their fields, their limits and their email body, and the one
// thing they must never do is let a submission to one arrive labelled as the
// other.
//
// Runs on Workers, not Node — no `process`, no Node built-ins. Everything
// below is Web-standard, and secrets arrive on `context.env`.
//
// Accepts two content types, because the form works without JavaScript:
//   * application/json                  — enhanced path, answers JSON
//   * application/x-www-form-urlencoded — native form post, answers a 303 to
//     /thanks so the browser lands on a real page
//
// Environment variables — the same three the contact form uses. There is no
// separate key: both send to the same inbox from the same verified sender.
//   RESEND_API_KEY   from resend.com/api-keys
//   CONTACT_TO       where submissions are delivered
//   CONTACT_FROM     a sender on a verified Resend domain
//
// **Nothing here publishes anything.** A submission becomes an email. It
// reaches the site only when a human adds it to
// `TestimonialsLocalDatasource` and pushes. That is the correct shape: a
// public endpoint that wrote straight to the page would be a defacement
// vector, and an endorsement nobody read before publishing is not an
// endorsement.

const RESEND_ENDPOINT = 'https://api.resend.com/emails';

const MAX = {
  name: 120,
  email: 200,
  role: 160,
  company: 160,
  quote: 1500,
  links: 600,
};

const MIN = { quote: 40 };

// How many profile links one submission may carry. A generous cap that still
// stops a submission being used as a link dump.
const MAX_LINKS = 4;

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

// Keeps only absolute http(s) URLs.
//
// This is not decoration. These links are destined to be published as anchors
// on a public page, and a `javascript:` or `data:` href pasted here would be
// carried through the email into the datasource by a human who is reading
// prose, not auditing schemes. Rejecting them at the door means the only
// thing that can reach the page is a real web address.
function cleanLinks(value) {
  return String(value ?? '')
    .split(/[\s,]+/)
    .map((entry) => entry.trim())
    .filter(Boolean)
    .filter((entry) => {
      let url;
      try {
        url = new URL(entry);
      } catch {
        return false;
      }
      return url.protocol === 'http:' || url.protocol === 'https:';
    })
    .slice(0, MAX_LINKS);
}

function validate(fields) {
  const errors = [];
  const name = singleLine(fields.name ?? '');
  const email = singleLine(fields.email ?? '');
  const role = singleLine(fields.role ?? '');
  const company = singleLine(fields.company ?? '');
  const quote = String(fields.quote ?? '').trim();
  const links = cleanLinks(fields.links);

  if (name.length < 2) errors.push('Tell me your name.');
  if (name.length > MAX.name) errors.push('That name is too long.');
  // Deliberately permissive: the only real test of an address is whether mail
  // to it lands, and strict patterns reject valid addresses.
  if (!/^[^@\s]+@[^@\s.]+\.[^@\s]+$/.test(email)) {
    errors.push('That email address does not look right.');
  }
  if (email.length > MAX.email) errors.push('That email address is too long.');
  if (role.length < 2) {
    errors.push('Add your role. It is what gives the words weight.');
  }
  if (role.length > MAX.role) errors.push('That role is too long.');
  if (company.length > MAX.company) errors.push('That company name is too long.');
  if (quote.length < MIN.quote) errors.push('A little more than that, if you can.');
  if (quote.length > MAX.quote) errors.push('That is longer than I can publish. Trim it a little?');
  if (String(fields.links ?? '').length > MAX.links) {
    errors.push('That is a lot of links. Four is plenty.');
  }

  return { errors, clean: { name, email, role, company, quote, links } };
}

function buildEmail({ name, email, role, company, quote, links }) {
  const attribution = company ? `${role}, ${company}` : role;

  const rows = [
    ['Name', name],
    ['Email', email],
    ['Role', attribution],
    ['Links', links.length ? links.join('\n') : '—'],
  ]
    .map(
      ([label, value]) =>
        `<tr>
           <td style="padding:6px 16px 6px 0;color:#8a8ea8;font:500 12px/1.5 ui-sans-serif,system-ui;text-transform:uppercase;letter-spacing:.08em;vertical-align:top">${escapeHtml(label)}</td>
           <td style="padding:6px 0;color:#e9ebf7;font:400 15px/1.6 ui-sans-serif,system-ui">${escapeHtml(value).replaceAll('\n', '<br>')}</td>
         </tr>`,
    )
    .join('');

  const body = escapeHtml(quote).replaceAll('\n', '<br>');

  // The ready-to-paste block is the point of this email. Adding a testimonial
  // means editing a Dart const, and retyping somebody's paragraph by hand into
  // one is how a quote quietly acquires a word it never had.
  const snippet = [
    'TestimonialModel(',
    `  slug: '${name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')}',`,
    `  quote: ${JSON.stringify(quote)},`,
    `  name: ${JSON.stringify(name)},`,
    `  role: ${JSON.stringify(role)},`,
    company ? `  company: ${JSON.stringify(company)},` : null,
    links.length
      ? `  links: [${links.map((l) => JSON.stringify(l)).join(', ')}],`
      : null,
    '  emphasis: \'\', // pick the clause worth reading — must be verbatim',
    ')',
  ]
    .filter(Boolean)
    .join('\n');

  const html = `<div style="background:#282739;padding:32px">
  <div style="max-width:560px;margin:0 auto;background:#35364a;border:1px solid #434659;padding:28px">
    <p style="margin:0 0 20px;color:#a5a8ff;font:600 11px/1 ui-monospace,monospace;text-transform:uppercase;letter-spacing:.18em">New testimonial</p>
    <table style="border-collapse:collapse;width:100%">${rows}</table>
    <div style="height:1px;background:#434659;margin:22px 0"></div>
    <div style="color:#d0d4ed;font:400 15px/1.65 ui-sans-serif,system-ui">${body}</div>
    <div style="height:1px;background:#434659;margin:22px 0"></div>
    <p style="margin:0 0 10px;color:#8a8ea8;font:500 11px/1 ui-monospace,monospace;text-transform:uppercase;letter-spacing:.14em">Paste into TestimonialsLocalDatasource</p>
    <pre style="margin:0;padding:14px;background:#282739;border:1px solid #434659;color:#a9adc6;font:400 12px/1.6 ui-monospace,monospace;white-space:pre-wrap;word-break:break-word">${escapeHtml(snippet)}</pre>
    <p style="margin:16px 0 0;color:#616580;font:400 12px/1.5 ui-sans-serif,system-ui">Check the wording against what they wrote before pushing. Nothing is live until you do.</p>
  </div>
</div>`;

  const text =
    `New testimonial\n\n` +
    `Name: ${name}\nEmail: ${email}\nRole: ${attribution}\n` +
    `Links: ${links.length ? links.join(', ') : '—'}\n\n` +
    `${quote}\n\n---\n\n${snippet}\n`;

  return { subject: `Testimonial from ${name}`, html, text };
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
  //
  // `website`, not the contact form's `company` — company is a real field on
  // this form, and reusing that name would silently drop every submission
  // that named an employer.
  if (String(fields.website ?? '').trim() !== '') return succeed();

  const { errors, clean } = validate(fields);
  if (errors.length) return fail(422, errors[0]);

  const apiKey = env.RESEND_API_KEY;
  const to = env.CONTACT_TO;
  const from = env.CONTACT_FROM;

  if (!apiKey || !to || !from) {
    // Naming the absent variables is deliberate. They are declared in a public
    // repository, so the names are not a secret, and knowing one is unset gives
    // an attacker nothing they can act on — while a generic message turns every
    // misconfiguration into a guessing game against a live deploy.
    const absent = [
      !apiKey && 'RESEND_API_KEY',
      !to && 'CONTACT_TO',
      !from && 'CONTACT_FROM',
    ].filter(Boolean);

    console.error('testimonial: unset ->', absent.join(', '));
    return fail(
      500,
      `The form is not configured yet (unset: ${absent.join(', ')}). ` +
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
        // So replying goes to the person who wrote it — which matters more
        // here than on the contact form, because confirming before publishing
        // is part of the flow.
        reply_to: `${clean.name} <${clean.email}>`,
      }),
    });

    if (!res.ok) {
      console.error('testimonial: resend rejected', res.status, await res.text());
      return fail(502, 'That did not send. Try again, or email me directly.');
    }
  } catch (err) {
    console.error('testimonial: resend request failed', err);
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
