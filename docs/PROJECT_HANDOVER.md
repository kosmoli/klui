# Klui 项目状态交接文档

**创建时间**: 2026-01-12
**项目**: Letta Flutter UI (klui)
**所有者**: Kosmo
**仓库**: https://github.com/kosmoli/klui
**语言**: 中文交流，代码注释和commit用英文
**当前分支**: `main`
**最新提交**: `ef36785` - feat: implement theme system with CRT retro design and chat UI

---

## 📊 项目概览

Klui 是一个为 Letta AI Agent 平台设计的 Flutter Web 应用，采用 Neo-Brutalist CRT 复古终端风格。目标是服务专业用户，提供完整的 API 访问功能（与官方简化版 UI 形成差异化）。

### 核心定位
- **服务对象**: 需要完整 API 访问的专业用户
- **设计理念**: 暴露所有 API 功能，不隐藏高级选项
- **差异化**: 官方 UI = 简化版面向初学者，Klui = 完整版面向专家

---

## ✅ 已完成的工作 (2026-01-12)

### 1. 主题系统重构 ⭐ 核心架构

**重要**: 这是项目最重要的架构改进，**所有新代码必须遵守**。

#### 迁移内容
- ✅ 从静态 `KluiColors` 迁移到 `ThemeExtension<KluiCustomColors>()`
- ✅ 实现完整的主题切换支持（支持 lerp 动画过渡）
- ✅ 已迁移文件：
  - `lib/shared/widgets/agent_card.dart`
  - `lib/shared/widgets/main_navigation.dart`
  - `lib/features/providers/widgets/provider_card.dart`
  - `lib/features/providers/widgets/provider_form.dart`
  - `lib/features/agents/screens/agent_list_screen.dart`
  - `lib/features/chat/widgets/tool_call_card.dart`
  - 所有聊天气泡组件（UserMessageBubble, AssistantMessageBubble, ReasoningBubble, ErrorBubble）

#### 使用规则（MANDATORY）

```dart
// ✅ 正确方式
@override
Widget build(BuildContext context) {
  final colors = Theme.of(context).extension<KluiCustomColors>()!;
  return Container(color: colors.surface);
}

// ❌ 错误方式（已弃用）
import 'klui_colors.dart';
Container(color: KluiColors.surface)
```

**文档位置**: `CLAUDE.md` 第 11.4 节已更新，强制要求使用主题系统

#### KluiCustomColors 详解

`KluiCustomColors` 是一个继承自 `ThemeExtension<KluiCustomColors>` 的类，定义了应用中所有自定义颜色。

**为什么需要它？**
- **单一真相源**: 在一个地方修改颜色，整个应用自动更新
- **支持主题切换**: 轻松添加亮色/暗色/自定义主题
- **未来可扩展**: 遵循 Flutter 主题最佳实践
- **动画支持**: lerp() 方法实现平滑过渡

**可用颜色**:
```dart
final colors = Theme.of(context).extension<KluiCustomColors>()!;

// 背景色
colors.background          // 主背景
colors.surface            // 卡片/表面背景
colors.surfaceVariant     // 输入框等变体背景

// 消息气泡
colors.userBubble         // 用户消息背景（CRT绿色 #00FF41）
colors.userText           // 用户消息文字
colors.assistantBubble    // 助手消息背景
colors.assistantText      // 助手消息文字
colors.reasoning          // 推理过程文字

// 工具颜色
colors.toolBash           // Bash/Shell工具
colors.toolFile           // 文件操作工具
colors.toolSearch         // 搜索工具
colors.toolMemory         // 记忆工具

// 状态颜色
colors.statusStreaming    // 流式传输状态
colors.statusReady        // 等待批准状态
colors.statusRunning      // 运行中状态
colors.statusSuccess      // 成功状态
colors.statusError        // 错误状态
colors.success            // 通用成功
colors.error              // 通用错误
colors.warning            // 警告

// 文字颜色
colors.textPrimary        // 主要文字
colors.textSecondary      // 次要文字
colors.textDisabled       // 禁用文字

// 边框
colors.border             // 标准边框
```

**关键特性**:
1. **lerp() 方法**: 主题切换时平滑过渡所有颜色
2. **copyWith() 方法**: 部分颜色覆盖
3. **静态访问器**: `KluiCustomColors.light` 和 `KluiCustomColors.dark`

### 2. CRT 复古终端主题设计

