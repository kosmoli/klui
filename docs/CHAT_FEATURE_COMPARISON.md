# Chat Feature Comparison & Implementation Plan

**Date**: 2026-01-12
**Status**: Planning Phase
**Purpose**: Compare Klui with reference implementations and prioritize missing features

---

## Executive Summary

After analyzing three projects (Klui, Letta Code, Happy), Klui has implemented **core chat functionality** but is missing **critical user experience features** that are present in reference implementations.

### Current Status
- ✅ **Working**: SSE streaming, message types, agent switching, error handling
- ❌ **Missing**: Abort functionality, message persistence, diff visualization, input autocomplete, error retry

---

## Feature Comparison Matrix

| Feature | Klui | Letta Code | Happy | Priority | Complexity |
|---------|------|------------|-------|----------|------------|
| **Core Messaging** |
| User messages | ✅ | ✅ | ✅ | - | - |
| Assistant messages | ✅ | ✅ | ✅ | - | - |
| Reasoning messages | ✅ | ✅ | ✅ | - | - |
| Tool call messages | ✅ | ✅ | ✅ | - | - |
| Tool return messages | ✅ | ✅ | ✅ | - | - |
| Error messages | ✅ | ✅ | ✅ | - | - |
| Approval requests | ✅ | ✅ | ✅ | - | - |
| Usage statistics | ✅ | ✅ | ✅ | - | - |
| **Real-time Features** |
| SSE streaming | ✅ | ✅ | ✅ | - | - |
| Auto-scroll | ✅ | ✅ | ✅ | - | - |
| Loading indicators | ✅ | ✅ | ✅ | - | - |
| Agent selector | ✅ | ✅ | ✅ | - | - |
| **Critical UX** |
| **Abort/Interrupt** | ❌ | ✅ (ESC) | ✅ | 🔴 HIGH | Medium |
| **Message persistence** | ❌ | ✅ | ✅ | 🔴 HIGH | Low |
| **Error retry** | ❌ | ❌ | ✅ | 🔴 HIGH | Medium |
| **Diff visualization** | ❌ | ✅ | ❌ | 🔴 HIGH | High |
| **Input autocomplete** | ❌ | ✅ | ❌ | 🟡 MEDIUM | High |
| **Inline approval with reason** | ❌ | ✅ | ❌ | 🟡 MEDIUM | Medium |
| **Permission modes** | ❌ | ❌ | ✅ | 🟡 MEDIUM | Low |
| **Context size warnings** | ❌ | ❌ | ✅ | 🟡 MEDIUM | Low |
| **Code highlighting** | ❌ | ✅ | ✅ | 🟢 LOW | Medium |
| **Message search** | ❌ | ✅ | ✅ | 🟢 LOW | High |
| **Conversation export** | ❌ | ✅ | ❌ | 🟢 LOW | Medium |

---

## Detailed Feature Analysis

### 1. Abort/Interrupt Functionality

**Reference Implementations:**
- **Letta Code**: ESC key listener, displays "Press ESC to abort" during tool execution
- **Happy**: Stop button in UI, aborts pending operations

**Impact:**
- Users cannot cancel long-running or stuck agent operations
- Poor UX when agent makes mistakes or takes too long
- Must-have for production use

**Implementation Plan:**
```dart
// ChatState - Add abort state
class ChatState {
  final bool canAbort;  // Show abort button
  final String? abortReason;
}

// ChatController - Add abort method
Future<void> abortMessage(String reason) async {
  // Close SSE stream
  // Add abort message to history
  // Notify user
}

// ChatScreen - Add ESC key listener + abort button
KeyboardListener(
  focusNode: _focusNode,
  onKeyEvent: (event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      ref.read(provider.notifier).abortMessage('User pressed ESC');
    }
  },
  child: ...,
)
```

**Files to Modify:**
- `lib/core/providers/chat_providers.dart`
- `lib/features/chat/screens/chat_screen.dart`
- `lib/l10n/app_en.arb` (add i18n strings)

**Complexity**: Medium (2-3 hours)

---

### 2. Message Persistence

**Reference Implementations:**
- **Letta Code**: Saves conversation state to local file
- **Happy**: Uses IndexedDB for web, SQLite for mobile

