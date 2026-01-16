// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for Agent's Tools

@ProviderFor(agentTools)
const agentToolsProvider = AgentToolsFamily._();

/// Provider for Agent's Tools

final class AgentToolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tool>>,
          List<Tool>,
          FutureOr<List<Tool>>
        >
    with $FutureModifier<List<Tool>>, $FutureProvider<List<Tool>> {
  /// Provider for Agent's Tools
  const AgentToolsProvider._({
    required AgentToolsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'agentToolsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentToolsHash();

  @override
  String toString() {
    return r'agentToolsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Tool>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tool>> create(Ref ref) {
    final argument = this.argument as String;
    return agentTools(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentToolsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentToolsHash() => r'5fb8174eb0231c72bddab3d0d577b99648b78bb0';

/// Provider for Agent's Tools

final class AgentToolsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Tool>>, String> {
  const AgentToolsFamily._()
    : super(
        retry: null,
        name: r'agentToolsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for Agent's Tools

  AgentToolsProvider call(String agentId) =>
      AgentToolsProvider._(argument: agentId, from: this);

  @override
  String toString() => r'agentToolsProvider';
}

/// Provider for All Available Tools

@ProviderFor(allTools)
const allToolsProvider = AllToolsProvider._();

/// Provider for All Available Tools

final class AllToolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tool>>,
          List<Tool>,
          FutureOr<List<Tool>>
        >
    with $FutureModifier<List<Tool>>, $FutureProvider<List<Tool>> {
  /// Provider for All Available Tools
  const AllToolsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allToolsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allToolsHash();

  @$internal
  @override
  $FutureProviderElement<List<Tool>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tool>> create(Ref ref) {
    return allTools(ref);
  }
}

String _$allToolsHash() => r'80e0a79875451722e4c3ee0593bcd93512325f38';

/// Provider for Attaching Tool to Agent

@ProviderFor(attachTool)
const attachToolProvider = AttachToolFamily._();

/// Provider for Attaching Tool to Agent

final class AttachToolProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Provider for Attaching Tool to Agent
  const AttachToolProvider._({
    required AttachToolFamily super.from,
    required ({String agentId, String toolId}) super.argument,
  }) : super(
         retry: null,
         name: r'attachToolProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attachToolHash();

  @override
  String toString() {
    return r'attachToolProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as ({String agentId, String toolId});
    return attachTool(ref, agentId: argument.agentId, toolId: argument.toolId);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachToolProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attachToolHash() => r'a49cd5de21c52bdbc0cf7e36b7f0dec72b20650b';

/// Provider for Attaching Tool to Agent

final class AttachToolFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({String agentId, String toolId})
        > {
  const AttachToolFamily._()
    : super(
        retry: null,
        name: r'attachToolProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for Attaching Tool to Agent

  AttachToolProvider call({required String agentId, required String toolId}) =>
      AttachToolProvider._(
        argument: (agentId: agentId, toolId: toolId),
        from: this,
      );

  @override
  String toString() => r'attachToolProvider';
}

/// Provider for Detaching Tool from Agent

@ProviderFor(detachTool)
const detachToolProvider = DetachToolFamily._();

/// Provider for Detaching Tool from Agent

final class DetachToolProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Provider for Detaching Tool from Agent
  const DetachToolProvider._({
    required DetachToolFamily super.from,
    required ({String agentId, String toolId}) super.argument,
  }) : super(
         retry: null,
         name: r'detachToolProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detachToolHash();

  @override
  String toString() {
    return r'detachToolProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as ({String agentId, String toolId});
    return detachTool(ref, agentId: argument.agentId, toolId: argument.toolId);
  }

  @override
  bool operator ==(Object other) {
    return other is DetachToolProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detachToolHash() => r'96322076cc549fc2b340174e17713c38d4dc2813';

/// Provider for Detaching Tool from Agent

final class DetachToolFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({String agentId, String toolId})
        > {
  const DetachToolFamily._()
    : super(
        retry: null,
        name: r'detachToolProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for Detaching Tool from Agent

  DetachToolProvider call({required String agentId, required String toolId}) =>
      DetachToolProvider._(
        argument: (agentId: agentId, toolId: toolId),
        from: this,
      );

  @override
  String toString() => r'detachToolProvider';
}