- ✅ 荧光绿主色 (#00FF41) - 复古 CRT 显示器效果
- ✅ 深色背景 (#0A0E0A) - 高对比度，护眼
- ✅ Neo-Brutalist 设计风格 - 粗犷、高对比度、技术美学
- ✅ 等宽字体（JetBrains Mono, Space Mono）- 代码和技术细节
- ✅ 高对比度边框（2px）- 清晰的视觉层次

**主题文件结构**:
```
lib/core/theme/
├── klui_colors.dart           # 静态颜色定义（向后兼容）
├── klui_theme_extension.dart  # 主题扩展（核心，新代码必须用）
├── klui_text_styles.dart      # 文字样式定义
└── neo_brutalist_theme.dart   # ThemeData 配置
```

### 3. 聊天 UI 组件系统

已完成所有核心聊天组件，可直接用于实时聊天功能。

#### 消息气泡组件

**位置**: `lib/features/chat/widgets/bubbles/`

1. **UserMessageBubble** (`user_message_bubble.dart`)
   - 右对齐显示
   - CRT 绿色背景
   - 支持长文本换行
   - 完整的 Semantics 支持

2. **AssistantMessageBubble** (`assistant_message_bubble.dart`)
   - 左对齐显示
   - 支持 Markdown 渲染
   - 代码块语法高亮
   - 自适应布局

3. **ReasoningBubble** (`reasoning_bubble.dart`)
   - 可折叠的推理过程展示
   - 默认收起状态
   - 淡色文字表示"思考中"
   - 点击展开/收起动画

4. **ErrorBubble** (`error_bubble.dart`)
   - 错误消息样式
   - 红色边框和背景
   - 清晰的错误提示

#### 工具调用组件

**ToolCallCard** (`lib/features/chat/widgets/tool_call_card.dart`)

完整的工具调用交互卡片，包含：

- **状态指示点** (带动画)
  - `streaming`: 灰色动画点（流式传输）
  - `ready`: 灰色闪烁点（等待批准）
  - `running`: 黄色闪烁点（执行中）
  - `finished`: 绿色实心点（成功）/ 红色实心点（失败）

- **工具信息展示**
  - 工具名称（带颜色标识）
    - Bash/Shell: toolBash 颜色
    - Write/Edit: toolFile 颜色
    - Search: toolSearch 颜色
    - Memory: toolMemory 颜色
  - 可展开的参数显示
  - Chevron 箭头动画

- **批准操作**（phase = 'ready' 时显示）
  - Approve 按钮（绿色，成功色）
  - Reject 按钮（红色，错误色）
  - 触摸友好的按钮尺寸（48x48）

- **执行结果**（phase = 'finished' 时显示）
  - 代码块渲染（带水平滚动）
  - 语言标签（如 PYTHON, JAVASCRIPT）
  - 可选择性文本

**代码实现亮点**:
```dart
// 工具颜色动态选择
Color _getToolColor(BuildContext context) {
  final colors = Theme.of(context).extension<KluiCustomColors>()!;
  final toolName = widget.message.toolName?.toLowerCase() ?? '';
  if (toolName.contains('bash') || toolName.contains('shell')) {
    return colors.toolBash;
  } else if (toolName.contains('write') || toolName.contains('edit')) {
    return colors.toolFile;
  } else if (toolName.contains('search')) {
    return colors.toolSearch;
  } else if (toolName.contains('memory')) {
    return colors.toolMemory;
  }
  return colors.assistantText;
}
```

#### 示例页面

**ChatExampleScreen** (`lib/features/chat/screens/chat_example_screen.dart`)
- 聊天 UI 演示页面
- 包含所有消息类型的示例
- **注意**: 按用户要求，此页面未迁移到主题系统

#### 数据模型

**ChatMessage** (`lib/core/models/chat_message.dart`)

使用 Freezed 生成的不可变数据模型：

```dart
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String role,           // user, assistant, system
    required String content,
    String? toolName,               // 工具调用时使用
    Map<String, dynamic>? toolInput, // 工具参数
    Map<String, dynamic>? metadata,  // 元数据（phase, isOk等）
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
```

**metadata 字段说明**:
- `phase`: 消息阶段（'streaming', 'ready', 'running', 'finished'）
- `isOk`: 工具执行是否成功（布尔值）

#### 文档

**CHAT_UI_DESIGN.md** (`docs/CHAT_UI_DESIGN.md`)
- 完整的聊天 UI 设计规范
- 消息类型说明
- 移动端优化建议
- Flutter Web 性能优化配置

### 4. 无障碍访问 (Accessibility)

所有 UI 组件已完成无障碍标注：

#### Semantics 使用规范

1. **MergeSemantics** - 图标+文字组合
```dart
MergeSemantics(
  child: Row(
    children: [
      Icon(Icons.smart_toy),
      Text('Agent'),
    ],
  ),
)
```

2. **ExcludeSemantics** - 纯装饰元素
```dart
ExcludeSemantics(
  child: Icon(Icons.star),  // 纯装饰，不读给屏幕阅读器
)
```

3. **自定义 Semantics** - 交互控件
```dart
Semantics(
  label: context.l10n.agent_card_label(agent.name),
  button: true,
  hint: context.l10n.agent_card_hint_view_details,
  child: InkWell(onTap: () {}),
)
```

#### i18n 支持

- ✅ 所有用户可见字符串使用 `context.l10n.xxx`
- ✅ ARB 文件: `lib/l10n/app_en.arb` (模板), `lib/l10n/app_zh.arb` (中文)
- ✅ 生成代码: `lib/l10n/generated/app_localizations.dart`

**构建命令**:
```bash
flutter gen-l10n  # 生成 l10n 代码
flutter build web # 自动生成 l10n + riverpod
```

### 5. Agent 管理功能

#### 已完成

1. **Agent List Screen** (`lib/features/agents/screens/agent_list_screen.dart`)
   - ✅ 展示所有 Agent
   - ✅ 删除功能（带确认对话框）
   - ✅ 空状态提示
   - ✅ 加载和错误状态
   - ✅ FloatingActionButton 跳转到创建页面

2. **Agent Create Screen** (`lib/features/agents/screens/agent_create_screen.dart`)
   - ✅ BYOK 模式完整表单（1303 行）
   - ✅ LLM 配置（Provider, Model 选择）
   - ✅ Embedding 配置
   - ✅ 工具选择（多选）
   - ✅ 系统提示词编辑
   - ✅ 表单验证

3. **Agent Detail Screen** (`lib/features/agents/screens/agent_detail_screen.dart`)
   - ✅ Agent 信息展示（484 行）
   - ✅ 配置详情查看
   - ✅ 工具列表展示

#### 待完善

- ⏳ Agent 编辑功能
- ⏳ Agent 详情页添加"开始对话"按钮

### 6. Provider 管理

#### 已完成

1. **Provider List Screen** (`lib/features/providers/screens/provider_list_screen.dart`)
   - ✅ 展示所有 Provider
   - ✅ 分类显示（Base vs Database）
   - ✅ Provider 类型标识

2. **Provider Form** (`lib/features/providers/widgets/provider_form.dart`)
   - ✅ 创建/编辑表单
   - ✅ Provider 类型选择（OpenAI, Anthropic, Ollama等）
   - ✅ Base URL 配置
   - ✅ API Key 输入（密文显示）

3. **Provider Card** (`lib/features/providers/widgets/provider_card.dart`)
   - ✅ Neo-Brutalist 卡片设计
   - ✅ 类型徽章（providerType）
   - ✅ 分类徽章（providerCategory: BASE/DATABASE）
   - ✅ Base URL 显示
   - ✅ 删除按钮

#### 待完善

- ⏳ Provider 删除确认逻辑
- ⏳ 测试连接功能

### 7. 路由系统

**配置文件**: `lib/core/routes/app_router.dart`

使用 `go_router` 16.x 实现：

```dart
// 路由结构
/                          → HomeScreen (重定向到 /agents)
/agents                    → AgentListScreen
/agents/create             → AgentCreateScreen
/agents/:id                → AgentDetailScreen
/providers                 → ProviderListScreen
/providers/create          → ProviderCreateScreen
/chat                      → ChatScreen (未来)
/chat/:agentId             → ChatDetailScreen (未来)
```

---

## ⏳ 待实现功能

### 优先级 1: 实时聊天 (SSE 流式传输) ⭐

**状态**: UI 组件完成，需要集成后端 SSE 流

#### 需要做的事情

1. **选择 SSE 客户端库**
   - 选项 1: `http` 包手动解析（推荐用于 Web）
   - 选项 2: `flutter_http_sse` 包（需验证 Web 兼容性）

2. **创建 Chat Provider** (`lib/core/providers/chat_provider.dart`)

```dart
// 示例结构
@riverpod
Stream<List<ChatMessage>> chatMessages(ChatMessagesRef ref, String agentId) {
  // SSE 连接到 /agents/{agentId}/chat
  // 解析流式消息
  // 返回消息列表 Stream
}

@riverpod
Future<void> sendMessage(SendMessageRef ref, {
  required String agentId,
  required String message,
}) async {
  // POST 请求发送消息
  // 处理响应
}
```

3. **实现 SSE 客户端**

```dart
// 伪代码示例
class ChatSseClient {
  Stream<ChatMessage> connect(String agentId) async* {
    final client = ApiClient(); // 从 api_client.dart 获取
    final url = '/agents/$agentId/chat';

    // 建立 SSE 连接
    final stream = client.streamPost(url, data: {'message': 'hello'});

    await for (final data in stream) {
      final message = ChatMessage.fromJson(data);
      yield message;
    }
  }
}
```

4. **创建聊天界面** (`lib/features/chat/screens/chat_screen.dart`)

   需要整合：
   - 聊天消息列表（使用现有的气泡组件）
   - 用户输入框（底部固定，多行支持）
   - ToolCallCard 的批准/拒绝交互
   - 自动滚动到底部

5. **处理消息类型分发**

```dart
Widget _buildMessageBubble(ChatMessage message) {
  switch (message.role) {
    case 'user':
      return UserMessageBubble(message: message);
    case 'assistant':
      if (message.toolName != null) {
        return ToolCallCard(message: message);
      }
      return AssistantMessageBubble(message: message);
    case 'reasoning':
      return ReasoningBubble(message: message);
    case 'error':
      return ErrorBubble(message: message);
    default:
      return const SizedBox.shrink();
  }
}
```

#### API 端点

**文档**: `docs/LETTA_API_OVERVIEW.md`

```bash
POST /agents/{agent_id}/chat
Content-Type: application/json
Authorization: Bearer {token}

{
  "message": "用户消息",
  "stream": true  # 启用 SSE 流式传输
}

# 响应: text/event-stream 格式
data: {"role": "reasoning", "content": "思考中..."}
data: {"role": "tool_call", "tool_name": "bash", "tool_input": {...}}
data: {"role": "assistant", "content": "回复内容"}
```

#### 参考实现

- **Letta Code**: `/root/work/letta-code/src/cli/App.tsx` (查看 SSE 处理逻辑)
- **Happy**: `/root/work/happy/sources/components/AgentInput.tsx` (移动端聊天实现)

### 优先级 2: Agent 功能完善

#### Agent 编辑功能

**位置**: `lib/features/agents/screens/agent_edit_screen.dart`

复用 `agent_create_screen.dart` 的表单组件，需要：
1. 预填充现有数据
2. PUT 请求到 `/agents/{id}` 而不是 POST
3. 保存成功后返回详情页

#### Agent 详情页添加"开始对话"按钮

**位置**: `lib/features/agents/screens/agent_detail_screen.dart`

```dart
FloatingActionButton.extended(
  onPressed: () => context.go('/chat/${agent.id}'),
  icon: const Icon(Icons.chat),
  label: const Text('Start Chat'),
)
```

### 优先级 3: Provider 功能完善

#### Provider 删除确认

**当前状态**: UI 有删除按钮，但未实现确认对话框

**需要实现**:
```dart
void _showDeleteDialog(BuildContext context, ProviderConfig provider) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Provider'),
      content: Text('Are you sure you want to delete ${provider.name}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        TextButton(
          onPressed: () {
            ref.read(providerListProvider.notifier).deleteProvider(provider.id);
            Navigator.pop(context);
          },
          child: Text('Delete', style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
}
```

#### 测试连接功能

**API 端点**: `POST /providers/test` (需确认实际端点)

**UI 实现**:
- 在 ProviderForm 底部添加"Test Connection"按钮
- 点击后显示加载状态
- 成功/失败提示

### 优先级 4: Tools 管理

**状态**: 未开始

#### 需要实现

1. **Tools List Screen** (`lib/features/tools/screens/tools_list_screen.dart`)
   - 展示所有可用工具
   - 工具描述和参数说明
   - 启用/禁用开关

2. **Tool 配置界面** (如果需要)
   - 工具参数配置
   - 权限设置

3. **集成到 Agent 创建流程**
   - Agent 创建时选择工具
   - 工具依赖检查

---

## 🏗️ 架构规则 (MANDATORY)

### 三层架构（严格遵循）

```
UI Layer (features/)
  ↓ 仅使用 providers
Provider Layer (core/providers/api_providers.dart)
  ↓ 仅使用 ApiHelper + ApiClient
API Layer (core/utils/api_client.dart, api_helper.dart)
  ↓ HTTP 请求
Letta Backend
```

#### 规则清单

**✅ DO**:
1. UI 必须通过 `ref.watch(provider)` 或 `ref.read(provider.future)` 访问数据
2. Providers 必须使用 `ApiHelper.parseList/parseSingle/parseEmpty` 解析响应
3. Providers 必须通过 `ApiException` 处理错误
4. 遵循单向数据流

**❌ DON'T**:
1. UI 禁止直接导入 `api_client.dart`
2. Providers 禁止包含 UI 逻辑（导航、格式化等）
3. 禁止散落 JSON 解析代码（统一使用 ApiHelper）
4. 禁止跨层混合职责

#### 正确示例

```dart
// ✅ Provider 层 (core/providers/api_providers.dart)
@riverpod
Future<List<Agent>> agentList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/');
  return ApiHelper.parseList(response, Agent.fromJson);
}

// ✅ UI 层 (features/agents/screens/agent_list_screen.dart)
class AgentListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentListProvider);

    return agentsAsync.when(
      data: (agents) => ListView.builder(
        itemCount: agents.length,
        itemBuilder: (context, index) => AgentCard(agent: agents[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

#### 错误示例

```dart
// ❌ UI 层直接使用 ApiClient
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(apiClientProvider); // ❌ 不要这样做
    // ...
  }
}

