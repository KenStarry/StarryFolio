// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'testimonial_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(TestimonialFormController)
final testimonialFormControllerProvider = TestimonialFormControllerProvider._();

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
final class TestimonialFormControllerProvider
    extends $NotifierProvider<TestimonialFormController, ContactFormState> {
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
  TestimonialFormControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'testimonialFormControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$testimonialFormControllerHash();

  @$internal
  @override
  TestimonialFormController create() => TestimonialFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactFormState>(value),
    );
  }
}

String _$testimonialFormControllerHash() =>
    r'033a35975ad69c03ff1adfb31da58c86774abf9b';

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

abstract class _$TestimonialFormController extends $Notifier<ContactFormState> {
  ContactFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ContactFormState, ContactFormState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ContactFormState, ContactFormState>,
        ContactFormState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
