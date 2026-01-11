# Happy Project Analysis

**Last Updated**: 2026-01-11
**Project Location**: `/root/work/happy`
**Purpose**: Reference implementation for mobile/web coding agent UI (React Native + Expo)

## Overview

Happy is a **mobile and web client** for Claude Code & Codex. It provides cross-platform access to coding agents with:
- 📱 Native iOS/Android apps (React Native + Expo)
- 🌐 Web application
- 🔔 Push notifications
- 🔐 End-to-end encryption
- ⚡ Real-time sync via WebRTC

This serves as an excellent reference for:
- Mobile UI patterns for agent chat
- Real-time message streaming
- Cross-platform design
- Touch interactions
- Responsive layouts
- Code display on mobile

## Project Architecture

### Tech Stack
- **Framework**: React Native + Expo (iOS/Android/Web/Desktop)
- **Language**: TypeScript
- **Navigation**: React Navigation v7
- **State Management**: React Context + Hooks (no Redux)
- **Real-time**: LiveKit (WebRTC) + WebSocket
- **UI Libraries**:
  - `@expo/ui` - Expo UI components
  - `react-native-unistyles` - Theme system
  - `@shopify/flash-list` - Performance lists
  - `@legendapp/list` - Advanced list management
  - `@shopify/react-native-skia` - Graphics/rendering

### Project Structure

```
happy/
├── sources/
│   ├── app/                    # Expo Router app (file-based routing)
│   │   ├── (app)/             # Tab navigation screens
│   │   │   ├── chat/          # Chat screens
│   │   │   ├── settings/      # Settings screens
│   │   │   └── ...
│   │   └── _layout.tsx        # Root layout
│   ├── components/            # Shared UI components
│   │   ├── AgentInput.tsx     # Chat input (45KB)
│   │   ├── ActiveSessionsGroup.tsx
│   │   ├── CommandView.tsx    # Command display
│   │   └── ...
│   ├── sync/                  # Real-time sync
│   │   └── client.ts          # Sync client
│   ├── encryption/            # E2E encryption
│   ├── realtime/              # WebRTC/WebSocket
│   ├── hooks/                 # Custom React hooks
│   ├── text/                  # i18n translations
│   ├── theme/                 # Theme configuration
│   └── types/                 # TypeScript types
├── src-tauri/                 # Desktop app (Tauri)
└── public/                    # Web assets
```

## Key Insights for Klui

### 1. Chat Input Component

**File**: `sources/components/AgentInput.tsx` (45KB!)

**Features**:
- Multi-line text input with auto-grow
- Auto-complete with suggestions
- Attachment support (files, images)
- Voice input (microphone button)
- Permission mode selector
- Token usage display
- Git status indicator
- Agent/machine selector
- Connection status indicator
- Send button with loading state

**UI Structure**:
```
┌─────────────────────────────────────────┐
│ 💬 Agent: claude-3-5-sonnet      ✅    │ ← Status bar
├─────────────────────────────────────────┤
│ /command  file.txt                     │ ← Input with autocomplete
│                                          │
│                                          │
├─────────────────────────────────────────┤
│ 📎 🎤 🔒 ⚡  [📤 Send]                   │ ← Action buttons
│ 45K tokens                              │ ← Token count
└─────────────────────────────────────────┘
```

**Key Props**:
```typescript
interface AgentInputProps {
  value: string;
  placeholder: string;
  sessionId?: string;
  onSend: () => void;
  sendIcon?: React.ReactNode;
  onMicPress?: () => void;
  isMicActive?: boolean;
  permissionMode?: PermissionMode;
  onPermissionModeChange?: (mode: PermissionMode) => void;
  modelMode?: ModelMode;
  onModelModeChange?: (mode: ModelMode) => void;
  metadata?: Metadata | null;
  onAbort?: () => void;
  showAbortButton?: boolean;
  connectionStatus?: { text, color, dotColor, isPulsing };
  autocompletePrefixes: string[];
  autocompleteSuggestions: (query: string) => Promise<Suggestion[]>;
  usageData?: { inputTokens, outputTokens, cacheCreation, cacheRead, contextSize };
  onFileViewerPress?: () => void;
  agentType?: 'claude' | 'codex' | 'gemini';
  // ... more props
}
```

### 2. Message Display Components

**File**: `sources/components/CommandView.tsx`

**Message Types**:
- User messages (right-aligned, blue)
- Assistant messages (left-aligned, gray)
- Command messages (tool calls)
- Error messages (red, with retry)
- System messages (centered, gray)

**Rendering Strategy**:
- Uses FlashList for performance (virtualized lists)
- Lazy loading of message content
- Image caching
- Code syntax highlighting

**Example Structure**:
```typescript
<FlashList
  data={messages}
  renderItem={({ item }) => {
    if (item.role === 'user') {
      return <UserMessage content={item.content} />;
    } else if (item.role === 'assistant') {
      return <AssistantMessage content={item.content} />;
    } else if (item.type === 'command') {
      return <CommandMessage command={item} />;
    }
  }}
  estimatedItemSize={100}
  onEndReached={loadMoreMessages}
/>
```