// ❌ Provider 包含 UI 逻辑
@riverpod
Future<List<Agent>> agentList(Ref ref) async {
  final agents = await _fetchAgents();
  // ❌ 不要在这里做格式化、导航等 UI 逻辑
  final formatted = agents.map((a) => a.name.toUpperCase()).toList();
  return formatted;
}
```

**文档**: `CLAUDE.md` 第 3.1 节

### 代码质量规则

#### 1. 主题系统（MANDATORY）

**所有新代码必须使用**:
```dart
final colors = Theme.of(context).extension<KluiCustomColors>()!;
```

**禁止使用**:
```dart
import 'klui_colors.dart';
KluiColors.surface  // ❌ 已弃用
```

**文档**: `CLAUDE.md` 第 11.4 节

#### 2. Semantics（无障碍访问）

**优先级 1**: 标准 Widget 已有 Semantics，无需额外包装
- IconButton, TextButton, ElevatedButton, TextField, Checkbox 等

**优先级 2**: 需要添加自定义 Semantics 的场景
1. **装饰性图标**: `label + button: true`
2. **图片**: `label: '描述性替代文本'`（避免"图片"这类无用描述）
3. **自定义控件**: `button: true + label + hint`
4. **纯装饰**: `excludeSemantics: true` 或 `ExcludeSemantics` 包装
5. **图标+文字组合**: `MergeSemantics` 合并为一个语义单元
6. **无文字的可点击元素**: 添加 `hint`（如"双击缩放"）

**文档**: `CLAUDE.md` 第 11.3 节

#### 3. i18n（国际化）

**所有用户可见字符串** → 使用 `context.l10n.string_key`

**设置**:
- Flutter 官方 `flutter_localizations` + `intl` 包
- ARB 文件: `lib/l10n/app_en.arb`（模板）, `lib/l10n/app_zh.arb`（中文）
- 访问: `import 'context_extensions.dart'`, 使用 `context.l10n.key_name`

**文档**: `CLAUDE.md` 第 11.3 节

#### 4. 错误处理

**系统边界必须有 try-catch**:
- Provider 层捕获 API 异常
- UI 层通过 `AsyncValue.error` 显示错误

```dart
// ✅ Provider 层
@riverpod
Future<List<Agent>> agentList(Ref ref) async {
  try {
    final client = ref.watch(apiClientProvider);
    final response = await client.get('/agents/');
    return ApiHelper.parseList(response, Agent.fromJson);
  } catch (e) {
    throw ApiException('Failed to load agents: $e');
  }
}
```

#### 5. Const 构造函数

**优先使用 const**，但注意：
- 不能用 const 声明包含动态颜色的 Widget
- 非 const 表达式（如 `colors.surface`）不能在 const 构造函数中使用

```dart
// ✅ 正确
const Text('Hello');
Container(color: colors.surface)  // 非 const

