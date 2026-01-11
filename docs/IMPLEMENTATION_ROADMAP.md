# Klui 实施路线图

**Last Updated**: 2026-01-11
**Purpose**: 汇总所有功能规划和实施方案，提供清晰的开发路线

---

## 📑 文档索引

1. **聊天功能规划** - `docs/CHAT_FEATURE_PLAN.md`
2. **API 层优化** - `docs/API_LAYER_OPTIMIZATION.md`
3. **Letta Code 功能分析** - `docs/LETTA_CODE_FEATURES.md`
4. **Letta 后端分析** - `docs/LETTA_BACKEND_ANALYSIS.md`
5. **远程开发方案对比** - `docs/REMOTE_DEV_COMPARISON.md`
6. **本文档** - 总体路线图

---

## 🎯 核心目标

构建一个**移动优先**的 Letta Web UI，支持：
- ✅ 移动端远程开发（iOS/Android）
- ✅ Agent 管理
- ✅ 聊天交互
- ✅ 工具调用批准
- ✅ 记忆管理

---

## 🏗️ 架构决策

### 技术栈

```yaml
Framework: Flutter 3.38.5
Language: Dart 3.10.4
State Management: Riverpod 3.0.3
Navigation: go_router 16.x
Target:
  - Mobile: iOS, Android (primary)
  - Web: CanvasKit renderer (secondary)
API: Letta Backend (REST + SSE)
```

### 架构原则

```
┌─────────────────────────────────────────┐
│         Klui (Flutter)                  │
│  ┌──────────────┐  ┌─────────────────┐  │
│  │   移动端      │  │    桌面端       │  │
│  │ (iOS/Android) │  │ (Web/Desktop)   │  │
│  └──────────────┘  └─────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  UI Layer (features/)            │   │
│  │   - Agent screens                │   │
│  │   - Provider screens             │   │
│  │   - Chat screens                 │   │
│  │   - Settings screens             │   │
│  └──────────────┬──────────────────┘   │
│                 │ (Riverpod providers)  │
│  ┌──────────────▼──────────────────┐   │
│  │  Provider Layer (core/providers/)│ │
│  │   - agent_providers.dart         │   │
│  │   - provider_providers.dart      │   │
│  │   - model_providers.dart         │   │
│  │   - chat_providers.dart          │   │
│  └──────────────┬──────────────────┘   │
│                 │ (API helpers)        │
│  ┌──────────────▼──────────────────┐   │
│  │  API Layer (core/utils/)         │   │
│  │   - api_client.dart              │   │
│  │   - api_helper.dart              │   │
│  └──────────────┬──────────────────┘   │
│                 │ HTTP/SSE             │
└─────────────────┼─────────────────────┘
                  │
                  ▼
        ┌─────────────────────┐
        │  Letta Backend       │
        │  - Agent management  │
        │  - Memory system     │
        │  - Tool execution    │
        │  - SSE streaming     │
        └─────────────────────┘
```

**关键原则** (来自 `CLAUDE.md`):
1. ✅ UI MUST use `ref.watch(provider)` or `ref.read(provider.future)`
2. ✅ Providers MUST use `ApiHelper.parseList/parseSingle/parseEmpty`
3. ✅ Providers MUST handle errors via `ApiException`
4. ❌ UI MUST NOT import `api_client.dart` directly
5. ❌ Providers MUST NOT contain UI logic

---

## 📅 开发阶段

### ✅ Phase 0: 基础设施 (已完成)

- [x] 项目初始化
- [x] Riverpod 状态管理
- [x] go_router 路由配置
- [x] API 封装 (ApiClient, ApiHelper)
- [x] 基础模型 (Agent, Provider, LLMModel, EmbeddingModel)
- [x] CRUD Providers (Agent, Provider, Model)
- [x] 列表页面
- [x] 详情页面

---

### 🚧 Phase 1: 聊天功能 (当前优先级)

**目标**: 实现基本的聊天交互功能

**详见**: `docs/CHAT_FEATURE_PLAN.md`

#### 1.1 消息模型

