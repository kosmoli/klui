# Chat Feature Implementation Plan

## API Overview

### 1. Send Message API
**Endpoint**: `POST /v1/agents/{agent_id}/messages`

**Request Body** (`LettaStreamingRequest`):
```json
{
  "messages": [
    {
      "role": "user",  // or "system", "assistant", "tool"
      "content": "user message here"
    }
  ],
  "streaming": true,  // Enable SSE streaming
  "stream_tokens": true,  // Stream individual tokens (optional)
  "max_steps": 10,  // Maximum agent loop iterations (default: 10)
  "use_assistant_message": true,  // Use assistant message tool
  "include_pings": true  // Include keepalive pings
}
```

**Response Formats**:
- **Non-streaming** (`streaming: false`): `LettaResponse` (complete response)
- **Streaming** (`streaming: true`): SSE stream of `LettaStreamingResponse` events

### 2. Message List API
**Endpoint**: `GET /v1/agents/{agent_id}/messages`

**Query Parameters**:
- `before`: Cursor for pagination (message ID)
- `after`: Cursor for pagination (message ID)
- `limit`: Max messages (default: 100)
- `order`: "asc" or "desc" (default: "desc")
- `group_id`: Filter by group ID

**Response**: `List[LettaMessageUnion]`

### 3. Message Response Types

Letta provides multiple message types in responses:

#### Core Message Types:
1. **UserMessage** - User input messages
   - Fields: `id`, `date`, `content` (string or multi-modal), `name`

2. **AssistantMessage** - Agent text responses
   - Fields: `id`, `date`, `content` (string or multi-modal), `name`

3. **ReasoningMessage** - Agent internal reasoning (optional display)
   - Fields: `id`, `date`, `reasoning`, `source` ("reasoner_model" | "non_reasoner_model")

4. **HiddenReasoningMessage** - Redacted reasoning
   - Fields: `id`, `date`, `state` ("redacted" | "omitted")

5. **ToolCallMessage** - Tool invocations by agent
   - Fields: `id`, `date`, `tool_call` or `tool_calls`
   - ToolCall: `name`, `arguments`, `tool_call_id`

6. **ToolReturnMessage** - Tool execution results
   - Fields: `id`, `date`, `tool_return`, `status` ("success" | "error"), `tool_call_id`, `stdout`, `stderr`

7. **SystemMessage** - System messages (not streamed)
   - Fields: `id`, `date`, `content`

8. **ApprovalRequestMessage** - Tool approval requests
   - Fields: `id`, `date`, `tool_call` or `tool_calls`

9. **ApprovalResponseMessage** - User approval responses
   - Fields: `id`, `date`, `approvals`

10. **LettaPing** - Keepalive pings (streaming only)
    - Fields: `message_type: "ping"`

11. **LettaErrorMessage** - Error messages
    - Fields: `message_type: "error"`, `error` (object with `type`, `details`)

#### Metadata Types:
12. **LettaStopReason** - Why the agent stopped
    - Fields: `message_type: "stop_reason"`, `stop_reason` (object with `type`, `reason`)

13. **LettaUsageStatistics** - Token usage
    - Fields: `message_type: "usage_statistics", usage (object with token counts)

### 4. Complete Response Structure

**Non-streaming response** (`LettaResponse`):
```json
{
  "messages": [
    // Array of LettaMessageUnion types
  ],
  "stop_reason": {
    "type": "end_of_turn" | "max_steps" | "cancelled" | "error" | ...
    "reason": "why stopped"
  },
  "usage": {
    // Token usage statistics
  }
}
```

**Streaming response** (SSE events):
```
data: {"message_type": "reasoning_message", "reasoning": "...", ...}
data: {"message_type": "tool_call_message", "tool_call": {...}, ...}
data: {"message_type": "assistant_message", "content": "...", ...}
data: {"message_type": "stop_reason", "stop_reason": {...}}
data: {"message_type": "usage_statistics", "usage": {...}}
```

## Implementation Plan

### Phase 1: Basic Chat (MVP)

#### 1.1 Create Chat Models
**File**: `lib/core/models/chat.dart`

**Models to create**:
```dart
// Request models
class ChatMessage {
  final String role;  // "user", "assistant", "system"
  final String content;
}