**Impact:**
- Refreshing page loses entire conversation history
- Cannot resume previous conversations
- Poor user experience

**Implementation Plan:**
```dart
// Use shared_preferences for web localStorage
class ChatStorage {
  static const _key = 'chat_history_';

  Future<void> saveMessages(String agentId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(messages.map((m) => m.toJson()).toList());
    await prefs.setString('$_key$agentId', json);
  }

  Future<List<ChatMessage>> loadMessages(String agentId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_key$agentId');
    if (json == null) return [];
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((j) => ChatMessage.fromJson(j)).toList();
  }
}

// ChatController - Auto-save on state change
@override
ChatState build(String agentId) {
  _loadFromStorage(agentId);
  ref.onDispose(() => _saveToStorage(agentId));
  return const ChatState();
}
```

**Files to Modify:**
- `lib/core/providers/chat_providers.dart`
- `lib/core/utils/chat_storage.dart` (new)
- `pubspec.yaml` (add shared_preferences dependency)

**Complexity**: Low (1-2 hours)

---

### 3. Error Retry Logic

**Reference Implementations:**
- **Happy**: Automatic retry with exponential backoff for transient errors

**Impact:**
- Network blips cause permanent failures
- LLM API rate limits result in lost messages
- Frustrating user experience

**Implementation Plan:**
```dart
// ChatController - Wrap sendMessage with retry
Future<void> sendMessage(String content, {int retries = 3}) async {
  try {
    await _sendMessageInternal(content);
  } catch (e) {
    if (_isTransientError(e) && retries > 0) {
      await Future.delayed(Duration(seconds: 2 ^ (3 - retries)));
      await sendMessage(content, retries: retries - 1);
    } else {
      rethrow;
    }
  }
}

bool _isTransientError(dynamic error) {
  final msg = error.toString().toLowerCase();
  return msg.contains('timeout') ||
         msg.contains('rate limit') ||
         msg.contains('connection');
}
```

**Files to Modify:**
- `lib/core/providers/chat_providers.dart`

**Complexity**: Medium (1-2 hours)

---

### 4. File Edit Diff Visualization

**Reference Implementations:**
- **Letta Code**: Uses `react-diff-viewer` to show before/after for file edits
- Color-coded additions (green) and deletions (red)
- Syntax highlighting for code changes

**Impact:**
- Users cannot see what agent changed in files
- Critical for code-editing agents
- Security risk (blind file modifications)

**Implementation Plan:**
```dart
// Use flutter_highlight for syntax highlighting
// Implement custom diff viewer widget

class DiffViewerWidget extends StatelessWidget {
  final String before;
  final String after;
  final String language;

  @override
  Widget build(BuildContext context) {
    final diffs = computeDiff(before, after);
    return ListView.builder(
      itemCount: diffs.length,
      itemBuilder: (context, index) {
        final diff = diffs[index];
        return Container(
          color: diff.type == DiffType.addition ? Colors.green[100] : Colors.red[100],
          child: HighlightView(code: diff.content, language: language),
        );
      },
    );
  }
}

// ToolCallCard - Show diff for file_edit tools
if (toolName == 'file_edit') {
  DiffViewerWidget(
    before: toolInput['old_content'],
    after: toolReturn['new_content'],
    language: _detectLanguage(filePath),
  )
}
```

**Files to Modify:**
- `lib/features/chat/widgets/tool_call_card.dart`
- `lib/features/chat/widgets/diff_viewer.dart` (new)
- `pubspec.yaml` (add flutter_highlight dependency)

**Complexity**: High (4-6 hours)

---

### 5. Input Autocomplete

**Reference Implementations:**
- **Letta Code**: Tab completion for file paths and commands
- Indexes workspace files for fast lookup

**Impact:**
- Slower input for file operations
- Higher error rate (typos in paths)
- Power user feature

**Implementation Plan:**
```dart
// AutocompleteTextField with file suggestions
class ChatInputField extends StatelessWidget {
  Future<List<String>> _getSuggestions(String pattern) async {
    if (pattern.startsWith('/') || pattern.startsWith('./')) {
      // File path completion
      return _fileSystemAPI.suggestFiles(pattern);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) async {
        return await _getSuggestions(textEditingValue.text);
      },
      onSelected: (option) {
        _controller.text = option;
      },
    );
  }
}
```