```dart
// lib/core/models/chat_message.dart

enum MessageType {
  user,           // 用户消息
  assistant,      // Assistant 回复
  toolCall,       // 工具调用请求
  toolReturn,     // 工具执行结果
  reasoning,      // 推理过程（Claude Opus）
  error,          // 错误消息
}

class ChatMessage {
  final String id;
  final MessageType type;
  final String content;
  final Map<String, dynamic>? metadata;

  // Tool call 特有字段
  final String? toolName;
  final Map<String, dynamic>? toolInput;

  // Tool return 特有字段
  final String? toolCallId;
  final bool? isToolError;
}
```

#### 1.2 聊天 Provider

```dart
// lib/core/providers/chat_providers.dart

@riverpod
class ChatNotifier extends _$ChatNotifier {
  Future<void> sendMessage(String agentId, String content) async {
    // 1. 添加用户消息到列表
    // 2. 调用 Letta API 发送消息
    // 3. 处理 SSE 流式响应
    // 4. 更新消息状态
  }

  Stream<ChatMessage> streamMessages(String agentId, String message) async* {
    // SSE 流式处理
  }

  Future<void> approveToolCall(String runId, String toolCallId, Map<String, dynamic> output) async {
    // 批准工具调用
  }

  Future<void> rejectToolCall(String runId, String toolCallId) async {
    // 拒绝工具调用
  }
}
```

#### 1.3 聊天 UI

```dart
// lib/features/chat/screens/chat_screen.dart

class ChatScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider(agentId));
    final isStreaming = ref.watch(isStreamingProvider(agentId));

    return Column(
      children: [
        // 消息列表
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return MessageBubble(messages[index]);
            },
          ),
        ),

        // 工具批准对话框
        if (pendingApproval != null)
          ToolApprovalDialog(
            approval: pendingApproval,
            onApprove: (output) => ref.read(chatNotifierProvider.notifier).approveToolCall(...),
            onReject: () => ref.read(chatNotifierProvider.notifier).rejectToolCall(...),
          ),

        // 输入框
        MessageInput(
          onSend: (message) => ref.read(chatNotifierProvider.notifier).sendMessage(...),
          enabled: !isStreaming,
        ),
      ],
    );
  }
}
```

#### 1.4 SSE 流式响应处理

```dart
// lib/core/utils/sse_parser.dart

class LettaSSEParser {
  static Stream<ChatMessage> parse(Stream<String> sseStream) async* {
    await for (final chunk in sseStream) {
      // 解析 SSE 格式
      // data: {"type":"assistant_message", ...}
      final lines = chunk.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = jsonDecode(line.substring(6));
          yield _parseMessage(data);
        }
      }
    }
  }

  static ChatMessage _parseMessage(Map<String, dynamic> data) {
    // 根据 data['type'] 解析不同类型的消息
    // - assistant_message
    // - tool_call_message
    // - tool_return_message
    // - reasoning_message (Claude Opus)
  }
}
```

**Letta 后端消息类型**:
```typescript
// Assistant 消息
{
  "type": "assistant_message",
  "content": "Hello!",
  "id": "msg_..."
}

// Tool Call 消息
{
  "type": "tool_call_message",
  "tool": "web_search",
  "tool_input": { "query": "..." },
  "id": "tool_..."
}

// Tool Return 消息
{
  "type": "tool_return_message",
  "tool_call_id": "tool_...",
  "output": "..."
}

// Reasoning 消息（Claude Opus）
{
  "type": "reasoning_message",
  "content": "Thinking..."
}
```

**预计工作量**: 3-5 天

---

### 🔧 Phase 2: 工具批准系统

**目标**: 实现工具调用的权限控制

#### 2.1 工具批准模型

```dart
// lib/core/models/tool_approval.dart

class ToolApprovalRequest {
  final String runId;
  final String toolCallId;
  final String toolName;
  final Map<String, dynamic> toolInput;
  final String? description;
  final bool isDangerous;
}

class ToolApprovalDecision {
  final bool approved;
  final Map<String, dynamic>? modifiedOutput;
  final String? reason;
}
```

#### 2.2 权限分析器（参考 Letta Code）