// ❌ 错误
const Container(color: colors.surface)  // colors 不是常量表达式
```

---

## 🔧 开发工作流

### 构建和部署 (CRITICAL)

⚠️ **必须在 `/root/work/klui` 目录下执行**

```bash
# 验证目录
pwd  # 应显示 /root/work/klui
ls deploy.sh  # 确认文件存在

# ✅ 唯一正确的构建部署方式
./deploy.sh
```

#### deploy.sh 做什么？

1. 验证正确工作目录
2. 设置正确的 Flutter PATH (`/opt/flutter/bin`)
3. 使用正确 API_BASE_URL 构建 (`http://38.175.200.93:8283/v1`)
4. 停止旧 HTTP 服务器
5. 启动新 HTTP 服务器（端口 8080）
6. 显示验证信息（URL、进程 ID）

#### ⛔ 禁止使用的命令

- ❌ `flutter build web` (用 deploy.sh 代替)
- ❌ `dart run build_runner` (deploy.sh 会处理)
- ❌ 手动启动 Python HTTP 服务器 (deploy.sh 管理)

#### 完整路径（避免目录混淆）

- Flutter SDK: `/opt/flutter/bin`
- Flutter 可执行文件: `/opt/flutter/bin/flutter`
- Dart 可执行文件: `/opt/flutter/bin/dart`
- 项目根目录: `/root/work/klui`
- 部署脚本: `/root/work/klui/deploy.sh`

