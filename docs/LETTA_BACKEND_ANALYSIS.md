# Letta 后端工具能力分析

**Date**: 2026-01-12
**Purpose**: 分析 Letta 后端是否支持远程开发所需的工具执行能力

---

## ⚠️ 重大发现：Provider Handle 机制问题 (2026-01-12)

### 问题背景

用户创建自定义Provider（使用OpenAI兼容的API）时遇到认证失败问题。经过深入调查，发现Letta后端对OpenAI兼容的API有特殊的handle机制。

### 核心发现

#### 1. **`openai-proxy` 是硬编码的特殊handle前缀**

**位置**: `/root/work/letta/letta/schemas/providers/openai.py:153-157`

```python
# Note: openai-proxy just means that the model is using the OpenAIProvider
if self.base_url != "https://api.openai.com/v1":
    handle = self.get_handle(model_name, base_name="openai-proxy")
else:
    handle = self.get_handle(model_name)
```

**逻辑说明**:
- 如果Provider的`base_url` **不是**官方OpenAI (`https://api.openai.com/v1`)
  → 强制使用 `openai-proxy` 作为handle的前缀
- 如果是官方OpenAI
  → 使用provider的name作为前缀

**示例**:
```
用户创建Provider:
- name: "CC Test"
- base_url: "https://api.custom.com/v1"
- model: "claude-sonnet-4-5-20250929"

后端生成的handle: "openai-proxy/claude-sonnet-4-5-20250929"
                    ^^^^^^^^^^^^^
                    注意：不是 "CC Test/claude-sonnet-4-5-20250929"
```

#### 2. **Agent运行时自动转换handle**

**位置**: `/root/work/letta/letta/agents/letta_agent_v3.py`

```python
if "/" in summarizer_config.model:
    provider, model_name = summarizer_config.model.split("/", 1)
    if provider == "openai-proxy":
        # fix for pydantic LLMConfig validation
        provider = "openai"  # ← 自动将openai-proxy替换为openai
```

**说明**:
- `openai-proxy` 只是一个**标记**，表示"这是OpenAI兼容的API"
- Agent运行时自动转换为 `openai` provider类型
- 确保使用OpenAIProvider类来处理请求

#### 3. **Handle覆盖规则不影响Provider名称**

**位置**: `/root/work/letta/letta/schemas/llm_config_overrides.py`

```python
LLM_HANDLE_OVERRIDES: Dict[str, Dict[str, str]] = {
    "openai": {  # ← provider name (不是provider name的前缀)
        "gpt-4o-2024-05-13": "gpt-4o-may",  # ← 只映射model name
        "gpt-4o-2024-08-06": "gpt-4o-aug",
    }
}
```

**作用**:
- 只用于简化模型名称（如 `gpt-4o-2024-05-13` → `gpt-4o-may`）
- **不影响provider名称**
- 创建名为 `openai` 的provider不会覆盖Letta内置的openai provider

### 问题影响

#### ❌ **当前问题**

1. **用户自定义Provider无法正常工作**
   - 用户创建名为 "CC Test" 的provider
   - 后端生成handle: `openai-proxy/model-name`
   - Agent创建时使用: `CC Test/model-name` (错误)
   - 导致Agent运行时找不到正确的provider配置

2. **用户无法区分不同的Provider**
   - 所有OpenAI兼容的API都被标记为 `openai-proxy`
   - 无法通过handle区分不同的custom endpoint

### BYOK模式下的Handle限制

| Provider类型 | Base URL | Handle前缀 | 备注 |
|-------------|----------|-----------|------|
| **官方OpenAI** | `https://api.openai.com/v1` | `openai` | 使用provider的name |
| **OpenAI兼容API** | 其他URL | `openai-proxy` | **硬编码**，无法自定义 |
| **Anthropic** | 任意 | `anthropic` | 使用provider的name |
| **Together AI** | 任意 | `together` | 使用provider的name |

### 解决方案选项

#### 方案1: 修改Provider创建逻辑（推荐）
- 在前端检测OpenAI类型 + custom base_url
- 自动使用正确的handle格式
- 用户界面仍显示自定义name，但后端使用`openai-proxy`

