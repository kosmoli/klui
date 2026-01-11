# Klui - Letta Agent Management UI

> **项目名称**: Klui (Letta UI)
> **技术栈**: Flutter 3.38.5 / Dart 3.10.4
> **创建时间**: 2026-01-05
> **版本**: v1.0.0-alpha
> **当前阶段**: Phase 1 - 基础架构完成 ✅

## 项目概述

基于 Flutter 开发的**移动优先** Letta Agent 管理界面，专注于在移动端（iOS/Android）实现远程软件开发功能。

**核心特性**：
- 📱 **移动优先设计** - 针对触摸交互优化
- 💬 **实时聊天** - SSE 流式响应，支持工具调用批准
- 🔧 **远程开发** - 通过 Letta 后端执行代码和文件操作
- 🧠 **记忆管理** - 查看 Agent 的记忆块
- 🤖 **Agent 管理** - 创建、配置、监控 AI Agent

**技术栈**：

| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter SDK | 3.38.5 | UI 框架 |
| Dart | 3.10.4 | 编程语言 |
| Riverpod | 3.0.3 | 状态管理 |
| go_router | 16.3.0 | 路由管理 |
| http | 1.6.0 | HTTP 客户端 |
| Letta Backend | - | AI Agent 后端 |

## 当前进度

### ✅ 已完成 (Phase 0)

- [x] 项目初始化和架构搭建
- [x] Riverpod 状态管理 + go_router 路由
- [x] API 封装（ApiClient, ApiHelper）
- [x] 数据模型（Agent, Provider, LLMModel, EmbeddingModel）
- [x] Agent CRUD 功能（列表、详情、创建、删除）
- [x] Provider CRUD 功能（列表、详情、创建）
- [x] LLMModel 列表和过滤
- [x] 三层架构（UI → Provider → API）

### 🚧 进行中 (Phase 1)

- [ ] 聊天功能（SSE 流式响应）
- [ ] 消息模型和 UI
- [ ] 工具批准系统

### ⏸️ 计划中 (Phase 2+)

- [ ] 远程开发能力（代码执行、文件操作）
- [ ] 记忆管理 UI
- [ ] 桌面端适配

**详见**: [docs/IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md)

## 📚 文档索引

### 核心文档
- **[实施路线图](docs/IMPLEMENTATION_ROADMAP.md)** 📋 - 总体规划和进度跟踪
- **[CLAUDE.md](CLAUDE.md)** 📖 - 开发指南和架构规则（必读！）

### 功能规划
- **[聊天功能规划](docs/CHAT_FEATURE_PLAN.md)** 💬 - 13 种消息类型、SSE 流式响应、工具批准
- **[API 层优化](docs/API_LAYER_OPTIMIZATION.md)** 🔧 - API 封装、错误处理、SDK 分离标准

### 参考分析
- **[Letta Code 功能分析](docs/LETTA_CODE_FEATURES.md)** 📊 - Letta Code 的 7 大核心能力
- **[Letta 后端分析](docs/LETTA_BACKEND_ANALYSIS.md)** 🖥️ - 后端工具执行能力
- **[远程开发方案对比](docs/REMOTE_DEV_COMPARISON.md)** 🎯 - Happy 模式 vs Letta 后端
- **[Freezed 迁移指南](docs/FREEZED_MIGRATION_GUIDE.md)** 🔧 - Freezed 3.0.0 使用和迁移

### 相关项目
- **Letta Backend**: `../letta/` - AI Agent 后端服务器
- **Letta Code**: `../letta-code/` - CLI 参考实现
- **Happy**: `../happy/` - 移动端参考实现

## 项目结构

