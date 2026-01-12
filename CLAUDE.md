# Klui Dev Instructions for AI

**Project**: Letta Flutter UI (klui)
**Owner**: Kosmo
**Repo**: https://github.com/kosmoli/klui
**Language**: 中文交流（代码注释和commit message用英文）

## Priority Rules

### 1. Git Golden Rules (CRITICAL - Follow Strictly)
- ✅ **Commit ONLY** - Never use stash as backup
- ✅ **Verify content** - `git diff --cached` before every commit
- ✅ **Complete restoration** - Never selective file restore
- ✅ **Deploy chain verify** - Git → Build → Server → Browser
- ❌ **No stash backup** - Use commit, not stash
- ❌ **No selective restore** - Restore all or nothing
- ❌ **No trust in labels** - Verify actual content only

**Emergency if code lost**:
```bash
git reflog show --date=format='%m-%d %H:%M:%S' | head -50
git reset --hard <target-commit>
git commit -m "EMERGENCY: restore"
git push --force
```

**Full rules**: `docs/GIT_WORKFLOW_GOLDEN_RULES.md`

### 2. Problem Solving Priority
1. **Check docs first**: `klui/docs/` (DEPLOYMENT_TEST_STEPS.md, FLUTTER_WEB_PITFALLS.md, LETTA_PROJECT_ANALYSIS.md)
2. **Reference implementations**: Letta Code (terminal UI), Happy (mobile/web UI)
3. **Try standard solutions**: Check code, logs, debug tools
4. **Search internet**: Use WebSearch tool for errors/best practices
5. **Update docs**: Record findings in relevant docs

**Search examples**: "Flutter Web CORS error", "Letta API provider configuration"

### 3. Tech Stack
- Flutter 3.38.5, Dart 3.10.4, WebAssembly compilation
- Riverpod 3.0.3 (code generation with `@riverpod`)
- go_router 16.x for routing
- flutter_http_sse for streaming (planned)

### 3.1 Architecture (MANDATORY - Follow Strictly)

**Three-Layer Architecture**:
```
UI Layer (features/)
  ↓ only uses providers
Provider Layer (core/providers/api_providers.dart)
  ↓ only uses ApiHelper + ApiClient
API Layer (core/utils/api_client.dart, api_helper.dart)
  ↓ HTTP requests
Letta Backend
```

**Rules**:
1. ✅ UI MUST access data via `ref.watch(provider)` or `ref.read(provider.future)`
2. ✅ Providers MUST use `ApiHelper.parseList/parseSingle/parseEmpty`
3. ✅ Providers MUST handle errors via `ApiException`
4. ❌ UI MUST NOT import `api_client.dart` directly
5. ❌ Providers MUST NOT contain UI logic (navigation, formatting, etc.)

**Example**:
```dart
// ✅ CORRECT
@riverpod
Future<List<Agent>> agentList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/');
  return ApiHelper.parseList(response, Agent.fromJson);
}

// ❌ WRONG
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(apiClientProvider);  // ❌ Don't do this
    ...
  }
}
```

**SDK Separation Readiness**:
- Current: API layer embedded in klui (~430 lines)
- When to separate: API code > 2000 lines OR multiple consumer projects
- See: `docs/API_LAYER_OPTIMIZATION.md`

### 4. API Integration
**API Base**: http://38.175.200.93:8283/v1
**All requests need**: Bearer Token authentication
**Key endpoints**: Agents (52), Tools (21), Providers (7), Models (3)
**Full API docs**: `docs/LETTA_API_OVERVIEW.md`

**Provider modes**:
- **Base**: Memory providers from env vars (non-BYOK)
- **BYOK**: Database providers, user-created (requires Provider management UI)

### 5. Current Status
**Phase**: Phase 0 - Project initialization
**Latest working commit**: 0507713 (restored from stash@{0})
**Features**:
- ✅ Agent list (with delete)
- ✅ Agent create screen (1303 lines, BYOK mode)
- ✅ Agent detail screen (484 lines)
- ✅ Dark theme (Neo-Brutalist design)
- ⏳ Real-time chat (SSE streaming)
- ⏳ Provider management
- ⏳ Tools management

