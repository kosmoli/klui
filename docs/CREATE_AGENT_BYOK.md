# Create Agent - BYOK vs Non-BYOK Mode

> **创建时间**: 2026-01-09
> **作者**: Kosmo & Claude
> **目的**: 根据模式自动选择正确的 API 请求格式

---

## 概述

Letta API 支持两种创建 Agent 的方式：

1. **非 BYOK 模式**（简写形式） - 使用 base providers
2. **BYOK 模式**（完整配置） - 使用用户自定义 providers

我们的 `CreateAgentRequest` 模型会**自动检测模式**并生成正确的请求格式。

---

## 两种模式的区别

### 非 BYOK 模式（base providers）

**特点**：
- Provider Category: `base`
- 从环境变量创建
- 简洁的 API 请求

**请求格式**：
```json
{
  "name": "my-agent",
  "model": "openai/gpt-4o",
  "embedding": "openai/text-embedding-3-small"
}
```

### BYOK 模式（user-created providers）

**特点**：
- Provider Category: `byok`
- 用户通过 API 创建
- 完整的配置控制

**请求格式**：
```json
{
  "name": "my-agent",
  "llm_config": {
    "config": {
      "model": "gpt-4o",
      "provider": "openai",
      "model_endpoint_type": "openai"
    }
  },
  "embedding_config": {
    "config": {
      "model": "text-embedding-3-small",
      "provider": "openai",
      "model_endpoint_type": "openai"
    }
  }
}
```

---

## 使用方法

### 1. 创建请求

```dart
import 'package:klui/core/models/create_agent_request.dart';

final request = CreateAgentRequest(
  name: 'my-agent',
  description: 'A helpful assistant',
  llmModel: selectedLLMModel,
  embeddingModel: selectedEmbeddingModel,
  systemPrompt: 'You are a helpful assistant.',
);

// 检查模式
print(request.isBYOK); // true or false
```

### 2. 转换为 JSON

```dart
// 自动根据模式选择正确的格式
final json = request.toJson();
```

### 3. 创建 Agent

```dart
// 使用 Riverpod Provider
final agent = await ref.read(createAgentProvider(request).future);
```

---

## 模式检测逻辑

`CreateAgentRequest` 通过检查 `llmModel.providerCategory` 来判断模式：

```dart
bool get isBYOK => llmModel.providerCategory == 'byok';
```

- `providerCategory == 'base'` → 非 BYOK 模式
- `providerCategory == 'byok'` → BYOK 模式

---

## 实际示例

### 示例 1: 非 BYOK 模式

```dart
// 从 base providers 选择模型
final baseLLMModel = LLMModel(
  // ... 其他字段
  providerCategory: 'base', // ← 关键字段
);

final request = CreateAgentRequest(
  name: 'my-agent',
  llmModel: baseLLMModel,
  embeddingModel: baseEmbeddingModel,
);

// 生成的 JSON：
// {
//   "name": "my-agent",
//   "model": "openai/gpt-4o",
//   "embedding": "openai/text-embedding-3-small"
// }
```

### 示例 2: BYOK 模式

```dart
// 从 BYOK providers 选择模型
final byokLLMModel = LLMModel(
  // ... 其他字段
  providerCategory: 'byok', // ← 关键字段
);

final request = CreateAgentRequest(
  name: 'my-agent',
  llmModel: byokLLMModel,
  embeddingModel: byokEmbeddingModel,
);

// 生成的 JSON：
// {
//   "name": "my-agent",
//   "llm_config": {
//     "config": {
//       "model": "gpt-4o",
//       "provider": "openai",
//       "model_endpoint_type": "openai"
//     }
//   },
//   "embedding_config": {
//     "config": {
//       "model": "text-embedding-3-small",
//       "provider": "openai",
//       "model_endpoint_type": "openai"
//     }
//   }
// }
```

---

## API Provider

```dart
@riverpod
Future<Agent> createAgent(Ref ref, CreateAgentRequest request) async {
  final client = ref.watch(apiClientProvider);

  // 自动根据模式选择正确的 JSON 格式
  final requestBody = request.toJson();

  final response = await client.post(
    '/agents/',
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final dynamic decoded = jsonDecode(response.body);
    return Agent.fromJson(decoded as Map<String, dynamic>);
  } else {
    throw Exception('Failed to create agent: ${response.statusCode}');
  }
}
```

---

## 前端 UI 实现

### 在创建 Agent 表单中

```dart
class CreateAgentScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final isBYOKMode = ref.watch(byokModeProvider);

    return Column(
      children: [
        // BYOK 模式开关
        SwitchListTile(
          title: Text('BYOK Mode'),
          subtitle: Text('Use custom providers'),
          value: isBYOKMode,
          onChanged: (value) {
            ref.read(byokModeProvider.notifier).state = value;
          },
        ),

        // 根据模式显示不同的模型列表
        if (isBYOKMode)
          _buildBYOKModelSelector()
        else
          _buildBaseModelSelector(),
      ],
    );
  }

  Widget _buildBaseModelSelector() {
    final baseModels = ref.watch(baseLLMModelListProvider);
    // 显示 base providers 的模型
  }

  Widget _buildBYOKModelSelector() {
    final byokModels = ref.watch(byokLLMModelListProvider);
    // 显示 BYOK providers 的模型
  }

  Future<void> _submitCreateAgent() async {
    final request = CreateAgentRequest(
      name: nameController.text,
      description: descriptionController.text,
      llmModel: selectedLLMModel,
      embeddingModel: selectedEmbeddingModel,
      systemPrompt: systemPromptController.text,
    );

    try {
      final agent = await ref.read(createAgentProvider(request).future);
      // 成功创建
    } catch (e) {
      // 处理错误
    }
  }
}
```

---

## 优势

✅ **自动模式检测**: 无需手动判断使用哪种格式
✅ **类型安全**: 编译时检查所有字段
✅ **代码简洁**: 一个模型处理两种模式
✅ **易于维护**: 集中管理请求格式逻辑

---

## 总结

通过 `CreateAgentRequest` 模型，我们实现了：

1. **非 BYOK 模式**: 使用简洁的 `model` 和 `embedding` 字段
2. **BYOK 模式**: 使用完整的 `llm_config` 和 `embedding_config`
3. **自动检测**: 根据 `providerCategory` 自动选择正确的格式
4. **类型安全**: 编译时确保所有必需字段存在

这样既符合 Letta API 的设计理念，也能为用户提供最佳的开发体验！
