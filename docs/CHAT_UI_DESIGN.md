# Klui Chat Interface Design Specification

**Date**: 2026-01-11
**Designer**: Claude Sonnet 4.5
**Aesthetic Direction**: Neo-Brutalist Developer Terminal

---

## 🎯 Design Philosophy

### Core Principles

1. **Information Density Over Whitespace**
   - Developer tools prioritize information density
   - Every pixel serves a purpose
   - Inspired by VS Code's compact panel design

2. **Status-First Communication**
   - Tool states are visually distinct (color + animation)
   - Never ambiguous about what's happening
   - Clear visual hierarchy

3. **Touch-Friendly but Not "Mobile-First Generic"**
   - 48px minimum touch targets
   - But maintains developer-tool aesthetics
   - No "cute" rounded corners or playful animations

4. **Typography as Identity**
   - JetBrains Mono (display) + System UI (body)
   - Code looks like code
   - Monospaced fonts for tool names, status

---

## 🎨 Aesthetic Specification

### Color Palette

```dart
// Primary Colors - High Contrast Industrial
class KluiColors {
  // Backgrounds
  static const background = Color(0xFF0D1117);      // GitHub Dark Dim
  static const surface = Color(0xFF161B22);         // Panel bg
  static const surfaceVariant = Color(0xFF21262D);  // Input border

  // User Message
  static const userBubble = Color(0xFF1F6FEB);      // GitHub Blue
  static const userText = Color(0xFFFFFFFF);

  // Assistant Message
  static const assistantBubble = Color(0xFF21262D); // Panel gray
  static const assistantText = Color(0xFFC9D1D9);   // Muted text

  // Status Indicators (Critical for Tool States)
  static const statusStreaming = Color(0xFF6E7681); // Gray - animating
  static const statusReady = Color(0xFFD29922);     // Orange - blinking
  static const statusRunning = Color(0xFFE3B341);   // Yellow - blinking
  static const statusSuccess = Color(0xFF3FB950);   // Green - solid
  static const statusError = Color(0xFFF85149);     // Red - solid

  // Tool Accents
  static const toolBash = Color(0xFFFF7B72);        // Red
  static const toolFile = Color(0xFF79C0FF);        // Blue
  static const toolSearch = Color(0xFFA5D6FF);      // Light Blue
  static const toolMemory = Color(0xFFD2A8FF);      // Purple

  // Semantic
  static const reasoning = Color(0xFF6E7681);      // Dimmed gray
  static const error = Color(0xFFFF7B72);           // Error red
  static const success = Color(0xFF3FB950);         // Success green
  static const warning = Color(0xFFD29922);         // Warning orange

  // Borders
  static const border = Color(0xFF30363D);          // Subtle border
  static const borderFocus = Color(0xFF388BFD);     // Focus blue
}
```

### Typography

```dart
class KluiTextStyles {
  // Display Fonts - JetBrains Mono for code/tools
  static const displayFont = 'JetBrains Mono';

  // Body Fonts - System UI for readability
  static const bodyFont = 'SF Pro Text'; // iOS
  // static const bodyFont = 'Roboto'; // Android fallback

  // Styles
  static const toolName = TextStyle(
    fontFamily: displayFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const statusIndicator = TextStyle(
    fontFamily: displayFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static const userMessage = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: KluiColors.userText,
  );

  static const assistantMessage = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: KluiColors.assistantText,
    height: 1.5,
  );

  static const reasoning = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: KluiColors.reasoning,
    fontStyle: FontStyle.italic,
  );

  static const codeBlock = TextStyle(
    fontFamily: displayFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
}
```

---

## 📱 Component Design

### 1. Message List - Reverse Scroll

```dart
// lib/features/chat/widgets/chat_message_list.dart

class ChatMessageList extends ConsumerWidget {
  const ChatMessageList({
    required this.agentId,
    required this.messages,
    super.key,
  });

  final String agentId;
  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      // CRITICAL: Reverse for chat-like behavior
      reverse: true,

      // Performance optimization
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,

      // Item count
      itemCount: messages.length,

      // Item builder
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageTile(
          key: ValueKey(message.id),
          message: message,
          // Stream from bottom to top
          isLast: index == 0,
        );
      },

      // Smooth scrolling
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),

      // Padding
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    );
  }
}
```

**Key Design Decisions**:
- ✅ `reverse: true` - Messages start from bottom
- ✅ `BouncingScrollPhysics` - iOS-like bounce on edges
- ✅ `addAutomaticKeepAlives` - Preserve state while scrolling
- ✅ `ValueKey` - Prevent re-render on list updates

---

### 2. Message Type Renderer