```
klui/
├── docs/                          # 项目文档
│   ├── LETTA_PROJECT_ANALYSIS.md  # 后端深度分析（17章节）
│   ├── FLUTTER_PLAN_2026.md       # Flutter 技术方案
│   └── LETTA_API_OVERVIEW.md      # API 完整参考
├── lib/                           # Flutter 源代码
│   ├── core/                      # 核心层
│   │   ├── config/                # 配置
│   │   ├── models/                # 数据模型
│   │   ├── providers/             # Riverpod Providers
│   │   ├── routes/                # 路由配置
│   │   └── utils/                 # 工具类
│   ├── features/                  # 功能模块
│   │   ├── agents/                # Agent 管理
│   │   └── chat/                  # 聊天功能
│   └── main.dart                 # 应用入口
├── test/                          # 测试代码
└── README.md                      # 本文件
```

## 快速开始

### 前置要求

- Flutter SDK >= 3.38.5
- Dart >= 3.10.4
- Letta Server 运行在 http://localhost:8283

### 开发模式

```bash
# Web 开发
flutter run -d chrome

# 移动端开发
flutter run

# 桌面端开发
flutter run -d macos  # macOS
flutter run -d windows  # Windows
flutter run -d linux  # Linux
```

### 生产构建

```bash
# Web 构建（✅ 已测试成功）
flutter build web --release

# 移动端构建
flutter build apk --release
flutter build ipa --release

# 桌面端构建
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

## 开发进度

### ✅ Phase 1: 基础架构（完成 2026-01-07）

- [x] Flutter 项目初始化
- [x] 目录结构创建（分层架构）
- [x] 依赖配置（Riverpod、go_router、http）
- [x] API Client 实现（HTTP + 认证）
- [x] 数据模型（Agent、Message、ToolCall）
- [x] Riverpod Providers 配置
- [x] go_router 路由配置
- [x] Agent 列表页 UI
- [x] Web 构建成功

### ✅ Phase 2: Agents 功能（完成 2026-01-09）🎉

- [x] Agent 详情页
  - [x] 基本信息（ID、名称、描述、类型）
  - [x] 模型配置显示（Base/BYOK 模式区分）
  - [x] Embedding 配置显示
  - [x] 时间戳信息
  - [x] 系统提示词显示
  - [x] 删除功能
- [x] Agent 创建向导
  - [x] BYOK 模式创建（Provider 选择）
  - [x] Base 模式创建（直接使用 Base 模型）
  - [x] 三步向导流程
  - [x] 表单验证
  - [x] 错误处理
- [x] Agent 列表增强
  - [x] 模型信息显示（handle 格式）
  - [x] Base/BYOK 模式统一显示
  - [x] 卡片式 Neo-Brutalist 设计
- [x] 连接 Letta API
  - [x] 创建 Agent API
  - [x] 删除 Agent API
  - [x] 获取 Agent 详情 API
  - [x] 获取模型列表 API（Base + BYOK）
  - [x] 获取 Provider 列表 API

### ⏳ Phase 3: 聊天功能（计划中）

- [ ] 聊天界面 UI
- [ ] SSE 流式响应
- [ ] 消息历史
- [ ] 实时更新

### ⏳ Phase 4: 其他功能（计划中）

- [ ] 记忆管理
- [ ] 工具管理
- [ ] Provider 管理
- [ ] 数据可视化

### ⏳ Phase 5: 优化和发布（计划中）

- [ ] 性能优化
- [ ] 响应式布局完善
- [ ] 测试覆盖
- [ ] 文档完善
- [ ] 生产发布

## 技术亮点

- ✅ **Material 3 设计**：现代化 UI 设计语言
- ✅ **类型安全**：Dart 3.10 强类型系统
- ✅ **状态管理**：Riverpod 3.0 响应式状态管理
- ✅ **路由管理**：go_router 声明式路由
- ✅ **HTTP 认证**：Bearer Token 自动注入
- ✅ **错误处理**：统一错误处理机制
- ✅ **响应式布局**：跨平台自适应 UI

## 已知问题

### ⚠️ Freezed Web 编译兼容性

**问题**：Freezed 3.2.3 与 Flutter 3.38.5 的 Web 编译器（dart2js）存在兼容性问题

**解决方案**：目前使用手写的简单模型类替代 Freezed

**参考**：
- [Dart2Js.dart crash Issue #60801](https://github.com/dart-lang/sdk/issues/60801)
- [Freezed compilation issues](https://stackoverflow.com/questions/60691939/flutter-compilation-issues-with-the-packages-freezed-and-json-serializable)

## 详细架构

### Demo 架构 - Agent 列表模块 (2026-01-07)

#### 功能描述

实现了第一个可工作的 Demo：从 Letta API 获取并显示 Agent 列表。

**核心功能**：
- 从 Letta API (`/v1/agents/`) 获取 Agent 列表
- 显示 Agent 名称、描述、创建时间
- 支持下拉刷新
- 处理加载状态和错误状态

**解决的问题**：
- ✅ 跨域 CORS 问题（浏览器访问 API）
- ✅ API 路径配置（`/v1/` vs `/api/v1/`）
- ✅ 远程部署时的 IP 地址配置
- ✅ JSON 数据解析和模型转换

#### 架构设计

**技术栈**：
- **状态管理**: Riverpod 3.0.3 (代码生成 `@riverpod`)
- **HTTP 客户端**: http 1.6.0 + 自定义重试逻辑
- **路由**: go_router 16.3.0
- **数据模型**: 手写简单类（避免 Freezed Web 编译问题）

**数据流向**：

```
UI (AgentListScreen)
    ↓ watch