### 6. Core Models
**Agent**: id, name, description, systemPrompt, tools[], createdAt
**LLMModel**: handle, name, displayName, providerName, model, modelType ("llm"/"embedding")
**ProviderConfig**: name, providerType, isBase, isDefault, tags[]
**EmbeddingModel**: Similar to LLMModel

**Key**: `modelType` field distinguishes LLM vs embedding models

### 7. Build & Deploy
**🚨 CRITICAL: ALWAYS use deploy.sh script - NEVER manual build commands!**

**Working Directory**: `/root/work/klui` (NEVER run from /root/work)

**After code changes, ALWAYS build and deploy**:
```bash
cd /root/work/klui  # MUST be in klui directory!
./deploy.sh
```

**⛔ DO NOT use manual commands like**:
- ❌ `flutter build web` (WRONG - use deploy.sh instead)
- ❌ `dart run build_runner` (WRONG - deploy.sh handles this)
- ❌ Direct python server start (WRONG - deploy.sh manages this)

**✅ ALWAYS use deploy.sh because it**:
- ✅ Verifies correct directory
- ✅ Sets correct Flutter PATH
- ✅ Builds with correct API_BASE_URL
- ✅ Stops old HTTP server
- ✅ Starts new HTTP server
- ✅ Shows verification info

**Verify directory before deploy**:
```bash
pwd  # Should show: /root/work/klui
ls deploy.sh  # Should exist
```

**Full paths** (to avoid directory confusion):
- Flutter SDK: `/opt/flutter/bin`
- Flutter executable: `/opt/flutter/bin/flutter`
- Dart executable: `/opt/flutter/bin/dart`
- Project root: `/root/work/klui`
- Deploy script: `/root/work/klui/deploy.sh`

**Deploy script does**:
- Build Flutter web app
- Stop old HTTP server
- Start new HTTP server on port 8080
- Show verification info

**Important**: Browser hard refresh required (Ctrl+Shift+R)

**Note**: Keep this file concise. Follow brief style when adding new requirements.

### 8. Letta Backend Analysis
**Location**: `/root/work/letta/`
**Analysis**: `docs/LETTA_PROJECT_ANALYSIS.md` (16 chapters)
**Key findings**:
- Provider selection: Base (env vars) vs BYOK (database)
- Embedding API key: Cannot separate from LLM API key in base mode
- letta-free model: Has inconsistent `model_type` across endpoints

**When investigating backend**:
1. Use Read/Grep/Glob tools in `/root/work/letta/`
2. Update `docs/LETTA_PROJECT_ANALYSIS.md` with findings
3. Include code evidence and examples

### 8.1 Letta Code Analysis (Terminal UI Reference)
**Location**: `/root/work/letta-code/`
**Analysis**: `docs/LETTA_CODE_ANALYSIS.md`
**Purpose**: Reference for terminal-based coding agent UI
**Key learnings**:
- Message display patterns (Ink/React for CLI)
- Tool call presentation (expandable cards)
- Approval workflow UX (inline approvals)
- Streaming implementation (SSE handling)
- Error handling patterns

**When investigating Letta Code**:
1. Focus on `src/cli/App.tsx` (main app, 270KB)
2. Check `src/cli/components/` for UI patterns
3. Review `src/tools/manager.ts` for tool execution
4. Update `docs/LETTA_CODE_ANALYSIS.md` with findings

### 8.2 Happy Analysis (Mobile/Web UI Reference)
**Location**: `/root/work/happy/`
**Analysis**: `docs/HAPPY_ANALYSIS.md`
**Purpose**: Reference for cross-platform (React Native + Expo) agent UI
**Key learnings**:
- Mobile UI patterns for agent chat
- Real-time message streaming (LiveKit/WebRTC)
- Responsive design strategies
- Code display on mobile
- Performance optimizations (FlashList)
- Touch interactions and gestures

**When investigating Happy**:
1. Focus on `sources/components/AgentInput.tsx` (45KB input component)
2. Check `sources/app/` for routing/navigation
3. Review `sources/components/` for UI patterns
4. Update `docs/HAPPY_ANALYSIS.md` with findings

