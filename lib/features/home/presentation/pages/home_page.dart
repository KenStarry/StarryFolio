import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../../about/domain/model/about_profile.dart';
import '../components/about_section.dart';
import '../components/contact_section.dart';
import '../components/hero_section.dart';
import '../components/honours_band.dart';
import '../components/services_section.dart';
import '../components/work_section.dart';

/// The landing page.
///
/// Async because the work teaser, the services row and the about band all read
/// repositories. The awaits happen here, once, and the resolved data is handed
/// down — so the entire page, cards included, is present in the pre-rendered
/// HTML. Fetching
/// inside the sections instead would either serve crawlers a loading state or
/// throw, depending on how it was reached for; see CLAUDE.md §1.
///
/// Section tones alternate base → raised → base → raised so the page reads as
/// stacked bands. [AboutSection] and [ContactSection] set their own ground
/// because they are two-column splits rather than centred blocks.
class HomePage extends AsyncStatelessComponent {
  const HomePage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    // Every project, not just a teaser: the work section renders the newest
    // as a feature card and the full set as its filterable index.
    final featured = await Locator.projects.getProjects();
    final services = await Locator.services.getServices();
    final about = await Locator.about.getProfile();

    // Resolved once: the profile feeds both the About band and the `knowsAbout`
    // claim in the Person JSON-LD, and those two must describe the same person.
    final profile = about.getOrElse((_) => const AboutProfile());
    final aboutError = about.fold<String?>((message) => message, (_) => null);

    return Component.fragment([
      const PageMeta(
        path: RoutePaths.home,
        title: '${SiteConfig.name} — ${SiteConfig.role}',
        description: SiteConfig.tagline,
      ),
      StructuredData(
        id: 'ld-person',
        SchemaOrg.person(knowsAbout: profile.skillNames),
      ),
      StructuredData(id: 'ld-website', SchemaOrg.website()),

      const HeroSection(),          // base
      // Sits directly under the hero, sharing its ground so the plate reads as
      // seated on the same sheet rather than as the next section starting.
      HonoursBand(
        education: profile.education.isEmpty ? null : profile.education.first,
      ),
      AboutSection(                 // base  (own ground)
        profile: profile,
        error: aboutError,
      ),

      // A failure in either repository must not blank the page — everything
      // around it is static content that still deserves to be indexed. The
      // services row surfaces its `Left` as a real block; the work teaser
      // degrades to its heading and the link to the full index.
      ServicesSection(              // raised
        services: services.getOrElse((_) => const []),
        error: services.fold<String?>((message) => message, (_) => null),
      ),

      WorkSection(projects: featured.getOrElse((_) => const [])), // base
      const ContactSection(),       // raised
    ]);
  }
}
