import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../components/about_section.dart';
import '../components/contact_section.dart';
import '../components/hero_section.dart';
import '../components/work_section.dart';

/// The landing page.
///
/// Async because the featured-work strip reads the projects repository. The
/// await happens here, once, and the resolved list is handed down — so the
/// entire page, including the cards, is present in the pre-rendered HTML.
class HomePage extends AsyncStatelessComponent {
  const HomePage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final featured = await Locator.projects.getFeaturedProjects();

    return Component.fragment([
      const PageMeta(
        path: RoutePaths.home,
        title: '${SiteConfig.name} — ${SiteConfig.role}',
        description: SiteConfig.tagline,
      ),
      StructuredData(id: 'ld-person', SchemaOrg.person()),
      StructuredData(id: 'ld-website', SchemaOrg.website()),
      const HeroSection(),
      const AboutSection(),
      // A failure here must not blank the page — the rest is static content
      // that still deserves to be indexed.
      WorkSection(projects: featured.getOrElse((_) => const [])),
      const ContactSection(),
    ]);
  }
}