### 3. Real-time Sync

**File**: `sources/sync/client.ts`

**Architecture**:
- **LiveKit** (WebRTC) for real-time updates
- **WebSocket** fallback for compatibility
- **E2E encryption** (libsodium)
- **Offline support** with local queue

**Sync Flow**:
```
Desktop (CLI) → Happy Server → Mobile/Web
     ↓              ↓              ↓
  Start Session   Encrypt      Receive
  Send Message    Relay        Decrypt
                  Broadcast    Display
```

**Key Features**:
- Bi-directional sync
- Conflict resolution
- Session state management
- Push notifications for approvals

### 4. Code Display

**File**: `sources/components/CodeView.tsx`

**Features**:
- Syntax highlighting
- Line numbers
- Diff display
- Copy code button
- Collapse/expand
- File type icon
- Language detection

**Implementation**:
- Uses `react-native-syntax-highlighter`
- Custom theme matching code editor
- Markdown rendering for code blocks
- Diff formatting (red for deletions, green for additions)

### 5. Theme System

**File**: `sources/theme.ts`

**Architecture**:
- `react-native-unistyles` for theming
- Dynamic theme switching (light/dark)
- Custom color palettes
- Responsive breakpoints
- Platform-specific styles

**Theme Structure**:
```typescript
const theme = createTheme({
  colors: {
    primary: '#6366f1',
    background: '#0f172a',
    surface: '#1e293b',
    // ... more colors
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
  },
  typography: {
    h1: { fontSize: 32, fontWeight: 'bold' },
    body: { fontSize: 16, lineHeight: 24 },
    // ... more typography
  },
});
```

### 6. Responsive Design

**Strategy**:
- Mobile-first approach
- Breakpoint-based layouts
- Touch-friendly targets (min 44px)
- Adaptive font sizes
- Platform-specific components

**Example**:
```typescript
import { useWindowDimensions } from 'react-native';

const { width } = useWindowDimensions();
const isTablet = width >= 768;
const isDesktop = width >= 1024;

// Render different layouts based on screen size
if (isDesktop) {
  return <DesktopLayout />;
} else if (isTablet) {
  return <TabletLayout />;
} else {
  return <MobileLayout />;
}
```

### 7. Performance Optimizations

**File**: `sources/components/layout.ts`

**Techniques**:
1. **FlashList** - Virtualized lists with constant rendering
2. **Memoization** - `React.memo` for expensive components
3. **Lazy loading** - Code splitting with React.lazy
4. **Image caching** - Expo Image with caching
5. **Debouncing** - Input debouncing for search/autocomplete
6. **Throttling** - Scroll event throttling

**Example**:
```typescript
const MemoizedMessage = React.memo(({ message }) => {
  return <Message content={message.content} />;
}, (prev, next) => prev.message.id === next.message.id);
```

### 8. Navigation

**File**: `sources/app/_layout.tsx`

**Architecture**:
- Expo Router (file-based routing)
- Tab navigation for main screens
- Stack navigation for nested screens
- Modal presentation for overlays
- Deep linking support

**Route Structure**:
```
app/
├── (app)/
│   ├── _layout.tsx          # Tab navigator
│   ├── index.tsx            # Home/sessions list
│   ├── chat/
│   │   ├── [sessionId].tsx  # Chat screen
│   │   └── _layout.tsx      # Chat stack navigator
│   └── settings/
│       ├── _layout.tsx      # Settings stack
│       ├── account.tsx
│       └── ...
├── (auth)/
│   ├── _layout.tsx          # Auth stack
│   └── login.tsx
└── _layout.tsx              # Root layout
```

### 9. Push Notifications

**Implementation**:
- Expo Notifications
- Permission handling
- Background tasks
- Rich notifications (with actions)
- Sound/vibration/haptic feedback

**Notification Types**:
- Approval requests - "Agent needs your permission"
- Errors - "Agent encountered an error"
- Completions - "Task completed"
- Messages - "New message from agent"

### 10. Accessibility

**Features**:
- Screen reader support
- Semantic labels
- Focus management
- Keyboard navigation (Web/Desktop)
- High contrast mode
- Font scaling support

**Example**:
```typescript
<Pressable
  accessibilityLabel="Send message"
  accessibilityHint="Sends your message to the agent"
  accessibilityRole="button"
  onPress={handleSend}
>
  <SendIcon />
</Pressable>
```

## Key Takeaways for Klui Implementation

### ✅ Good Patterns to Adopt

1. **Chat Input Design**
   - Multi-line with auto-grow
   - Clear send button with loading state
   - Token count display
   - Quick action buttons
   - Auto-complete support

2. **Message List Performance**
   - Use virtualized lists (ListView.builder in Flutter)
   - Lazy load message content
   - Separate message types into different widgets
   - Implement infinite scroll for history