#### 重要提示

**浏览器需要硬刷新**: Ctrl+Shift+R（清除缓存）

---

### Git 工作流（黄金规则）

#### 提交前检查

**必须验证暂存内容**:
```bash
git add -A                    # 暂存所有更改
git diff --cached             # 验证暂存内容
git status                    # 确认文件列表
```

#### Commit 消息格式

**标准格式**:
```
type: description

[optional body]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>
```

**类型（type）**:
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式（不影响逻辑）
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具链相关

**示例**:
```
feat: implement BYOK mode agent creation

Added complete agent creation form with:
- Provider and model selection
- Embedding configuration
- Tool multi-selection
- System prompt editor

🤖 Generated with [Claude Code](https://claude.com/claude-code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>
```

#### 紧急恢复流程

如果代码丢失或需要回退：
```bash
# 1. 查看最近操作
git reflog show --date=format='%m-%d %H:%M:%S' | head -50

# 2. 找到目标 commit hash
git reset --hard <target-commit>

# 3. 立即提交
git commit -m "EMERGENCY: restore from reflog"

# 4. 强制推送（谨慎使用）
git push --force
```

**文档**: `docs/GIT_WORKFLOW_GOLDEN_RULES.md`

#### Git 黄金规则（CRITICAL）

✅ **DO**:
- Commit ONLY（永不使用 stash 作为备份）
- 每次提交前 `git diff --cached` 验证内容
- 完整恢复（永不分文件恢复）
- 验证 Git → Build → Server → Browser 全链路