```dart
// lib/features/chat/widgets/message_tile.dart

class _MessageTile extends ConsumerWidget {
  const _MessageTile({
    super.key,
    required this.message,
    required this.isLast,
  });

  final ChatMessage message;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Route to different widgets based on message type
    switch (message.type) {
      case MessageType.user:
        return _UserMessageBubble(message: message);

      case MessageType.assistant:
        return _AssistantMessageBubble(message: message);

      case MessageType.reasoning:
        return _ReasoningBubble(message: message);

      case MessageType.toolCall:
        return _ToolCallCard(message: message);

      case MessageType.toolReturn:
        return _ToolReturnBubble(message: message);

      case MessageType.error:
        return _ErrorBubble(message: message);

      case MessageType.status:
        return _StatusBubble(message: message);
    }
  }
}
```

---

### 3. User Message Bubble

```dart
// lib/features/chat/widgets/bubbles/user_message_bubble.dart

class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      // Right-aligned for user messages
      alignment: Alignment.centerRight,
      child: Container(
        // Maximum width constraint
        constraints: const BoxConstraints(
          maxWidth: 280, // Mobile-optimized
        ),

        // Styling
        margin: const EdgeInsets.only(
          left: 48, // Space for avatar
          bottom: 8,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: KluiColors.userBubble,
          borderRadius: BorderRadius.circular(12),
          // Subtle shadow for depth
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Text(
          message.content,
          style: KluiTextStyles.userMessage,
        ),
      ),
    );
  }
}
```

**Design Notes**:
- ✅ Right alignment (standard chat pattern)
- ✅ Blue background (high contrast)
- ✅ Rounded corners (12px - not too round)
- ✅ Max width 280px (readability on mobile)
- ✅ Subtle shadow (depth without clutter)

---

### 4. Assistant Message with Markdown

```dart
// lib/features/chat/widgets/bubbles/assistant_message_bubble.dart

class _AssistantMessageBubble extends StatelessWidget {
  const _AssistantMessageBubble({
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      // Left-aligned for assistant
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),

        margin: const EdgeInsets.only(
          right: 48,
          bottom: 8,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: KluiColors.assistantBubble,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: KluiColors.border,
            width: 1,
          ),
        ),

        child: MarkdownBody(
          data: message.content,
          styleSheet: MarkdownStyleSheet(
            // Code blocks
            code: KluiTextStyles.codeBlock.copyWith(
              color: KluiColors.toolSearch,
              backgroundColor: KluiColors.background,
            ),

            // Code blocks with language syntax highlighting
            codeblockDecoration: BoxDecoration(
              color: KluiColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: KluiColors.border,
                width: 1,
              ),
            ),

            // Inline code
            code: KluiTextStyles.codeBlock.copyWith(
              fontSize: 13,
              color: KluiColors.toolSearch,
            ),

            // Headers
            h1: KluiTextStyles.assistantMessage.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            h2: KluiTextStyles.assistantMessage.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            h3: KluiTextStyles.assistantMessage.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),

            // Lists
            listBullet: KluiTextStyles.assistantMessage.copyWith(
              color: KluiColors.userBubble,
            ),

            // Blockquotes
            blockquote: KluiTextStyles.assistantMessage.copyWith(
              fontStyle: FontStyle.italic,
              color: KluiColors.reasoning,
            ),

            // Links
            a: KluiTextStyles.assistantMessage.copyWith(
              color: KluiColors.userBubble,
              decoration: TextDecoration.underline,
            ),

            // Horizontal rules
            hr: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: KluiColors.border,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Design Notes**:
- ✅ Left alignment
- ✅ Dark gray background (subtle)
- ✅ Border for definition
- ✅ Markdown rendering with syntax highlighting
- ✅ Code blocks get special styling (monospaced, background)

---

### 5. Reasoning Bubble (Collapsible)

```dart
// lib/features/chat/widgets/bubbles/reasoning_bubble.dart

class _ReasoningBubble extends ConsumerStatefulWidget {
  const _ReasoningBubble({
    required this.message,
  });

  final ChatMessage message;

  @override
  ConsumerState<_ReasoningBubble> createState() => _ReasoningBubbleState();
}