3. **Code Display**
   - Syntax highlighting is essential
   - Line numbers for reference
   - Copy code button
   - Collapse long code blocks
   - Diff formatting for edits

4. **Responsive Layout**
   - Mobile-first approach
   - Breakpoint-based adaptations
   - Touch-friendly targets (min 44px)
   - Adaptive font sizes

5. **Real-time Updates**
   - Show streaming indicators
   - Incremental message updates
   - Connection status display
   - Error recovery UI

### ⚠️ React Native vs Flutter Differences

**React Native (Happy)**:
- JSX components
- Flexbox layout
- Native modules for platform features
- Expo for build/tooling
- JavaScript/TypeScript

**Flutter (Klui)**:
- Widget composition
- Box layout constraints
- Platform channels
- Flutter CLI
- Dart language

**Adaptations Needed**:
- Convert JSX to Widgets
- Flexbox → Row/Column/Stack
- React hooks → StatefulWidget/StatelessWidget
- Navigation libraries → go_router
- Theme system → Theme widgets
- State management → Riverpod

## Happy's UI Patterns for Reference

### Chat Screen Layout

**File**: `sources/app/(app)/chat/[sessionId].tsx`

**Structure**:
```
┌─────────────────────────────────┐
│ ← Back  Agent Name    Settings ⚙️│ Header
├─────────────────────────────────┤
│                                 │
│  User: Hello!              ●    │ Message List
│                  2m ago         │ (Scrollable)
│  Agent: Hi there!         ●    │
│                  1m ago         │
│                                 │
├─────────────────────────────────┤
│ 💬 /    [📎] [🎤]       [Send]  │ Input Bar
│ 45K tokens                        │
└─────────────────────────────────┘
```

### Message Bubble Styling

**User Message**:
```dart
Container(
  alignment: Alignment.centerRight,
  child: Container(
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: EdgeInsets.all(12),
    child: Text(message.content),
  ),
)
```

**Assistant Message**:
```dart
Container(
  alignment: Alignment.centerLeft,
  child: Container(
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
    ),
    padding: EdgeInsets.all(12),
    child: MarkdownBody(data: message.content),
  ),
)
```

### Tool Call Display

**Pattern** (from CommandView.tsx):
```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    children: [
      // Header
      Row(
        children: [
          Icon(Icons.build),
          Text(tool.name),
          Spacer(),
          Text(status, style: TextStyle(color: statusColor)),
        ],
      ),
      // Arguments (collapsible)
      if (isExpanded)
        CodeBlock(arguments),
      // Result (collapsible)
      if (hasResult && isExpanded)
        ResultBlock(result),
    ],
  ),
)
```

## Mobile-Specific Features

### Touch Interactions

1. **Swipe to Actions**:
   - Swipe left on message → Delete
   - Swipe right on message → Reply
   - Swipe on session → Archive/delete

2. **Long Press**:
   - Long press message → Copy/Forward/Delete
   - Long press code → Copy all
   - Long press session → Rename/Delete

3. **Pull to Refresh**:
   - Pull down on message list → Reload history
   - Pull down on sessions list → Refresh sessions

### Keyboard Handling

**Platform-specific**:
- iOS: Custom keyboard toolbar
- Android: Adjust resize behavior
- Web/Desktop: Physical keyboard shortcuts

**Example**:
```dart
KeyboardActions(
  enable: true,
  actions: [
    KeyboardAction(
      displayName: 'Send',
      onTap: () => sendMessage(),
    ),
  ],
)
```

### Safe Areas

**Important for notched devices**:
```dart
SafeArea(
  child: Scaffold(
    body: MessageList(),
    bottomNavigationBar: ChatInput(),
  ),
)
```

## Next Investigation Steps

1. **Message rendering details**:
   - How markdown is rendered
   - Code syntax highlighting
   - Image display
   - File attachments

2. **Real-time sync implementation**:
   - WebSocket connection management
   - Message streaming
   - Conflict resolution
   - Offline handling

3. **Performance optimization**:
   - List virtualization
   - Image caching
   - Memory management
   - Battery optimization

4. **Platform-specific features**:
   - iOS widgets
   - Android notifications
   - Web PWA features
   - Desktop Tauri integration

## References

- **Happy GitHub**: https://github.com/slopus/happy-coder
- **Happy Documentation**: https://happy.engineering/docs/
- **Expo Router**: https://docs.expo.dev/router/introduction/
- **React Native Unistyles**: https://reactnativeunistyles.com/
- **LiveKit React Native**: https://docs.livekit.io/react-native/

---

**How to Update This Document**:
When investigating Happy, add findings in the relevant section:
- UI patterns → "Key Insights for Klui"
- Component analysis → Create new subsection
- Real-time features → "Real-time Sync"
- Mobile patterns → "Mobile-Specific Features"

Maintain chronological order within sections (newest at top).
