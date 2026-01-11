# API Layer Optimization

**Last Updated**: 2026-01-11
**Purpose**: Document current API layer structure and path to SDK separation

## Current Status

We have a clean, well-organized API layer that is ready for extraction into a separate SDK when needed.

### Architecture

```
lib/core/
├── utils/
│   ├── api_client.dart          # HTTP client with retry logic
│   └── api_helper.dart          # NEW: Unified parsing & error handling
└── providers/
    └── api_providers.dart       # Riverpod providers (13 providers)
```

### Key Components

#### 1. ApiClient (`lib/core/utils/api_client.dart`)
- HTTP client wrapper
- Automatic retry (3 attempts, exponential backoff)
- Auth interceptor
- Methods: `get()`, `post()`, `put()`, `delete()`

#### 2. ApiHelper (`lib/core/utils/api_helper.dart`) - NEW
**Purpose**: Centralized response parsing and error handling

**Features**:
```dart
// Parse list responses
List<Agent> agents = ApiHelper.parseList(response, Agent.fromJson);

// Parse single object
Agent agent = ApiHelper.parseSingle(response, Agent.fromJson);

// Parse empty response (DELETE)
ApiHelper.parseEmpty(response);

// Unified error handling
throw ApiException.fromResponse(response);
```

**Benefits**:
- Eliminates duplicate JSON parsing code
- Consistent error messages
- Easy to extend with new features
- Ready for SDK extraction

#### 3. Providers (`lib/core/providers/api_providers.dart`)
13 Riverpod providers covering:
- Agent CRUD (4 providers)
- Provider CRUD (4 providers)
- Model listing (5 providers)

## Current Usage Pattern

### UI Layer (Features)
```dart
// ✅ CORRECT: Use providers
final agents = await ref.read(agentListProvider.future);
final agent = await ref.read(agentProvider(id).future);

// ❌ AVOID: Direct API calls
final response = await ref.read(apiClientProvider).get('/agents');
```

### Provider Layer
```dart
// Uses ApiHelper for parsing
@riverpod
Future<List<Agent>> agentList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/');
  return ApiHelper.parseList(response, Agent.fromJson);
}
```

## Optimization Completed

### ✅ What We Did

1. **Added ApiHelper class** (`lib/core/utils/api_helper.dart`)
   - Unified response parsing
   - Centralized error handling
   - `ApiException` class
   - `ApiParseException` class

2. **Maintained Clean Architecture**
   - UI → Providers → ApiClient → HTTP
   - No direct API calls in UI layer (except 1 case to be fixed)

3. **Code Quality**
   - Consistent error messages
   - Reduced code duplication
   - Type-safe models

### ⚠️ Known Limitations

1. **Direct API Call** (`agent_create_screen.dart:96`)
   ```dart
   // TODO: Replace with embeddingModelListProvider
   final embeddingResponse = await ref.read(apiClientProvider).get('/models/embedding');
   ```
   - **Reason**: Original code uses LLMModel for embeddings (legacy design)
   - **Impact**: Low - only in one place
   - **Fix**: Should be addressed during EmbeddingModel refactor

2. **Scattered Providers**
   - All 13 providers in one file (349 lines)
   - **Impact**: Medium - harder to navigate
   - **Future**: Could split into feature-based files

3. **No Request Models**
   - Don't have request/response DTOs
   - **Impact**: Low - simple JSON serialization works fine
   - **Future**: Could add if complexity grows

## Path to SDK Separation

### Trigger Conditions (When to Separate)

Consider separating SDK when 3+ of these are true:

- [ ] API code > 2000 lines
- [ ] Second consumer project exists
- [ ] API relatively stable (few breaking changes)
- [ ] Chat/Messaging fully implemented
- [ ] Team size > 2 developers

### SDK Structure (Future)

```
letta-dart-sdk/
├── lib/
│   ├── letta_client.dart        # Main entry point
│   ├── src/
│   │   ├── client.dart           # HTTP client
│   │   ├── api_helper.dart       # Parsing & errors
│   │   ├── agents/
│   │   │   ├── agents_client.dart
│   │   │   └── models.dart
│   │   ├── providers/
│   │   ├── messages/
│   │   │   └── streaming.dart    # SSE support
│   │   └── models/
│   └── examples/
├── test/
├── pubspec.yaml
├── README.md
└── CHANGELOG.md
```