class ChatRequest {
  final List<ChatMessage> messages;
  final bool streaming;
  final int? maxSteps;
}

// Response models
enum MessageType {
  systemMessage,
  userMessage,
  assistantMessage,
  reasoningMessage,
  hiddenReasoningMessage,
  toolCallMessage,
  toolReturnMessage,
  approvalRequestMessage,
  approvalResponseMessage,
  ping,
  error,
  stopReason,
  usageStatistics,
}

abstract class LettaMessage {
  final String id;
  final DateTime date;
  final MessageType messageType;
  final String? name;
}

class UserMessage extends LettaMessage {
  final String content;
}

class AssistantMessage extends LettaMessage {
  final String content;
}

class ReasoningMessage extends LettaMessage {
  final String reasoning;
  final String source;
}

class ToolCallMessage extends LettaMessage {
  final List<ToolCall> toolCalls;
}

class ToolCall {
  final String name;
  final String arguments;
  final String toolCallId;
}

class ToolReturnMessage extends LettaMessage {
  final String toolReturn;
  final String status;
  final String toolCallId;
  final List<String>? stdout;
  final List<String>? stderr;
}

class LettaStopReason {
  final String type;
  final String reason;
}

class LettaUsageStatistics {
  final int? totalTokens;
  final int? promptTokens;
  final int? completionTokens;
}

class ChatResponse {
  final List<LettaMessage> messages;
  final LettaStopReason stopReason;
  final LettaUsageStatistics usage;
}
```

#### 1.2 Create Chat API Client
**File**: `lib/core/services/chat_api_client.dart`

**Methods**:
```dart
class ChatApiClient {
  // Send message (non-streaming)
  Future<ChatResponse> sendMessage({
    required String agentId,
    required List<ChatMessage> messages,
    int? maxSteps,
  });

  // Send message (streaming) - returns SSE stream
  Stream<LettaMessage> sendMessageStream({
    required String agentId,
    required List<ChatMessage> messages,
    int? maxSteps,
    bool streamTokens = false,
  });

  // Get message history
  Future<List<LettaMessage>> getMessages({
    required String agentId,
    String? before,
    String? after,
    int limit = 100,
    String order = "desc",
  });
}
```

#### 1.3 Create Chat Screen UI
**File**: `lib/features/chat/screens/chat_screen.dart`

**UI Components**:
- Message list (scrollable)
  - User messages (right-aligned, blue)
  - Assistant messages (left-aligned, gray)
  - Reasoning messages (collapsible, optional toggle)
  - Tool calls (collapsible, code block style)
  - Tool returns (collapsible, success/error styling)
- Input area
  - Text field (multiline)
  - Send button
- Header
  - Agent name
  - Status indicator
  - Settings button
- Loading indicators
  - Streaming indicator
  - Tool execution indicator

**Layout**:
```
┌─────────────────────────────┐
│ Agent Name              ⚙️   │ Header
├─────────────────────────────┤
│                             │
│  User message               │
│                 Hello!      │
│                             │
│  Assistant message          │
│  Hi there!                  │
│                             │
│  ▼ Tool Call (click to exp) │
│  search_web(...)            │
│                             │
│  ▼ Tool Return              │
│  Results: ...               │
│                             │
├─────────────────────────────┤
│ Type your message...  [Send]│ Input
└─────────────────────────────┘
```

#### 1.4 Chat State Management
**File**: `lib/features/chat/providers/chat_providers.dart`

**Using Riverpod**:
```dart
// Chat state model
class ChatState {
  final List<LettaMessage> messages;
  final bool isLoading;
  final bool isStreaming;
  final String? error;
  final LettaUsageStatistics? usage;
}

// Chat notifier
class ChatNotifier extends StateNotifier<ChatState> {
  Future<void> sendMessage(String agentId, String content);
  Future<void> loadHistory(String agentId);
  Future<void> clearHistory();
}

