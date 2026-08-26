import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/app_icons.dart';

/// One way to get in touch.
typedef Channel = ({
  String label,
  String handle,
  String url,
  String icon,
  String note,
});

/// The grid of direct channels beside the form.
///
/// A form suits someone with a brief; a lot of people would rather just send a
/// message on something they already have open. Both are offered, and the
/// channels are named with the actual handle rather than a generic "message
/// me", so the reader knows where they are going before they click.
///
/// Channels with no value configured are omitted entirely — a `wa.me/` link
/// with no number opens WhatsApp on nothing, which is worse than not offering
/// it.
class ChannelGrid extends StatelessComponent {
  const ChannelGrid({super.key});

  static List<Channel> get channels => [
        (
          label: 'Email',
          handle: SiteConfig.email,
          url: 'mailto:${SiteConfig.email}',
          icon: 'mail',
          note: 'Best for anything with a brief attached',
        ),
        if (SiteConfig.whatsappNumber.isNotEmpty)
          (
            label: 'WhatsApp',
            handle: 'Message directly',
            url: SiteConfig.whatsappUrl,
            icon: 'whatsapp',
            note: 'Quickest for a short question',
          ),
        for (final social in SiteConfig.socials)
          (
            label: social.label,
            handle: social.handle,
            url: social.url,
            icon: social.label.toLowerCase(),
            note: switch (social.label.toLowerCase()) {
              'github' => 'The code, and what I am building now',
              'linkedin' => 'For anything formal',
              'x' => 'Where I think out loud',
              _ => 'Find me here',
            },
          ),
      ];

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'grid gap-px overflow-hidden border border-ink-700 '
          'bg-ink-700 sm:grid-cols-2',
      [
        for (final channel in channels)
          a(
            href: channel.url,
            target: channel.url.startsWith('mailto:') ? null : Target.blank,
            attributes: channel.url.startsWith('mailto:')
                ? null
                : {
                    // rel=me on the identity profiles corroborates the `sameAs`
                    // entries in the Person JSON-LD.
                    'rel': channel.icon == 'whatsapp' ? 'noopener' : 'me noopener',
                  },
            classes: 'group flex flex-col bg-ink-900 p-6 transition-colors '
                'duration-400 ease-soft hover:bg-ink-850 sm:p-7',
            [
              div(
                classes: 'flex items-center justify-between',
                [
                  span(
                    classes: 'text-iris-400 transition-transform duration-500 '
                        'ease-spring group-hover:scale-110',
                    [AppIcons.social(channel.icon, classes: 'h-5 w-5')],
                  ),
                  span(
                    classes: 'text-ink-600 transition-all duration-500 '
                        'ease-soft group-hover:translate-x-1 '
                        'group-hover:text-iris-300',
                    [AppIcons.arrowUpRight(classes: 'h-4 w-4')],
                  ),
                ],
              ),
              h3(
                classes: 'mt-6 font-display text-lg font-bold tracking-tight '
                    'text-ink-100',
                [Component.text(channel.label)],
              ),
              p(
                classes: 'mt-1 truncate font-mono text-[11px] text-ink-400',
                [Component.text(channel.handle)],
              ),
              p(
                classes: 'mt-4 text-xs leading-relaxed text-ink-500',
                [Component.text(channel.note)],
              ),
            ],
          ),
      ],
    );
  }
}
