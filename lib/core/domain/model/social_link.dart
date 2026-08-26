/// A profile elsewhere on the internet. Rendered in the footer and the contact
/// section, and emitted as `sameAs` in the Person JSON-LD (see `structured_data.dart`),
/// which is how search engines tie those profiles back to this site.
class SocialLink {
  const SocialLink({
    required this.label,
    required this.handle,
    required this.url,
  });

  final String label;
  final String handle;
  final String url;
}