**Files to Modify:**
- `lib/features/chat/screens/chat_screen.dart`
- `lib/core/utils/file_system_helper.dart` (new)
- Need backend API for file listing

**Complexity**: High (4-6 hours) + Backend support

---

### 6. Inline Approval with Reason

**Reference Implementations:**
- **Letta Code**: "Deny" button opens text input for reason
- Agent receives denial reason and adjusts behavior

**Impact:**
- Users cannot explain why they denied a tool call
- Agent repeats same mistakes
- Better human-AI collaboration

**Implementation Plan:**
```dart
// ApprovalRequestWidget - Add "Deny with reason"
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Deny tool call'),
    content: TextField(
      decoration: InputDecoration('Enter reason (optional)'),
      onChanged: (value) => _denyReason = value,
    ),
    actions: [
      TextButton('Cancel', ...),
      TextButton('Deny', () => _denyApproval(_denyReason)),
    ],
  ),
);
```

**Files to Modify:**
- `lib/features/chat/widgets/approval_request_widget.dart` (new)
- `lib/core/providers/chat_providers.dart`

**Complexity**: Medium (2-3 hours)

---

### 7. Permission Modes

**Reference Implementations:**
- **Happy**: Auto-approve mode vs Manual approval mode
- Toggle in settings

**Impact:**
- Power users want to auto-approve safe operations
- New users want oversight on all actions
- Flexibility for different workflows

**Implementation Plan:**
```dart
// PermissionMode enum
enum PermissionMode {
  auto,     // Auto-approve all
  manual,   // Manual approval for all
  hybrid;   // Auto-approve safe tools, manual for risky
}

// Settings screen - Add permission mode selector
// ChatController - Check mode before showing approval
if (mode == PermissionMode.auto || _isSafeTool(toolName)) {
  _autoApprove(toolCall);
} else {
  _showApprovalDialog(toolCall);
}
```

**Files to Modify:**
- `lib/core/models/permission_mode.dart` (new)
- `lib/features/chat/screens/chat_settings_screen.dart` (new)
- `lib/core/providers/chat_providers.dart`
- `lib/l10n/app_en.arb`

**Complexity**: Low-Medium (2-3 hours)

---

### 8. Context Size Warnings

**Reference Implementations:**
- **Happy**: Shows token usage bar
- Warns at 80%, blocks at 100%

**Impact:**
- Users don't know when approaching limit
- Messages get cut off
- Better conversation management

**Implementation Plan:**
```dart
// ChatState - Add token tracking
class ChatState {
  final int tokensUsed;
  final int maxTokens;
  double get usagePercent => tokensUsed / maxTokens;

  bool get isNearLimit => usagePercent > 0.8;
  bool get isAtLimit => usagePercent >= 1.0;
}

// UI - Show warning bar
if (chatState.isNearLimit) {
  Container(
    color: Colors.orange,
    child: Text('Warning: ${chatState.usagePercent * 100}% of context used'),
  )
}
```

**Files to Modify:**
- `lib/core/providers/chat_providers.dart`
- `lib/features/chat/screens/chat_screen.dart`
- `lib/l10n/app_en.arb`

**Complexity**: Low (1 hour)

---

## Implementation Priority

### Phase 1: Critical UX (Week 1)
**Must-have for production use**

1. ✅ **Abort functionality** (2-3 hours)
   - ESC key listener
   - Abort button in UI
   - Graceful stream cancellation

2. ✅ **Message persistence** (1-2 hours)
   - LocalStorage integration
   - Auto-save on state change
   - Load on app startup

3. ✅ **Error retry** (1-2 hours)
   - Transient error detection
   - Exponential backoff
   - Retry notification

**Total Time**: 4-7 hours

---

### Phase 2: Important Features (Week 2)
**Significantly improves UX**

4. ✅ **Inline approval with reason** (2-3 hours)
   - Deny dialog with text input
   - Reason sent to backend
   - Agent feedback loop