### 9. Documentation Structure
`klui/docs/`:
- DEPLOYMENT_TEST_STEPS.md (11,883 bytes)
- FLUTTER_PLAN_2026.md (19,795 bytes)
- LETTA_API_OVERVIEW.md (15,987 bytes)
- LETTA_PROJECT_ANALYSIS.md (166,733 bytes)
- LETTA_CODE_ANALYSIS.md (NEW) - Terminal UI reference
- HAPPY_ANALYSIS.md (NEW) - Mobile/Web UI reference
- CHAT_FEATURE_PLAN.md (NEW) - Chat implementation plan
- GIT_WORKFLOW_GOLDEN_RULES.md
- FLUTTER_WEB_PITFALLS.md (backup only)

### 10. Commit & Workflow
**Commit message format** (Must use standard English):
```
type: description

[optional body]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>
```

**Types**: feat, fix, docs, style, refactor, test, chore
**Examples**:
- `feat: implement BYOK mode agent creation`
- `fix: handle embedding model display with handle`
- `docs: update API documentation`

**Important**: Always use English for commits, Chinese for conversation only

**After testing succeeds**:
```bash
git tag -a v1.x-working -m "Tested and working"
git push origin main
git push origin v1.x-working
```

### 11. Code Quality
- Use `const` constructors
- Use `ListView.builder` not `ListView()`
- Delay load routes with `import ... deferred`
- Error handling: try-catch with user-friendly messages
- Riverpod: Use `@riverpod` annotation with code generation
- **Data Models MUST use Freezed** (see 11.5 below)
- **Logging MUST use KluiLogger** (see 11.6 below)

### 11.1 CRITICAL: Command Retry Rule (MUST FOLLOW)

**STRICT LIMIT**: If a command fails with the same error, retry AT MOST ONCE

**Examples of PROHIBITED behavior**:
- ❌ Running `grep file.txt` 50+ times when it says "No such file"
- ❌ Repeating failed `cd` or `ls` commands without changing approach
- ❌ Ignoring error messages and hoping they'll go away

**Correct behavior**:
- ✅ Command fails → Check error → Try ONCE with fix → If still fails, STOP and ask user
- ✅ File not found → Verify path with `pwd`/`find` → Try corrected path → If still fails, STOP
- ✅ Build error → Read error message → Fix code → Rebuild → If still fails, ask for help

**Emergency stop trigger**: If you notice yourself repeating the same command > 2 times, immediately STOP and ask user for guidance.

**This rule prevents infinite loops and wasted tokens.**

### 11.2 Code Architecture Rules (MANDATORY)
**Follow three-layer architecture strictly**:

**DO**:
- ✅ UI → Provider → ApiHelper → ApiClient → HTTP
- ✅ Use `ref.watch(provider)` in widgets
- ✅ Use `ApiHelper.parseList/parseSingle/parseEmpty` in providers
- ✅ Handle errors with `ApiException`

**DON'T**:
- ❌ Import `api_client.dart` in UI code
- ❌ Put UI logic (navigation, formatting) in providers
- ❌ Scatter JSON parsing (use ApiHelper)
- ❌ Mix concerns across layers

### 11.3 Semantics & i18n (MANDATORY - Accessibility & Internationalization)

**CRITICAL**: Follow these standards for ALL UI code

#### Semantics Standards

**Priority 1: Use Standard Widgets** - They already have Semantics
- IconButton, TextButton, ElevatedButton, TextField, Checkbox, etc.
- NO extra Semantics wrapper needed for standard widgets

**Priority 2: Add Custom Semantics When**:
1. **Decorative icons** (Icon widgets without text): `label + button: true`
2. **Images**: `label: 'Descriptive alt text'` (avoid "image")
3. **Custom controls** (GestureDetector, InkWell, Stack): `button: true + label + hint`
4. **Pure decoration**: `excludeSemantics: true` or `ExcludeSemantics` wrapper
5. **Icon+Text combos**: `MergeSemantics` to combine into one label
6. **Textless clickables**: Add `hint` (e.g., "Double tap to zoom")

**Label Rules**:
- Concise, descriptive
- Start with widget type if not obvious: "Agent card: ..."
- Include state: "(selected)", "(destructive action)"
- Use i18n strings via `context.l10n.key_name`

**i18n Standards**:
- ALL user-visible strings → use `context.l10n.string_key`
- Setup: Flutter's official `flutter_localizations` + `intl` package
- ARB files: `lib/l10n/app_en.arb` (template), `lib/l10n/app_zh.arb` (Chinese)
- Generated code: `lib/l10n/generated/app_localizations.dart`
- Access: Import `context_extensions.dart`, use `context.l10n.key_name`