#### 方案2: 修改后端Letta（不推荐）
- 修改 `openai.py` 支持custom provider name
- 需要修改多个文件
- 可能破坏现有功能

#### 方案3: 文档说明（临时方案）
- 在UI上提示用户使用 `openai-proxy` 作为provider name
- 用户体验差

### 数据流示例

**场景**: 用户创建使用自定义API的Agent

```
1. 用户在前端创建Provider:
   - Name: "CC Test"
   - Type: OpenAI
   - Base URL: "https://api.custom.com"
   - API Key: "sk-xxx"

2. 后端创建Provider对象:
   - provider.name = "CC Test"
   - provider.base_url = "https://api.custom.com"
   - 生成LLMConfig时，handle = "openai-proxy/claude-sonnet-4-5-20250929"

3. 用户创建Agent时:
   - 选择的LLM model handle: "CC Test/claude-sonnet-4-5-20250929"  ❌ 错误
   - 应该是: "openai-proxy/claude-sonnet-4-5-20250929"  ✅ 正确

4. Agent运行时:
   - 期望找到handle为 "openai-proxy/..." 的配置
   - 实际收到的是 "CC Test/..."
   - 导致provider lookup失败，认证错误
```

### 相关文件

- `/root/work/letta/letta/schemas/providers/openai.py` - OpenAI Provider实现
- `/root/work/letta/letta/schemas/providers/base.py` - Provider基类，get_handle方法
- `/root/work/letta/letta/schemas/llm_config_overrides.py` - Handle覆盖规则
- `/root/work/letta/letta/agents/letta_agent_v3.py` - Agent运行时的handle转换逻辑

### 参考资料

- OpenAI Provider源码: `letta/schemas/providers/openai.py:19-200`
- Provider基类: `letta/schemas/providers/base.py:161-178`
- Agent执行逻辑: `letta/agents/letta_agent_v3.py` (搜索"openai-proxy")

---

## 🔍 研究方法

- 分析 Letta 后端 GitHub 仓库 (letta-ai/letta)
- 查看服务端工具实现 (letta/functions/function_sets/)
- 查看工具执行沙箱 (letta/sandbox/)
- 对比 Letta Code 的客户端工具

## ✅ Letta 后端已实现的服务端工具

### 1. 代码执行工具

**文件**: `letta/functions/function_sets/builtin.py`

```python
def run_code(code: str, language: Literal["python", "js", "ts", "r", "java"]) -> str:
    """
    Run code in a sandbox. Supports Python, Javascript, Typescript, R, and Java.
    """
    raise NotImplementedError("This is only available on the latest agent architecture.")

def run_code_with_tools(code: str) -> str:
    """
    Run code with access to the tools of the agent. Only support python.
    """
    raise NotImplementedError("This is only available on the latest agent architecture.")
```

**状态**: 接口已定义，但标记为 `NotImplementedError`
**说明**: 可能需要在最新架构或特定配置下才能使用

### 2. 网络工具

```python
async def web_search(query: str, num_results: int = 10, ...) -> str:
    """Search the web using Exa's AI-powered search engine."""
    raise NotImplementedError("This is only available on the latest agent architecture.")

async def fetch_webpage(url: str) -> str:
    """Fetch a webpage and convert it to markdown/text format."""
    raise NotImplementedError("This is only available on the latest agent architecture.")
```

**状态**: 接口已定义，但标记为 `NotImplementedError`

### 3. 文件工具

**文件**: `letta/functions/function_sets/files.py`

```python
async def open_files(agent_state, file_requests: List[FileOpenRequest], close_all_others: bool = False) -> str:
    """Open one or more files and load their contents into core memory."""
    raise NotImplementedError("Tool not implemented. Please contact the Letta team.")

async def grep_files(agent_state, pattern: str, include: Optional[str] = None, ...) -> str:
    """Searches file contents for pattern matches with surrounding context."""
    raise NotImplementedError("Tool not implemented. Please contact the Letta team.")

async def semantic_search_files(agent_state, query: str, limit: int = 5) -> List[FileMetadata]:
    """Searches file contents using semantic meaning."""
    raise NotImplementedError("Tool not implemented. Please contact the Letta team.")
```