class _ReasoningBubbleState extends ConsumerState<_ReasoningBubble> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: KluiColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: KluiColors.border,
          width: 1,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Always Visible
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              child: Row(
                children: [
                  // Thinking Icon
                  const Text(
                    '💭',
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(width: 8),

                  // Title
                  Text(
                    'Thinking...',
                    style: KluiTextStyles.reasoning.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  // Expand/Collapse Icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: KluiColors.reasoning,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content - Expandable
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                0,
                12,
                12,
              ),

              child: MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: KluiTextStyles.reasoning,
                  code: KluiTextStyles.reasoning.copyWith(
                    fontFamily: KluiTextStyles.displayFont,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

**Design Notes**:
- ✅ 💭 Icon (clear visual indicator)
- ✅ Default collapsed (reduces clutter)
- ✅ Subtle styling (not distracting)
- ✅ Smooth rotation animation (200ms)
- ✅ Full Markdown support when expanded

---

### 6. Tool Call Card (The Hero Component)

```dart
// lib/features/chat/widgets/tool_call_card.dart

class _ToolCallCard extends ConsumerWidget {
  const _ToolCallCard({
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolName = message.toolName ?? 'Unknown Tool';
    final toolInput = message.toolInput ?? {};
    final phase = message.metadata?['phase'] ?? 'ready';

    // Determine tool color
    final toolColor = _getToolColor(toolName);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: KluiColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: toolColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: toolColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Tool Name + Status
          _ToolCallHeader(
            toolName: toolName,
            toolColor: toolColor,
            phase: phase,
            toolInput: toolInput,
          ),

          // Approval UI (if ready)
          if (phase == 'ready')
            _ToolApprovalActions(
              message: message,
              toolColor: toolColor,
            ),

          // Result (if finished)
          if (phase == 'finished' && message.content.isNotEmpty)
            _ToolCallResult(
              result: message.content,
              isSuccess: message.metadata?['isOk'] == true,
            ),
        ],
      ),
    );
  }

  Color _getToolColor(String toolName) {
    final name = toolName.toLowerCase();
    if (name.contains('bash') || name.contains('shell')) {
      return KluiColors.toolBash;
    } else if (name.contains('write') || name.contains('edit')) {
      return KluiColors.toolFile;
    } else if (name.contains('search')) {
      return KluiColors.toolSearch;
    } else if (name.contains('memory')) {
      return KluiColors.toolMemory;
    }
    return KluiColors.assistantText;
  }
}

// --- Header Component ---

class _ToolCallHeader extends StatelessWidget {
  const _ToolCallHeader({
    required this.toolName,
    required this.toolColor,
    required this.phase,
    required this.toolInput,
  });

  final String toolName;
  final Color toolColor;
  final String phase;
  final Map<String, dynamic> toolInput;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Show tool details modal
      },

      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [
            // Status Indicator Dot
            _StatusDot(
              phase: phase,
              color: toolColor,
            ),

            const SizedBox(width: 12),

            // Tool Name
            Expanded(
              child: Text(
                toolName,
                style: KluiTextStyles.toolName.copyWith(
                  color: toolColor,
                ),
              ),
            ),

            // Chevron (if has input)
            if (toolInput.isNotEmpty)
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: KluiColors.reasoning,
              ),
          ],
        ),
      ),
    );
  }
}

// --- Status Indicator Dot ---

class _StatusDot extends StatefulWidget {
  const _StatusDot({
    required this.phase,
    required this.color,
  });

  final String phase;
  final Color color;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Blink animation for ready/running phases
    if (widget.phase == 'ready' || widget.phase == 'running') {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..repeat(reverse: true);

      _animation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(_controller);
    } else {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );

      _animation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(_controller);

      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color dotColor;

    switch (widget.phase) {
      case 'streaming':
        dotColor = KluiColors.statusStreaming;
        break;
      case 'ready':
        dotColor = KluiColors.statusReady;
        break;
      case 'running':
        dotColor = KluiColors.statusRunning;
        break;
      case 'finished':
        dotColor = KluiColors.statusSuccess;
        break;
      default:
        dotColor = KluiColors.reasoning;
    }

    return SizedBox(
      width: 12,
      height: 12,

      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Approval Actions ---

class _ToolApprovalActions extends ConsumerWidget {
  const _ToolApprovalActions({
    required this.message,
    required this.toolColor,
  });

  final ChatMessage message;
  final Color toolColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16,
      ),

      child: Row(
        children: [
          // Reject Button
          Expanded(
            child: _ApprovalButton(
              label: 'Reject',
              icon: Icons.block,
              color: KluiColors.error,
              backgroundColor: KluiColors.error.withOpacity(0.1),
              onTap: () {
                ref.read(chatNotifierProvider.notifier)
                    .rejectToolCall(message.id);
              },
            ),
          ),

          const SizedBox(width: 12),

          // Approve Button
          Expanded(
            child: _ApprovalButton(
              label: 'Approve',
              icon: Icons.check_circle,
              color: KluiColors.success,
              backgroundColor: KluiColors.success.withOpacity(0.1),
              onTap: () {
                ref.read(chatNotifierProvider.notifier)
                    .approveToolCall(
                      message.id,
                      toolInput: message.toolInput ?? {},
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalButton extends StatelessWidget {
  const _ApprovalButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(8),

      child: Container(
        // Minimum touch target: 48px
        constraints: const BoxConstraints(
          minHeight: 48,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),

            const SizedBox(width: 8),

            Text(
              label,
              style: TextStyle(
                fontFamily: KluiTextStyles.bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Tool Result ---

class _ToolCallResult extends StatelessWidget {
  const _ToolCallResult({
    required this.result,
    required this.isSuccess,
  });

  final String result;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    // Check if result is code
    final isCode = result.trimLeft().startsWith('```');

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16,
      ),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: KluiColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess
              ? KluiColors.border
              : KluiColors.error,
          width: 1,
        ),
      ),

      child: isCode
          ? _CodeBlockView(
              code: result,
              isSuccess: isSuccess,
            )
          : Text(
              result,
              style: KluiTextStyles.assistantMessage.copyWith(
                fontSize: 14,
                fontFamily: isSuccess
                    ? KluiTextStyles.displayFont
                    : KluiTextStyles.bodyFont,
              ),
            ),
    );
  }
}