❌ **DON'T**:
- ❌ 用 stash 备份（用 commit 代替）
- ❌ 选择性文件恢复（全恢复或全不恢复）
- ❌ 相信标签（只验证实际内容）

---

## 📁 关键文件位置

### 核心配置

| 文件路径 | 说明 |
|---------|------|
| `/root/work/klui/CLAUDE.md` | **项目主文档（必读！）** |
| `/root/work/klui/pubspec.yaml` | 依赖配置 |
| `/root/work/klui/deploy.sh` | **部署脚本（唯一构建方式）** |

### API 相关

| 文件路径 | 说明 |
|---------|------|
| `lib/core/utils/api_client.dart` | HTTP 客户端（封装 Dio） |
| `lib/core/utils/api_helper.dart` | API 辅助函数（解析、错误处理） |
| `lib/core/providers/api_providers.dart` | Riverpod providers 定义 |

### 主题系统

| 文件路径 | 说明 |
|---------|------|
| `lib/core/theme/klui_theme_extension.dart` | **主题扩展（核心）** |
| `lib/core/theme/klui_colors.dart` | 颜色定义（向后兼容） |
| `lib/core/theme/klui_text_styles.dart` | 文字样式 |
| `lib/core/theme/neo_brutalist_theme.dart` | ThemeData 配置 |

### 路由

| 文件路径 | 说明 |
|---------|------|
| `lib/core/routes/app_router.dart` | go_router 配置 |

### 数据模型

| 文件路径 | 说明 |
|---------|------|
| `lib/core/models/agent.dart` | Agent 数据模型 |
| `lib/core/models/provider.dart` | Provider 数据模型 |
| `lib/core/models/chat_message.dart` | 聊天消息模型 |

### 文档

| 文件路径 | 说明 |
|---------|------|
| `docs/LETTA_API_OVERVIEW.md` | Letta API 文档（15,987 字节） |
| `docs/LETTA_PROJECT_ANALYSIS.md` | Letta 后端分析（166,733 字节） |
| `docs/LETTA_CODE_ANALYSIS.md` | 终端 UI 参考实现 |
| `docs/HAPPY_ANALYSIS.md` | 移动/Web UI 参考实现 |
| `docs/CHAT_UI_DESIGN.md` | 聊天 UI 设计文档 |
| `docs/GIT_WORKFLOW_GOLDEN_RULES.md` | Git 工作流规则 |
| `docs/FLUTTER_WEB_PITFALLS.md` | Flutter Web 常见问题 |
| `docs/DEPLOYMENT_TEST_STEPS.md` | 部署测试步骤 |