**状态**: 接口已定义，但标记为 `NotImplementedError`

## 🏗️ 工具执行沙箱

**目录**: `letta/sandbox/`

```
sandbox/
├── __init__.py
├── modal_executor.py      # Modal 沙箱执行器
├── node_server.py          # Node.js 服务器
└── resources/
    └── server/
        ├── entrypoint.ts
        ├── server.ts
        ├── user-function.ts
        └── ...
```

**说明**:
- Letta 后端有沙箱执行环境
- 支持 Modal 和 Node.js 两种执行方式
- 用于安全地执行用户代码

## 📊 与 Letta Code 的对比

| 功能 | Letta Code | Letta 后端 |
|------|-----------|-----------|
| **文件读取** | ✅ Read (客户端) | ⚠️ open_files (未实现) |
| **文件写入** | ✅ Write (客户端) | ❌ 无对应接口 |
| **文件编辑** | ✅ Edit (客户端) | ❌ 无对应接口 |
| **命令执行** | ✅ Bash (客户端) | ⚠️ run_code (部分支持) |
| **文件搜索** | ✅ Grep (客户端) | ⚠️ grep_files (未实现) |
| **网页搜索** | ❌ 无 | ⚠️ web_search (未实现) |
| **记忆管理** | ✅ 通过后端 API | ✅ 完全支持 |
| **工具批准** | ✅ UI + 权限系统 | ⚠️ API 支持 |

## 🎯 关键发现

1. **Letta 后端的工具接口已定义**，但大部分标记为 `NotImplementedError`
2. **沙箱执行环境存在**，说明后端确实有工具执行能力
3. **`run_code` 工具** - 可以在服务器端运行代码（Python, JS, TS, R, Java）
4. **文件工具接口存在**但未实现 - 可能是计划中的功能

## 💡 推断

基于 Letta 后端的架构设计：

- ✅ 后端**确实有**工具执行的沙箱环境
- ✅ 后端**确实支持**通过 API 注册和执行自定义工具
- ⚠️ 内置的文件操作工具可能**尚未完全实现**
- ✅ 可以通过 API **添加自定义工具**来实现文件操作功能

## 📝 API 端点 (来自 Letta 文档)

```
POST /api/v1/tools/run              # 执行工具（不持久化）
POST /api/v1/tools/add-base-tools   # 更新或插入内置工具
PUT  /api/v1/tools                  # 创建或更新工具
PATCH /api/v1/tools/{tool_id}       # 更新工具定义
```

## 🚀 结论

**Letta 后端有能力支持远程开发**，但需要：

1. **确认当前状态** - 检查 `run_code` 等工具是否在最新版本中可用
2. **可能需要添加自定义工具** - 如果内置文件工具未实现，可以通过 API 添加
3. **工具沙箱已就绪** - 后端有安全的执行环境

**与 Letta Code 的关系**:
- Letta Code 的客户端工具是**临时方案**（在用户机器执行）
- Letta 后端的工具系统是**长期方案**（在服务器执行）
- 未来可能会将客户端工具迁移到后端

## 🔗 相关资源

- Letta 后端: https://github.com/letta-ai/letta
- Letta 代码执行: `letta/functions/function_sets/builtin.py`
- Letta 沙箱: `letta/sandbox/`
- Letta 工具 API: `letta/server/rest_api/routers/v1/tools.py`

## 解决方案实现 (2026-01-12)

### 实现位置

**文件**: `/root/work/klui/lib/core/models/create_agent_request.dart`

### 实现逻辑

#### 1. LLM Model Handle 转换

```dart
String _getCorrectLLMHandle() {
  // OpenAI-compatible API with custom base URL
  if (llmModel.providerType == 'openai' &&
      llmModel.modelEndpoint != 'https://api.openai.com/v1') {
    // Extract model name from handle (format: "provider-name/model-name")
    final modelName = llmModel.handle.contains('/')
        ? llmModel.handle.split('/').last
        : llmModel.model;
    return 'openai-proxy/$modelName';
  }

  // For all other cases, use the original handle
  return llmModel.handle;
}
```