// --- Code Block View ---

class _CodeBlockView extends StatelessWidget {
  const _CodeBlockView({
    required this.code,
    required this.isSuccess,
  });

  final String code;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    // Extract language and code
    final lines = code.split('\n');
    final firstLine = lines.first.trim();
    final hasLanguage = firstLine.startsWith('```');

    String language = 'text';
    String codeContent = code;

    if (hasLanguage) {
      final langMatch = RegExp(r'```(\w+)?').firstMatch(firstLine);
      language = langMatch?.group(1) ?? 'text';
      codeContent = lines.skip(1).join('\n');
      // Remove trailing ```
      if (codeContent.endsWith('```')) {
        codeContent = codeContent.substring(
          0,
          codeContent.length - 3,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language Header
        if (language != 'text')
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),

            child: Text(
              language.toUpperCase(),
              style: KluiTextStyles.statusIndicator.copyWith(
                color: KluiColors.toolSearch,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),

        // Code Content - Horizontal Scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            codeContent.trim(),
            style: KluiTextStyles.codeBlock.copyWith(
              color: isSuccess
                  ? KluiColors.assistantText
                  : KluiColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
```

**Design Notes**:
- ✅ Color-coded border (tool type)
- ✅ Status dot with animation (blink for ready/running)
- ✅ Expandable header (tap to show full input)
- ✅ Approval buttons (48px minimum, clear icons)
- ✅ Code block result (syntax highlight, horizontal scroll)
- ✅ Visual hierarchy (header → actions → result)

---

## 📐 Layout Architecture

### Main Chat Screen

```dart
// lib/features/chat/screens/chat_screen.dart

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.agentId,
    super.key,
  });

  final String agentId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(agentId));
    final isStreaming = ref.watch(isStreamingProvider(agentId));

    return Scaffold(
      backgroundColor: KluiColors.background,

      // App Bar - Agent Info
      appBar: AppBar(
        backgroundColor: KluiColors.surface,
        elevation: 0,
        title: Text(
          'Agent Chat',
          style: KluiTextStyles.assistantMessage.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Open settings
            },
          ),
        ],
      ),

      // Body - Messages List
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ChatMessageList(
              agentId: agentId,
              messages: messages,
              scrollController: _scrollController,
            ),
          ),

          // Input Area
          _ChatInputArea(
            controller: _controller,
            focusNode: _focusNode,
            isStreaming: isStreaming,
            onSend: (message) {
              ref.read(chatNotifierProvider.notifier)
                  .sendMessage(agentId, message);
              _controller.clear();
              _focusNode.unfocus();
            },
          ),
        ],
      ),
    );
  }
}
```

---

### Input Area

```dart
// lib/features/chat/widgets/chat_input_area.dart

class _ChatInputArea extends StatelessWidget {
  const _ChatInputArea({
    required this.controller,
    required this.focusNode,
    required this.isStreaming,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isStreaming;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),

      decoration: BoxDecoration(
        color: KluiColors.surface,
        border: Border(
          top: BorderSide(
            color: KluiColors.border,
            width: 1,
          ),
        ),
      ),

      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text Field
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,

                enabled: !isStreaming,
                maxLines: 5,
                minLines: 1,

                style: KluiTextStyles.assistantMessage.copyWith(
                  fontSize: 16,
                ),

                decoration: InputDecoration(
                  hintText: 'Message agent...',
                  hintStyle: KluiTextStyles.assistantMessage.copyWith(
                    color: KluiColors.reasoning,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: KluiColors.border,
                      width: 1,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: KluiColors.border,
                      width: 1,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: KluiColors.borderFocus,
                      width: 2,
                    ),
                  ),

                  filled: true,
                  fillColor: KluiColors.surfaceVariant,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),