---

## 🎯 下一步行动建议

### 立即可做（高优先级）

#### 1. 实现实时聊天功能 ⭐⭐⭐

**理由**: UI 组件已全部完成，只需集成 SSE 流

**步骤**:
1. 创建 `lib/core/providers/chat_provider.dart`
2. 实现 SSE 客户端（推荐使用 `http` 包手动解析）
3. 创建 `lib/features/chat/screens/chat_screen.dart`
4. 整合 ToolCallCard 和消息气泡
5. 添加用户输入框

**预计工作量**: 4-6 小时

**参考文档**:
- `docs/LETTA_API_OVERVIEW.md` (API 端点)
- `docs/CHAT_UI_DESIGN.md` (UI 规范)
- `/root/work/letta-code/src/cli/App.tsx` (SSE 处理参考)

#### 2. 完善 Agent 详情页 ⭐⭐

**步骤**:
1. 在 Agent 详情页添加"开始对话"按钮
2. 跳转到聊天页面（携带 agentId）
3. 实现 Agent 编辑功能（复用创建表单）

**预计工作量**: 2-3 小时

#### 3. 完善 Provider 删除功能 ⭐

**步骤**:
1. 实现删除确认对话框
2. 集成 DELETE 请求到 `/providers/{id}`
3. 更新列表状态

**预计工作量**: 1 小时

### 中期目标

#### 4. Tools 管理功能

**需要实现**:
- Tool 列表展示
- Tool 配置界面
- 启用/禁用管理
- 集成到 Agent 创建流程

**预计工作量**: 6-8 小时

#### 5. 用户体验优化

- 加载动画（骨架屏）
- 错误提示优化（用户友好的错误消息）
- 空状态页面（插图 + 引导文字）
- Toast/Snackbar 通知

**预计工作量**: 4-6 小时

### 长期目标

#### 6. 高级功能

- 导入/导出 Agent 配置（JSON/YAML）
- 批量操作（多选删除、导出）
- 搜索和过滤（实时搜索、高级筛选）
- 快捷键支持
- 主题切换（亮色/暗色模式）

**预计工作量**: 10-15 小时

---

## ⚠️ 重要提醒

### 给新 Session 的 Claude

#### 1. 优先阅读清单

**必读**（按顺序）:
1. `/root/work/klui/CLAUDE.md` - **完整阅读**
   - 重点: 第 3.1 节（三层架构）
   - 重点: 第 11.4 节（主题系统 MANDATORY）
   - 重点: 第 7 节（构建部署）

2. `/root/work/klui/docs/LETTA_API_OVERVIEW.md` - API 端点
3. `/root/work/klui/docs/GIT_WORKFLOW_GOLDEN_RULES.md` - Git 规则

**参考**:
- `docs/CHAT_UI_DESIGN.md` - 聊天 UI 设计
- `docs/LETTA_PROJECT_ANALYSIS.md` - 后端分析
- `docs/LETTA_CODE_ANALYSIS.md` - 终端 UI 参考
- `docs/HAPPY_ANALYSIS.md` - 移动 UI 参考

#### 2. 开始编码前检查

- [ ] 确认在 `/root/work/klui` 目录
- [ ] 确认使用 `./deploy.sh` 构建部署（不用手动 flutter build）
- [ ] 确认遵守主题系统规则（`Theme.of(context).extension<KluiCustomColors>()!`）
- [ ] 确认遵守三层架构（UI → Provider → ApiHelper → ApiClient）
- [ ] 确认添加 Semantics 标签
- [ ] 确认使用 i18n 字符串

#### 3. 遇到问题的解决顺序

1. **查文档**: 先看 `docs/` 目录
2. **看参考实现**:
   - Letta Code: `/root/work/letta-code/`（终端 UI）
   - Happy: `/root/work/happy/`（移动 UI）
3. **搜错误信息**: 使用 WebSearch 工具查询 Flutter/后端错误
4. **读后端代码**: `/root/work/letta/`（Letta 后端实现）
5. **更新文档**: 记录新发现到相关文档

#### 4. 永远不要做的事