// Providers
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(...);
final chatMessagesProvider = Provider(...);
```

### Phase 2: Advanced Features

#### 2.1 Streaming Support
- Implement SSE parsing
- Real-time message updates
- Token-by-token rendering for assistant messages
- Tool execution progress indicators

#### 2.2 Tool Approval
- Display approval requests
- Approve/reject buttons
- Multi-tool approval
- Reason input field

#### 2.3 Message Actions
- Copy message content
- Regenerate response
- Edit user message
- Delete message
- View reasoning (toggle)

#### 2.4 Advanced UI
- Markdown rendering for assistant messages
- Code syntax highlighting
- Image/file attachments (if supported)
- Message search
- Export conversation

### Phase 3: Polish & Optimization

#### 3.1 Performance
- Message pagination
- Lazy loading
- Message caching
- Optimistic UI updates

#### 3.2 UX Improvements
- Auto-scroll behavior
- Input suggestions
- Message timestamps
- Typing indicators
- Error recovery

#### 3.3 Accessibility
- Keyboard navigation
- Screen reader support
- Focus management
- Semantic labels

## Technical Decisions

### 1. SSE Library
**Option**: Use `dart`'s built-in `HttpClient` with custom SSE parser
- Pros: No external dependencies, full control
- Cons: More implementation work
- Alternative: `flutter_http_sse` package (if compatible with Web)

### 2. State Management
**Choice**: Riverpod (already in use)
- Chat state: `StateNotifierProvider`
- Message list: `StateProvider`
- Streaming controller: `StreamProvider`

### 3. Message Rendering
**Choice**: Custom widgets with conditional rendering
- `UserMessageWidget`
- `AssistantMessageWidget` (with markdown support)
- `ToolCallMessageWidget` (collapsible)
- `ReasoningMessageWidget` (collapsible, optional)

### 4. Caching Strategy
**Choice**: In-memory + LocalStorage
- Current session: In-memory (StateNotifier)
- Session persistence: `shared_preferences` or `hive`
- Message history: Lazy load from API

## File Structure

```
lib/
├── core/
│   ├── models/
│   │   └── chat.dart              # All chat-related models
│   └── services/
│       └── chat_api_client.dart   # Chat API client
├── features/
│   └── chat/
│       ├── screens/
│       │   └── chat_screen.dart   # Main chat UI
│       ├── widgets/
│       │   ├── message_bubble.dart
│       │   ├── tool_call_widget.dart
│       │   ├── reasoning_widget.dart
│       │   └── chat_input_bar.dart
│       └── providers/
│           └── chat_providers.dart # State management
└── l10n/
    ├── app_en.arb                 # English translations
    └── app_zh.arb                 # Chinese translations
```

## API Integration Notes

### Authentication
- All requests need Bearer token
- Header: `Authorization: Bearer <token>`

### Error Handling
- HTTP 409: Pending approval error
- HTTP 422: Validation error
- HTTP 500: Server error

### SSE Format
```
event: message
data: {"message_type": "assistant_message", ...}

event: message
data: {"message_type": "tool_call_message", ...}

event: message
data: {"message_type": "stop_reason", ...}
```

### Testing API
```bash
# Non-streaming
curl -X POST http://localhost:8283/v1/agents/{agent_id}/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "messages": [{"role": "user", "content": "Hello"}],
    "streaming": false
  }'

# Streaming
curl -X POST http://localhost:8283/v1/agents/{agent_id}/messages/stream \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "messages": [{"role": "user", "content": "Hello"}],
    "streaming": true
  }'
```

## Success Criteria

- ✅ Send and receive messages
- ✅ Display all message types correctly
- ✅ Stream messages in real-time
- ✅ Handle tool calls and returns
- ✅ Show reasoning (optional/toggle)
- ✅ Display usage statistics
- ✅ Handle errors gracefully
- ✅ Support message history
- ✅ Responsive design (mobile/desktop)
- ✅ Accessible (WCAG AA)

## Next Steps

1. Create chat models (`lib/core/models/chat.dart`)
2. Implement chat API client with SSE support
3. Build basic chat UI screen
4. Set up Riverpod state management
5. Test with real Letta backend
6. Add advanced features iteratively
7. Polish and optimize