                // Submit on send
                textInputAction: TextInputAction.send,
                onSubmitted: isStreaming
                    ? null
                    : (text) {
                        if (text.trim().isNotEmpty) {
                          onSend(text.trim());
                        }
                      },
              ),
            ),

            const SizedBox(width: 8),

            // Send Button
            _SendButton(
              isStreaming: isStreaming,
              onPressed: controller.text.trim().isNotEmpty && !isStreaming
                  ? () => onSend(controller.text.trim())
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.isStreaming,
    required this.onPressed,
  });

  final bool isStreaming;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Square button: 48x48
      width: 48,
      height: 48,

      decoration: BoxDecoration(
        color: onPressed != null
            ? KluiColors.userBubble
            : KluiColors.surfaceVariant,
        shape: BoxShape.circle,
      ),

      child: IconButton(
        icon: isStreaming
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    KluiColors.userText,
                  ),
                ),
              )
            : const Icon(
                Icons.send,
                size: 20,
                color: KluiColors.userText,
              ),

        onPressed: onPressed,

        // Minimum touch target
        padding: EdgeInsets.zero,
      ),
    );
  }
}
```

---

## 🎬 Animations & Micro-interactions

```dart
// lib/features/chat/widgets/animations/chat_page_transition.dart

class ChatPageTransition extends PageRouteBuilder {
  const ChatPageTransition({
    required this.child,
  });

  final Widget child;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0), // From right
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),

      child: child,
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? barrierColor => null;
}
```

---

## 📱 Performance Optimizations

```dart
// lib/core/utils/performance_config.dart

class KluiPerformanceConfig {
  // Image caching
  static const int maxMemoryCacheSize = 100 * 1024 * 1024; // 100 MB

  // ListView optimization
  static const int cacheExtent = 500; // Pre-render 500px

  // Text rendering
  static const int maxStringLength = 10000; // Truncate long text

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 200);

  // Debounce
  static const Duration inputDebounce = Duration(milliseconds: 300);
}
```

---

## 🎯 Key Differentiators

### 1. Status Dots (The Hero Element)
- ✅ Animated (blink for ready/running)
- ✅ Color-coded by phase
- ✅ 8px size (visible but not distracting)
- ✅ Always visible (not hidden behind dropdown)

### 2. Tool Cards
- ✅ Color-coded borders (tool type)
- ✅ Expandable header
- ✅ Inline approval buttons
- ✅ Code blocks with horizontal scroll

### 3. Typography
- ✅ JetBrains Mono for tools/code
- ✅ System UI for body text
- ✅ Font size hierarchy (10-24px)
- ✅ Letter spacing for tech aesthetic

### 4. Color Palette
- ✅ GitHub Dark Dim inspiration
- ✅ High contrast (accessibility)
- ✅ Semantic colors (tool types, states)
- ✅ No purple gradients (!)

---

## 📦 File Structure

```
lib/features/chat/
├── screens/
│   └── chat_screen.dart                 # Main chat screen
├── widgets/
│   ├── chat_message_list.dart           # Reverse ListView
│   ├── message_tile.dart                # Type router
│   ├── bubbles/
│   │   ├── user_message_bubble.dart
│   │   ├── assistant_message_bubble.dart
│   │   ├── reasoning_bubble.dart        # Collapsible
│   │   ├── error_bubble.dart
│   │   └── status_bubble.dart
│   ├── tool_call_card.dart              # Tool card + approval
│   │   ├── tool_approval_actions.dart
│   │   ├── tool_call_result.dart
│   │   └── code_block_view.dart
│   ├── chat_input_area.dart             # Bottom input
│   └── animations/
│       └── chat_page_transition.dart
└── providers/
    └── chat_providers.dart              # Riverpod providers
```

---

## 🚀 Next Steps

1. **Implement Core Components**
   - Start with message list + user bubble
   - Add assistant bubble + Markdown
   - Implement tool call card

2. **Add Interactions**
   - Tool approval flow
   - Collapsible reasoning
   - Expandable tool input

3. **Polish**
   - Animations
   - Micro-interactions
   - Performance testing

4. **Test**
   - Long message lists
   - Fast streaming
   - Tool approval edge cases

---

**This design is intentionally brutalist, information-dense, and optimized for developers who value clarity over cuteness. Every element serves a purpose.**