**Example Implementation**:
```dart
// Standard widget - NO custom Semantics needed
TextButton(onPressed: () {}, child: Text('Save'))

// Decorative icon - NEEDS Semantics
Semantics(
  label: context.l10n.agent_action_delete,
  button: true,
  hint: context.l10n.agent_action_delete_hint,
  child: Icon(Icons.delete),
)

// Icon+Text combo - USE MergeSemantics
MergeSemantics(
  child: Row(children: [
    Icon(Icons.delete),
    Text(context.l10n.agent_action_delete),
  ]),
)

// Custom clickable - NEEDS Semantics
Semantics(
  label: context.l10n.agent_card_label(
    agent.name,
    agent.agentType ?? context.l10n.agent_card_not_specified,
    agent.model ?? context.l10n.agent_card_not_specified,
  ),
  button: true,
  hint: context.l10n.agent_card_hint_view_details,
  child: InkWell(onTap: () {}, child: Card(...)),
)
```

**Build Commands**:
- Setup: `flutter gen-l10n` (generates from ARB files)
- Rebuild: `flutter build web` (auto-generates l10n + riverpod)

### 11.4 Theme System Usage (MANDATORY - Color Management)

**CRITICAL**: ALL new code MUST use theme system for colors

#### Why Theme System?
- **Single source of truth**: Change colors in ONE place, entire app updates
- **Theme switching ready**: Easy to add light/dark/custom themes later
- **Future-proof**: Follows Flutter best practices for theming

#### How to Use Theme System

**✅ CORRECT - Use Theme Extension**:
```dart
@override
Widget build(BuildContext context) {
  final colors = Theme.of(context).extension<KluiCustomColors>()!;

  return Container(
    color: colors.surface,              // ✅ Theme-aware
    border: Border.all(color: colors.border),
    child: Text(
      'Hello',
      style: TextStyle(color: colors.textPrimary),
    ),
  );
}
```

**❌ WRONG - Direct KluiColors**:
```dart
import 'klui_colors.dart';

Container(
  color: KluiColors.surface,  // ❌ Not theme-aware
  border: Border.all(color: KluiColors.border),
)
```

#### Available Colors

```dart
final colors = Theme.of(context).extension<KluiCustomColors>()!;

// Backgrounds
colors.background          // Main background
colors.surface            // Card/surface background
colors.surfaceVariant     // Input/variant background

// Message Bubbles
colors.userBubble         // User message background (CRT green)
colors.userText           // Text on user bubble
colors.assistantBubble    // Assistant message background
colors.assistantText      // Assistant message text
colors.reasoning          // Thinking/reasoning text

// Tool Colors
colors.toolFile           // File operations
colors.toolSearch         // Search operations

// Status Colors
colors.success            // Success state
colors.error              // Error state
colors.warning            // Warning state

// Text Colors
colors.textPrimary        // Primary text
colors.textSecondary      // Secondary text
colors.textDisabled       // Disabled text

// Border
colors.border             // Standard border
```

#### Import Requirements

```dart
import '../../core/theme/klui_theme_extension.dart';
// DO NOT import 'klui_colors.dart' in new code
```

#### Legacy Code

Old code using `KluiColors.xxx` still works but should be refactored when touched.
Priority for refactoring:
1. High-traffic components (cards, lists, navigation)
2. User-facing messages
3. Status indicators
4. Low-utility widgets (can keep `KluiColors` if rarely used)

### 12. DO NOT
- ❌ Modify Letta backend code (unless necessary)
- ❌ Use Freezed for Web (compilation issues) - **NOTE: This restriction is outdated. Freezed IS now REQUIRED for all data models.**
- ❌ Hide advanced options (this is for power users)
- ❌ Over-engineer simple features
- ❌ Add comments/docs unless requested
- ❌ Forget error handling at system boundaries
- ❌ **Skip Semantics annotations (blocks accessibility & testing)**
- ❌ **Violate three-layer architecture (see 11.2)**
- ❌ **Use KluiColors directly in new code (use Theme.of(context).extension<KluiCustomColors>() instead)**
- ❌ **Create data models without Freezed (see 11.5 below)**
- ❌ **Use print() statements for logging (use KluiLogger instead, see 11.6 below)**