### Extraction Steps (Future)

1. **Create new package**
   ```bash
   mkdir letta-dart-sdk
   cd letta-dart-sdk
   dart create --template=package .
   ```

2. **Move API layer**
   ```bash
   cp -r klui/lib/core/utils/api_client.dart letta-dart-sdk/lib/src/client.dart
   cp -r klui/lib/core/utils/api_helper.dart letta-dart-sdk/lib/src/api_helper.dart
   cp -r klui/lib/core/models letta-dart-sdk/lib/src/models
   # ... and so on
   ```

3. **Add package exports**
   ```dart
   // letta_dart_sdk/letta_client.dart
   export 'src/client.dart';
   export 'src/api_helper.dart';
   export 'src/models/agent.dart';
   // ...
   ```

4. **Publish to pub.dev**
   ```bash
   dart pub publish
   ```

5. **Update klui**
   ```yaml
   # klui/pubspec.yaml
   dependencies:
     letta_client: ^1.0.0
   ```

## Best Practices (Current & Future)

### ✅ DO

1. **Always use providers in UI**
   ```dart
   final agents = ref.watch(agentListProvider);
   ```

2. **Let providers handle errors**
   ```dart
   try {
     final agent = await ref.read(createAgentProvider(request).future);
   } catch (e) {
     // Show user-friendly error
   }
   ```

3. **Keep API layer independent**
   - No UI logic in providers
   - No navigation in providers
   - No UI-specific formatting

4. **Use ApiHelper for parsing**
   ```dart
   return ApiHelper.parseList(response, Model.fromJson);
   ```

### ❌ DON'T

1. **Don't import api_client in UI**
   ```dart
   // ❌ WRONG
   import '../../core/utils/api_client.dart';
   final response = await client.get('/agents');
   ```

2. **Don't mix concerns**
   ```dart
   // ❌ WRONG
   @riverpod
   Future<Agent> createAgent(Ref ref, Agent agent) async {
     final client = ref.watch(apiClientProvider);
     final response = await client.post('/agents', body: agent.toJson());

     // ❌ Don't navigate here
     // context.go('/agents/${agent.id}');

     return Agent.fromJson(jsonDecode(response.body));
   }
   ```

3. **Don't scatter error handling**
   ```dart
   // ❌ WRONG: Different error handling everywhere
   if (response.statusCode == 404) {
     throw Exception('Not found');
   } else if (response.statusCode == 500) {
     throw Exception('Server error');
   }

   // ✅ CORRECT: Use ApiHelper
   ApiHelper.parseSingle(response, Agent.fromJson);
   ```

## Metrics

### Current State
- **API Layer Size**: ~430 lines
- **Number of Providers**: 13
- **Number of Models**: 6
- **Code Duplication**: Reduced from 13 → 1 (ApiHelper)
- **Error Handling**: Unified via ApiException

### Target State for SDK Separation
- **API Layer Size**: >2000 lines
- **Number of Providers**: 30+
- **Number of Models**: 15+
- **Features**: Chat, SSE, Tools, Approvals

## Next Steps

### Immediate (Current Sprint)
- [x] Add ApiHelper
- [x] Add ApiException
- [x] Document architecture
- [ ] Fix remaining direct API call (optional)

### Short-term (Next Few Sprints)
- [ ] Implement Chat functionality
- [ ] Add SSE streaming support
- [ ] Create ChatApiClient

### Long-term (When Ready)
- [ ] Evaluate SDK separation criteria
- [ ] If 3+ criteria met, start separation
- [ ] Publish to pub.dev

## References

- **Letta TypeScript SDK**: https://github.com/letta-ai/letta-client-typescript
- **Dart Package Publishing**: https://dart.dev/tools/pub/publishing
- **Pub Package Layout**: https://dart.dev/tools/pub/glossary#layout

---

**Conclusion**: Our API layer is well-structured and ready for SDK separation when the time is right. The ApiHelper addition has reduced code duplication and improved error handling. We should focus on building features (Chat, Messaging) now, and revisit SDK separation when we have more code and a stable API.