```dart
// lib/core/utils/permission_analyzer.dart

class PermissionAnalyzer {
  static ToolApprovalDecision analyze(
    String toolName,
    Map<String, dynamic> toolInput,
  ) {
    // 根据 Letta Code 的权限规则分析
    // - 读取文件: 允许
    // - 写入文件: 询问
    // - 执行命令: 拒绝（除非是 safe_commands）
    // - web_search: 允许
  }
}
```

**Letta Code 的权限规则**（参考）:
```typescript
// 安全工具（无需批准）
const SAFE_TOOLS = ['memory', 'conversation_search', 'web_search', 'fetch_webpage'];

// 危险工具（总是拒绝）
const DANGEROUS_TOOLS = ['shell', 'run_shell_command'];

// 文件操作工具（需要批准）
const FILE_TOOLS = ['read', 'write', 'edit', 'multi_edit'];
```

#### 2.3 批准 UI

```dart
// lib/features/chat/components/tool_approval_dialog.dart

class ToolApprovalDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('工具执行批准'),
      content: Column(
        children: [
          Text('工具: ${approval.toolName}'),
          Text('参数: ${approval.toolInput}'),
          if (approval.isDangerous)
            Text('⚠️ 此操作可能有风险', style: TextStyle(color: Colors.red)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onReject,
          child: Text('拒绝'),
        ),
        ElevatedButton(
          onPressed: onApprove,
          child: Text('批准'),
        ),
      ],
    );
  }
}
```

**预计工作量**: 2-3 天

---

### 📁 Phase 3: 远程开发能力

**目标**: 支持通过 Letta 后端执行代码和文件操作

**详见**: `docs/REMOTE_DEV_COMPARISON.md`

**架构决策**: 直接使用 Letta 后端（不使用 Letta Code 包装）

#### 3.1 代码执行（使用 run_code 工具）

```dart
// 示例：让 Agent 执行代码

final response = await agent.sendMessage('''
使用 run_code 工具执行以下操作：
1. 列出当前目录文件
2. 读取 package.json
3. 运行 npm test
返回结果。
''');
```

**Letta 后端的 run_code 工具**:
```python
def run_code(code: str, language: Literal["python", "js", "ts", "r", "java"]) -> str:
    """
    Run code in a sandbox. Supports Python, Javascript, Typescript, R, and Java.
    """
    # 在沙箱中执行代码
    # 返回 stdout, stderr, error traces
```

#### 3.2 文件操作（阶段 1：使用 run_code）

```dart
// 临时方案：通过 run_code 执行文件操作
final response = await agent.sendMessage('''
使用 Python 的 run_code 工具执行：
```python
import os
# 列出文件
files = os.listdir('.')
print(files)

# 读取文件
with open('src/main.ts', 'r') as f:
    content = f.read()
    print(content[:500])  # 打印前 500 字符
```
''');
```

#### 3.3 文件操作（阶段 2：等待 Letta 后端实现或添加自定义工具）

**方案 A**: 等待 Letta 后端实现文件工具
- `open_files` - 接口已定义，未实现
- `grep_files` - 接口已定义，未实现

**方案 B**: 添加自定义工具
```dart
// 通过 Letta API 添加工具
POST /v1/tools
{
  "name": "server_read_file",
  "description": "Read a file from server workspace",
  "source_code": '''
async def server_read_file(path: str) -> str:
    """Read file from server workspace directory"""
    import os
    if not os.path.exists(path):
        return f"Error: File not found: {path}"
    with open(path, 'r') as f:
        return f.read()
  ''',
  "tool_type": "python"
}
```

#### 3.4 文件浏览器 UI

```dart
// lib/features/chat/screens/file_browser_screen.dart

class FileBrowserScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(serverFilesProvider);

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(files[index].name),
          trailing: Icon(Icons.insert_drive_file),
          onTap: () {
            // 打开文件预览
            ref.read(chatNotifierProvider.notifier).sendMessage('''
              请使用 run_code 读取文件：${files[index].path}
              返回前 1000 行内容。
            ''');
          },
        );
      },
    );
  }
}
```

**预计工作量**: 3-5 天

---

### 🧠 Phase 4: 记忆管理 UI

