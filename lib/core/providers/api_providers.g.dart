// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for API Client

@ProviderFor(apiClient)
const apiClientProvider = ApiClientProvider._();

/// Provider for API Client

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  /// Provider for API Client
  const ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'3551d104159b8ad2d26864a53c9723933ed20798';

/// Provider for Agent List

@ProviderFor(agentList)
const agentListProvider = AgentListProvider._();

/// Provider for Agent List

final class AgentListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Agent>>,
          List<Agent>,
          FutureOr<List<Agent>>
        >
    with $FutureModifier<List<Agent>>, $FutureProvider<List<Agent>> {
  /// Provider for Agent List
  const AgentListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentListHash();

  @$internal
  @override
  $FutureProviderElement<List<Agent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Agent>> create(Ref ref) {
    return agentList(ref);
  }
}

String _$agentListHash() => r'529cf9da508f8a414eea61271a315d7850202d2e';

/// Provider for single Agent

@ProviderFor(agent)
const agentProvider = AgentFamily._();

/// Provider for single Agent

final class AgentProvider
    extends $FunctionalProvider<AsyncValue<Agent>, Agent, FutureOr<Agent>>
    with $FutureModifier<Agent>, $FutureProvider<Agent> {
  /// Provider for single Agent
  const AgentProvider._({
    required AgentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'agentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentHash();

  @override
  String toString() {
    return r'agentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Agent> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Agent> create(Ref ref) {
    final argument = this.argument as String;
    return agent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentHash() => r'03615c190ad7dfcc24441e434b2c0eddd1bb5ab6';

/// Provider for single Agent

final class AgentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Agent>, String> {
  const AgentFamily._()
    : super(
        retry: null,
        name: r'agentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for single Agent

  AgentProvider call(String id) => AgentProvider._(argument: id, from: this);

  @override
  String toString() => r'agentProvider';
}

/// Provider for deleting an Agent

@ProviderFor(deleteAgent)
const deleteAgentProvider = DeleteAgentFamily._();

/// Provider for deleting an Agent

final class DeleteAgentProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Provider for deleting an Agent
  const DeleteAgentProvider._({
    required DeleteAgentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteAgentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteAgentHash();

  @override
  String toString() {
    return r'deleteAgentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return deleteAgent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteAgentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteAgentHash() => r'23930ead26f6bc98f762018b20ae30072ccaa127';

/// Provider for deleting an Agent

final class DeleteAgentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const DeleteAgentFamily._()
    : super(
        retry: null,
        name: r'deleteAgentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for deleting an Agent

  DeleteAgentProvider call(String id) =>
      DeleteAgentProvider._(argument: id, from: this);

  @override
  String toString() => r'deleteAgentProvider';
}

/// Provider for Provider List

@ProviderFor(providerList)
const providerListProvider = ProviderListProvider._();

/// Provider for Provider List

final class ProviderListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<models.ProviderConfig>>,
          List<models.ProviderConfig>,
          FutureOr<List<models.ProviderConfig>>
        >
    with
        $FutureModifier<List<models.ProviderConfig>>,
        $FutureProvider<List<models.ProviderConfig>> {
  /// Provider for Provider List
  const ProviderListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerListHash();

  @$internal
  @override
  $FutureProviderElement<List<models.ProviderConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<models.ProviderConfig>> create(Ref ref) {
    return providerList(ref);
  }
}

String _$providerListHash() => r'938dcf28ed80102178de4cbe68cfcc295a72c090';

/// Provider for single Provider

@ProviderFor(provider)
const providerProvider = ProviderFamily._();

/// Provider for single Provider

final class ProviderProvider
    extends
        $FunctionalProvider<
          AsyncValue<models.ProviderConfig>,
          models.ProviderConfig,
          FutureOr<models.ProviderConfig>
        >
    with
        $FutureModifier<models.ProviderConfig>,
        $FutureProvider<models.ProviderConfig> {
  /// Provider for single Provider
  const ProviderProvider._({
    required ProviderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'providerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$providerHash();

  @override
  String toString() {
    return r'providerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<models.ProviderConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<models.ProviderConfig> create(Ref ref) {
    final argument = this.argument as String;
    return provider(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$providerHash() => r'37853e15d270d218489a529c8cd7813e513ba213';

/// Provider for single Provider

final class ProviderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<models.ProviderConfig>, String> {
  const ProviderFamily._()
    : super(
        retry: null,
        name: r'providerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for single Provider

  ProviderProvider call(String id) =>
      ProviderProvider._(argument: id, from: this);

  @override
  String toString() => r'providerProvider';
}

/// Provider for LLM Models List (all models)
/// In Memos, all models come from user-created providers

@ProviderFor(llmModelList)
const llmModelListProvider = LlmModelListProvider._();

/// Provider for LLM Models List (all models)
/// In Memos, all models come from user-created providers

final class LlmModelListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LLMModel>>,
          List<LLMModel>,
          FutureOr<List<LLMModel>>
        >
    with $FutureModifier<List<LLMModel>>, $FutureProvider<List<LLMModel>> {
  /// Provider for LLM Models List (all models)
  /// In Memos, all models come from user-created providers
  const LlmModelListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'llmModelListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$llmModelListHash();

  @$internal
  @override
  $FutureProviderElement<List<LLMModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LLMModel>> create(Ref ref) {
    return llmModelList(ref);
  }
}

String _$llmModelListHash() => r'e1ba792a8b9c23e2cff28736bc41dffd450c5872';

/// Provider for LLM Models List filtered by provider name
/// This provider dynamically loads models for a specific provider

@ProviderFor(llmModelListByProvider)
const llmModelListByProviderProvider = LlmModelListByProviderFamily._();

/// Provider for LLM Models List filtered by provider name
/// This provider dynamically loads models for a specific provider

final class LlmModelListByProviderProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LLMModel>>,
          List<LLMModel>,
          FutureOr<List<LLMModel>>
        >
    with $FutureModifier<List<LLMModel>>, $FutureProvider<List<LLMModel>> {
  /// Provider for LLM Models List filtered by provider name
  /// This provider dynamically loads models for a specific provider
  const LlmModelListByProviderProvider._({
    required LlmModelListByProviderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'llmModelListByProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$llmModelListByProviderHash();

  @override
  String toString() {
    return r'llmModelListByProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<LLMModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LLMModel>> create(Ref ref) {
    final argument = this.argument as String;
    return llmModelListByProvider(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LlmModelListByProviderProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$llmModelListByProviderHash() =>
    r'989e0f45f49739619e41247ebba2f9fa7f55060e';

/// Provider for LLM Models List filtered by provider name
/// This provider dynamically loads models for a specific provider

final class LlmModelListByProviderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<LLMModel>>, String> {
  const LlmModelListByProviderFamily._()
    : super(
        retry: null,
        name: r'llmModelListByProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for LLM Models List filtered by provider name
  /// This provider dynamically loads models for a specific provider

  LlmModelListByProviderProvider call(String providerName) =>
      LlmModelListByProviderProvider._(argument: providerName, from: this);

  @override
  String toString() => r'llmModelListByProviderProvider';
}

/// Provider for Embedding Models List

@ProviderFor(embeddingModelList)
const embeddingModelListProvider = EmbeddingModelListProvider._();

/// Provider for Embedding Models List

final class EmbeddingModelListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EmbeddingModel>>,
          List<EmbeddingModel>,
          FutureOr<List<EmbeddingModel>>
        >
    with
        $FutureModifier<List<EmbeddingModel>>,
        $FutureProvider<List<EmbeddingModel>> {
  /// Provider for Embedding Models List
  const EmbeddingModelListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'embeddingModelListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$embeddingModelListHash();

  @$internal
  @override
  $FutureProviderElement<List<EmbeddingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EmbeddingModel>> create(Ref ref) {
    return embeddingModelList(ref);
  }
}

String _$embeddingModelListHash() =>
    r'15beba45029166b0f263358263b488f869df224e';

/// Provider for creating an Agent
/// In Memos, always uses simple format (no BYOK distinction)

@ProviderFor(createAgent)
const createAgentProvider = CreateAgentFamily._();

/// Provider for creating an Agent
/// In Memos, always uses simple format (no BYOK distinction)

final class CreateAgentProvider
    extends $FunctionalProvider<AsyncValue<Agent>, Agent, FutureOr<Agent>>
    with $FutureModifier<Agent>, $FutureProvider<Agent> {
  /// Provider for creating an Agent
  /// In Memos, always uses simple format (no BYOK distinction)
  const CreateAgentProvider._({
    required CreateAgentFamily super.from,
    required CreateAgentRequest super.argument,
  }) : super(
         retry: null,
         name: r'createAgentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createAgentHash();

  @override
  String toString() {
    return r'createAgentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Agent> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Agent> create(Ref ref) {
    final argument = this.argument as CreateAgentRequest;
    return createAgent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateAgentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createAgentHash() => r'b6307c845aca9f0fcfcd16cd0863e6c71e76a2bd';

/// Provider for creating an Agent
/// In Memos, always uses simple format (no BYOK distinction)

final class CreateAgentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Agent>, CreateAgentRequest> {
  const CreateAgentFamily._()
    : super(
        retry: null,
        name: r'createAgentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for creating an Agent
  /// In Memos, always uses simple format (no BYOK distinction)

  CreateAgentProvider call(CreateAgentRequest request) =>
      CreateAgentProvider._(argument: request, from: this);

  @override
  String toString() => r'createAgentProvider';
}

/// Provider for creating a Provider

@ProviderFor(createProvider)
const createProviderProvider = CreateProviderFamily._();

/// Provider for creating a Provider

final class CreateProviderProvider
    extends
        $FunctionalProvider<
          AsyncValue<models.ProviderConfig>,
          models.ProviderConfig,
          FutureOr<models.ProviderConfig>
        >
    with
        $FutureModifier<models.ProviderConfig>,
        $FutureProvider<models.ProviderConfig> {
  /// Provider for creating a Provider
  const CreateProviderProvider._({
    required CreateProviderFamily super.from,
    required CreateProviderRequest super.argument,
  }) : super(
         retry: null,
         name: r'createProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createProviderHash();

  @override
  String toString() {
    return r'createProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<models.ProviderConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<models.ProviderConfig> create(Ref ref) {
    final argument = this.argument as CreateProviderRequest;
    return createProvider(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createProviderHash() => r'ac7076b535b94c16d59623401c29a7453970c7e1';

/// Provider for creating a Provider

final class CreateProviderFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<models.ProviderConfig>,
          CreateProviderRequest
        > {
  const CreateProviderFamily._()
    : super(
        retry: null,
        name: r'createProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for creating a Provider

  CreateProviderProvider call(CreateProviderRequest request) =>
      CreateProviderProvider._(argument: request, from: this);

  @override
  String toString() => r'createProviderProvider';
}

/// Provider for deleting a Provider

@ProviderFor(deleteProvider)
const deleteProviderProvider = DeleteProviderFamily._();

/// Provider for deleting a Provider

final class DeleteProviderProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Provider for deleting a Provider
  const DeleteProviderProvider._({
    required DeleteProviderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteProviderHash();

  @override
  String toString() {
    return r'deleteProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return deleteProvider(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteProviderHash() => r'b1a8ccc54d093701b1b27327a3e671ed6d0c64e3';

/// Provider for deleting a Provider

final class DeleteProviderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const DeleteProviderFamily._()
    : super(
        retry: null,
        name: r'deleteProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for deleting a Provider

  DeleteProviderProvider call(String id) =>
      DeleteProviderProvider._(argument: id, from: this);

  @override
  String toString() => r'deleteProviderProvider';
}

/// Provider for updating an Agent

@ProviderFor(updateAgent)
const updateAgentProvider = UpdateAgentFamily._();

/// Provider for updating an Agent

final class UpdateAgentProvider
    extends $FunctionalProvider<AsyncValue<Agent>, Agent, FutureOr<Agent>>
    with $FutureModifier<Agent>, $FutureProvider<Agent> {
  /// Provider for updating an Agent
  const UpdateAgentProvider._({
    required UpdateAgentFamily super.from,
    required ({String id, CreateAgentRequest request}) super.argument,
  }) : super(
         retry: null,
         name: r'updateAgentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateAgentHash();

  @override
  String toString() {
    return r'updateAgentProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Agent> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Agent> create(Ref ref) {
    final argument = this.argument as ({String id, CreateAgentRequest request});
    return updateAgent(ref, id: argument.id, request: argument.request);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateAgentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateAgentHash() => r'bc2092061c07da976b709273878f45d5c0fa885f';

/// Provider for updating an Agent

final class UpdateAgentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Agent>,
          ({String id, CreateAgentRequest request})
        > {
  const UpdateAgentFamily._()
    : super(
        retry: null,
        name: r'updateAgentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for updating an Agent

  UpdateAgentProvider call({
    required String id,
    required CreateAgentRequest request,
  }) => UpdateAgentProvider._(argument: (id: id, request: request), from: this);

  @override
  String toString() => r'updateAgentProvider';
}

/// Provider for updating a Provider

@ProviderFor(updateProvider)
const updateProviderProvider = UpdateProviderFamily._();

/// Provider for updating a Provider

final class UpdateProviderProvider
    extends
        $FunctionalProvider<
          AsyncValue<models.ProviderConfig>,
          models.ProviderConfig,
          FutureOr<models.ProviderConfig>
        >
    with
        $FutureModifier<models.ProviderConfig>,
        $FutureProvider<models.ProviderConfig> {
  /// Provider for updating a Provider
  const UpdateProviderProvider._({
    required UpdateProviderFamily super.from,
    required ({String id, CreateProviderRequest request}) super.argument,
  }) : super(
         retry: null,
         name: r'updateProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateProviderHash();

  @override
  String toString() {
    return r'updateProviderProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<models.ProviderConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<models.ProviderConfig> create(Ref ref) {
    final argument =
        this.argument as ({String id, CreateProviderRequest request});
    return updateProvider(ref, id: argument.id, request: argument.request);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateProviderHash() => r'6b81b073b02ebaab31d360b961b9ad0a8b901678';

/// Provider for updating a Provider

final class UpdateProviderFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<models.ProviderConfig>,
          ({String id, CreateProviderRequest request})
        > {
  const UpdateProviderFamily._()
    : super(
        retry: null,
        name: r'updateProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for updating a Provider

  UpdateProviderProvider call({
    required String id,
    required CreateProviderRequest request,
  }) => UpdateProviderProvider._(
    argument: (id: id, request: request),
    from: this,
  );

  @override
  String toString() => r'updateProviderProvider';
}
