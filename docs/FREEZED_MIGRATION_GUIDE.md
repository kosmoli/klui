# Freezed 3.0.0 验证与迁移指南

**Date**: 2026-01-11
**Purpose**: 验证 Freezed 3.0.0 是否可用，并提供从手写模型迁移到 Freezed 的指南

---

## ✅ Freezed 3.0.0 验证结果

### 验证成功！（2026-01-11 16:27）

```bash
# 验证命令
export PATH="/opt/flutter/bin:$PATH"
cd /root/work/klui
dart run build_runner build --delete-conflicting-outputs
```

**结果**：
- ✅ 成功生成 `test_freezed.freezed.dart` (9.1KB)
- ✅ 成功生成 `test_freezed.g.dart` (725B)
- ✅ 编译时间：28秒
- ✅ 无错误（仅有版本约束警告）

**生成的代码示例**：
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

mixin _$TestUser {
  String get id;
  String get name;
  int get age;
  String? get email;
  bool get isActive;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestUserCopyWith<TestUser> get copyWith;

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other);
  // ... 更多生成的代码
}
```

### 依赖版本（已配置）

```yaml
# pubspec.yaml
dependencies:
  freezed_annotation: ^3.0.0
  riverpod_annotation: ^3.0.0

dev_dependencies:
  build_runner: ^2.4.11
  freezed: ^3.2.3
  riverpod_generator: ^3.0.0
  json_serializable: ^6.7.1
```

**结论**: ✅ **Freezed 3.0.0 可以正常使用！**

---

## 🔑 Freezed 3.0.0 关键变更

### 1. **必须使用 `abstract` 类**

```dart
// ❌ 错误（Freezed 2.x 语法）
@freezed
class User with _$User {
  const factory User({
    required String name,
  }) = _User;
}

// ✅ 正确（Freezed 3.0+ 语法）
@freezed
abstract class User with _$User {
  const factory User({
    required String name,
  }) = _User;
}
```

### 2. **为什么之前编译失败？**

Freezed 3.0.0 于 **2025年2月** 发布，引入了**破坏性变更**：
- 所有带 `@freezed` 注解的类必须是 `abstract`
- 这是为了解决 Dart 类型系统的某些限制
- 参考：[Stack Overflow - Missing methods to override](https://stackoverflow.com/questions/79651439/missing-methods-to-override-in-freezed-flutter)

---

## 📋 当前项目状态

### 现有模型（手写）

项目中所有模型都是手写的，包括：
- ✅ `lib/core/models/agent.dart` (149行)
- ✅ `lib/core/models/provider.dart`
- ✅ `lib/core/models/llm_model.dart`
- ✅ `lib/core/models/embedding_model.dart`
- ✅ `lib/core/models/create_agent_request.dart`
- ✅ `lib/core/models/create_provider_request.dart`

### 为什么之前不用 Freezed？

根据注释 `/// Simple Agent model (without Freezed due to Web compilation issues)`：

**可能的原因**：
1. 使用了旧版 Freezed 语法（没有 `abstract`）
2. 编译器报错找不到 `$User` 类
3. 被迫手写所有样板代码

**现在已解决**：Freezed 3.0.0 + `abstract` 关键字可以正常工作！

---

## 🚀 迁移示例

### 示例 1: Agent 模型

**之前（手写，149行）**:
```dart
class Agent {
  final String id;
  final String name;
  final String? description;
  // ... 15+ 个字段

  const Agent({
    required this.id,
    required this.name,
    this.description,
    // ... 重复所有字段
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as String,
      name: json['name'] as String,
      // ... 重复所有解析逻辑
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // ... 重复所有序列化逻辑
    };
  }

  Agent copyWith({
    String? id,
    String? name,
    // ... 重复所有参数
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      // ... 重复所有逻辑
    );
  }

  @override
  String toString() { ... }

  @override
  bool operator ==(Object other) { ... }

  @override
  int get hashCode => ...;
}
```

**之后（Freezed，~30行）**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent.freezed.dart';
part 'agent.g.dart';

@freezed
abstract class Agent with _$Agent {
  const factory Agent({
    required String id,
    required String name,
    String? description,
    String? model,
    String? embedding,
    String? agentType,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, dynamic>? config,
    Map<String, dynamic>? llmConfig,
    Map<String, dynamic>? embeddingConfig,
    Map<String, dynamic>? modelSettings,
    @JsonKey(fromJson: _toolsFromJson) List<String>? tools,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'system') String? systemPrompt,
  }) = _Agent;

  factory Agent.fromJson(Map<String, dynamic> json) =>
      _$AgentFromJson(json);

  // 自定义 tools 解析逻辑
  static List<String>? _toolsFromJson(dynamic tools) {
    if (tools == null) return null;
    if (tools is List) {
      return tools.map((e) {
        if (e is String) return e;
        if (e is Map) return (e as Map)['name']?.toString() ?? e.toString();
        return e.toString();
      }).toList();
    }
    return null;
  }
}
```

**代码减少**: 149行 → 30行（减少 80%）

---

## 🛠️ 迁移步骤

### 步骤 1: 安装依赖

```bash
flutter pub get
```

### 步骤 2: 创建 Freezed 模型

1. 在模型文件顶部添加：
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filename.freezed.dart';
part 'filename.g.dart';
```

2. 将类改为 `abstract class`，添加 `@freezed` 注解

### 步骤 3: 运行代码生成

```bash
# 一次性生成
dart run build_runner build --delete-conflicting-outputs

# 或监听模式（开发时推荐）
dart run build_runner watch --delete-conflicting-outputs
```