- ❌ **跳过主题系统**: 使用 KluiColors 直接访问
- ❌ **违反三层架构**: UI 层直接用 api_client
- ❌ **手动构建**: 不用 deploy.sh 而直接运行 flutter build web
- ❌ **省略 Semantics**: 不添加无障碍标签
- ❌ **硬编码字符串**: 不使用 i18n
- ❌ **忽略错误处理**: 系统边界没有 try-catch
- ❌ **过度设计**: 简单功能复杂化
- ❌ **隐藏高级选项**: 这是对专业用户的工具
- ❌ **重复命令**: 同一命令失败 >2 次立即停止，问用户
- ❌ **假设路径**: 使用 pwd/ls 验证目录和文件

---

## 📊 技术栈

### 核心框架
- **Flutter**: 3.38.5
- **Dart**: 3.10.4
- **目标平台**: Web（WebAssembly 编译）

### 状态管理
- **Riverpod**: 3.0.3
- **代码生成**: `@riverpod` 注解
- **构建**: `dart run build_runner build`

### 路由
- **go_router**: 16.x
- **深度链接**: 支持
- **路由守卫**: 待实现

### 国际化
- **flutter_localizations**: 官方方案
- **intl**: 包
- **ARB 文件**: app_en.arb, app_zh.arb

### UI 组件
- **Material Design**: Flutter 内置
- **自定义主题**: Neo-Brutalist CRT 风格
- **Markdown**: flutter_markdown 包

### 网络
- **HTTP 客户端**: Dio（通过 ApiClient 封装）
- **SSE**: 待实现（推荐 http 包手动解析）

### 后端
- **Letta API**: http://38.175.200.93:8283/v1
- **认证**: Bearer Token
- **流式传输**: SSE (Server-Sent Events)

---

## 🔗 外部参考项目

### Letta 后端
- **路径**: `/root/work/letta/`
- **用途**: API 端点实现、数据结构定义
- **分析**: `docs/LETTA_PROJECT_ANALYSIS.md` (166,733 字节)

### Letta Code（终端 UI）
- **路径**: `/root/work/letta-code/`
- **用途**: 终端聊天 UI 参考实现
- **重点文件**:
  - `src/cli/App.tsx` (主应用，270KB)
  - `src/cli/components/` (UI 组件)
  - `src/tools/manager.ts` (工具执行)
- **分析**: `docs/LETTA_CODE_ANALYSIS.md`

### Happy（移动/Web UI）
- **路径**: `/root/work/happy/`
- **用途**: 跨平台 Agent UI 参考
- **重点文件**:
  - `sources/components/AgentInput.tsx` (45KB 输入组件)
  - `sources/app/` (路由和导航)
  - `sources/components/` (UI 组件)
- **分析**: `docs/HAPPY_ANALYSIS.md`

---

## 🎓 学习资源

### Flutter 官方文档
- [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)
- [Riverpod](https://riverpod.dev/)
- [go_router](https://gorouter.dev/)

### Letta 官方文档
- [Letta GitHub](https://github.com/letta-ai/letta)
- [API 文档](https://docs.letta.com/)（如果可用）

### 关键概念理解

#### ThemeExtension
- **作用**: 扩展 Flutter 主题系统
- **好处**: 支持主题切换、动画过渡
- **使用**: `Theme.of(context).extension<MyTheme>()!`

#### Riverpod
- **作用**: 状态管理和依赖注入
- **代码生成**: 使用 `@riverpod` 注解自动生成 provider
- **访问**: `ref.watch(provider)` 或 `ref.read(provider)`

#### SSE (Server-Sent Events)
- **作用**: 服务器到客户端的单向流式传输
- **格式**: `text/event-stream`
- **解析**: 逐行读取，`data:` 开头的是 JSON 数据

---

## 📝 开发日志

### 2026-01-12

**完成**:
- ✅ 主题系统迁移（所有核心组件）
- ✅ CRT 复古终端主题实现
- ✅ 聊天 UI 组件系统（4种气泡 + ToolCallCard）
- ✅ 无障碍访问标注（Semantics）
- ✅ 文档更新（CLAUDE.md + HANDOVER）

**提交**: `ef36785` - feat: implement theme system with CRT retro design and chat UI

**文件统计**: 23 files changed, +3,955 lines, -264 lines

**下一步**:
- ⏳ 实时聊天 SSE 集成
- ⏳ Agent 编辑功能
- ⏳ Provider 删除确认

---

**更新时间**: 2026-01-12
**最后更新者**: Claude Sonnet 4.5
**文档版本**: 1.0
**状态**: 主题系统迁移完成，准备实现实时聊天功能