Provider (agentListProvider)
    ↓ get
ApiClient (HTTP + Retry)
    ↓ fetch
Letta API (http://IP:8283/v1/agents/)
    ↓ JSON response
Agent.fromJson() 解析
    ↓ List<Agent>
UI 显示列表
```

**组件交互**：

```dart
// 1. UI 监听状态
class AgentListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentListProvider);
    // 根据 loading/data/error 状态渲染 UI
  }
}

// 2. Provider 提供数据
@riverpod
Future<List<Agent>> agentList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/');
  // JSON 解析并返回 List<Agent>
}

// 3. API Client 处理 HTTP
class ApiClient {
  Future<Response> get(String path) async {
    final url = Uri.parse('${AppConfig.fullApiBaseUrl}$path');
    return _client.get(url).timeout(timeout);
  }
}
```

#### 实现原理

**1. 环境配置 (`app_config.dart`)**

```dart
class AppConfig {
  // 使用编译时常量，支持构建时传入
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8283',
  );

  static const String apiVersion = 'v1';
  static String get fullApiBaseUrl => '$apiBaseUrl/$apiVersion';
}
```

**关键设计决策**：
- ✅ 使用 `String.fromEnvironment` 而不是硬编码 IP
- ✅ 支持构建时通过 `--dart-define=API_BASE_URL=...` 传入
- ✅ 默认值 `localhost:8283` 用于本地开发
- ✅ 生产构建时传入实际 IP，代码无需修改

**为什么这样设计**：
- 避免在源代码中硬编码 IP 地址
- 同一套代码可以用于不同环境（dev/staging/prod）
- 符合 12-factor app 的配置原则

**2. 数据模型 (`agent.dart`)**

```dart
class Agent {
  final String id;
  final String name;
  final String? description;
  // ... 其他字段

  const Agent({...});

  // JSON 反序列化
  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      // ... 字段映射
    );
  }

  // JSON 序列化
  Map<String, dynamic> toJson() {...}

  // copyWith 方法
  Agent copyWith({...}) {...}

  // 相等性比较
  @override
  bool operator ==(Object other) {...}
}
```

**关键设计决策**：
- ✅ 手写简单类而不是使用 Freezed
- ✅ 实现了 `fromJson`/`toJson` 用于序列化
- ✅ 实现了 `copyWith` 用于不可变更新
- ✅ 实现了 `==` 和 `hashCode` 用于集合操作

**为什么不用 Freezed**：
- ❌ Freezed 3.2.3 与 Flutter Web 编译器存在兼容性问题
- ❌ 生成的 mixin 在 dart2js 中无法识别
- ✅ 手写类虽然代码多一点，但更可靠
- ✅ 性能更好（无需代码生成）

**3. API Provider (`api_providers.dart`)**

```dart
@riverpod
Future<List<Agent>> agentList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/');

  if (response.statusCode == 200) {
    // 解析 JSON
    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : [];

    // 转换为 Agent 对象列表
    return jsonData
        .map((json) => Agent.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load agents: ${response.statusCode}');
  }
}
```

**关键设计决策**：
- ✅ 使用 `@riverpod` 注解自动生成 provider 代码
- ✅ 返回 `Future<List<Agent>>` 支持异步加载
- ✅ 错误处理：抛出 Exception 让 UI 层处理
- ✅ 空列表处理：如果 API 返回非 List，返回空数组而不是崩溃

**4. HTTP 客户端 (`api_client.dart`)**

```dart
class ApiClient {
  late final http.Client _client;

