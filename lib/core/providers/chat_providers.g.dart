// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global provider to persist the currently selected agent ID
/// This survives navigation between screens

@ProviderFor(SelectedAgentId)
const selectedAgentIdProvider = SelectedAgentIdProvider._();

/// Global provider to persist the currently selected agent ID
/// This survives navigation between screens
final class SelectedAgentIdProvider
    extends $NotifierProvider<SelectedAgentId, String> {
  /// Global provider to persist the currently selected agent ID
  /// This survives navigation between screens
  const SelectedAgentIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAgentIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAgentIdHash();

  @$internal
  @override
  SelectedAgentId create() => SelectedAgentId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedAgentIdHash() => r'5871f644e7afcdb99a8d465cd54c69ff91989afd';

/// Global provider to persist the currently selected agent ID
/// This survives navigation between screens

abstract class _$SelectedAgentId extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Chat state holder using Notifier for Riverpod 3.x

@ProviderFor(ChatStateHolder)
const chatStateHolderProvider = ChatStateHolderFamily._();

/// Chat state holder using Notifier for Riverpod 3.x
final class ChatStateHolderProvider
    extends $NotifierProvider<ChatStateHolder, ChatState> {
  /// Chat state holder using Notifier for Riverpod 3.x
  const ChatStateHolderProvider._({
    required ChatStateHolderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatStateHolderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatStateHolderHash();

  @override
  String toString() {
    return r'chatStateHolderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatStateHolder create() => ChatStateHolder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatStateHolderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatStateHolderHash() => r'ad03fb88e9f4478e7f8602894e08ec36a93559ec';

/// Chat state holder using Notifier for Riverpod 3.x

final class ChatStateHolderFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatStateHolder,
          ChatState,
          ChatState,
          ChatState,
          String
        > {
  const ChatStateHolderFamily._()
    : super(
        retry: null,
        name: r'chatStateHolderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Chat state holder using Notifier for Riverpod 3.x

  ChatStateHolderProvider call(String agentId) =>
      ChatStateHolderProvider._(argument: agentId, from: this);

  @override
  String toString() => r'chatStateHolderProvider';
}

/// Chat state holder using Notifier for Riverpod 3.x

abstract class _$ChatStateHolder extends $Notifier<ChatState> {
  late final _$args = ref.$arg as String;
  String get agentId => _$args;

  ChatState build(String agentId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ChatState, ChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatState, ChatState>,
              ChatState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