5. ✅ **Permission modes** (2-3 hours)
   - Auto/Manual/Hybrid modes
   - Settings screen
   - Mode-aware approval flow

6. ✅ **Context size warnings** (1 hour)
   - Token usage bar
   - Warning notifications
   - Usage statistics display

**Total Time**: 5-7 hours

---

### Phase 3: Advanced Features (Week 3-4)
**Power user features**

7. ✅ **Diff visualization** (4-6 hours)
   - Diff viewer widget
   - Syntax highlighting
   - Before/after comparison

8. ✅ **Input autocomplete** (4-6 hours)
   - File path completion
   - Command suggestions
   - Workspace indexing

9. ✅ **Code highlighting** (2-3 hours)
   - Highlight code blocks
   - Language detection
   - Copy code button

**Total Time**: 10-15 hours

---

### Phase 4: Nice-to-Have (Future)
**Quality of life improvements**

10. ✅ **Message search** (3-4 hours)
11. ✅ **Conversation export** (2-3 hours)
12. ✅ **Multi-agent chat** (4-6 hours)

**Total Time**: 9-13 hours

---

## Reference Implementations

### Letta Code (Terminal UI)
- **Location**: `/root/work/letta-code/`
- **Key Files**:
  - `src/cli/App.tsx` (~270KB) - Main application logic
  - `src/cli/components/` - UI components
  - `src/tools/manager.ts` - Tool execution

**Strengths**:
- Most sophisticated approval system
- Excellent diff rendering
- Comprehensive error handling
- Rich keyboard shortcuts

**Weaknesses**:
- Terminal-only (limited UI)
- No mobile support

---

### Happy (Mobile/Web)
- **Location**: `/root/work/happy/`
- **Key Files**:
  - `sources/components/AgentInput.tsx` (~45KB) - Input component
  - `sources/app/` - Routing/navigation
  - `sources/components/` - UI patterns

**Strengths**:
- Best real-time sync (LiveKit/WebRTC)
- Rich input component
- Permission modes
- Cross-platform (React Native + Expo)

**Weaknesses**:
- No diff visualization
- Less sophisticated approval system

---

## Dependencies & Packages

### Already Available
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `http` - API client

### Need to Add
```yaml
dependencies:
  shared_preferences: ^2.2.2  # Message persistence
  flutter_highlight: ^0.7.0   # Code highlighting
  diff_match_patch: ^0.4.1    # Diff visualization
  keyboard_actions: ^4.2.0    # Keyboard shortcuts
```

---

## API Requirements

### Backend Endpoints Needed
- `POST /agents/{id}/messages/abort` - Cancel running operation
- `GET /files/list` - File autocomplete
- `GET /files/diff` - File diff computation
- `GET /agents/{id}/tokens` - Context usage

---

## Success Metrics

### Phase 1 (Critical)
- ✅ Users can abort operations in < 1 second
- ✅ Messages persist across page refreshes
- ✅ Transient errors auto-retry < 5 seconds

### Phase 2 (Important)
- ✅ Users can provide denial reasons
- ✅ Permission modes work correctly
- ✅ Context warnings appear at 80%

### Phase 3 (Advanced)
- ✅ Diffs render for file edits
- ✅ Autocomplete suggests files
- ✅ Code blocks are highlighted

---

## Open Questions

1. **Abort API**: Does Letta backend support abort endpoint?
   - Check: `/root/work/letta/` API docs
   - Fallback: Close SSE stream from client side

2. **File Access**: How to list files for autocomplete?
   - Need backend API or in-memory index
   - Security considerations (sandboxing)

3. **Diff Computation**: Client-side or server-side?
   - Client: `diff_match_patch` package
   - Server: More accurate for large files

4. **Token Counting**: Backend or frontend?
   - Backend: Accurate GPT tokenization
   - Frontend: Approximate (word count * 1.3)

---

## Next Steps

1. **Confirm priority** with stakeholders
2. **Check backend APIs** for abort, file listing, token counting
3. **Start Phase 1** implementation
4. **Test and iterate** based on user feedback

---

**Last Updated**: 2026-01-12
**Maintained By**: Klui Development Team