### 步骤 4: 验证生成的代码

生成的文件：
- `*.freezed.dart` - Freezed 生成的不可变类
- `*.g.dart` - JSON 序列化代码

### 步骤 5: 清理旧代码

删除手写的：
- `fromJson` 方法（保留工厂构造函数）
- `toJson` 方法
- `copyWith` 方法
- `toString` 方法
- `operator ==` 和 `hashCode`

---

## 📊 Freezed vs 手写对比

| 特性 | 手写 | Freezed |
|------|---------------------|------------------------|
| 代码量 | ~150 行 | ~30 行 |
| 维护性 | ❌ 新字段需修改 4+ 处 | ✅ 只需添加字段 |
| 类型安全 | ⚠️ 手动实现 | ✅ 自动生成 |
| copyWith | ✅ 手动实现 | ✅ 自动生成 |
| JSON 序列化 | ❌ 手动实现 | ✅ 自动生成 |
| == 和 hashCode | ❌ 手动实现 | ✅ 自动生成 |
| 联合类型 (Union types) | ❌ 不支持 | ✅ 支持 |
| 模式匹配 | ❌ 不支持 | ✅ 支持 `when` / `maybeWhen` |

---

## 🎯 推荐策略

### 选项 A: 逐步迁移（推荐）

**优先级**：
1. ✅ **新模型**：直接使用 Freezed
2. 🔄 **经常修改的模型**：迁移到 Freezed（减少维护成本）
3. ⏸️ **稳定模型**：保持手写（不着急）

**好处**：
- 风险低，逐个模型验证
- 新功能立即享受 Freezed 好处
- 不影响现有代码

### 选项 B: 全部迁移

一次性迁移所有模型：

```bash
# 1. 批量替换所有模型
# 2. 运行 build_runner
dart run build_runner build --delete-conflicting-outputs

# 3. 运行测试验证
flutter test
```

**风险**：
- 需要大量测试验证
- 可能引入 bug
- 建议先在分支上测试

---

## 🧪 验证测试

我已经创建了测试文件：`lib/core/models/test_freezed.dart`

**内容**：
```dart
@freezed
abstract class TestUser with _$TestUser {
  const factory TestUser({
    required String id,
    required String name,
    required int age,
    String? email,
    @Default(false) bool isActive,
  }) = _TestUser;

  factory TestUser.fromJson(Map<String, dynamic> json) =>
      _$TestUserFromJson(json);
}
```

**如何验证**：
```bash
# 在有 Flutter/Dart SDK 的环境中运行
cd /root/work/klui
dart run build_runner build --delete-conflicting-outputs
```

**预期结果**：
- ✅ 生成 `test_freezed.freezed.dart`
- ✅ 生成 `test_freezed.g.dart`
- ✅ 无编译错误

---

## 💡 常见问题

### Q1: 为什么 Freezed 需要两个 part 文件？

**A**:
- `*.freezed.dart` - Freezed 框架生成的代码（不可变类、copyWith、union types）
- `*.g.dart` - json_serializable 生成的代码（JSON 序列化）

### Q2: `@JsonKey` 如何使用？

**A**:
```dart
@freezed
abstract class Agent with _$Agent {
  const factory Agent({
    @JsonKey(name: 'agent_type') String? agentType,  // 字段重命名
    @JsonKey(fromJson: _dateFromJson) DateTime? createdAt,  // 自定义解析
    @Default([]) List<String> tags,  // 默认值
    @JsonKey(includeIfNull: false) String? description,  // null 不序列化
  }) = _Agent;
}
```

### Q3: 如何处理复杂的 fromJson 逻辑？

**A**: 使用静态方法
```dart
static List<String>? _toolsFromJson(dynamic tools) {
  if (tools == null) return null;
  if (tools is List) {
    return tools.map((e) => e.toString()).toList();
  }
  return null;
}
```

### Q4: Freezed 与 Riverpod 兼容吗？

**A**: ✅ 完美兼容！
```dart
@riverpod
class AgentNotifier extends _$AgentNotifier {
  @override
  Future<Agent> build(String agentId) async {
    final client = ref.watch(apiClientProvider);
    final response = await client.get('/agents/$agentId');
    return ApiHelper.parseSingle(response, Agent.fromJson);
  }
}
```

---

## 📚 参考资料

- [Freezed 官方文档](https://pub.dev/packages/freezed)
- [Freezed Changelog - 3.0.0 Release](https://pub.dev/packages/freezed/changelog#300)
- [Stack Overflow - Freezed 3.0 abstract class requirement](https://stackoverflow.com/questions/79651439/missing-methods-to-override-in-freezed-flutter)
- [Dart Macros Discontinued & Freezed 3.0 Released](https://alperenderici.medium.com/dart-macros-discontinued-freezed-3-0-released-why-it-happened-whats-new-and-alternatives-385fc0c571a4)

---

## ✅ 结论

**Freezed 3.0.0 现在可以正常使用！**

**关键点**：
1. ✅ 使用 `abstract class` 而不是 `class`
2. ✅ 依赖版本已正确配置
3. ✅ 可以减少 80% 的样板代码
4. ✅ 提供类型安全、copyWith、JSON 序列化等功能

**下一步**：
1. 在有 Flutter SDK 的环境中运行 `dart run build_runner build`
2. 验证 `test_freezed.dart` 是否正常生成代码
3. 逐步迁移现有模型到 Freezed（推荐优先迁移经常修改的模型）

**是否需要我帮你批量迁移现有模型？**