**目标**: 查看和管理 Agent 的记忆块

#### 4.1 记忆列表页面

```dart
// lib/features/agents/screens/agent_memory_screen.dart

class AgentMemoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watch(agentBlocksProvider(agentId));

    return ListView.builder(
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(blocks[index].label),
          subtitle: Text(blocks[index].description ?? ''),
          trailing: Text('${blocks[index].value.length}/${blocks[index].limit ?? '∞'}'),
          onTap: () {
            // 显示记忆块详情
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => MemoryDetailScreen(block: blocks[index]),
            ));
          },
        );
      },
    );
  }
}
```

#### 4.2 记忆详情页面

```dart
// lib/features/agents/screens/memory_detail_screen.dart

class MemoryDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(block.label)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('描述:', style: Theme.of(context).textTheme.subtitle1),
            Text(block.description ?? '无'),
            SizedBox(height: 16),
            Text('内容:', style: Theme.of(context).textTheme.subtitle1),
            Text(block.value),
          ],
        ),
      ),
    );
  }
}
```

**预计工作量**: 2-3 天

---

### 🎨 Phase 5: UI 优化

#### 5.1 移动端优化
- 触摸友好的按钮大小
- 滑动手势支持
- 响应式布局
- Dark mode

#### 5.2 性能优化
- 消息列表虚拟化
- 图片懒加载
- 缓存策略

**预计工作量**: 2-3 天

---

## 📊 进度跟踪

| 阶段 | 任务 | 状态 | 预计工作量 |
|------|------|------|-----------|
| Phase 0 | 基础设施 | ✅ 完成 | - |
| Phase 1 | 聊天功能 | 🚧 进行中 | 3-5 天 |
| Phase 2 | 工具批准 | ⏸️ 待开始 | 2-3 天 |
| Phase 3 | 远程开发 | ⏸️ 待开始 | 3-5 天 |
| Phase 4 | 记忆管理 | ⏸️ 待开始 | 2-3 天 |
| Phase 5 | UI 优化 | ⏸️ 待开始 | 2-3 天 |

**总预计工作量**: 12-19 天

---

## 🔄 当前优先级

### 高优先级 (P0)
1. ✅ Agent CRUD 功能
2. ✅ Provider CRUD 功能
3. 🚧 聊天 UI + SSE 流式响应
4. ⏸️ 工具批准系统

### 中优先级 (P1)
5. ⏸️ 远程开发能力（run_code）
6. ⏸️ 记忆查看 UI
7. ⏸️ 移动端优化

### 低优先级 (P2)
8. ⏸️ 完整的记忆管理（创建/编辑/删除）
9. ⏸️ 文件浏览器 UI
10. ⏸️ 桌面端适配

---

## 📚 相关文档

### 设计文档
- `docs/CHAT_FEATURE_PLAN.md` - 聊天功能详细规划
- `docs/API_LAYER_OPTIMIZATION.md` - API 层优化记录
- `docs/LETTA_CODE_FEATURES.md` - Letta Code 功能分析
- `docs/LETTA_BACKEND_ANALYSIS.md` - Letta 后端工具分析
- `docs/REMOTE_DEV_COMPARISON.md` - 远程开发方案对比

### 技术文档
- `CLAUDE.md` - 项目开发指南（必读！）
- `README.md` - 项目介绍
- `pubspec.yaml` - 依赖配置

### 参考实现
- Letta Code: `../letta-code/` - CLI 参考实现
- Letta Backend: `../letta/` - 后端服务器
- Happy: `../happy/` - 移动端参考实现

---

## 🎯 里程碑

### Milestone 1: MVP (Minimum Viable Product)
- ✅ Agent 管理
- ✅ Provider 管理
- 🚧 基本聊天功能
- 🚧 工具批准

### Milestone 2: 远程开发
- ⏸️ 代码执行
- ⏸️ 文件操作（通过 run_code）
- ⏸️ 记忆查看

### Milestone 3: 完整功能
- ⏸️ 完整记忆管理
- ⏸️ 文件浏览器
- ⏸️ UI 优化

---

**下一步**: 开始实现 Phase 1 - 聊天功能！