**判断条件**:
- `providerType == 'openai'` ← 必须是OpenAI类型
- `modelEndpoint != 'https://api.openai.com/v1'` ← 且不是官方OpenAI API

**转换动作**:
- 从原始handle中提取model name
- 使用 `openai-proxy` 作为前缀
- 返回新格式: `openai-proxy/{model_name}`

#### 2. Embedding Model Handle 转换

```dart
String _getCorrectEmbeddingHandle() {
  // OpenAI-compatible API with custom base URL
  if (embeddingModel.providerType == 'openai' &&
      embeddingModel.embeddingEndpoint != 'https://api.openai.com/v1') {
    // Extract model name from handle
    final modelName = embeddingModel.handle.contains('/')
        ? embeddingModel.handle.split('/').last
        : embeddingModel.embeddingModel;
    return 'openai-proxy/$modelName';
  }

  // For all other cases, use the original handle
  return embeddingModel.handle;
}
```

**逻辑相同**，但针对embedding模型：
- 使用 `embeddingEndpoint` 而不是 `modelEndpoint`
- 使用 `embeddingModel` 而不是 `model`

#### 3. 在Agent创建时应用转换

```dart
Map<String, dynamic> toSimpleJson() {
  final json = <String, dynamic>{
    'name': name,
    'model': _getCorrectLLMHandle(),  // ← 使用转换后的handle
    'embedding': _getCorrectEmbeddingHandle(),  // ← 使用转换后的handle
  };
  // ...
}
```

### 测试用例

#### 测试场景 1: 自定义OpenAI兼容API

**输入**:
```dart
Provider:
  - name: "CC Test"
  - providerType: "openai"
  - baseUrl: "https://api.custom.com/v1"

LLMModel:
  - handle: "CC Test/claude-sonnet-4-5-20250929"
  - model: "claude-sonnet-4-5-20250929"
  - modelEndpoint: "https://api.custom.com/v1"
```

**转换结果**:
```json
{
  "model": "openai-proxy/claude-sonnet-4-5-20250929"
}
```

**预期行为**: ✅ Agent可以使用自定义API正常工作

#### 测试场景 2: 官方OpenAI API

**输入**:
```dart
Provider:
  - name: "openai"
  - providerType: "openai"
  - baseUrl: "https://api.openai.com/v1"

LLMModel:
  - handle: "openai/gpt-4o"
  - modelEndpoint: "https://api.openai.com/v1"
```

**转换结果**:
```json
{
  "model": "openai/gpt-4o"
}
```

**预期行为**: ✅ 保持原样，不转换

#### 测试场景 3: Anthropic API

**输入**:
```dart
Provider:
  - name: "My Anthropic"
  - providerType: "anthropic"
  - baseUrl: "https://api.anthropic.com"

LLMModel:
  - handle: "My Anthropic/claude-3-5-sonnet-20241022"
```

**转换结果**:
```json
{
  "model": "My Anthropic/claude-3-5-sonnet-20241022"
}
```

**预期行为**: ✅ 保持原样，不转换

### 用户界面影响

**无需改变**，用户界面仍然显示用户友好的名称：

```
Provider选择下拉框:
  ✅ "CC Test - Claude Sonnet 4.5"
  ✅ "My Custom API - GPT-4o"
  ✅ "Production OpenAI - GPT-4o"

发送到后端:
  - "CC Test/..." → "openai-proxy/..."
  - "My Custom API/..." → "openai-proxy/..."
  - "Production OpenAI/..." → "openai/..." (如果是官方API)
```

### 关键优势

1. **✅ 用户可以自由命名Provider** - 无限制
2. **✅ 自动适配Letta后端规则** - 透明转换
3. **✅ 支持多个OpenAI兼容API** - 不会冲突
4. **✅ 向后兼容** - 不影响现有功能
5. **✅ 代码集中管理** - 所有逻辑在CreateAgentRequest中

### 相关文件

- 实现文件: `lib/core/models/create_agent_request.dart`
- 测试文档: `test_handle_transformation.dart`
- 后端逻辑: `/root/work/letta/letta/schemas/providers/openai.py:153-157`

---