### 11.5 Data Models MUST Use Freezed (MANDATORY)

**CRITICAL**: All data models in `lib/core/models/` MUST use Freezed package.

#### Why Freezed?
- ✅ Immutable data classes by default
- ✅ Auto-generated `copyWith`, `==`, `hashCode`, `toString`
- ✅ Built-in JSON serialization with `@freezed` annotation
- ✅ Union types (sealed classes) for state management
- ✅ Null safety and pattern matching support

#### How to Use Freezed

**Basic Model**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_model.freezed.dart';
part 'my_model.g.dart';

@freezed
class MyModel with _$MyModel {
  const factory MyModel({
    required String id,
    required String name,
    String? description,
  }) = _MyModel;

  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
}
```

**Model with Collections**:
```dart
@freezed
class Agent with _$Agent {
  const factory Agent({
    required String id,
    required String name,
    @Default([]) List<String> tools,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Agent;

  factory Agent.fromJson(Map<String, dynamic> json) => _$AgentFromJson(json);
}
```

#### Current Models Using Freezed
- ✅ `chat_message.dart` - Chat messages with type enums
- ✅ `agent.dart` - Agent configuration
- ✅ `provider.dart` - Provider configuration
- ✅ `llm_model.dart` - LLM model definitions
- ✅ `embedding_model.dart` - Embedding model definitions

#### Non-Freezed Files (To Be Migrated)
The following files should be migrated to Freezed when touched:
- `message.dart` - Internal message type
- `create_agent_request.dart` - Request DTOs
- `create_provider_request.dart` - Request DTOs
- `create_agent_example.dart` - Example data

#### Build Commands
- Generate code: `dart run build_runner build --delete-conflicting-outputs`
- Regenerate after model changes
- Freezed generates both `.freezed.dart` and `.g.dart` files

### 11.6 Logging Standards (MANDATORY)

**CRITICAL**: All code MUST use `KluiLogger` instead of `print()` statements.

#### Why Use KluiLogger?
- ✅ Structured log levels (FINEST, DEBUG, INFO, WARNING, SEVERE)
- ✅ Timestamps and source tracking
- ✅ Production-ready (auto-filters debug logs in release mode)
- ✅ Consistent formatting across the app
- ✅ Easy to redirect to external logging services

#### How to Use KluiLogger

**Import and Initialize**:
```dart
import '../utils/logger.dart';

// Create logger at file level
final _log = KluiLogger('MyClassName');
```

**Log Levels**:
```dart
// DEBUG - Detailed diagnostics (hidden in release)
_log.debug('Variable value: $variable');
_log.d('Shorthand for debug');

// INFO - General information (shown in release)
_log.info('User logged in');
_log.i('Shorthand for info');

// WARNING - Something unexpected but recoverable
_log.warning('Cache miss, fetching from network');
_log.w('Shorthand for warning');

// ERROR - Error that occurred
_log.error('Failed to connect to API', error, stackTrace);
_log.e('Shorthand for error');
```

**Initialization in main()**:
```dart
void main() {
  initLogging(); // MUST be first
  runApp(MyApp());
}
```

#### Log Level Guidelines

- **DEBUG**: Variable values, detailed flow, JSON dumps
- **INFO**: User actions, API calls, state changes
- **WARNING**: Retry attempts, fallbacks, deprecated usage
- **ERROR**: Exceptions, API failures, validation errors

#### DO
- ✅ Use `KluiLogger` in all new code
- ✅ Use appropriate log levels
- ✅ Include context in log messages
- ✅ Log errors with error objects and stack traces

#### DON'T
- ❌ Use `print()` statements (breaks production)
- ❌ Log sensitive data (passwords, tokens, PII)
- ❌ Use excessive DEBUG logging (performance impact)
- ❌ Forget to call `initLogging()` in main()

### 13. Project Goals
**Core定位**: Serve professional users who need full API access
**Difference from official UI**: Official = simplified for beginners, klui = complete for experts
**Design philosophy**: Expose ALL API functionality, don't hide advanced options

**BYOK mode**: Full provider management UI required
**Non-BYOK mode**: Use Letta defaults, no database provider needed

---

**Last Updated**: 2026-01-11
**Claude Version**: Sonnet 4.5
**Mode**: Frontend Development 🚀
