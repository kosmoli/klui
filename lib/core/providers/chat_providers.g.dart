// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$chatStateHolderHash() => r'398df69adfe9d681aa05bdc5e7bde6414ea9ef47';

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
