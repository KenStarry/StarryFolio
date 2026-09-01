// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the contact form island.
///
/// Client-side only, like every controller here — it calls `fetch`, which does
/// not exist during the static build. The `kIsWeb` guard means a server-side
/// render can never reach that code path.

@ProviderFor(ContactFormController)
final contactFormControllerProvider = ContactFormControllerProvider._();

/// Drives the contact form island.
///
/// Client-side only, like every controller here — it calls `fetch`, which does
/// not exist during the static build. The `kIsWeb` guard means a server-side
/// render can never reach that code path.
final class ContactFormControllerProvider
    extends $NotifierProvider<ContactFormController, ContactFormState> {
  /// Drives the contact form island.
  ///
  /// Client-side only, like every controller here — it calls `fetch`, which does
  /// not exist during the static build. The `kIsWeb` guard means a server-side
  /// render can never reach that code path.
  ContactFormControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'contactFormControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$contactFormControllerHash();

  @$internal
  @override
  ContactFormController create() => ContactFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactFormState>(value),
    );
  }
}

String _$contactFormControllerHash() =>
    r'6c8372972b9838fad60715c4c5fe6fb8a1f570d1';

/// Drives the contact form island.
///
/// Client-side only, like every controller here — it calls `fetch`, which does
/// not exist during the static build. The `kIsWeb` guard means a server-side
/// render can never reach that code path.

abstract class _$ContactFormController extends $Notifier<ContactFormState> {
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
