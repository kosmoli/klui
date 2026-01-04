# Letta Flutter 前端技术方案（2026）

> **版本**: v1.0
> **制定时间**: 2025-01-05
> **技术栈**: Flutter 3.32+ / Dart 3.6+

## 目录

- [1. 技术栈选型](#1-技术栈选型)
- [2. 依赖包清单](#2-依赖包清单)
- [3. 项目结构设计](#3-项目结构设计)
- [4. 核心功能实现](#4-核心功能实现)
- [5. 状态管理方案](#5-状态管理方案)
- [6. 路由设计](#6-路由设计)
- [7. SSE 流式响应](#7-sse-流式响应)
- [8. 性能优化](#8-性能优化)
- [9. 开发计划](#9-开发计划)

---

## 1. 技术栈选型

### 1.1 为什么选择 Flutter？

| 优势 | 说明 |
|------|------|
| **真正的跨平台** | 一套代码，支持 iOS、Android、Web、Desktop（macOS/Windows/Linux） |
| **优秀的性能** | 编译为原生 ARM/x64 代码，60fps 流畅体验 |
| **丰富的 UI** | Material 3 开箱即用，自定义组件简单 |
| **成熟的状态管理** | Riverpod 3.0 提供编译时安全 |
| **官方路由** | go_router 16.x，声明式路由，支持深度链接 |

### 1.2 版本要求

```yaml
Flutter SDK: >= 3.32 (2025年5月 Google I/O)
Dart: >= 3.6
Platform Support:
  - Web: CanvasKit（默认）/ Skwasm（实验性）
  - Mobile: iOS 12+, Android 6.0+
  - Desktop: macOS 10.15+, Windows 10+, Linux (主流发行版)
```

### 1.3 重要变更（2025）

**⚠️ HTML Renderer 已移除**

Flutter 3.29 (2025年2月) 开始，HTML renderer 正式移除：

```bash
# ❌ 不再支持
flutter build web --web-renderer html

# ✅ 现在的选项
flutter build web              # CanvasKit（默认）
flutter build web --wasm       # WebAssembly 模式
```

**影响**：
- CanvasKit 包大小较大 (~2MB)，但性能更好
- 不再支持 HTML 模式的小包优化
- 首次加载时间会稍长，但运行时性能更好

---

## 2. 依赖包清单

### 2.1 pubspec.yaml 配置

```yaml
name: letta_flutter
description: Letta Agent Management UI
version: 1.0.0

environment:
  sdk: '>=3.6.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # 🌐 HTTP & 网络
  http: ^1.2.0
  flutter_http_sse: ^1.1.0        # SSE 流式响应（Letta 必需）
  dio: ^5.4.0                     # 替代方案（功能更强）

  # 📊 状态管理 - Riverpod 3.0
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

  # 🧭 路由 - go_router 16.x
  go_router: ^16.2.0

  # 🎨 UI 组件
  flutter_adaptive_scaffold: ^0.1.10  # 响应式布局
  material_symbols_icons: ^0.1.0     # Material 3 图标

  # 🔧 工具库
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  intl: ^0.18.1

  # 💾 持久化（可选）
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  build_runner: ^2.4.8
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^3.0.0
  go_router_builder: ^16.0.0

  flutter_lints: ^3.0.0
  riverpod_lint: ^3.0.0
```

### 2.2 包说明

| 包 | 版本 | 用途 | 必需 |
|----|------|------|------|
| flutter_http_sse | ^1.1.0 | SSE 流式响应 | ✅ |
| flutter_riverpod | ^3.0.0 | 状态管理 | ✅ |
| go_router | ^16.2.0 | 路由管理 | ✅ |
| flutter_adaptive_scaffold | ^0.1.10 | 响应式布局 | ✅ |
| dio | ^5.4.0 | HTTP 客户端（备选） | ⚠️ |
| flutter_secure_storage | ^9.0.0 | 安全存储 API key | ⚠️ |

---

## 3. 项目结构设计

### 3.1 完整目录结构

```
letta_flutter/
├── lib/
│   ├── main.dart                          # 应用入口
│   │
│   ├── core/                              # 核心层
│   │   ├── network/
│   │   │   ├── api_client.dart             # HTTP 客户端封装
│   │   │   ├── sse_client.dart             # SSE 客户端
│   │   │   ├── api_endpoints.dart          # API 端点定义
│   │   │   └── interceptors.dart          # 请求拦截器
│   │   │
│   │   ├── models/                         # 数据模型
│   │   │   ├── agent.dart
│   │   │   ├── message.dart
│   │   │   ├── tool.dart
│   │   │   ├── provider.dart
│   │   │   └── memory_block.dart
│   │   │
│   │   ├── providers/                      # Riverpod Providers
│   │   │   ├── agents/
│   │   │   │   ├── agent_providers.dart
│   │   │   │   └── chat_providers.dart
│   │   │   ├── auth_providers.dart
│   │   │   └── tool_providers.dart
│   │   │
│   │   └── router/                         # go_router 配置
│   │       └── app_router.dart
│   │
│   ├── features/                           # 功能模块
│   │   ├── agents/
│   │   │   ├── list/
│   │   │   ├── detail/
│   │   │   ├── create/
│   │   │   └── chat/
│   │   ├── tools/
│   │   ├── providers/
│   │   └── memory/
│   │
│   ├── shared/                             # 共享组件
│   │   ├── widgets/
│   │   │   ├── common/
│   │   │   └── chat/
│   │   └── theme/
│   │
│   └── l10n/                               # 国际化
│
├── web/
│   ├── index.html
│   └── manifest.json
│
├── platforms/
│   ├── android/
│   ├── ios/
│   ├── macos/
│   ├── windows/
│   └── linux/
│
├── test/                                   # 测试
├── pubspec.yaml
└── README.md
```

### 3.2 分层架构

```
┌─────────────────────────────────────┐
│         Presentation Layer          │  ← Widgets, Pages
│    (features/, shared/widgets/)      │
├─────────────────────────────────────┤
│          Business Layer             │  ← Providers, Controllers
│         (core/providers/)            │
├─────────────────────────────────────┤
│           Data Layer                │  ← Models, Repository
│      (core/models/, network/)        │
├─────────────────────────────────────┤
│            API Layer                │  ← HTTP Client, SSE
│       (core/network/)                │
└─────────────────────────────────────┘
```

---

## 4. 核心功能实现

### 4.1 Agent 管理

#### Agent 列表
```dart
// features/agents/list/agents_list_page.dart
class AgentsListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Agents')),
      body: agentsAsync.when(
        data: (agents) => GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
          ),
          itemCount: agents.length,
          itemBuilder: (context, index) {
            return AgentCard(agent: agents[index]);
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorWidget(error: err),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/agents/new'),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### 创建 Agent Wizard
```dart
// features/agents/create/create_agent_wizard.dart
class CreateAgentWizard extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateAgentWizard> createState() => _CreateAgentWizardState();
}

class _CreateAgentWizardState extends ConsumerState<CreateAgentWizard> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _systemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Agent')),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _BasicInfoStep(),
          _MemoryConfigStep(),
          _ToolsConfigStep(),
          _ReviewStep(),
        ],
      ),
      bottomNavigationBar: _buildNavigation(),
    );
  }
}
```

### 4.2 聊天界面

#### 流式聊天
```dart
// features/agents/chat/chat_page.dart
class ChatPage extends ConsumerStatefulWidget {
  final String agentId;

  const ChatPage({required this.agentId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.agentId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.read(chatMessagesProvider(widget.agentId).notifier).clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: messages[index]);
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatMessagesProvider(widget.agentId).notifier).sendMessage(
      agentId: widget.agentId,
      content: content,
    );

    _textController.clear();
  }
}
```

---

## 5. 状态管理方案

### 5.1 Riverpod 3.0 Providers

#### Agent List Provider
```dart
// core/providers/agents/agent_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agent_providers.g.dart';

@riverpod
class AgentList extends _$AgentList {
  @override
  Future<List<Agent>> build() async {
    final client = ref.read(apiClientProvider);
    final response = await client.get('/v1/agents/');
    return (response.data as List)
        .map((json) => Agent.fromJson(json))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }

  Future<void> deleteAgent(String id) async {
    final client = ref.read(apiClientProvider);
    await client.delete('/v1/agents/$id');
    ref.invalidateSelf();
  }
}
```

#### Chat Messages Provider
```dart
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<Message> build() => [];

  void addMessage(Message message) {
    state = [...state, message];
  }

  void clear() {
    state = [];
  }

  Future<void> sendMessage({
    required String agentId,
    required String content,
  }) async {
    // 添加用户消息
    addMessage(Message(
      role: 'user',
      content: content,
      date: DateTime.now(),
    ));

    // 发送并流式接收 AI 响应
    final sseClient = ref.read(sseClientProvider);

    await for (final event in sseClient.sendMessageStream(
      agentId: agentId,
      content: content,
    )) {
      addMessage(event);
    }
  }
}
```

### 5.2 API Client Provider

```dart
// core/providers/auth_providers.dart

@riverpod
http.Client apiClient(ApiClientRef ref) {
  final token = ref.watch(authTokenProvider);
  return AuthenticatedClient(token);
}

@riverpod
class AuthToken extends _$AuthToken {
  @override
  String build() {
    // 从本地存储读取 token
    return prefs.getString('auth_token') ?? '';
  }

  void setToken(String token) {
    prefs.setString('auth_token', token);
    state = token;
  }
}
```

---

## 6. 路由设计

### 6.1 go_router 配置

```dart
// core/router/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/agents',
    debugLogDiagnostics: true,

    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          // Agents
          GoRoute(
            path: '/agents',
            name: 'agents',
            builder: (context, state) => AgentsListPage(),
          ),

          GoRoute(
            path: '/agents/:id',
            name: 'agent-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AgentDetailPage(agentId: id);
            },
            routes: [
              GoRoute(
                path: 'chat',
                name: 'agent-chat',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ChatPage(agentId: id);
                },
              ),
            ],
          ),

          GoRoute(
            path: '/agents/new',
            name: 'create-agent',
            builder: (context, state) => CreateAgentWizard(),
          ),

          // Tools
          GoRoute(
            path: '/tools',
            name: 'tools',
            builder: (context, state) => ToolsListPage(),
          ),

          // Providers
          GoRoute(
            path: '/providers',
            name: 'providers',
            builder: (context, state) => ProvidersPage(),
          ),

          // Memory
          GoRoute(
            path: '/memory/:agentId',
            name: 'memory',
            builder: (context, state) {
              final agentId = state.pathParameters['agentId']!;
              return MemoryBlocksPage(agentId: agentId);
            },
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});
```

### 6.2 导航使用

```dart
// 导航到 Agent 聊天
context.go('/agents/$agentId/chat');