  ApiClient({String? authToken}) {
    _client = RetryClient(
      AuthInterceptor(
        client: http.Client(),
        authToken: authToken,
      ),
      retries: 3,
      when: (response) {
        // 仅在 5xx 错误时重试
        return response.statusCode == null ||
            response.statusCode! >= 500 ||
            response.statusCode == 408;
      },
      delay: (attempt) {
        // 指数退避：1s, 2s, 4s
        return Duration(milliseconds: 1000 * (1 << attempt));
      },
    );
  }

  Future<http.Response> get(String path) async {
    final url = Uri.parse('${AppConfig.fullApiBaseUrl}$path');
    return _client.get(url).timeout(AppConfig.requestTimeout);
  }
}
```

**关键设计决策**：
- ✅ 包装 `http.Client` 添加重试逻辑
- ✅ 包装认证拦截器（预留 Bearer Token 支持）
- ✅ 指数退避算法避免服务器压力
- ✅ 仅在服务器错误（5xx）时重试，客户端错误（4xx）不重试
- ✅ 超时保护（默认 30 秒）

**5. UI 实现 (`agent_list_screen.dart`)**

```dart
class AgentListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Letta Agents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(agentListProvider),
          ),
        ],
      ),
      body: agentsAsync.when(
        data: (agents) {
          if (agents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No agents found'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              return AgentCard(agent: agent);
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
```

**关键设计决策**：
- ✅ 使用 `ConsumerWidget` 而不是 `StatefulWidget`
- ✅ 使用 `.when()` 处理 AsyncValue 的三种状态
- ✅ 空状态显示友好的提示信息
- ✅ 错误状态显示错误消息（生产环境应更友好）
- ✅ 刷新按钮通过 `ref.invalidate()` 触发重新加载

#### 配置说明

**Letta 后端配置** (`.env`):

```bash
# OpenAI API 配置
OPENAI_API_KEY=sk-your-api-key
OPENAI_API_BASE=https://your-api.com/v1

# CORS 配置 - 关键！
ACCEPTABLE_ORIGINS=http://localhost:8080,http://YOUR_IP:8080
```

**Letta 容器配置** (`compose.yaml`):

```yaml
environment:
  - ACCEPTABLE_ORIGINS=${ACCEPTABLE_ORIGINS:-http://localhost:8080}
```

**前端构建**:

```bash
# 本地开发
flutter run -d chrome

# 生产构建（使用实际 IP）
flutter build web --release --dart-define=API_BASE_URL=http://YOUR_IP:8283
```

**部署**:

```bash
# 启动 HTTP 服务器
cd build/web
python3 -m http.server 8080
```

#### 部署注意事项

⚠️ **CORS 配置**：
- 必须在 Letta 的 `.env` 中配置 `ACCEPTABLE_ORIGINS`
- 必须在 `compose.yaml` 中声明环境变量
- 前端地址必须加入允许列表（如 `http://YOUR_IP:8080`）
- 修改后需重启容器：`docker compose restart`

⚠️ **IP 地址 vs localhost**：
- 本地开发：可以使用 `localhost:8283`
- 远程部署：**必须使用实际 IP**（浏览器无法访问服务器的 localhost）
- 构建时通过 `--dart-define` 传入 IP，不要硬编码

⚠️ **API 路径**：
- ✅ 正确：`/v1/agents/`
- ❌ 错误：`/api/v1/agents/`

⚠️ **Provider 格式**：
- ✅ 正确：`openai-proxy/model-name`
- ❌ 错误：`model-name`（缺少 provider 前缀）

#### 示例代码

**获取 Agent 列表**:

```dart
// 在任何 Widget 中使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentListProvider);

    return agentsAsync.when(
      data: (agents) => ListView.builder(
        itemCount: agents.length,
        itemBuilder: (context, index) => Text(agents[index].name),
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
```

**刷新列表**:

```dart
ElevatedButton(
  onPressed: () => ref.invalidate(agentListProvider),
  child: Text('Refresh'),
)
```

**导航到详情页**:

```dart
onTap: () {
  context.go('/agents/${agent.id}');
}
```

#### 性能优化

- ✅ 使用 `const` 构造函数减少重建
- ✅ 使用 `ListView.builder` 懒加载
- ✅ Riverpod 自动缓存和去重请求
- ✅ HTTP 客户端重试机制避免失败

#### 下一步优化

- [ ] 添加分页支持（API 支持 limit/offset）
- [ ] 添加搜索和过滤功能
- [ ] 添加下拉刷新手势
- [ ] 优化错误提示（用户友好化）
- [ ] 添加骨架屏（Skeleton Screen）
- [ ] 实现缓存策略（离线支持）

---

### 🎉 里程碑 2: Agent CRUD 完成（2026-01-09）

#### 功能概述

实现了完整的 Agent 管理功能，包括创建、读取、更新、删除（CRUD）操作。

**核心功能**：
- ✅ Agent 列表展示（支持 Base/BYOK 模式）
- ✅ Agent 详情页面（完整的配置信息）
- ✅ Agent 创建向导（三步流程，支持 BYOK/Base 模式）
- ✅ Agent 删除功能（带确认对话框）

**解决的关键问题**：
1. ✅ Base vs BYOK 模式判断和显示
2. ✅ 模型 handle 格式统一显示
3. ✅ 详情页面字体样式统一
4. ✅ Provider 和模型列表的动态加载
5. ✅ 一键构建和部署自动化

#### 关键技术点

**1. Agent 模式判断**
```dart
// ✅ 正确判断：检查 model 字段
bool get isBaseMode => agent.model != null;
bool get isBYOKMode => agent.model == null;

// ❌ 错误判断：不要用 provider_category
```

**2. 模型显示统一**
```dart
String _getModelLabel(Agent agent) {
  if (agent.model != null) {
    return agent.model!;  // Base 模式
  } else {
    // BYOK 模式：构造 handle
    return '${provider}/${model}';
  }
}
```

**3. 详情页面布局**
- 水平布局（Label 固定宽度，Value 自适应）
- 统一字体样式（技术值用 monoSmall，文本值用 bodyMedium）
- 清晰的视觉层次（Label 灰色 w600，Value 黑色 w500）

**4. 一键部署**
```bash
./deploy.sh  # 自动构建、停止旧服务、启动新服务
```

#### 文档更新

- ✅ 新增章节 20：Agent 显示和模式判断的关键发现
- ✅ 记录 Base/BYOK 模式的 API 返回格式差异
- ✅ 提供前端实现建议和代码示例
- ✅ 更新 README 开发进度

---

## 相关链接

- [Letta 官方文档](https://docs.letta.com)
- [Letta GitHub](https://github.com/letta-ai/letta)
- [Flutter 官方文档](https://docs.flutter.dev)
- [Riverpod 文档](https://riverpod.dev)
- [go_router 文档](https://gorouter.dev)

---

**开发者**: Kosmo & Claude Code (Sonnet 4.5)
**最后更新**: 2026-01-09
**项目地址**: https://github.com/kosmoli/klui
**当前版本**: v1.1.0-milestone2
