# Letta Code Project Analysis

**Last Updated**: 2026-01-11
**Project Location**: `/root/work/letta-code`
**Purpose**: Reference implementation for terminal-based coding agent UI

## Overview

Letta Code is a **memory-first coding harness** built on top of the Letta API. It's a terminal-based tool (CLI) that provides persistent agent sessions with memory and learning capabilities. This serves as an excellent reference for:
- Terminal UI rendering patterns
- Message display strategies
- Tool call presentation
- Agent state management
- Approval workflow UX

## Project Architecture

### Tech Stack
- **Runtime**: Bun (JavaScript/TypeScript)
- **UI Framework**: Ink (React for CLI)
- **Language**: TypeScript
- **Package Manager**: Bun

### Project Structure

```
letta-code/
├── src/
│   ├── agent/              # Agent management and client
│   ├── cli/                # CLI UI components (Ink/React)
│   │   ├── App.tsx         # Main application (27KB, 270KB total)
│   │   ├── components/     # UI components
│   │   ├── commands/       # CLI command handlers
│   │   └── hooks/          # React hooks
│   ├── tools/              # Tool execution and permissions
│   ├── permissions/        # Permission analysis
│   ├── lsp/                # Language Server Protocol integration
│   └── ralph/              # "Ralph" mode (feature flags)
├── .skills/                # Reusable agent skills
└── bin/                    # Executable scripts
```

## Key Insights for Klui

### 1. Message Display Patterns

#### Terminal Rendering (src/cli/App.tsx)
Letta Code uses **Ink** (React for CLI) with different message types:

**User Messages**:
- Right-aligned in terminal
- Simple text display
- Green color by default

**Assistant Messages** (`AssistantMessageRich`):
- Left-aligned
- Rich text rendering with markdown
- Syntax highlighting for code blocks
- collapsible sections

**Tool Call Messages** (`BashCommandMessage`):
- Show command being executed
- Syntax highlighted code display
- Execution status indicators
- Expandable/collapsible

**Tool Return Messages**:
- Success: Green checkmark
- Error: Red X with error details
- Stdout/stderr display
- Diff formatting for file changes

#### Key Components

**File**: `src/cli/components/AssistantMessageRich.tsx`
- Renders assistant responses with markdown
- Code block syntax highlighting
- File edit diff visualization
- Collapsible reasoning sections

**File**: `src/cli/components/BashCommandMessage.tsx`
- Displays shell commands
- Shows command output
- Status indicators (running/success/error)

**File**: `src/cli/components/Inline*Approval.tsx`
- Multiple approval types:
  - `InlineBashApproval` - Shell command approval
  - `InlineFileEditApproval` - File edit approval
  - `InlineGenericApproval` - Generic tool approval
  - `InlineTaskApproval` - Task/subtask approval
  - `InlineQuestionApproval` - Question approval
  - `InlineEnterPlanModeApproval` - Plan mode approval

### 2. Tool Call Presentation

**Key Pattern**: Tool calls are shown as **expandable cards** with:
- Tool name
- Arguments (formatted JSON)
- Approval status
- Execution status
- Result display

**Example Structure**:
```
┌─ 🔧 search_web (click to expand) ───────┐
│ Status: ⏳ Executing                    │
│ Arguments:                              │
│ {                                      │
│   "query": "Flutter Web SSE example"    │
│ }                                      │
└─────────────────────────────────────────┘
         ▼ (expand)
┌─ 📄 Results ──────────────────────────┐
│ Found 5 relevant pages...             │
│ 1. flutter.dev - SSE Guide            │
│ ...                                   │
└────────────────────────────────────────┘
```

### 3. Approval Workflow

**File**: `src/permissions/analyzer.ts`
- Analyzes tool calls for security risks
- Categorizes tools by risk level
- Auto-approves safe operations
- Requires approval for dangerous operations

**File**: `src/tools/manager.ts`
- Tool execution logic
- Permission checking
- Error handling
- stdout/stderr capture

**Approval States**:
1. **Pending** - Waiting for user input
2. **Approved** - User granted permission
3. **Rejected** - User denied permission
4. **Auto-approved** - Safe tool, auto-executed
5. **Desync** - State mismatch, needs recovery

### 4. Streaming Implementation

**File**: `src/agent/message.ts` (`sendMessageStream`)
- Uses Letta client's streaming API
- Handles SSE (Server-Sent Events)
- Real-time message updates
- Progress indicators

**Streaming Flow**:
```
User Input
    ↓
Start Stream
    ↓
Receive: reasoning_message
    ↓
Display: "Thinking..." (collapsible)
    ↓
Receive: tool_call_message
    ↓
Display: Tool call card (pending approval)
    ↓
User Approves
    ↓
Receive: tool_return_message
    ↓
Display: Tool results
    ↓
Receive: assistant_message
    ↓
Display: Response text
    ↓
Receive: stop_reason
    ↓
End Stream
```

### 5. Message State Management

**File**: `src/cli/App.tsx` (main component)

**State Structure**:
```typescript
interface ChatState {
  messages: Message[];           // All messages in session
  isStreaming: boolean;          // Currently streaming?
  isAwaitingApproval: boolean;   // Waiting for approval?
  currentRunId?: string;         // Active run ID
  agentId: string;               // Current agent ID
  sessionStats: SessionStats;    // Token usage, etc.
}
```

**Key Patterns**:
- Messages are **immutable** - new messages appended to list
- Each message has unique ID
- Streaming updates replace placeholder messages
- Approval messages are inline with chat flow

### 6. Memory Display