// 返回上一页
context.pop();

// 替换当前路由
context.go('/agents', extra: {'replace': true});
```

---

## 7. SSE 流式响应

### 7.1 SSE Client 实现

```dart
// core/network/sse_client.dart

import 'package:flutter_http_sse/flutter_http_sse.dart';

class SSEClient {
  final String baseUrl;
  final String token;

  SSEClient({required this.baseUrl, required this.token});

  Stream<Message> sendMessageStream({
    required String agentId,
    required String content,
  }) async* {
    final url = Uri.parse('$baseUrl/v1/agents/$agentId/messages/stream');

    final sseClient = SSClient.connect(
      url,
      method: 'POST',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'messages': [{'role': 'user', 'content': content}],
      }),
    );

    await for (final event in sseClient.events) {
      if (event.type == 'message') {
        final data = jsonDecode(event.data);
        final message = Message.fromJson(data);
        yield message;
      }
    }
  }
}
```

### 7.2 流式文本组件

```dart
// shared/widgets/chat/streaming_text.dart

class StreamingText extends StatefulWidget {
  final Stream<String> textStream;

  const StreamingText({required this.textStream});

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText> {
  String _fullText = '';

  @override
  void initState() {
    super.initState();
    widget.textStream.listen((chunk) {
      setState(() {
        _fullText += chunk;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText(_fullText);
  }
}
```

---

## 8. 性能优化

### 8.1 Web 性能优化

基于 [Flutter 官方优化指南](https://blog.flutter.dev/best-practices-for-optimizing-flutter-web-loading-speed-7cc0df14ce5c)：

#### 代码分割
```dart
// 使用 deferred loading 延迟加载路由
import 'package:features/agents/agents_list_page.dart' deferred as agents;

// 路由配置中
builder: (context, state) async {
  await agents.library;
  return agents.AgentsListPage();
}
```

#### 图片优化
```dart
// 使用 CachedNetworkImage
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

#### 构建优化
```bash
# WebAssembly 模式
flutter build web --release --wasm

# 启用压缩
flutter build web --release --wasm --csp
```

### 8.2 App 性能优化

#### 列表优化
```dart
// 使用 ListView.builder
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
  // 添加 cacheExtent
  cacheExtent: 500,
)
```

#### Const 使用
```dart
// 尽可能使用 const
const Text('Hello');
const SizedBox(height: 16);
```

---

## 9. 开发计划

### Phase 1: 基础架构（2 周）

**目标**: 搭建项目框架

- [ ] Flutter 项目初始化（3.32+）
- [ ] Riverpod 3.0 + go_router 16.x 配置
- [ ] API 客户端封装
- [ ] SSE 客户端实现
- [ ] 响应式布局框架
- [ ] 主题配置

**交付物**: 可运行的基础框架

### Phase 2: Agents 功能（3 周）

**目标**: Agent 完整管理

- [ ] Agent 列表页面
- [ ] Agent 详情页面
- [ ] 创建 Agent Wizard（多步骤表单）
- [ ] Agent 编辑功能
- [ ] Agent 删除功能
- [ ] Agent 搜索和筛选

**交付物**: 完整的 Agent 管理功能

### Phase 3: 聊天功能（2 周）

**目标**: 实时聊天界面

- [ ] 聊天页面布局
- [ ] SSE 流式响应集成
- [ ] 消息气泡组件
- [ ] 输入框和发送功能
- [ ] 消息历史显示
- [ ] 工具调用可视化

**交付物**: 可用的聊天功能

### Phase 4: 其他功能（4 周）

- [ ] Tools 管理页面
- [ ] Providers 管理页面
- [ ] Memory 管理页面
- [ ] 全局搜索功能
- [ ] 设置页面

**交付物**: 完整的管理界面

### Phase 5: 优化和发布（2 周）

- [ ] 性能优化
- [ ] 平台适配测试
- [ ] 错误处理完善
- [ ] 文档编写
- [ ] 部署上线

**交付物**: 生产级应用

---

## 10. 参考资源

### 官方文档

- [Flutter 官方文档](https://docs.flutter.dev)
- [Flutter Web 渲染器](https://docs.flutter.dev/platform-integration/web/renderers)
- [Riverpod 官方文档](https://riverpod.dev)
- [go_router 文档](https://pub.dev/packages/go_router)

### 社区资源

- [flutter_http_sse GitHub](https://github.com/ElshiatyTube/flutter_http_sse)
- [Flutter 性能优化指南](https://blog.flutter.dev/best-practices-for-optimizing-flutter-web-loading-speed-7cc0df14ce5c)

---

**文档版本**: v1.0
**最后更新**: 2025-01-05
**作者**: Claude Code (Sonnet 4.5)