**File**: `src/cli/components/MemoryViewer.tsx`

**Memory Types**:
- **Core Memory** - Agent's persona and context
- **Archival Memory** - Long-term knowledge storage
- **Working Memory** - Current conversation context

**Display Approach**:
- Separate view from chat (toggle with `/memory`)
- Read-only display
- Searchable
- Paginated for large memory

### 7. Error Handling

**File**: `src/cli/components/ErrorMessageRich.tsx`

**Error Types**:
- API Errors (network, server)
- Approval Errors (permission denied)
- Tool Errors (execution failures)
- State Errors (desync, corruption)

**Display Pattern**:
```
┌─ ❌ Error ──────────────────────────────┐
│ Tool execution failed                   │
│                                          │
│ Error: File not found                   │
│ Command: write_file("test.txt", ...)    │
│                                          │
│ [Retry] [Ignore] [Cancel Session]       │
└──────────────────────────────────────────┘
```

### 8. Input Handling

**File**: `src/cli/components/InputRich.tsx`

**Features**:
- Multi-line input support
- Command detection (`/` commands)
- File attachments
- Auto-complete
- Input history (up/down arrows)
- Ctrl+C to cancel

**Commands**:
- `/help` - Show help
- `/clear` - Clear session (not memory)
- `/memory` - View memory
- `/remember` - Add to memory
- `/skill` - Learn new skill
- `/model` - Change model
- `/profile` - Manage profiles

## Key Takeaways for Klui Implementation

### ✅ Good Patterns to Adopt

1. **Collapsible Tool Calls**
   - Tool calls should be expandable cards
   - Show tool name, arguments, status
   - Collapsed by default, expand on click

2. **Inline Approvals**
   - Approval requests inline in chat flow
   - Clear approve/reject buttons
   - Show tool details before approval

3. **Streaming Indicators**
   - Show "Thinking..." during reasoning
   - Progress indicators for long operations
   - Real-time token count updates

4. **Rich Text Display**
   - Markdown rendering for assistant messages
   - Syntax highlighting for code
   - Diff formatting for file edits

5. **Error Recovery**
   - Clear error messages
   - Retry/retry options
   - Don't block entire session on single error

### ⚠️ Terminal vs Web Differences

**Terminal (Letta Code)**:
- Sequential rendering (top to bottom)
- Limited width (terminal columns)
- No scrolling history (uses `less` for pagination)
- Keyboard shortcuts for navigation
- Static layout after render

**Web (Klui)**:
- Scrollable message list
- Responsive width
- Lazy loading for history
- Touch/mouse interactions
- Dynamic layout updates
- Can update any message at any time

**Adaptations Needed**:
- Use ListView.builder instead of Static
- Implement infinite scroll for history
- Add pull-to-refresh
- Touch-friendly button sizes
- Responsive layout for mobile/desktop
- Real-time updates (no need for full re-render)

## Letta Code API Usage

### Client Initialization

**File**: `src/agent/client.ts`

```typescript
import { LettaClient } from "@letta-ai/letta-client";

const client = new LettaClient({
  baseURL: process.env.LETTA_BASE_URL || "https://api.letta.com",
  apiKey: process.env.LETTA_API_KEY,
});
```

### Sending Messages

**File**: `src/agent/message.ts`

```typescript
async function sendMessageStream(
  agentId: string,
  messages: MessageCreate[],
  onMessage: (message: LettaMessageUnion) => void,
  onStop: (stopReason: LettaStopReason) => void,
  onError: (error: Error) => void
) {
  const stream = await client.agents.messages.stream({
    agentId,
    messages,
    streaming: true,
    streamTokens: false,  // or true for token-level streaming
  });

  for await (const event of stream) {
    if (event.message_type === "usage_statistics") {
      // Handle usage stats
    } else if (event.message_type === "stop_reason") {
      onStop(event);
    } else {
      onMessage(event);
    }
  }
}
```

### Message Type Handling

**Letta Code processes these message types**:
- `reasoning_message` → Collapsible "Thinking..." section
- `tool_call_message` → Tool call card with approve/reject
- `tool_return_message` → Tool results (success/error)
- `assistant_message` → Rich text response
- `user_message` → User input display
- `approval_request_message` → Inline approval UI
- `error` → Error card with retry options
- `ping` → Ignore (keepalive)
- `stop_reason` → Update session status
- `usage_statistics` → Update token counts

## Next Investigation Steps

1. **Deep dive into message components**:
   - `AssistantMessageRich.tsx` - Markdown + syntax highlighting
   - `BashCommandMessage.tsx` - Tool call display
   - Inline approval components

2. **Streaming implementation**:
   - How SSE events are parsed
   - Message state updates during streaming
   - Error recovery during stream

3. **Tool execution flow**:
   - Permission checking
   - Approval workflow
   - Result display

4. **Memory management**:
   - How memory is displayed
   - Search functionality
   - Update mechanism

## References

- **Letta Code GitHub**: https://github.com/letta-ai/letta-code
- **Letta Documentation**: https://docs.letta.com/letta-code
- **Ink (React for CLI)**: https://github.com/vadimdemedes/ink
- **Letta Client SDK**: https://github.com/letta-ai/letta-client-typescript

---

**How to Update This Document**:
When investigating Letta Code, add findings in the relevant section:
- Architecture discoveries → "Project Architecture"
- UI patterns → "Key Insights for Klui"
- API usage examples → "Letta Code API Usage"
- Component analysis → "Next Investigation Steps" (or create new section)

Maintain chronological order within sections (newest at top).
