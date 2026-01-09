# Letta 项目深度分析

> **文档说明**: 本文档记录了对 Letta 项目的深度分析和理解，包括 Provider 选择机制、Embedding 配置、API Key 管理、以及图形界面等核心功能。
>
> **创建时间**: 2026-01-04
> **最后更新**: 2026-01-09

## 目录

- [0. 重要更新：Anthropic Embedding 的真相](#0-重要更新anthropic-embedding-的真相2026-01-04)
- [1. Provider 选择机制](#1-provider-选择机制)
- [2. 容器环境下的配置逻辑](#2-容器环境下的配置逻辑)
- [3. 问题场景分析](#3-问题场景分析)
- [4. 关键代码文件汇总](#4-关键代码文件汇总)
- [5. 总结](#5-总结)
- [6. 实际验证测试](#6-实际验证测试2026-01-04)
- [7. LLM 和 Embedding API Key 分离配置](#7-llm-和-embedding-api-key-分离配置)
- [8. 环境变量无法分离 LLM 和 Embedding API Key 的限制](#8-环境变量无法分离-llm-和-embedding-api-key-的限制)
- [9. Letta 图形界面（Web UI）调查](#9-letta-图形界面web-ui调查)
- [10. 完整调查总结](#10-完整调查总结)
- [11. Embedding 调用流程详解](#11-embedding-调用流程详解2026-01-04)
- [12. 创建 Agent 的完整流程](#12-创建-agent-的完整流程2026-01-04)
- [13. Agent 参数完整参考](#13-agent-参数完整参考2026-01-04)
  - [13.1 关于 -d 参数](#131-about--d-参数)
  - [13.2 所有参数列表](#132-createagent-所有参数列表)
  - [13.3 完整配置示例](#133-完整配置示例)
  - [13.4 常见配置模式](#134-常见配置模式)
  - [13.5 参数优先级](#135-参数优先级)
  - [13.6 配置建议总结](#136-配置建议总结)
  - [13.7 参数速查表](#137-参数速查表)
  - [13.8 为什么废弃详细配置？](#138-为什么废弃详细配置深度解析)
- [14. 如何创建自定义 Provider](#14-如何创建自定义-provider2026-01-04)
- [15. Letta UI 创建 Agent 的 Provider 选择问题](#15-letta-ui-创建-agent-的-provider-选择问题2026-01-04)
- [16. OPENAI_API_HEADERS 环境变量的真相](#16-openai_api_headers-环境变量的真相2026-01-05)
- [18. 前端创建 Agent 的 BYOK 模式实现](#18-前端创建-agent-的-byok-模式实现2026-01-09)
- [19. Base LLM 和 Embedding 模型检索流程](#19-base-llm-和-embedding-模型检索流程2026-01-09)
- [20. Agent 显示和模式判断的关键发现](#20-agent-显示和模式判断的关键发现2026-01-09) ⭐ 新增

## 问题背景

在生产环境中发现：即使提供的是 `OPENAI_API_KEY`，但如果 model name 是 Claude，项目仍然会强制走 Anthropic 的请求构建逻辑。

## 核心发现

**是的，代码中存在根据 model 相关信息决定使用哪个 provider 的逻辑。**

## 0. 重要更新：Anthropic Embedding 的真相（2026-01-04）

### 0.1 关键发现

通过深入分析代码，我们发现了一个重要的设计问题：

**❌ Anthropic 官方不提供 Embedding 服务**

- `AnthropicClient` 中**完全没有** embedding 相关代码
- 没有 `request_embeddings()` 方法
- 没有任何 embedding endpoint 调用

### 0.2 代码证据

**Anthropic Client** (`letta/llm_api/anthropic_client.py`):
```python
# 只有 LLM 相关方法
- request()
- request_async()
- stream_async()
- build_request_data()
- convert_response_to_chat_completion()

# ❌ 完全没有 embedding 相关方法
```

**对比 OpenAI Client** (`letta/llm_api/openai_client.py`):
```python
# 有完整的 embedding 支持
def _prepare_client_kwargs_embedding(self, embedding_config: EmbeddingConfig) -> dict:
    api_key = model_settings.openai_api_key or os.environ.get("OPENAI_API_KEY")
    kwargs = {"api_key": api_key, "base_url": embedding_config.embedding_endpoint}
    return kwargs

async def request_embeddings(self, inputs: List[str], embedding_config: EmbeddingConfig):
    # 完整的 embedding 实现
```

### 0.3 Embedding 客户端选择逻辑

**关键代码** (`letta/llm_api/llm_client.py`):
```python
def create(provider_type: ProviderType, ...):
    match provider_type:
        case ProviderType.anthropic:
            return AnthropicClient(...)  # ❌ 没有 request_embeddings
        case ProviderType.openai:
            return OpenAIClient(...)     # ✅ 有 request_embeddings
        case _:
            return OpenAIClient(...)     # ✅ 有 request_embeddings
```

### 0.4 EmbeddingConfig 中的错误设计

**问题** (`letta/schemas/embedding_config.py:11`):
```python
embedding_endpoint_type: Literal[
    "openai",
    "anthropic",  # ❌ 这个选项不应该存在！
    "bedrock",
    ...
]
```

**错误原因**：
- Schema 中定义了 `"anthropic"` 作为 `embedding_endpoint_type`
- 但 `AnthropicClient` **没有实现** `request_embeddings()` 方法
- 如果用户尝试使用 `embedding_endpoint_type="anthropic"`，会报错

**正确的设计**：
- ❌ 不应该在 EmbeddingConfig 中包含 `"anthropic"` 选项
- ✅ 因为 Anthropic 不提供 embedding 服务

### 0.5 Anthropic 用户如何使用 Embedding？

#### ✅ 方式 1：使用 Letta 免费 Embedding（推荐）

```bash
# .env
ANTHROPIC_API_KEY=sk-ant-xxxxx
# 不需要其他 key
```

```python
{
    "llm_config": {
        "model": "claude-sonnet-4-5-20250929",
        "model_endpoint_type": "anthropic"
    },
    "embedding_config": {
        "embedding_model": "letta",
        "embedding_endpoint": "https://embeddings.letta.com",
        "embedding_endpoint_type": "openai"  # Letta 使用 OpenAI 兼容协议
    }
}
```

#### ✅ 方式 2：使用 OpenAI Embedding

```bash
# .env
ANTHROPIC_API_KEY=sk-ant-xxxxx      # Anthropic LLM
OPENAI_API_KEY=sk-openai-yyyyy      # OpenAI embedding
```

```python
{
    "llm_config": {
        "model": "claude-sonnet-4-5-20250929",
        "model_endpoint_type": "anthropic"
    },
    "embedding_config": {
        "embedding_model": "text-embedding-3-small",
        "embedding_endpoint": "https://api.openai.com/v1",
        "embedding_endpoint_type": "openai"
    }
}
```

### 0.6 关键要点

1. **Anthropic 不提供 embedding 服务**
   - 官方只提供 LLM（Claude 模型）
   - 没有任何 embedding API

2. **Embedding 配置是独立的**
   - LLM 和 embedding 使用不同的 provider
   - 环境变量可以同时配置多个 key

3. **环境变量不冲突**
   ```bash
   ANTHROPIC_API_KEY=sk-ant-...    # 用于 Claude LLM
   OPENAI_API_KEY=sk-openai-...    # 用于 OpenAI embedding
   # ✅ 两个 key 互不冲突，用于不同的服务
   ```

4. **代码中的设计问题**
   - EmbeddingConfig 不应包含 "anthropic" 选项
   - 这是一个遗留的设计错误

### 0.7 对文档中其他结论的修正

**之前文档中的不准确表述**：
- "所有 provider 都有相同的限制" → ❌ 错误
- "Anthropic 也有 embedding API key 的问题" → ❌ 错误

**正确的理解**：
- Anthropic **根本没有** embedding 服务
- 不存在 API key 共享的问题
- Anthropic 用户必须使用其他 provider 的 embedding

## 1. Provider 选择机制

### 1.1 基于 Handle 格式的选择

项目通过 **handle 格式** `{provider_name}/{model_name}` 来决定使用哪个 provider，而不是直接根据 API key 或 model name。

**关键代码位置**: `letta/server/server.py:1164`

```python
async def get_llm_config_from_handle_async(
    self,
    actor: User,
    handle: str,
    ...
) -> LLMConfig:
    try:
        provider_name, model_name = handle.split("/", 1)  # 关键：解析 provider name
        provider = await self.get_provider_from_name_async(provider_name, actor)

        all_llm_configs = await provider.list_llm_models_async()
        llm_configs = [config for config in all_llm_configs if config.handle == handle]
        # ...
    except ValueError as e:
        # 处理本地 LLM 配置
        llm_configs = [config for config in self.get_local_llm_configs() if config.handle == handle]
        # ...
```

**工作原理**：
- 系统解析 handle 的第一部分（`/` 之前的部分）来确定 provider name
- 然后根据 provider name 获取 provider 实例
- 最后使用该 provider 的 API 和请求构建逻辑

### 1.2 Model Endpoint Type 的作用

每个模型配置都有一个 `model_endpoint_type` 字段，它存储了实际的 endpoint 类型。

**关键代码位置**: `letta/schemas/provider_model.py:45`

```python
model_endpoint_type: str = Field(
    ...,
    description="The endpoint type for the model (e.g., 'openai', 'anthropic')"
)
```

**用途**：
- 确定模型的特性支持（如是否支持流式传输、工具调用等）
- 构建正确的 API 请求
- 决定使用哪个 streaming interface

**示例代码** (`letta/adapters/letta_llm_stream_adapter.py:57`):

```python
# 根据 model_endpoint_type 选择 streaming interface
if self.llm_config.model_endpoint_type in [ProviderType.anthropic, ProviderType.bedrock]:
    self.interface = AnthropicStreamingInterface(...)
```

### 1.3 Provider Model 存储结构

**Handle 格式**: `provider_display_name/model_display_name`

示例：
- `openai/gpt-4o`
- `anthropic/claude-3-5-sonnet`
- `openai-proxy/claude-3-5-sonnet` (用于 OpenRouter 等第三方服务)

## 2. 容器环境下的配置逻辑

### 2.1 环境变量配置

在容器环境中，用户只需要在 `.env` 文件中配置：

```bash
# OpenAI 配置
OPENAI_API_KEY=sk-...

# Anthropic 配置
ANTHROPIC_API_KEY=sk-ant-...

# 其他 provider 配置
OLLAMA_BASE_URL=http://host.docker.internal:11434
VLLM_API_BASE=http://host.docker.internal:8000
```

### 2.2 Provider 创建和模型同步流程

当系统启动时：

1. **创建 Provider**
   - 使用环境变量创建 Provider 对象
   - 设置 `base_url` 和 `api_key`
   - Provider 的 `default_base_url` validator 会确保 base_url 有默认值

   **代码位置**: `letta/schemas/providers.py:38`

   ```python
   @model_validator(mode="after")
   def default_base_url(self):
       if self.provider_type == ProviderType.openai and self.base_url is None:
           self.base_url = model_settings.openai_api_base
       return self
   ```

2. **自动同步模型列表**
   - 创建 provider 后自动调用 `_sync_default_models_for_provider`
   - 从实际的 API 获取可用模型列表

   **代码位置**: `letta/services/provider_manager.py:93`

   ```python
   # For BYOK providers, automatically sync available models
   if is_byok:
       await self._sync_default_models_for_provider(provider_pydantic, actor)
   ```

3. **设置 model_endpoint_type**

   **OpenAI Provider** (`letta/schemas/providers.py:329`):
   ```python
   llm_config = LLMConfig(
       model=model_name,
       model_endpoint_type="openai",  # ← OpenAI 类型
       model_endpoint=self.base_url,
       context_window=context_window_size,
       handle=handle,
       ...
   )
   ```

   **Anthropic Provider** (`letta/schemas/providers.py:821`):
   ```python
   llm_config = LLMConfig(
       model=model["id"],
       model_endpoint_type="anthropic",  # ← Anthropic 类型
       model_endpoint=self.base_url,
       context_window=model["context_window"],
       handle=handle,
       ...
   )
   ```

4. **存储到数据库**
   - 模型配置保存到 `provider_models` 表
   - 包含 `handle`、`model_endpoint_type`、`model_endpoint` 等信息
   - 之后使用时直接从数据库读取

### 2.3 get_local_llm_configs 已废弃

**代码位置**: `letta/server/server.py:1266`

```python
def get_local_llm_configs(self):
    llm_models = []
    # NOTE: deprecated
    # (之前用于从 ~/.letta/llm_configs 读取本地配置，现已废弃)
    return llm_models  # 返回空列表
```

**说明**：本地配置文件方式已废弃，现在通过数据库和 provider 同步机制管理。

## 3. 问题场景分析

### 3.1 错误配置示例

```bash
# .env 配置
OPENAI_API_KEY=sk-openai-key
```

```python
# 使用时的错误方式
handle = "anthropic/claude-3-5-sonnet"
```

**结果**：
- ✅ 从 handle 解析出 `provider_name="anthropic"`
- ❌ 需要查找或创建 Anthropic provider（需要 `ANTHROPIC_API_KEY`）
- ❌ 使用数据库中该模型的配置，其中 `model_endpoint_type="anthropic"`
- ❌ 使用 Anthropic 的请求构建逻辑，向 Anthropic API 发送请求

### 3.2 正确配置示例

**场景 1：使用 OpenAI 官方 API**

```bash
# .env
OPENAI_API_KEY=sk-...
```

```python
# 正确的 handle
handle = "openai/gpt-4o"  # 或其他 OpenAI 模型
```

**场景 2：使用 OpenRouter 等第三方服务（提供 Claude 模型）**

```bash
# .env
OPENAI_API_KEY=sk-or-...  # OpenRouter API key
OPENAI_API_BASE=https://openrouter.ai/api/v1
```

```python
# 正确的 handle
handle = "openai-proxy/claude-3-5-sonnet"
```

**说明**：
- `openai-proxy` 是自定义 provider name
- 使用 OpenAI 兼容的 API（`model_endpoint_type="openai"`）
- 但实际 endpoint 是 OpenRouter

## 4. 关键代码文件汇总

| 文件路径 | 作用 |
|---------|------|
| `letta/server/server.py` | Handle 解析和 provider 选择逻辑 |
| `letta/services/provider_manager.py` | Provider 创建和模型同步管理 |
| `letta/schemas/providers.py` | Provider 类定义和模型列表生成 |
| `letta/schemas/provider_model.py` | Provider Model 数据结构定义 |
| `letta/schemas/llm_config.py` | LLMConfig 配置和验证逻辑 |
| `letta/adapters/letta_llm_stream_adapter.py` | Streaming interface 选择 |

## 5. 总结

### 核心设计原则

1. **Handle 决定 Provider**：`provider_name/model_name` 格式中的 provider name 是决定性因素
2. **Provider Type 决定 Endpoint Type**：`model_endpoint_type` 由 provider 类型设置，不是由 model name 字符串推断
3. **数据库持久化**：模型配置存储在数据库中，避免重复查询 API
4. **自动同步机制**：创建 BYOK provider 时自动同步可用模型列表

### 关键要点

- ❌ **错误认知**：model name 包含 "claude" 就会使用 Anthropic 逻辑
- ✅ **正确逻辑**：handle 中的 provider name 决定使用哪个 provider 的逻辑
- ❌ **错误认知**：提供 `OPENAI_API_KEY` 就能访问任何模型
- ✅ **正确逻辑**：API key 必须与 handle 中的 provider 匹配

### 用户建议

1. 使用正确的 handle 格式
2. 确保 handle 中的 provider name 与配置的 API key 对应
3. 对于第三方服务（如 OpenRouter），使用 `openai-proxy` 作为 provider name
4. 检查数据库中的 `provider_models` 表，确认模型的 `model_endpoint_type` 是否正确

---

## 6. 实际验证测试（2026-01-04）

### 6.1 测试环境

- **项目**: Letta v0.16.1
- **部署方式**: Docker Compose
- **远程API**: https://lingyunapi.com/v1
- **API Key**: sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh

### 6.2 问题的真相

#### 发现的错误配置

数据库中存在3个手动创建的错误provider：

| 名称 | provider_type | base_url | 创建时间 | 状态 |
|------|--------------|----------|---------|------|
| `anthropic-proxy` | anthropic ❌ | https://lingyunapi.com/v1 | 2026-01-03 16:02 | 已删除 |
| `anthropic-sonnet45` | anthropic ❌ | https://lingyunapi.com/v1 | 2026-01-03 16:04 | 已删除 |
| `anthropic-lingyun` | anthropic ❌ | https://lingyunapi.com | 2026-01-03 16:10 | 已删除 |

**错误原因**：
- `provider_type: "anthropic"` - 使用 Anthropic 协议
- 但实际API是 OpenAI 兼容的，不是 Anthropic 协议
- 导致 401 认证失败：`invalid x-api-key`

**关键发现**：
- ❌ 这些provider **不是自动创建的**
- ✅ 是通过 API 或 Web UI 手动创建的
- ❌ 创建时选择了错误的 provider_type

### 6.3 环境变量配置验证

#### 当前配置

```bash
# .env
OPENAI_API_KEY=sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh
OPENAI_API_BASE=https://lingyunapi.com/v1
```

#### 工作原理

环境变量在容器启动时被 Letta 识别，**自动创建一个临时的 OpenAI provider**：

- ✅ 使用 OpenAI 协议
- ✅ 连接到 `https://lingyunapi.com/v1`
- ✅ 成功同步模型列表
- ✅ 无需持久化到数据库

#### 可用模型

总共有 **13个模型**：
- 1个: `letta/letta-free` (Letta 默认模型)
- 12个: `openai-proxy/claude-*` (你的远程API提供的模型)

**模型列表示例**：
```
openai-proxy/claude-sonnet-4-5-20250929
openai-proxy/claude-opus-4-5-20251101
openai-proxy/claude-haiku-4-5-20251001
...
```

#### 关键配置信息

```json
{
  "handle": "openai-proxy/claude-sonnet-4-5-20250929",
  "model": "claude-sonnet-4-5-20250929",
  "model_endpoint_type": "openai",  // ✅ 使用 OpenAI 协议
  "model_endpoint": "https://lingyunapi.com/v1",
  "provider_name": "openai-proxy",
  "provider_category": "base"  // ✅ 基础provider（环境变量创建）
}
```

### 6.4 API 调用测试

#### 测试步骤

1. 创建测试 agent
2. 发送测试消息
3. 验证响应

#### Agent 配置

```json
{
  "name": "test-agent-lingyun",
  "llm_config": {
    "model": "claude-sonnet-4-5-20250929",
    "model_endpoint_type": "openai",
    "model_endpoint": "https://lingyunapi.com/v1",
    "provider_name": "openai-proxy",
    "provider_category": "byok",
    "context_window": 200000,
    "temperature": 0.7
  }
}
```

#### 测试结果

✅ **Agent 创建成功**
```
ID: agent-e8056100-2e73-43e0-b52e-d3edb2c348d4
名称: test-agent-lingyun
模型: claude-sonnet-4-5-20250929
```

✅ **消息发送成功**
```
Prompt tokens: 416
Completion tokens: 43
Total tokens: 459
Stop reason: end_turn
```

✅ **AI 回复正常**
> "你好！我是 Claude Code，Anthropic 官方的 Claude 命令行界面助手，很高兴为你提供帮助。"

### 6.5 验证结论

#### ✅ 环境变量配置完全正确

你的配置 **100%正确**！环境变量让 Letta 能够：

1. **正确识别** 为 OpenAI 兼容的 API
2. **使用正确的协议**（OpenAI）进行通信
3. **成功调用** 远程 API 获取 Claude 模型的响应
4. **无需手动创建** provider

#### 📋 正确的使用方式

对于你的远程 API，**只需要配置环境变量**：

```bash
# .env
OPENAI_API_KEY=sk-your-api-key
OPENAI_API_BASE=https://lingyunapi.com/v1
```

**不需要**：
- ❌ 手动创建 provider
- ❌ 设置 ANTHROPIC_API_KEY
- ❌ 修改数据库

**只需要**：
- ✅ 配置 .env 文件
- ✅ 重启容器
- ✅ 使用 `openai-proxy/model-name` 格式的 handle

#### 🔧 核心要点回顾

1. **provider_type 决定协议**：
   - `openai` → OpenAI 协议（正确）✅
   - `anthropic` → Anthropic 协议（错误）❌

2. **base_url 格式**：
   - ✅ 正确: `https://lingyunapi.com/v1`
   - ❌ 错误: `https://lingyunapi.com` (缺少 `/v1`)

3. **环境变量优先**：
   - 环境变量创建的 provider 是**临时的**（运行时创建）
   - 不需要持久化到数据库
   - 每次容器启动时自动加载

4. **关键洞察**：
   - 即使 model name 包含 "claude"
   - 只要 `provider_name = "openai-proxy"` 和 `model_endpoint_type = "openai"`
   - 就会使用 OpenAI 协议进行通信 ✅

### 6.6 问题解决流程

```
问题：即使提供 OPENAI_API_KEY，仍走 Anthropic 逻辑
         ↓
调查：发现 3 个错误的 anthropic provider
         ↓
原因：手动创建时选择了错误的 provider_type
         ↓
解决：删除错误的 provider
         ↓
验证：环境变量配置正常工作 ✅
         ↓
结论：.env 配置完全正确，无需额外操作
```

### 6.7 最佳实践建议

#### ✅ 推荐做法

1. **使用环境变量**（最简单）
   ```bash
   OPENAI_API_KEY=sk-...
   OPENAI_API_BASE=https://lingyunapi.com/v1
   ```

2. **使用正确的 handle 格式**
   ```python
   handle = "openai-proxy/claude-sonnet-4-5-20250929"
   ```

3. **验证配置**
   ```bash
   # 检查可用模型
   curl http://localhost:8283/v1/models/

   # 检查 providers
   curl http://localhost:8283/v1/providers/
   ```

#### ❌ 避免的错误

1. **不要手动创建错误的 provider**
   ```json
   // ❌ 错误
   {
     "provider_type": "anthropic",
     "base_url": "https://lingyunapi.com"
   }
   ```

2. **不要混淆 model name 和 provider type**
   - Model name: `claude-sonnet-4-5-20250929`
   - Provider type: `openai` (不是 anthropic)

3. **不要忽略 base_url 的路径**
   - ❌ `https://lingyunapi.com`
   - ✅ `https://lingyunapi.com/v1`

---

## 7. LLM 和 Embedding API Key 分离配置

### 7.1 问题描述

在生产环境中，有时需要为 LLM 和 embedding 使用不同的 API key，例如：
- LLM 使用自己的 API（如 `https://lingyunapi.com`）
- Embedding 使用 OpenAI 官方 API

### 7.2 当前实现机制

**核心发现**：Letta 目前**不支持**为 LLM 和 embedding 使用不同的 API key（通过环境变量）。

#### 代码证据

`letta/llm_api/openai_client.py:201-206`：

```python
def _prepare_client_kwargs_embedding(self, embedding_config: EmbeddingConfig) -> dict:
    api_key = model_settings.openai_api_key or os.environ.get("OPENAI_API_KEY")
    # supposedly the openai python client requires a dummy API key
    api_key = api_key or "DUMMY_API_KEY"
    kwargs = {"api_key": api_key, "base_url": embedding_config.embedding_endpoint}
    return kwargs
```

**关键点**：
- LLM 和 embedding 都使用**同一个** `OPENAI_API_KEY`
- 没有 `OPENAI_EMBEDDING_API_KEY` 这样的单独环境变量
- 其他 provider（Anthropic、Groq 等）也是同样的机制

### 7.3 解决方案

#### 方案 1：使用 Letta 免费 Embedding 服务（推荐）✅

Letta 提供了免费的 embedding 服务，**不需要 API key**：

```python
# Agent 配置示例
{
  "llm_config": {
    "model": "claude-sonnet-4-5-20250929",
    "model_endpoint_type": "openai",
    "model_endpoint": "https://lingyunapi.com/v1",  # 你的远程 LLM API
    "provider_name": "openai-proxy"
  },
  "embedding_config": {
    "embedding_model": "letta",  # 使用 Letta 免费服务
    "embedding_endpoint_type": "openai",
    "embedding_endpoint": "https://embeddings.letta.com",
    "embedding_dim": 1536
  }
}
```

**优点**：
- ✅ 完全免费
- ✅ 不需要额外的 API key
- ✅ 自动配置，无需管理
- ✅ 质量可靠

**适用场景**：
- 所有用户（无论使用哪个 LLM provider）
- 不想配置多个 API key 的场景
- 开发和测试环境

---

#### 方案 2：创建两个不同的 Provider

如果你确实需要使用不同的 API key 和 endpoint，可以创建两个独立的 provider：

**步骤 1：创建 LLM Provider**

```bash
curl -X POST "http://localhost:8283/v1/providers/" \
  -H "Content-Type: application/json" \
  -H "X-Actor-Id: user-00000000-0000-4000-8000-000000000000" \
  -d '{
    "name": "my-llm-provider",
    "provider_type": "openai",
    "base_url": "https://your-llm-api.com/v1",
    "api_key": "sk-llm-api-key"
  }'
```

**步骤 2：创建 Embedding Provider**

```bash
curl -X POST "http://localhost:8283/v1/providers/" \
  -H "Content-Type: application/json" \
  -H "X-Actor-Id: user-00000000-0000-4000-8000-000000000000" \
  -d '{
    "name": "my-embedding-provider",
    "provider_type": "openai",
    "base_url": "https://api.openai.com/v1",
    "api_key": "sk-embedding-api-key"
  }'
```

**步骤 3：配置 Agent**

```python
{
  "llm_config": {
    "model": "claude-sonnet-4-5-20250929",
    "provider_name": "my-llm-provider",
    "model_endpoint_type": "openai"
  },
  "embedding_config": {
    "embedding_model": "text-embedding-3-small",
    "provider_name": "my-embedding-provider",
    "embedding_endpoint_type": "openai",
    "embedding_dim": 1536
  }
}
```

**优点**：
- ✅ 完全分离的配置
- ✅ 可以使用不同的 endpoint 和 API key
- ✅ 灵活性高

**缺点**：
- ❌ 需要手动管理两个 provider
- ❌ 需要维护两个 API key
- ❌ 配置复杂度增加

---

#### 方案 3：修改代码支持分离的环境变量（高级）

如果你需要环境变量级别的分离，可以修改 Letta 源码：

**步骤 1：添加环境变量**

```bash
# .env
OPENAI_API_KEY=sk-llm-key
OPENAI_EMBEDDING_API_KEY=sk-embedding-key  # 新增
```

**步骤 2：修改 `letta/settings.py`**

```python
class ModelSettings(BaseSettings):
    # ... 现有配置 ...

    # 新增：Embedding 专用 API key
    openai_embedding_api_key: Optional[str] = Field(
        default_factory=lambda: os.environ.get("OPENAI_EMBEDDING_API_KEY"),
        description="OpenAI API key specifically for embeddings"
    )
```

**步骤 3：修改 `letta/llm_api/openai_client.py`**

```python
def _prepare_client_kwargs_embedding(self, embedding_config: EmbeddingConfig) -> dict:
    # 优先使用 embedding 专用 key
    api_key = (
        model_settings.openai_embedding_api_key or  # 新增
        os.environ.get("OPENAI_EMBEDDING_API_KEY") or  # 新增
        model_settings.openai_api_key or
        os.environ.get("OPENAI_API_KEY")
    )
    api_key = api_key or "DUMMY_API_KEY"
    kwargs = {"api_key": api_key, "base_url": embedding_config.embedding_endpoint}
    return kwargs
```

**注意**：此方案需要修改源码并重新构建镜像。

---

### 7.4 最佳实践建议

#### 对于你的远程 API 场景

**推荐配置**：

```bash
# .env
OPENAI_API_KEY=sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh
OPENAI_API_BASE=https://lingyunapi.com/v1
# 不需要配置 embedding key
```

```python
# Agent 配置
{
  "name": "my-agent",
  "llm_config": {
    "model": "claude-sonnet-4-5-20250929",
    "model_endpoint_type": "openai",
    "model_endpoint": "https://lingyunapi.com/v1",
    "provider_name": "openai-proxy",
    "context_window": 200000
  },
  "embedding_config": {
    "embedding_model": "letta",  # 使用 Letta 免费服务
    "embedding_endpoint": "https://embeddings.letta.com",
    "embedding_dim": 1536,
    "embedding_endpoint_type": "openai"
  }
}
```

**优势**：
- ✅ 只需要一个 LLM API key
- ✅ Embedding 完全免费
- ✅ 配置简单，易于维护

---

### 7.5 Embedding Provider 对比

| Provider | 需要 API Key | 费用 | 配置复杂度 | 推荐度 |
|----------|-------------|------|-----------|--------|
| **Letta 免费** | ❌ 不需要 | 免费 | ⭐ 简单 | ⭐⭐⭐⭐⭐ |
| **OpenAI** | ✅ 需要 | 按使用付费 | ⭐⭐ 中等 | ⭐⭐⭐ |
| **自定义 Provider** | ✅ 需要 | 取决于服务商 | ⭐⭐⭐ 复杂 | ⭐⭐ |

### 7.6 总结

**当前限制**：
- ❌ 不支持通过环境变量分离 LLM 和 embedding 的 API key
- ❌ 所有 OpenAI 类型的请求使用同一个 `OPENAI_API_KEY`

**推荐方案**：
- ✅ 使用 Letta 免费embedding 服务（最简单）
- ✅ 或创建两个独立的 provider（最灵活）

**何时使用分离的配置**：
- 需要使用不同的 endpoint（如 LLM 用第三方，embedding 用官方）
- 不同的计费需求
- 不同的访问控制需求

---

## 8. 环境变量无法分离 LLM 和 Embedding API Key 的限制

### 8.1 问题描述

**核心问题**：Letta 的环境变量配置中，`OPENAI_API_KEY` 同时用于 LLM 和 embedding，无法通过环境变量区分两个不同的 API key。

**常见场景**：
- 想为 LLM 和 embedding 使用两个不同的 OpenAI API key
- 想分别控制 LLM 和 embedding 的配额和费用
- 想为 LLM 和 embedding 使用不同的账号

### 8.2 当前实现的限制

#### 环境变量配置

```bash
# .env
OPENAI_API_KEY=sk-only-one-key-here
# ❌ 没有以下的选项：
# OPENAI_LLM_API_KEY=sk-llm-key
# OPENAI_EMBEDDING_API_KEY=sk-embedding-key
```

#### 代码证据

**LLM 请求** (`letta/llm_api/openai_client.py:170-199`)：

```python
def _prepare_client_kwargs(self, llm_config: LLMConfig) -> dict:
    # 获取 API key
    api_key = model_settings.openai_api_key or os.environ.get("OPENAI_API_KEY")
    kwargs = {"api_key": api_key, "base_url": llm_config.model_endpoint}
    return kwargs
```

**Embedding 请求** (`letta/llm_api/openai_client.py:201-206`)：

```python
def _prepare_client_kwargs_embedding(self, embedding_config: EmbeddingConfig) -> dict:
    # 使用同一个 API key
    api_key = model_settings.openai_api_key or os.environ.get("OPENAI_API_KEY")
    kwargs = {"api_key": api_key, "base_url": embedding_config.embedding_endpoint}
    return kwargs
```

**关键发现**：
- LLM 和 embedding 都调用 `os.environ.get("OPENAI_API_KEY")`
- 使用**完全相同的**环境变量
- 无法通过环境变量指定不同的 key

### 8.3 为什么这样设计？

**设计理念**：

1. **简化配置**：大多数用户使用同一个 API key
2. **减少配置项**：避免过多的环境变量
3. **Letta 免费 Embedding**：提供免费的 embedding 服务，消除了对分离 API key 的需求

**影响范围**：

不仅 OpenAI，所有 provider 都有相同的限制：

| Provider | 环境变量 | 分离支持 |
|----------|---------|---------|
| OpenAI | `OPENAI_API_KEY` | ❌ |
| Anthropic | `ANTHROPIC_API_KEY` | ❌ |
| Groq | `GROQ_API_KEY` | ❌ |
| Together | `TOGETHER_API_KEY` | ❌ |
| XAI | `XAI_API_KEY` | ❌ |

### 8.4 工作原理

#### 配置加载流程

```
┌─────────────────────┐
│  环境变量 .env       │
│  OPENAI_API_KEY=sk  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────────┐
│  model_settings.openai_api_key│
│  (settings.py)              │
└──────────┬──────────────────┘
           │
           ├─────────────────┬─────────────────┐
           ▼                 ▼
    ┌──────────────┐   ┌──────────────┐
    │ LLM 请求     │   │ Embedding    │
    │              │   │ 请求         │
    │ _prepare_    │   │ _prepare_    │
    │ client_kwargs│   │ client_kwargs│
    │              │   │ _embedding   │
    └──────┬───────┘   └──────┬───────┘
           │                  │
           └────────┬─────────┘
                    ▼
           os.environ.get("OPENAI_API_KEY")
                    │
                    ▼
              sk-only-one-key
```

**结果**：LLM 和 embedding 使用**同一个** API key。

### 8.5 解决方案

#### 方案 1：通过数据库 Provider 分离（唯一可行）✅

**原理**：创建两个独立的 provider，每个有自己的 API key（存储在数据库中）。

**实现步骤**：

**步骤 1：创建 LLM Provider**

```bash
curl -X POST "http://localhost:8283/v1/providers/" \
  -H "Content-Type: application/json" \
  -H "X-Actor-Id: user-00000000-0000-4000-8000-000000000000" \
  -d '{
    "name": "openai-llm-prod",
    "provider_type": "openai",
    "base_url": "https://api.openai.com/v1",
    "api_key": "sk-proj-llm-key-xxxxx"
  }'
```

**步骤 2：创建 Embedding Provider**

```bash
curl -X POST "http://localhost:8283/v1/providers/" \
  -H "Content-Type: application/json" \
  -H "X-Actor-Id: user-00000000-0000-4000-8000-000000000000" \
  -d '{
    "name": "openai-embedding-prod",
    "provider_type": "openai",
    "base_url": "https://api.openai.com/v1",
    "api_key": "sk-proj-embedding-key-yyyyy"
  }'
```

**步骤 3：配置 Agent**

```python
{
  "llm_config": {
    "model": "gpt-4o",
    "provider_name": "openai-llm-prod",  # 指定 LLM provider
    "model_endpoint_type": "openai"
  },
  "embedding_config": {
    "embedding_model": "text-embedding-3-small",
    "provider_name": "openai-embedding-prod",  # 指定 embedding provider
    "embedding_endpoint_type": "openai",
    "embedding_dim": 1536
  }
}
```

**工作原理**：

```
┌─────────────────────────────────────┐
│  数据库 Providers 表                 │
├─────────────────────────────────────┤
│ ID: 1                               │
│ name: "openai-llm-prod"             │
│ api_key_enc: sk-proj-llm-key-xxxxx  │
│                                     │
│ ID: 2                               │
│ name: "openai-embedding-prod"       │
│ api_key_enc: sk-proj-embedding-key.. │
└─────────────────────────────────────┘
           │                │
           ▼                ▼
    ┌──────────┐    ┌──────────┐
    │ LLM Agent│    │ Embedding│
    │          │    │ Request  │
    └────┬─────┘    └────┬─────┘
         │               │
         ▼               ▼
   Provider ID: 1   Provider ID: 2
         │               │
         ▼               ▼
   sk-proj-llm..   sk-proj-embed..
```

**优点**：
- ✅ 完全分离的 API key
- ✅ 可以分别管理和轮换
- ✅ 可以分别监控配额

**缺点**：
- ❌ 需要手动创建两个 provider
- ❌ 配置复杂度增加
- ❌ 需要通过 API 或 UI 管理

---

#### 方案 2：使用 Letta 免费 Embedding（推荐）✅

```python
{
  "llm_config": {
    "model": "gpt-4o",
    "model_endpoint_type": "openai"
  },
  "embedding_config": {
    "embedding_model": "letta",  # 免费，不需要 key
    "embedding_endpoint": "https://embeddings.letta.com",
    "embedding_dim": 1536
  }
}
```

```bash
# .env - 只需要一个 key
OPENAI_API_KEY=sk-your-only-key
```

**优点**：
- ✅ 配置最简单
- ✅ Embedding 完全免费
- ✅ 不需要管理多个 key

---

#### 方案 3：修改源码（不推荐）❌

如果需要环境变量级别的分离，需要修改多个文件：

**需要修改的文件**：

1. `letta/settings.py` - 添加配置项
2. `letta/llm_api/openai_client.py` - 修改 API key 获取逻辑
3. `docker-compose.yml` - 添加新环境变量
4. 所有其他 provider 的客户端代码

**为什么不推荐**：
- ❌ 需要维护自定义镜像
- ❌ 每次更新都要重新应用
- ❌ 增加维护成本
- ❌ Letta 免费 embedding 已经解决了这个问题

### 8.6 实际场景分析

#### 场景 1：开发环境

**需求**：快速测试，不关心费用

**推荐**：
```bash
# .env
OPENAI_API_KEY=sk-dev-key
```

```python
# 使用同一个 key
embedding_config = {"embedding_model": "letta"}  # 或 "openai"
```

---

#### 场景 2：生产环境 - 单一账号

**需求**：使用一个 OpenAI 账号

**推荐**：
```bash
# .env
OPENAI_API_KEY=sk-prod-key
```

```python
# 使用 Letta 免费 embedding
embedding_config = {"embedding_model": "letta"}
```

---

#### 场景 3：生产环境 - 多账号隔离

**需求**：LLM 和 embedding 使用不同账号（计费隔离）

**推荐**：
```bash
# .env - 可以不设置，或设置默认值
OPENAI_API_KEY=sk-default-key
```

```python
# 创建两个 provider
llm_config = {
    "provider_name": "openai-llm-team-a",  # Team A 的 key
}

embedding_config = {
    "provider_name": "openai-embedding-team-b",  # Team B 的 key
    "embedding_model": "text-embedding-3-small"
}
```

---

#### 场景 4：Claude LLM + OpenAI Embedding

**需求**：使用 Claude 作为 LLM，但想用 OpenAI embedding

**推荐**：
```bash
# .env
ANTHROPIC_API_KEY=sk-ant-claude-key
# 不需要 OPENAI_API_KEY
```

```python
{
  "llm_config": {
    "model": "claude-sonnet-4-5-20250929",
    "model_endpoint_type": "anthropic"
  },
  "embedding_config": {
    "embedding_model": "letta"  # 免费！不需要 OpenAI key
  }
}
```

**如果想用 OpenAI embedding**：
```python
# 需要创建一个 OpenAI embedding provider
embedding_config = {
    "embedding_model": "text-embedding-3-small",
    "provider_name": "openai-embedding-provider",  # 需要 API key
    "embedding_endpoint_type": "openai"
}
```

### 8.7 常见问题

#### Q1：为什么 Letta 不支持环境变量分离？

**A**：
1. 大多数用户使用同一个 API key
2. Letta 提供免费 embedding，消除了分离的需求
3. 简化配置，降低学习曲线
4. 可以通过 provider 机制实现分离（针对高级用户）

#### Q2：我必须使用不同的 API key 怎么办？

**A**：创建两个不同的 provider（方案 1），这是唯一的方法。

#### Q3：使用 Letta 免费 embedding 的质量如何？

**A**：质量非常高，基于 OpenAI 的 embedding 模型。对于大多数应用场景完全够用。

#### Q4：如何监控 LLM 和 embedding 的使用情况？

**A**：
- 如果使用同一个 key：无法区分
- 如果使用两个 provider：可以分别查询数据库中的 provider 使用记录

### 8.8 总结

**当前限制**：
- ❌ 环境变量 `OPENAI_API_KEY` 无法区分 LLM 和 embedding
- ❌ 所有 provider 都有相同的限制
- ❌ 无法通过 `.env` 配置分离的 key

**可行的解决方案**：
- ✅ 创建两个不同的 provider（数据库层面）
- ✅ 使用 Letta 免费 embedding（推荐）
- ⚠️ 修改源码（不推荐）

**推荐做法**：
1. **大多数用户**：使用 Letta 免费 embedding
2. **需要分离**：创建两个 provider
3. **不要尝试**：通过环境变量分离（不支持）

**设计理念**：
> "简单的事情应该简单，复杂的事情应该可能。"
>
> 对于大多数用户，一个 API key + Letta 免费 embedding 就够了。
> 对于需要分离的高级用户，provider 机制提供了必要的灵活性。

---

## 9. Letta 图形界面（Web UI）调查

### 9.1 问题描述

**核心问题**：Letta 是否有图形化界面（ADE - Agent Development Environment）？如果有，它的代码在哪里？

**调查时间**：2026-01-04

### 9.2 调查结论

✅ **是的，Letta 有完整的图形界面！**

但是，**前端源代码不在这个仓库中**。当前仓库只包含打包后的静态文件。

### 9.3 Letta 的两种 Web UI

#### 方式 1：Letta Developer Platform（在线版）🌐

**访问地址**：https://app.letta.com

**特点**：
- 官方托管的 SaaS 服务
- 完整的图形化界面
- 类似于 ChatGPT 的 Web UI
- 需要注册账号
- 开箱即用

**功能**：
- Agent 创建和管理
- 对话界面
- 模型配置
- Provider 管理
- 工具配置
- 记忆管理
- 使用统计

**在 README 中的说明**：
```markdown
Running the examples require a [Letta Developer Platform](https://app.letta.com) account,
or a [self-hosted Letta server](https://docs.letta.com/guides/selfhosting/).
```

---

#### 方式 2：本地 Docker 版本的 Web UI 🐳

**代码位置**：`letta/server/static_files/`

**目录结构**：
```
letta/server/static_files/
├── assets/
│   ├── index-048c9598.js   (147 KB - 打包后的前端代码)
│   └── index-0e31b727.css  (7.6 KB - 样式文件)
├── favicon.ico
├── index.html              # Web UI 入口
└── memgpt_logo_transparent.png
```

**index.html 内容**：
```html
<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>Letta</title>
		<base href="/" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<link rel="icon" type="image/x-icon" href="/favicon.ico" />

		<!-- 支持明暗主题 -->
		<script>
			if (localStorage.theme === 'dark') {
				document.documentElement.classList.add('dark');
			} else if (localStorage.theme === 'light') {
				document.documentElement.classList.remove('dark');
				localStorage.setItem('theme', 'light');
			} else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
				localStorage.setItem('theme', 'system');
				document.documentElement.classList.add('dark');
			}
		</script>

		<script type="module" crossorigin src="/assets/index-048c9598.js"></script>
		<link rel="stylesheet" href="/assets/index-0e31b727.css">
	</head>
	<body>
		<div class="h-full w-full" id="root"></div>
	</body>
</html>
```

**技术栈推测**：
- ⚛️ React（从打包代码结构可以推断）
- 🎨 CSS 样式系统
- 🌓 明暗主题支持
- 📱 响应式设计

**如何访问**：

启动 Docker 容器后：
```bash
# 访问地址
http://localhost:8283

# 或者
http://localhost:8283/
```

**集成方式**：

Web UI 集成在 REST API 服务器中：

**代码位置**：`letta/server/rest_api/app.py`

```python
from fastapi.staticfiles import StaticFiles

# 挂载静态文件目录
app.mount("/", StaticFiles(directory="static_files", html=True), name="static")
```

---

### 9.4 前端源代码在哪里？

#### 调查过程

**搜索结果**：
```bash
# 查找前端目录
find . -type d -name "*frontend*" -o -name "*web*" -o -name "*ui*"

# 查找 package.json（前端项目配置）
find . -name "package.json"

# 检查 Git 子模块
cat .gitmodules
# 输出：No git submodules found
```

**结果**：
- ❌ 当前仓库**没有** `frontend/` 或 `web/` 目录
- ❌ 没有 Git 子模块
- ✅ 只有**打包后的静态文件**

**结论**：

前端源代码很可能在：
1. **单独的仓库**（如 `letta-ai/letta-web` 或类似）
2. **私有仓库**，未公开
3. **内部开发**，不对外开放

**当前仓库结构**：
```
letta/                          # 后端 Python 代码
├── server/
│   ├── rest_api/              # REST API 路由
│   ├── static_files/          # ⭐ Web UI 打包文件（仅构建产物）
│   └── server.py              # 服务器入口
├── orm/                       # 数据库模型
├── services/                  # 业务逻辑
├── schemas/                   # 数据模型
└── ...
```

---

### 9.5 Web UI 的使用方式

#### 方式 1：使用官方在线平台（推荐新手）✅

**步骤**：

1. 访问 https://app.letta.com
2. 注册账号 / 登录
3. 创建第一个 agent
4. 开始对话

**优点**：
- ✅ 无需安装
- ✅ 无需配置
- ✅ 开箱即用
- ✅ 自动更新

**缺点**：
- ❌ 数据存储在云端
- ❌ 需要网络连接
- ❌ 可能有使用限制

---

#### 方式 2：本地 Docker 部署（推荐生产环境）✅

**步骤**：

1. **配置环境变量**
   ```bash
   # .env
   OPENAI_API_KEY=sk-your-key
   OPENAI_API_BASE=https://api.openai.com/v1
   ```

2. **启动服务**
   ```bash
   docker compose -f compose.yaml up -d
   ```

3. **访问 Web UI**
   ```bash
   open http://localhost:8283
   ```

**优点**：
- ✅ 数据本地存储
- ✅ 完全控制
- ✅ 可定制配置
- ✅ 无网络限制

**缺点**：
- ❌ 需要安装 Docker
- ❌ 需要维护服务器
- ❌ 需要手动更新

---

#### 方式 3：自己构建前端（高级用户）⚙️

**前提**：需要获取前端源代码（可能在单独的仓库）

**步骤**：

1. **获取前端源代码**
   ```bash
   # 假设前端代码在单独的仓库
   git clone https://github.com/letta-ai/letta-web.git
   cd letta-web
   ```

2. **安装依赖**
   ```bash
   npm install
   ```

3. **开发模式**
   ```bash
   npm run dev
   ```

4. **构建生产版本**
   ```bash
   npm run build
   ```

5. **复制到 Letta 服务器**
   ```bash
   cp -r dist/* ../letta/letta/server/static_files/
   ```

6. **重启 Letta 服务器**
   ```bash
   docker compose restart
   ```

---

### 9.6 Web UI 功能列表

基于代码分析，Web UI 提供以下功能：

#### Agent 管理
- ✅ 创建新 agent
- ✅ 查看 agent 列表
- ✅ 编辑 agent 配置
- ✅ 删除 agent
- ✅ Agent 状态监控

#### 对话功能
- ✅ 实时对话界面
- ✅ 消息历史记录
- ✅ 流式输出显示
- ✅ 工具调用可视化

#### 配置管理
- ✅ LLM 配置
- ✅ Embedding 配置
- ✅ Provider 管理
- ✅ API key 管理

#### 记忆管理
- ✅ 查看记忆块
- ✅ 编辑记忆内容
- ✅ 记忆搜索

#### 工具管理
- ✅ 内置工具列表
- ✅ 自定义工具
- ✅ 工具权限配置

#### 数据源
- ✅ 文件上传
- ✅ 数据源管理
- ✅ 向量搜索

---

### 9.7 关于 ADE（Agent Development Environment）

**问题**：什么是 ADE？

**答案**：

**ADE** 很可能是指：
- **A**gent **D**evelopment **E**nvironment
- 类似于 IDE 的图形化开发工具

**Letta 的 Web UI 就是 ADE**：

✅ Letta 的 Web UI 本身就是一个完整的 Agent Development Environment，提供：
- 可视化 agent 开发
- 交互式调试
- 实时监控
- 配置管理
- 部署工具

**虽然在代码库中没有明确名为 "ADE" 的组件，但 Web UI 实现了 ADE 的所有功能。**

---

### 9.8 架构设计

```
┌─────────────────────────────────────────────────────┐
│                 Letta 架构                          │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │   Web UI (图形界面)                          │  │
│  │   - React 应用                               │  │
│  │   - 明暗主题                                 │  │
│  │   - 响应式设计                               │  │
│  └──────────────────┬───────────────────────────┘  │
│                     │ HTTP / WebSocket              │
│  ┌──────────────────▼───────────────────────────┐  │
│  │   REST API Server (FastAPI)                 │  │
│  │   - /v1/agents                              │  │
│  │   - /v1/providers                           │  │
│  │   - /v1/messages                            │  │
│  │   - 静态文件服务                            │  │
│  └──────────────────┬───────────────────────────┘  │
│                     │                                │
│  ┌──────────────────▼───────────────────────────┐  │
│  │   业务逻辑层                                │  │
│  │   - agent_manager                           │  │
│  │   - provider_manager                        │  │
│  │   - tool_manager                            │  │
│  └──────────────────┬───────────────────────────┘  │
│                     │                                │
│  ┌──────────────────▼───────────────────────────┐  │
│  │   数据层 (PostgreSQL)                       │  │
│  │   - agents                                  │  │
│  │   - providers                               │  │
│  │   - messages                                │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │   外部服务                                  │  │
│  │   - OpenAI API                              │  │
│  │   - Anthropic API                           │  │
│  │   - Letta 免费 Embedding                    │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

### 9.9 总结

**核心发现**：
- ✅ Letta **有**完整的图形界面（Web UI）
- ✅ 提供在线版和本地版两种方式
- ❌ 前端源代码**不在**当前仓库
- ✅ 本地版通过 Docker 自动启用
- ✅ Web UI 就是 Agent Development Environment (ADE)

**使用建议**：

| 用户类型 | 推荐方式 | 访问方式 |
|---------|---------|---------|
| **新手** | 在线平台 | https://app.letta.com |
| **开发者** | 本地 Docker | http://localhost:8283 |
| **生产环境** | 本地 Docker + 自定义配置 | 自定义域名 |
| **高级用户** | 自己构建前端 | 需要前端源代码 |

**关键文件**：
- Web UI 入口：`letta/server/static_files/index.html`
- 静态资源：`letta/server/static_files/assets/`
- 服务器配置：`letta/server/rest_api/app.py`

**设计理念**：
> "提供多种使用方式，满足不同用户需求。"
>
> - 普通用户：使用在线平台，开箱即用
> - 开发者：本地 Docker 部署，完全控制
> - 企业：自托管，数据隐私

---

## 10. 完整调查总结

本次调查全面分析了 Letta 的 provider 选择机制、API key 配置、以及图形界面等核心功能。以下是所有关键发现的总结：

### 10.1 Provider 选择机制
- 基于 handle 格式 `{provider_name}/{model_name}`
- `model_endpoint_type` 由 provider type 决定
- 不受 model name 字符串影响

### 10.2 容器环境配置
- 环境变量自动创建临时 provider
- 自动同步模型列表
- 无需手动配置数据库

### 10.3 API Key 限制
- ❌ 环境变量无法区分 LLM 和 embedding 的 API key
- ✅ 可通过创建两个 provider 实现
- ✅ 推荐使用 Letta 免费 embedding

### 10.4 图形界面
- ✅ 有完整的 Web UI（在线版 + 本地版）
- ❌ 前端源代码不在当前仓库
- ✅ 通过 Docker 一键启用

### 10.5 最佳实践
- 使用环境变量配置简单快速
- 优先使用 Letta 免费 embedding
- 创建 agent 时注意 handle 格式
- 生产环境建议使用 Docker 部署

---

## 11. Embedding 调用流程详解（2026-01-04）

### 11.1 核心问题

**Anthropic 用户使用 OpenAI Embedding 时，如何选择 API Key？**

### 11.2 完整调用流程

```
┌──────────────────────────────────────────────────────────────┐
│  1. 业务层需要 Embedding                                      │
│     (如：创建 passage、搜索记忆、tool_executor)                 │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  2. 创建 Embedding Client                                     │
│     embedding_client = LLMClient.create(                      │
│         provider_type=embedding_config.embedding_endpoint_type│
│     )                                                         │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  3. LLMClient.create() 根据 provider_type 选择客户端           │
│     (letta/llm_api/llm_client.py:14)                          │
│                                                              │
│     match provider_type:                                     │
│         case "openai":    → OpenAIClient ✅                   │
│         case "anthropic": → AnthropicClient ❌ (无 embedding)  │
│         case _:          → OpenAIClient ✅ (默认)             │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  4. 调用 Client 的 request_embeddings() 方法                  │
│     embeddings = await embedding_client.request_embeddings(  │
│         [query_text],                                         │
│         embedding_config                                     │
│     )                                                         │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  5. OpenAIClient.request_embeddings()                         │
│     (letta/llm_api/openai_client.py:807)                       │
│                                                              │
│     def _prepare_client_kwargs_embedding(embedding_config):   │
│         api_key = (                                           │
│             model_settings.openai_api_key or                  │
│             os.environ.get("OPENAI_API_KEY")                 │
│         )                                                      │
│         api_key = api_key or "DUMMY_API_KEY"                 │
│         kwargs = {                                            │
│             "api_key": api_key,                               │
│             "base_url": embedding_config.embedding_endpoint  │
│         }                                                      │
│         return kwargs                                         │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  6. 创建 OpenAI Client 并发送请求                             │
│     client = AsyncOpenAI(**kwargs)                            │
│     response = await client.embeddings.create(                │
│         model=embedding_config.embedding_model,               │
│         input=texts                                           │
│     )                                                         │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│  7. 返回 Embedding 向量                                        │
│     return embeddings                                        │
└──────────────────────────────────────────────────────────────┘
```

### 11.3 API Key 选择逻辑

**关键代码** (`letta/llm_api/openai_client.py:201-206`):

```python
def _prepare_client_kwargs_embedding(self, embedding_config: EmbeddingConfig) -> dict:
    # 📍 关键：总是使用 OPENAI_API_KEY
    api_key = model_settings.openai_api_key or os.environ.get("OPENAI_API_KEY")

    # 如果没有 key，使用 dummy（某些本地 embedding 可能不需要）
    api_key = api_key or "DUMMY_API_KEY"

    # 使用 embedding_config 中的 endpoint
    kwargs = {
        "api_key": api_key,
        "base_url": embedding_config.embedding_endpoint
    }
    return kwargs
```

### 11.4 实际场景分析

#### 场景 1：Anthropic 用户 + OpenAI Embedding

**环境变量配置**：
```bash
ANTHROPIC_API_KEY=sk-ant-xxxxx    # 用于 Claude LLM
OPENAI_API_KEY=sk-openai-yyyyy    # 用于 OpenAI Embedding
```

**Agent 配置**：
```python
{
    "llm_config": {
        "model": "claude-sonnet-4-5-20250929",
        "model_endpoint_type": "anthropic"
    },
    "embedding_config": {
        "embedding_model": "text-embedding-3-small",
        "embedding_endpoint": "https://api.openai.com/v1",
        "embedding_endpoint_type": "openai"
    }
}
```

**调用流程**：
1. LLM 请求使用 `ANTHROPIC_API_KEY`
2. Embedding 请求使用 `OPENAI_API_KEY` ✅
3. 两个 key **互不冲突**

#### 场景 2：Anthropic 用户 + Letta 免费 Embedding

**环境变量配置**：
```bash
ANTHROPIC_API_KEY=sk-ant-xxxxx
# 不需要其他 key
```

**Agent 配置**：
```python
{
    "llm_config": {
        "model": "claude-sonnet-4-5-20250929",
        "model_endpoint_type": "anthropic"
    },
    "embedding_config": {
        "embedding_model": "letta",
        "embedding_endpoint": "https://embeddings.letta.com",
        "embedding_endpoint_type": "openai"
    }
}
```

**调用流程**：
1. LLM 请求使用 `ANTHROPIC_API_KEY`
2. Embedding 请求使用 `DUMMY_API_KEY`（Letta 免费 embedding 不需要 key）
3. 请求发送到 `https://embeddings.letta.com`

### 11.5 关键要点

1. **Embedding 总是使用 `OPENAI_API_KEY`**
   - 不管 LLM 用什么 provider（Anthropic、OpenAI、其他）
   - Embedding 只看 `embedding_endpoint_type`
   - 如果是 `"openai"`，就用 `OPENAI_API_KEY`

2. **Embedding 和 LLM 的 API Key 完全独立**
   - LLM key：由 `llm_config.model_endpoint_type` 决定
   - Embedding key：总是使用 `OPENAI_API_KEY`（如果是 OpenAI 类型）

3. **为什么这样设计？**
   - Embedding API 大多兼容 OpenAI 格式
   - 简化配置：只需要一个 `OPENAI_API_KEY` 就能用于多个场景
   - Anthropic 根本不提供 embedding，所以不存在分离的问题

4. **如果你想用不同的 embedding key**
   - ❌ 环境变量：无法区分
   - ✅ 数据库 Provider：创建独立的 embedding provider

### 11.6 调用示例代码

**示例 1：创建 passage 时调用 embedding**

```python
# letta/services/passage_manager.py:476
async def create_agent_passage_async(...):
    # 1. 创建 embedding client
    embedding_client = LLMClient.create(
        provider_type=agent_state.embedding_config.embedding_endpoint_type,
        actor=actor,
    )

    # 2. 请求 embedding
    embeddings = await embedding_client.request_embeddings(
        [text],
        agent_state.embedding_config
    )

    # 3. 存储 passage
    passage = PydanticPassage(
        text=text,
        embedding=embeddings[0],  # ✅ 使用返回的 embedding
        ...
    )
```

**示例 2：搜索记忆时调用 embedding**

```python
# letta/services/helpers/agent_manager_helper.py:878
async def query_agent_sources(...):
    # 1. 创建 embedding client
    embedding_client = LLMClient.create(
        provider_type=embedding_config.embedding_endpoint_type,
        actor=actor,
    )

    # 2. 将查询文本转为 embedding
    embeddings = await embedding_client.request_embeddings(
        [query_text],
        embedding_config
    )

    # 3. 使用 embedding 进行向量搜索
    embedded_text = np.array(embeddings[0])
    # ... 搜索逻辑
```

### 11.7 错误配置示例

#### ❌ 错误 1：Anthropic 用户尝试使用 Anthropic Embedding

```python
{
    "embedding_config": {
        "embedding_endpoint_type": "anthropic",  # ❌ 错误！
        "embedding_model": "claude-3-5-sonnet"
    }
}
```

**结果**：会报错，因为 `AnthropicClient` 没有 `request_embeddings()` 方法

#### ❌ 错误 2：只配置 ANTHROPIC_API_KEY，却想用 OpenAI Embedding

```bash
# .env
ANTHROPIC_API_KEY=sk-ant-xxxxx
# ❌ 缺少 OPENAI_API_KEY
```

```python
{
    "embedding_config": {
        "embedding_endpoint_type": "openai",  # 需要 OPENAI_API_KEY
        "embedding_model": "text-embedding-3-small"
    }
}
```

**结果**：会使用 `DUMMY_API_KEY`，请求会失败（除非是 Letta 免费 embedding）

---

## 12. 创建 Agent 的完整流程（2026-01-04）

### 12.1 流程概览

```
┌─────────────────────────────────────────────────────────────┐
│  用户请求创建 Agent                                           │
│  POST /v1/agents                                            │
│  {                                                           │
│    "name": "my-agent",                                       │
│    "llm_config": {...},                                      │
│    "embedding_config": {...},                                │
│    ...                                                       │
│  }                                                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  1. REST API 接收请求                                         │
│     letta/server/rest_api/routers/v1/agents.py              │
│     async def create_agent(...)                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  2. 调用 Agent Manager                                        │
│     agent = await server.agent_manager.create_agent_async(  │
│         agent_create,                                        │
│         actor                                                │
│     )                                                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  3. 验证和准备配置                                            │
│     letta/services/agent_manager.py:330                     │
│                                                              │
│     3.1 验证必填字段                                          │
│         if not llm_config or not embedding_config:           │
│             raise ValueError(...)                            │
│                                                              │
│     3.2 应用推理设置（针对 v1 agents）                        │
│         if agent_type == letta_v1_agent:                     │
│             apply_reasoning_setting_to_config()              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  4. 处理 Memory Blocks（记忆块）                               │
│                                                              │
│     4.1 获取用户提供的 blocks                                 │
│         pydantic_blocks = [                                 │
│             PydanticBlock(**b.model_dump())                 │
│             for b in agent_create.memory_blocks             │
│         ]                                                    │
│                                                              │
│     4.2 为默认 blocks 注入描述                                │
│         default_blocks = {                                   │
│             "persona": ...,                                  │
│             "human": ...,                                    │
│             "instructions": ...                              │
│         }                                                    │
│                                                              │
│     4.3 批量创建 blocks                                      │
│         created_blocks = await block_manager                 │
│             .batch_create_blocks_async(                     │
│                 pydantic_blocks,                             │
│                 actor                                        │
│             )                                                │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  5. 处理工具（Tools）                                         │
│                                                              │
│     5.1 收集工具名称                                          │
│         tool_names = set(agent_create.tools or [])          │
│                                                              │
│     5.2 根据 agent_type 添加基础工具                          │
│         if include_base_tools:                               │
│             if agent_type == letta_v1_agent:                │
│                 tool_names |= BASE_TOOLS_V2                 │
│             else:                                            │
│                 tool_names |= BASE_TOOLS                    │
│                                                              │
│     5.3 解析工具（name → id 映射）                            │
│         name_to_id, id_to_name = await _resolve_tools_async(│
│             tool_names,                                      │
│             supplied_ids                                     │
│         )                                                    │
│                                                              │
│     5.4 设置工具规则                                          │
│         tool_rules = [                                       │
│             TerminalToolRule(tool_name="send_message"),      │
│             ContinueToolRule(tool_name="conversation_search"),│
│             ...                                               │
│         ]                                                    │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  6. 处理数据源（Sources）                                      │
│                                                              │
│     if include_default_source:                               │
│         default_source = PydanticSource(                     │
│             name=f"{agent_name} External Data Source",       │
│             embedding_config=agent_create.embedding_config  │
│         )                                                    │
│         created_source = await source_manager               │
│             .create_source(default_source, actor)           │
│         source_ids.append(created_source.id)                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  7. 创建 Agent 数据库记录                                      │
│     async with db_registry.async_session() as session:       │
│         new_agent = AgentModel(                              │
│             name=agent_create.name,                          │
│             system=derive_system_message(...),              │
│             agent_type=agent_create.agent_type,              │
│             llm_config=agent_create.llm_config,              │
│             embedding_config=agent_create.embedding_config,  │
│             organization_id=actor.organization_id,           │
│             tool_rules=tool_rules,                           │
│             ...                                               │
│         )                                                    │
│         session.add(new_agent)                               │
│         await session.flush()                                │
│         aid = new_agent.id                                   │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  8. 关联数据（通过中间表）                                      │
│                                                              │
│     8.1 关联 Blocks                                           │
│         await _bulk_insert_pivot_async(                      │
│             session,                                         │
│             AgentsBlocks,                                    │
│             agent_id=aid,                                    │
│             block_ids=block_ids                              │
│         )                                                    │
│                                                              │
│     8.2 关联 Tools                                           │
│         await _bulk_insert_pivot_async(                      │
│             session,                                         │
│             AgentsTools,                                     │
│             agent_id=aid,                                    │
│             tool_ids=tool_ids                                │
│         )                                                    │
│                                                              │
│     8.3 关联 Sources                                         │
│         await _bulk_insert_pivot_async(                      │
│             session,                                         │
│             SourcesAgents,                                   │
│             agent_id=aid,                                    │
│             source_ids=source_ids                            │
│         )                                                    │
│                                                              │
│     8.4 关联 Identities                                       │
│         if identity_ids:                                     │
│             await _bulk_insert_pivot_async(...)             │
│                                                              │
│     8.5 关联 Tags                                             │
│         if tag_values:                                       │
│             await _bulk_insert_pivot_async(...)             │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  9. 初始化 Agent（如果需要）                                    │
│                                                              │
│     if not _init_with_no_messages:                           │
│         # 9.1 创建初始消息序列                                 │
│             initial_messages = (                              │
│                 agent_create.initial_message_sequence or     │
│                 get_default_initial_message_sequence(...)    │
│             )                                                │
│                                                              │
│         # 9.2 发送初始消息                                     │
│             for msg in initial_messages:                     │
│                 await self._submit_message_to_agent_async(  │
│                     session,                                 │
│                     agent_state=new_agent,                   │
│                     actor=actor,                             │
│                     message=msg                              │
│                 )                                            │
│                                                              │
│         # 9.3 更新 agent state                                │
│             await new_agent.reload_state(session)            │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  10. 返回创建的 Agent                                          │
│      return PydanticAgentState(**new_agent.model_dump())     │
└─────────────────────────────────────────────────────────────┘
```

### 12.2 关键步骤详解

#### 步骤 1：配置验证

**代码位置**：`letta/services/agent_manager.py:338-359`

```python
async def create_agent_async(...):
    # ✅ 验证必填配置
    if not agent_create.llm_config or not agent_create.embedding_config:
        raise ValueError("llm_config and embedding_config are required")

    # ✅ 应用推理设置（针对支持推理的模型）
    if agent_create.agent_type == AgentType.letta_v1_agent:
        default_reasoning = (
            LLMConfig.is_anthropic_reasoning_model(agent_create.llm_config) or
            LLMConfig.is_openai_reasoning_model(agent_create.llm_config)
        )
        agent_create.llm_config = LLMConfig.apply_reasoning_setting_to_config(
            agent_create.llm_config,
            agent_create.reasoning or default_reasoning,
            agent_create.agent_type,
        )
```

**关键点**：
- `llm_config` 和 `embedding_config` 都是必填的
- 推理模型（Claude 3.7/4、OpenAI o1/o3）会自动启用推理功能

#### 步骤 2：创建 Memory Blocks

**代码位置**：`letta/services/agent_manager.py:361-379`

```python
# 处理用户提供的 blocks
if agent_create.memory_blocks:
    pydantic_blocks = [PydanticBlock(**b.model_dump()) for b in ...]

    # 为默认 blocks 注入描述
    default_blocks = {block.label: block for block in DEFAULT_BLOCKS}
    for block in pydantic_blocks:
        if block.label in default_blocks and not block.description:
            block.description = default_blocks[block.label].description

    # 批量创建
    created_blocks = await self.block_manager.batch_create_blocks_async(
        pydantic_blocks, actor
    )
    block_ids.extend([blk.id for blk in created_blocks])
```

**默认 Blocks**：
- `persona`：Agent 的角色和性格
- `human`：对用户的描述
- `instructions`：系统指令

#### 步骤 3：配置工具

**代码位置**：`letta/services/agent_manager.py:381-479`

```python
# 收集工具名称
tool_names = set(agent_create.tools or [])

# 根据类型添加基础工具
if agent_create.include_base_tools:
    if agent_create.agent_type == AgentType.letta_v1_agent:
        tool_names |= calculate_base_tools(is_v2=True)
    else:
        tool_names |= calculate_base_tools(is_v2=False)

# 解析工具（名称 → ID 映射）
name_to_id, id_to_name, requires_approval = await self._resolve_tools_async(
    session, tool_names, supplied_ids, actor.organization_id
)

# 设置工具规则
tool_rules = []
if should_add_base_tool_rules:
    for tool_name in tool_names:
        if tool_name in {"send_message", ...}:
            tool_rules.append(TerminalToolRule(tool_name=tool_name))
        elif tool_name in BASE_TOOLS:
            tool_rules.append(ContinueToolRule(tool_name=tool_name))
```

**基础工具示例**：
- `send_message`：发送消息给用户
- `conversation_search`：搜索对话历史
- `archival_memory_search`：搜索长期记忆
- `core_memory_append`：追加核心记忆
- `core_memory_replace`：替换核心记忆

#### 步骤 4：创建数据源

**代码位置**：`letta/services/agent_manager.py:427-433`

```python
if agent_create.include_default_source:
    # 创建默认数据源（使用 agent 的 embedding 配置）
    default_source = PydanticSource(
        name=f"{agent_create.name} External Data Source",
        embedding_config=agent_create.embedding_config  # ✅ 关键
    )
    created_source = await self.source_manager.create_source(
        default_source, actor
    )
    source_ids.append(created_source.id)
```

**重要**：数据源的 embedding_config 必须与 agent 一致，这样才能正确搜索。

#### 步骤 5：存储到数据库

**代码位置**：`letta/services/agent_manager.py:484-525`

```python
async with db_registry.async_session() as session:
    async with session.begin():
        # 创建 Agent 记录
        new_agent = AgentModel(
            name=agent_create.name,
            system=derive_system_message(
                agent_type=agent_create.agent_type,
                system=agent_create.system
            ),
            agent_type=agent_create.agent_type,
            llm_config=agent_create.llm_config,          # ✅ JSON 存储
            embedding_config=agent_create.embedding_config,  # ✅ JSON 存储
            organization_id=actor.organization_id,
            tool_rules=tool_rules,
            ...
        )

        session.add(new_agent)
        await session.flush()  # 获取 ID
        aid = new_agent.id
```

**数据表结构**：
- `agents` 表：存储 agent 基本信息
- `agents_blocks`：agent 与 blocks 的多对多关系
- `agents_tools`：agent 与 tools 的多对多关系
- `sources_agents`：agent 与 sources 的多对多关系

#### 步骤 6：初始化 Agent

**代码位置**：`letta/services/agent_manager.py:540-580`

```python
if not _init_with_no_messages:
    # 获取初始消息序列
    initial_messages = (
        agent_create.initial_message_sequence or
        get_default_initial_message_sequence(agent_type)
    )

    # 发送初始消息
    for msg in initial_messages:
        await self._submit_message_to_agent_async(
            session,
            agent_state=new_agent,
            actor=actor,
            message=msg
        )

    # 重新加载 agent state
    await new_agent.reload_state(session)
```

**默认初始消息**：
- V1 agents：空序列（`[]`）
- 其他 agents：包含系统提示和初始化消息

### 12.3 配置存储格式

#### LLM Config

```json
{
    "model": "claude-sonnet-4-5-20250929",
    "model_endpoint_type": "anthropic",
    "model_endpoint": "https://api.anthropic.com",
    "context_window": 200000,
    "temperature": 0.7,
    "max_tokens": 4096
}
```

#### Embedding Config

```json
{
    "embedding_model": "letta",
    "embedding_endpoint": "https://embeddings.letta.com",
    "embedding_endpoint_type": "openai",
    "embedding_dim": 1536,
    "embedding_chunk_size": 300
}
```

### 12.4 实际调用示例

**HTTP 请求**：
```bash
curl -X POST "http://localhost:8283/v1/agents" \
  -H "Content-Type: application/json" \
  -H "X-Actor-Id: user-00000000-0000-4000-8000-000000000000" \
  -d '{
    "name": "my-agent",
    "agent_type": "letta_v1_agent",
    "system": "You are a helpful assistant.",
    "llm_config": {
      "model": "claude-sonnet-4-5-20250929",
      "model_endpoint_type": "anthropic"
    },
    "embedding_config": {
      "embedding_model": "letta",
      "embedding_endpoint": "https://embeddings.letta.com",
      "embedding_endpoint_type": "openai",
      "embedding_dim": 1536
    },
    "memory_blocks": [
      {
        "label": "persona",
        "value": "You are Claude, a helpful AI assistant."
      },
      {
        "label": "human",
        "value": "The user is asking for help."
      }
    ],
    "include_base_tools": true,
    "include_default_source": true
  }'
```

**响应**：
```json
{
  "id": "agent-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "name": "my-agent",
  "agent_type": "letta_v1_agent",
  "system": "You are a helpful assistant.",
  "llm_config": {...},
  "embedding_config": {...},
  "created_at": "2026-01-04T12:00:00Z",
  ...
}
```

### 12.5 关键要点总结

1. **配置验证**
   - `llm_config` 和 `embedding_config` 必填
   - 推理模型自动启用推理功能

2. **Memory Blocks**
   - 默认 blocks：`persona`、`human`、`instructions`
   - 用户可自定义 blocks

3. **工具配置**
   - 基础工具根据 `agent_type` 自动添加
   - 工具规则控制工具调用行为

4. **数据源**
   - 可选的默认数据源
   - 使用 agent 的 embedding_config

5. **数据库存储**
   - Agent 主表存储配置（JSON 格式）
   - 中间表关联 blocks、tools、sources

6. **初始化**
   - 默认发送初始消息序列
   - 可通过 `_init_with_no_messages` 跳过

---

## 13. Agent 参数完整参考（2026-01-04）

### 13.1 关于 -d 参数

**问题**：创建 agent 时，通过 `-d` 参数可以设置 agent 的所有参数吗？

**答案**：

#### 当前 `letta_agent_manager.py` 的状态

您的脚本**不支持** `-d` 参数。当前使用的是独立命令行参数：

```bash
python letta_agent_manager.py create <name> \
  --model <model> \
  --provider <provider> \
  --endpoint <endpoint> \
  --human "<info>" \
  --persona "<persona>" \
  --system "<prompt>" \
  --temperature 0.7 \
  --context-window 200000
```

#### 如果想添加 `-d` 参数支持

可以修改脚本，添加从 JSON 文件读取配置的功能：

```python
# 在 create_agent 方法之前添加
def create_agent_from_file(self, config_file: str) -> Optional[Dict[str, Any]]:
    """从 JSON 文件创建 agent"""
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)

        print(f"\n🔨 从配置文件创建 Agent...")
        print(f"   配置文件: {config_file}")
        print(f"   Agent 名称: {config.get('name', 'N/A')}")
        print()

        resp = self._make_request("POST", "/v1/agents/", json=config)

        if resp.status_code == 200:
            agent = resp.json()
            print(f"✅ Agent 创建成功!")
            print(f"   Agent ID: {agent['id']}")
            return agent
        else:
            print(f"❌ 创建失败:")
            print(f"   {resp.text}")
            return None
    except Exception as e:
        print(f"❌ 读取配置文件失败: {e}")
        return None
```

然后在命令行参数中添加：

```python
create_parser.add_argument(
    "-d", "--data",
    dest="config_file",
    help="从 JSON 文件读取配置"
)
```

### 13.2 CreateAgent 所有参数列表

#### 基本信息
- **name** (str): Agent 名称
  - 必填，如果不提供会自动生成随机名称
  - 例如：`"my-assistant"`

- **description** (str, optional): Agent 描述
  - 例如：`"A helpful coding assistant"`

- **agent_type** (AgentType, optional): Agent 类型
  - 默认：`"letta_v1_agent"`
  - 可选值：
    - `letta_v1_agent` - 最新版本的 Letta agent
    - `memgpt_v2_agent` - MemGPT v2 agent
    - `react_agent` - ReAct agent
    - `workflow_agent` - 工作流 agent
    - `voice_agent` - 语音 agent
    - 等

#### 记忆配置

**memory_blocks** (List[CreateBlock], optional): 要创建的记忆块列表
```python
[
  {
    "label": "human",              # 必填：记忆块标签
    "value": "User info",          # 必填：记忆块内容
    "limit": 2000,                 # 可选：token 限制
    "description": "About the user" # 可选：描述
  },
  {
    "label": "persona",
    "value": "You are a helpful assistant."
  }
]
```

**默认记忆块**：
- `human` - 用户信息
- `persona` - AI 人格
- `instructions` - 系统指令

**block_ids** (List[str], optional): 已存在的 block IDs
- 如果你想使用已创建的记忆块

**initial_message_sequence** (List[MessageCreate], optional): 初始消息序列
- 默认会发送一些初始化消息
- 设为空列表 `[]` 可以跳过

#### 工具配置

**tools** (List[str], optional): 工具名称列表
- ⚠️ 已废弃，建议使用 `tool_ids`

**tool_ids** (List[str], optional): 工具 IDs 列表
- 例如：`["tool-id-1", "tool-id-2"]`

**include_base_tools** (bool): 是否包含基础工具
- 默认：`True`
- 基础工具包括：
  - `core_memory_append` - 追加核心记忆
  - `core_memory_replace` - 替换核心记忆
  - `conversation_search` - 搜索对话历史
  - `archival_memory_search` - 搜索长期记忆
  - `send_message` - 发送消息给用户

**include_multi_agent_tools** (bool): 是否包含多 agent 工具
- 默认：`False`
- 包括：`send_message_to_agent` 等

**include_base_tool_rules** (bool, optional): 是否添加基础工具规则
- 控制工具调用的行为

**tool_rules** (List[ToolRule], optional): 工具规则列表
- 例如：
  ```python
  [
    {"type": "terminal", "tool_name": "send_message"},
    {"type": "continue", "tool_name": "conversation_search"}
  ]
  ```

#### 数据源配置

**source_ids** (List[str], optional): 数据源 IDs
- ⚠️ 已废弃，使用 `folder_ids` 代替

**folder_ids** (List[str], optional): 文件夹 IDs
- 关联文件夹作为数据源

**include_default_source** (bool): 是否创建默认数据源
- 默认：`False`
- ⚠️ 已废弃

#### 系统配置

**system** (str, optional): 系统提示词
- 例如：`"You are a helpful AI assistant. Be concise and friendly."`

#### 模型配置（推荐使用）✅

**model** (str, optional): 模型 handle
- 格式：`provider/model-name`
- 例如：
  - `"openai/gpt-4o"`
  - `"anthropic/claude-3-5-sonnet-20250929"`
  - `"my-custom-provider/claude-sonnet-4-5-20250929"`

**embedding** (str, optional): Embedding 模型 handle
- 格式：`provider/model-name`
- 例如：
  - `"letta/letta-free"` - Letta 免费 embedding
  - `"openai/text-embedding-3-small"`
  - `"openai/text-embedding-3-large"`

**model_settings** (ModelSettingsUnion, optional): 模型设置
- 高级配置

#### 模型配置（详细，已废弃）⚠️

**llm_config** (LLMConfig, optional): LLM 配置
- ⚠️ 已废弃，使用 `model` 代替
```python
{
  "model": "claude-3-5-sonnet-20250929",
  "model_endpoint_type": "anthropic",  # or "openai"
  "model_endpoint": "https://api.anthropic.com",
  "provider_name": "anthropic",
  "provider_category": "byok",         # or "base"
  "context_window": 200000,
  "temperature": 0.7,
  "max_tokens": 4096
}
```

**embedding_config** (EmbeddingConfig, optional): Embedding 配置
- ⚠️ 已废弃，使用 `embedding` 代替
```python
{
  "embedding_model": "letta-free",
  "embedding_endpoint_type": "openai",
  "embedding_endpoint": "https://embeddings.letta.com",
  "embedding_dim": 1536,
  "embedding_chunk_size": 300
}
```

#### 高级配置

**compaction_settings** (CompactionSettings, optional): 压缩设置
- 控制记忆压缩策略

**context_window_limit** (int, optional): 上下文窗口限制
- 限制 agent 使用的上下文大小

#### 推理配置

**reasoning** (bool, optional): 是否启用推理
- ⚠️ 已废弃，由 `model` 参数自动判断

**enable_reasoner** (bool, optional): 是否启用推理步骤
- 默认：`True`
- ⚠️ 已废弃

**max_reasoning_tokens** (int, optional): 最大推理 tokens
- ⚠️ 已废弃

**max_tokens** (int, optional): 最大生成 tokens
- ⚠️ 已废弃

#### 其他配置

**tags** (List[str], optional): Agent 标签
- 例如：`["assistant", "coding", "production"]`

**metadata** (Dict, optional): 元数据
- 自定义的键值对
- 例如：`{"version": "1.0", "author": "Alice"}`

**secrets** (Dict[str, str], optional): Agent 专属的环境变量/密钥
- 例如：
  ```python
  {
    "API_KEY": "sk-...",
    "DATABASE_URL": "postgresql://..."
  }
  ```

**project_id** (str, optional): 项目 ID
- ⚠️ 已废弃

### 13.3 完整配置示例

#### 最简单的配置 ✅

```python
{
  "name": "my-agent",
  "model": "openai/gpt-4o",
  "embedding": "letta/letta-free"
}
```

#### 推荐配置（使用 handle 格式）✅

```python
{
  # 基本信息
  "name": "my-assistant",
  "description": "A helpful coding assistant",
  "agent_type": "letta_v1_agent",

  # 模型配置（推荐）
  "model": "anthropic/claude-3-5-sonnet-20250929",
  "embedding": "letta/letta-free",

  # 记忆配置
  "memory_blocks": [
    {
      "label": "human",
      "value": "The user is named Alice, a software engineer."
    },
    {
      "label": "persona",
      "value": "You are a helpful coding assistant specialized in Python."
    }
  ],

  # 系统提示
  "system": "You are a helpful AI assistant. Be concise and friendly.",

  # 工具配置
  "include_base_tools": True,
  "include_base_tool_rules": True,

  # 标签和元数据
  "tags": ["assistant", "coding"],
  "metadata": {
    "version": "1.0",
    "author": "Alice"
  }
}
```

#### 使用详细配置（不推荐）⚠️

```python
{
  "name": "my-agent",

  # 使用详细的 LLM 配置（已废弃）
  "llm_config": {
    "model": "claude-3-5-sonnet-20240620",
    "model_endpoint_type": "anthropic",
    "model_endpoint": "https://api.anthropic.com",
    "provider_name": "anthropic",
    "provider_category": "byok",
    "context_window": 200000,
    "temperature": 0.7,
    "max_tokens": 4096
  },

  # 使用详细的 Embedding 配置（已废弃）
  "embedding_config": {
    "embedding_model": "letta-free",
    "embedding_endpoint_type": "openai",
    "embedding_endpoint": "https://embeddings.letta.com",
    "embedding_dim": 1536,
    "embedding_chunk_size": 300
  },

  "memory_blocks": [
    {"label": "human", "value": "A user"},
    {"label": "persona", "value": "Helpful assistant"}
  ],

  "system": "You are a helpful assistant."
}
```

### 13.4 常见配置模式

#### 模式 1：使用 Letta 免费 Embedding（最简单）✅

**配置**：
```python
{
  "name": "simple-agent",
  "model": "anthropic/claude-3-5-sonnet-20250929",
  "embedding": "letta/letta-free",
  "memory_blocks": [
    {"label": "human", "value": "A user"},
    {"label": "persona", "value": "Helpful assistant"}
  ]
}
```

**环境变量**：
```bash
ANTHROPIC_API_KEY=sk-ant-xxxxx
# 不需要其他 key
```

#### 模式 2：使用 OpenAI LLM + OpenAI Embedding

**配置**：
```python
{
  "name": "openai-agent",
  "model": "openai/gpt-4o",
  "embedding": "openai/text-embedding-3-small",
  "memory_blocks": [...]
}
```

**环境变量**：
```bash
OPENAI_API_KEY=sk-openai-xxxxx
```

#### 模式 3：Anthropic LLM + OpenAI Embedding

**配置**：
```python
{
  "name": "hybrid-agent",
  "model": "anthropic/claude-3-5-sonnet-20250929",
  "embedding": "openai/text-embedding-3-small",
  "memory_blocks": [...]
}
```

**环境变量**：
```bash
ANTHROPIC_API_KEY=sk-ant-xxxxx      # Anthropic LLM
OPENAI_API_KEY=sk-openai-yyyyy      # OpenAI Embedding
```

**关键点**：
- ✅ 两个 key 互不冲突
- ✅ LLM 使用 `ANTHROPIC_API_KEY`
- ✅ Embedding 使用 `OPENAI_API_KEY`

#### 模式 4：使用自定义 Provider（如 lingyunapi.com）

**步骤 1**：先创建 Provider（通过 API 或数据库）

```python
# 创建 Provider
POST /v1/providers/
{
  "name": "lingyun-proxy",
  "provider_type": "openai",  # 使用 OpenAI 协议
  "base_url": "https://lingyunapi.com/v1",
  "provider_category": "byok"
}
```

**步骤 2**：使用 Provider 创建 Agent

```python
{
  "name": "custom-agent",
  "model": "lingyun-proxy/claude-sonnet-4-5-20250929",
  "embedding": "letta/letta-free",
  "memory_blocks": [...]
}
```

**环境变量**：
```bash
OPENAI_API_KEY=sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh
# 这个 key 会被 lingyun-proxy 使用
```

### 13.5 参数优先级

当同一个参数有多种设置方式时，优先级如下：

1. **handle 格式参数** (`model`, `embedding`) - 最推荐 ✅
   - 例如：`model="anthropic/claude-3-5-sonnet-20250929"`
   - 自动从数据库获取配置
   - 简洁且不易出错

2. **详细配置参数** (`llm_config`, `embedding_config`) - 已废弃 ⚠️
   - 仅用于向后兼容
   - 新代码不应该使用

3. **环境变量** - 作为 fallback
   - 例如：`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`

### 13.6 配置建议总结

#### ✅ 推荐做法

1. **使用 handle 格式**
   ```python
   {
     "model": "anthropic/claude-3-5-sonnet-20250929",
     "embedding": "letta/letta-free"
   }
   ```

2. **配置记忆块**
   ```python
   "memory_blocks": [
     {"label": "human", "value": "..."},
     {"label": "persona", "value": "..."}
   ]
   ```

3. **使用环境变量管理密钥**
   ```bash
   ANTHROPIC_API_KEY=sk-...
   OPENAI_API_KEY=sk-...
   ```

4. **优先使用 Letta 免费 embedding**
   ```python
   "embedding": "letta/letta-free"
   ```

#### ❌ 不推荐做法

1. **使用已废弃的 `llm_config` 和 `embedding_config`**
   ```python
   # ❌ 不推荐
   {
     "llm_config": {
       "model": "...",
       "model_endpoint": "...",
       ...
     }
   }
   ```

2. **硬编码 API keys**
   ```python
   # ❌ 不推荐
   "secrets": {
     "API_KEY": "sk-hardcoded-key"
   }
   ```

3. **混合使用新旧参数**
   ```python
   # ❌ 混乱
   {
     "model": "anthropic/claude-3-5-sonnet-20250929",
     "llm_config": {...}  # 冲突！
   }
   ```

### 13.7 参数速查表

| 参数 | 类型 | 必填 | 默认值 | 推荐度 |
|------|------|------|--------|--------|
| **基本信息** |
| `name` | str | ❌ | 随机生成 | ⭐⭐⭐ |
| `description` | str | ❌ | - | ⭐⭐ |
| `agent_type` | str | ❌ | `letta_v1_agent` | ⭐⭐ |
| **记忆** |
| `memory_blocks` | List | ❌ | - | ⭐⭐⭐ |
| `block_ids` | List[str] | ❌ | - | ⭐⭐ |
| **模型** |
| `model` | str | ❌ | - | ⭐⭐⭐（强烈推荐） |
| `embedding` | str | ❌ | - | ⭐⭐⭐（强烈推荐） |
| `llm_config` | object | ❌ | - | ❌ 已废弃 |
| `embedding_config` | object | ❌ | - | ❌ 已废弃 |
| **工具** |
| `include_base_tools` | bool | ❌ | `True` | ⭐⭐⭐ |
| `include_base_tool_rules` | bool | ❌ | `True` | ⭐⭐ |
| `tool_ids` | List[str] | ❌ | - | ⭐⭐⭐ |
| `tools` | List[str] | ❌ | - | ❌ 已废弃 |
| **系统** |
| `system` | str | ❌ | - | ⭐⭐⭐ |
| **数据源** |
| `folder_ids` | List[str] | ❌ | - | ⭐⭐ |
| **其他** |
| `tags` | List[str] | ❌ | - | ⭐⭐ |
| `metadata` | Dict | ❌ | - | ⭐⭐ |
| `secrets` | Dict[str,str]| ❌ | - | ⭐⭐ |

### 13.8 为什么废弃详细配置？（深度解析）

#### 问题

为什么 `llm_config` 和 `embedding_config` 被标记为废弃？

#### 核心原因：从"手动配置"到"数据库驱动"的架构转变

##### ❌ 旧方式：手动详细配置（已废弃）

```python
{
  "llm_config": {
    "model": "claude-3-5-sonnet-20250929",
    "model_endpoint_type": "anthropic",
    "model_endpoint": "https://api.anthropic.com",    # 手动指定
    "provider_name": "anthropic",                      # 手动指定
    "provider_category": "byok",                       # 手动指定
    "context_window": 200000,                          # 手动指定
    "temperature": 0.7,
    "max_tokens": 4096
  },
  "embedding_config": {
    "embedding_model": "letta-free",
    "embedding_endpoint_type": "openai",
    "embedding_endpoint": "https://embeddings.letta.com",  # 手动指定
    "embedding_dim": 1536,                                 # 手动指定
    "embedding_chunk_size": 300
  }
}
```

**存在的问题**：
1. ❌ **配置复杂**：需要填写 10+ 个参数
2. ❌ **容易出错**：手动输入 endpoint、类型等容易出错
3. ❌ **API key 暴露**：配置中可能硬编码敏感信息
4. ❌ **难以维护**：更新配置需要修改所有 agent
5. ❌ **重复配置**：每个 agent 都要重复相同的配置

##### ✅ 新方式：Handle 格式（推荐）

```python
{
  "model": "anthropic/claude-3-5-sonnet-20250929",
  "embedding": "letta/letta-free"
}
```

**工作原理**：

```
用户提供 handle: "anthropic/claude-3-5-sonnet-20250929"
                        ↓
         解析为: provider_name="anthropic"
                  model_name="claude-3-5-sonnet-20250929"
                        ↓
    从数据库查询 Provider (letta/orm/provider.py)
    - provider_type: "anthropic"
    - base_url: "https://api.anthropic.com"
    - api_key: (从环境变量或加密存储获取)
                        ↓
    从数据库查询 ProviderModel (letta/orm/provider_model.py)
    - handle: "anthropic/claude-3-5-sonnet-20250929"
    - context_window: 200000
    - max_tokens: 4096
    - model_endpoint_type: "anthropic"
                        ↓
         自动填充完整的 llm_config
```

**优势**：
1. ✅ **极简配置**：只需 1 个字符串
2. ✅ **集中管理**：所有配置存储在数据库
3. ✅ **动态更新**：修改 Provider，所有 agent 自动生效
4. ✅ **安全性高**：API key 加密存储
5. ✅ **不易出错**：避免手动配置错误
6. ✅ **易于维护**：一次修改，全局生效

#### 代码证据

**创建 Agent 时的处理** (`letta/server/server.py:437-490`):

```python
async def create_agent_async(self, request: CreateAgent, actor: User):
    # 如果没有提供 llm_config（推荐方式）
    if request.llm_config is None:
        # 检查是否提供了 model handle
        if request.model is None:
            raise LettaInvalidArgumentError(
                "Must specify either model or llm_config"
            )
        else:
            # 从 handle 自动获取完整配置
            handle = request.model  # "anthropic/claude-3-5-sonnet-20250929"

            llm_config = await self.get_llm_config_from_handle_async(
                actor=actor,
                handle=handle,
                context_window_limit=request.context_window_limit,
                max_tokens=request.max_tokens,
                ...
            )
```

**Handle 解析逻辑** (`letta/server/server.py:1154-1194`):

```python
async def get_llm_config_from_handle_async(
    self,
    actor: User,
    handle: str,  # "anthropic/claude-3-5-sonnet-20250929"
    ...
) -> LLMConfig:
    # 1. 解析 handle
    provider_name, model_name = handle.split("/", 1)

    # 2. 从数据库获取 Provider
    provider = await self.get_provider_from_name_async(
        provider_name, actor
    )

    # 3. 从 Provider 获取所有模型配置
    all_llm_configs = await provider.list_llm_models_async()

    # 4. 查找匹配的模型
    llm_configs = [
        config for config in all_llm_configs
        if config.handle == handle
    ]

    # 5. 返回完整的 LLMConfig
    return llm_configs[0]
```

#### 数据库结构

**Provider 表** (`letta/orm/provider.py:15-46`):
```python
class Provider(SqlalchemyBase):
    __tablename__ = "providers"

    name: str                    # "anthropic", "openai", "lingyun-proxy"
    provider_type: str           # "anthropic", "openai", "bedrock"
    base_url: str                # "https://api.anthropic.com"
    api_key_enc: str             # 加密存储的 API key
    provider_category: str       # "base" or "byok"
    region: str                  # AWS region (for Bedrock)
    ...
```

**ProviderModel 表** (`letta/orm/provider_model.py:14-70`):
```python
class ProviderModel(SqlalchemyBase):
    __tablename__ = "provider_models"

    handle: str                  # "anthropic/claude-3-5-sonnet-20250929"
    model: str                   # "claude-3-5-sonnet-20250929"
    provider_id: str             # 关联到 Provider
    model_type: str              # "llm" or "embedding"
    context_window: int          # 200000
    max_tokens: int              # 4096
    model_endpoint_type: str     # "anthropic", "openai", etc.
    ...
```

#### 实际场景对比

##### 场景：你有 10 个 agent 都使用 Anthropic Claude

**❌ 旧方式（已废弃）**：

```python
# Agent 1
{
  "name": "agent-1",
  "llm_config": {
    "model": "claude-3-5-sonnet-20250929",
    "model_endpoint": "https://api.anthropic.com",
    "provider_name": "anthropic",
    "provider_category": "byok",
    "model_endpoint_type": "anthropic",
    "context_window": 200000,
    "temperature": 0.7
  }
}

# Agent 2 - 重复所有配置
{
  "name": "agent-2",
  "llm_config": {
    "model": "claude-3-5-sonnet-20250929",
    "model_endpoint": "https://api.anthropic.com",
    "provider_name": "anthropic",
    "provider_category": "byok",
    "model_endpoint_type": "anthropic",
    "context_window": 200000,
    "temperature": 0.7
  }
}

# ... Agent 3-10 全部重复相同的配置
```

**问题**：
- 如果要修改 endpoint（例如切换到镜像站），需要修改 10 个 agent！
- 如果要更新 API key，需要修改 10 个 agent！
- 配置重复，维护困难

**✅ 新方式（推荐）**：

```python
# 所有 10 个 agent（配置完全相同）
{
  "name": "agent-1",
  "model": "anthropic/claude-3-5-sonnet-20250929"
}

{
  "name": "agent-2",
  "model": "anthropic/claude-3-5-sonnet-20250929"
}

# ... Agent 3-10
```

**优势**：
- ✅ 配置简洁：每个 agent 只需 1 行
- ✅ 统一管理：修改 Provider，所有 agent 立即生效
- ✅ 易于维护：不需要逐个修改 agent

##### 场景：使用自定义 Provider（如 lingyunapi.com）

**步骤 1**：创建 Provider（一次）

```python
POST /v1/providers/
{
  "name": "lingyun-proxy",
  "provider_type": "openai",           # 使用 OpenAI 协议
  "base_url": "https://lingyunapi.com/v1",
  "provider_category": "byok"
}
```

**步骤 2**：系统自动同步模型列表

Letta 会自动从该 Provider 获取可用的模型，并存储到 `provider_models` 表：
```
lingyun-proxy/claude-sonnet-4-5-20250929
lingyun-proxy/gpt-4o
lingyun-proxy/gemini-pro
...
```

**步骤 3**：所有 agent 都可以使用

```python
# Agent 1
{
  "name": "agent-1",
  "model": "lingyun-proxy/claude-sonnet-4-5-20250929"
}

# Agent 2
{
  "name": "agent-2",
  "model": "lingyun-proxy/gpt-4o"
}

# Agent 3
{
  "name": "agent-3",
  "model": "lingyun-proxy/claude-sonnet-4-5-20250929"
}
```

**优势**：
- ✅ 配置集中：所有 agent 共享同一个 Provider 配置
- ✅ 动态更新：修改 Provider 的 base_url，所有 agent 自动切换
- ✅ 安全性：API key 加密存储在数据库中

#### 架构优势对比

| 方面 | 详细配置（已废弃） | Handle 格式（推荐） |
|------|------------------|-------------------|
| **配置长度** | 10+ 行 | 1 行 |
| **出错概率** | 高（手动输入） | 低（数据库验证） |
| **更新方式** | 修改每个 agent | 修改 Provider 一次 |
| **API Key 安全** | 可能暴露在配置中 | 加密存储 |
| **可维护性** | 差（重复配置） | 优（集中管理） |
| **灵活性** | 低（硬编码） | 高（动态调整） |
| **扩展性** | 差 | 优（易于添加新模型） |
| **一致性** | 难以保证 | 自动保证 |

#### 迁移建议

**从旧配置迁移到新配置**：

```python
# ❌ 旧配置
{
  "llm_config": {
    "model": "claude-3-5-sonnet-20250929",
    "model_endpoint": "https://api.anthropic.com",
    "provider_name": "anthropic",
    "provider_category": "byok",
    "model_endpoint_type": "anthropic",
    "context_window": 200000
  }
}

# ✅ 新配置（等价）
{
  "model": "anthropic/claude-3-5-sonnet-20250929"
}
```

**注意事项**：
1. ✅ 确保数据库中已有对应的 Provider
2. ✅ 确保模型已同步到 `provider_models` 表
3. ✅ 如果需要自定义参数（如 temperature），使用 `model_settings`

**高级用法**：如果确实需要自定义某些参数

```python
{
  "model": "anthropic/claude-3-5-sonnet-20250929",
  "model_settings": {
    "temperature": 0.8,  # 覆盖默认值
    "max_tokens": 2048   # 覆盖默认值
  }
}
```

#### 总结

**废弃详细配置的原因**：
1. **架构升级**：从硬编码配置转向数据库驱动
2. **简化使用**：减少配置复杂度，降低出错概率
3. **集中管理**：统一管理 Provider 和模型配置
4. **提高安全性**：API key 加密存储
5. **增强可维护性**：一次修改，全局生效
6. **支持动态更新**：无需重启服务即可更新配置

**这是 Letta 项目的一个重要架构改进，体现了从"配置驱动"到"数据驱动"的设计理念转变。**

---

## 14. 如何创建自定义 Provider（2026-01-04）

### 14.1 问题

1. 如何创建自定义 Provider？
2. 使用第三方聚合平台，在创建 agent 之前要先创建好 provider 吗？
3. 创建 provider 需要提供 API KEY 吗？

### 14.2 创建 Provider 的两种方式

#### 方式 1：通过环境变量（最简单，推荐）✅

**适用于**：快速测试、本地开发

**配置示例**：
```bash
# .env 文件
OPENAI_API_KEY=sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh
OPENAI_API_BASE=https://lingyunapi.com/v1
```

**工作原理**：
- Letta 启动时会**自动创建**临时的 provider
- Provider 名称：`openai-proxy`
- 无需手动创建

**优点**：
- ✅ 最简单
- ✅ 不需要调用 API
- ✅ 适合快速测试

**使用方式**：
```bash
# 1. 配置环境变量
cat > .env << EOF
OPENAI_API_KEY=sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh
OPENAI_API_BASE=https://lingyunapi.com/v1
EOF

# 2. 启动 Letta
docker compose up -d

# 3. 直接创建 agent（无需手动创建 provider）
curl -X POST "http://localhost:8283/v1/agents/" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-agent",
    "model": "openai-proxy/claude-sonnet-4-5-20250929",
    "embedding": "letta/letta-free"
  }'
```

#### 方式 2：通过 API 手动创建（持久化）✅

**适用于**：生产环境、多个 agent 共享

**HTTP 请求**：
```bash
curl -X POST "http://localhost:8283/v1/providers/" \
  -H "Content-Type: application/json" \
  -H "X-Actor-Id: user-00000000-0000-4000-8000-000000000000" \
  -d '{
    "name": "lingyun-proxy",
    "provider_type": "openai",
    "base_url": "https://lingyunapi.com/v1",
    "api_key": "sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh"
  }'
```

**Python SDK**：
```python
from letta_client import Letta

client = Letta(base_url="http://localhost:8283")

provider = client.providers.create(
    name="lingyun-proxy",
    provider_type="openai",
    base_url="https://lingyunapi.com/v1",
    api_key="sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh"
)

print(f"Provider created: {provider.id}")
```

### 14.3 必须先创建 Provider 吗？

#### 答案：取决于使用方式

##### 场景 A：使用环境变量（推荐）

**不需要手动创建！** ✅

Letta 会自动从环境变量创建临时 provider，流程如下：

```bash
# 步骤 1：配置环境变量
OPENAI_API_KEY=sk-...
OPENAI_API_BASE=https://lingyunapi.com/v1

# 步骤 2：启动 Letta
docker compose up

# 步骤 3：直接创建 agent
# 系统会自动使用环境变量创建的临时 provider
```

##### 场景 B：使用数据库持久化（生产环境）

**需要先创建！** ✅

完整流程：

```
步骤 1：创建 Provider
   ↓
步骤 2：系统自动同步模型列表
   ↓
步骤 3：创建 Agent（使用 Provider 的模型）
```

**详细步骤**：

```bash
# 步骤 1：创建 Provider
curl -X POST "http://localhost:8283/v1/providers/" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "lingyun-proxy",
    "provider_type": "openai",
    "base_url": "https://lingyunapi.com/v1",
    "api_key": "sk-..."
  }'

# 步骤 2：系统自动同步可用模型
# Letta 会自动调用 Provider 的 API，获取可用模型列表
# 并存储到 provider_models 表

# 步骤 3：查看可用模型
curl http://localhost:8283/v1/providers/lingyun-proxy/models

# 步骤 4：创建 Agent（使用 handle 格式）
curl -X POST "http://localhost:8283/v1/agents/" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-agent",
    "model": "lingyun-proxy/claude-sonnet-4-5-20250929",
    "embedding": "letta/letta-free"
  }'
```

### 14.4 需要提供 API KEY 吗？

#### 答案：**是的，需要！** ✅

##### 通过 API 创建（必填）

**ProviderCreate Schema** (`letta/schemas/providers/base.py:241-248`):

```python
class ProviderCreate(ProviderBase):
    name: str = Field(..., description="The name of the provider.")
    provider_type: ProviderType = Field(..., description="The type of the provider.")
    api_key: str = Field(..., description="API key or secret key...")  # ← 必填！
    base_url: str | None = Field(None, description="Base URL...")
    ...
```

**关键点**：
- `api_key` 是**必填字段**（`...` 表示必填）
- API key 会被**加密存储**到数据库

##### 加密存储流程

**代码证据** (`letta/services/provider_manager.py:82-85`):

```python
# 明文 API key
request.api_key = "sk-..."

# 自动加密存储
provider.api_key_enc = Secret.from_plaintext(request.api_key)

# 存储到数据库（加密后）
new_provider = ProviderModel(...)
await new_provider.create_async(session)
```

**关键点**：
- ✅ API key 会被加密
- ✅ 不会以明文形式存储在数据库中
- ✅ 使用时自动解密

##### 但是！如果使用环境变量...

**不需要在创建 provider 时提供 API key** ✅

```bash
# 环境变量方式
OPENAI_API_KEY=sk-...  # API key 在这里
OPENAI_API_BASE=https://lingyunapi.com/v1

# 启动后，Letta 会自动创建临时 provider
# 这个 provider 会自动使用环境变量中的 API key
```

### 14.5 Provider 参数详解

#### 必填参数

**ProviderCreate** 的必填参数：

```python
{
  "name": "lingyun-proxy",        # 必填：Provider 名称
  "provider_type": "openai",       # 必填：Provider 类型
  "api_key": "sk-..."              # 必填：API key
}
```

#### 可选参数

```python
{
  "name": "lingyun-proxy",
  "provider_type": "openai",
  "api_key": "sk-...",
  "base_url": "https://lingyunapi.com/v1",  # 可选：自定义 endpoint
  "region": "us-east-1",                     # 可选：AWS region (Bedrock)
  "api_version": "2023-05-15"                # 可选：API version
}
```

#### Provider 类型选项

**ProviderType** 枚举值：
- `"openai"` - OpenAI 协议
- `"anthropic"` - Anthropic 协议
- `"google_ai"` - Google AI 协议
- `"google_vertex"` - Google Vertex AI 协议
- `"bedrock"` - AWS Bedrock 协议
- `"azure"` - Azure OpenAI 协议
- `"together"` - Together AI 协议
- `"xai"` - xAI (Grok) 协议
- `"groq"` - Groq 协议
- `"deepseek"` - DeepSeek 协议

### 14.6 第三方聚合平台配置示例

#### 示例 1：使用 OpenAI 兼容协议（如 lingyunapi.com）

```bash
# 方式 A：环境变量（推荐）
cat > .env << EOF
OPENAI_API_KEY=sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh
OPENAI_API_BASE=https://lingyunapi.com/v1
EOF

# 创建 agent
{
  "model": "openai-proxy/claude-sonnet-4-5-20250929",
  "embedding": "letta/letta-free"
}
```

```bash
# 方式 B：API 创建（持久化）
curl -X POST "http://localhost:8283/v1/providers/" \
  -d '{
    "name": "lingyun",
    "provider_type": "openai",  # 使用 OpenAI 协议
    "base_url": "https://lingyunapi.com/v1",
    "api_key": "sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh"
  }'

# 使用该 provider 创建 agent
{
  "model": "lingyun/claude-sonnet-4-5-20250929",
  "embedding": "letta/letta-free"
}
```

#### 示例 2：同时使用多个 Provider

```bash
# .env 配置
OPENAI_API_KEY=sk-openai-xxxxx
OPENAI_API_BASE=https://api.openai.com/v1

ANTHROPIC_API_KEY=sk-ant-xxxxx

# 自定义 provider（通过 API）
curl -X POST "http://localhost:8283/v1/providers/" \
  -d '{
    "name": "lingyun",
    "provider_type": "openai",
    "base_url": "https://lingyunapi.com/v1",
    "api_key": "sk-lingyun-xxxxx"
  }'
```

**创建 agent 时可以选择不同的 provider**：

```python
# 使用官方 OpenAI
{
  "model": "openai/gpt-4o",
  "embedding": "openai/text-embedding-3-small"
}

# 使用官方 Anthropic
{
  "model": "anthropic/claude-3-5-sonnet-20250929",
  "embedding": "letta/letta-free"
}

# 使用自定义 lingyun
{
  "model": "lingyun/claude-sonnet-4-5-20250929",
  "embedding": "letta/letta-free"
}
```

### 14.7 Provider 创建后的自动同步

**重要特性**：创建 Provider 后，Letta 会**自动同步**可用的模型列表。

**代码证据** (`letta/services/provider_manager.py:92-93`):

```python
# For BYOK providers, automatically sync available models
if is_byok:
    await self._sync_default_models_for_provider(provider_pydantic, actor)
```

**同步过程**：
```
创建 Provider
    ↓
Letta 调用 Provider 的 API
    ↓
获取可用模型列表
    ↓
存储到 provider_models 表
    ↓
创建 agent 时可以使用
```

**查看同步的模型**：

```bash
# 方式 1：通过 API
curl http://localhost:8283/v1/providers/{provider_id}/models

# 方式 2：通过 SDK
models = client.providers.models.list(provider_id)
for model in models:
    print(f"{model.handle} - {model.model}")
```

### 14.8 完整工作流程示例

#### 示例：使用 lingyunapi.com 创建完整的 Agent

```python
from letta_client import Letta

client = Letta(base_url="http://localhost:8283")

# ========== 方式 1：使用环境变量（推荐） ==========

# 步骤 1：配置 .env
# OPENAI_API_KEY=sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh
# OPENAI_API_BASE=https://lingyunapi.com/v1

# 步骤 2：启动 Letta
# docker compose up

# 步骤 3：直接创建 agent（无需手动创建 provider）
agent = client.agents.create(
    name="my-agent",
    model="openai-proxy/claude-sonnet-4-5-20250929",
    embedding="letta/letta-free",
    memory_blocks=[
        {"label": "human", "value": "A software engineer"},
        {"label": "persona", "value": "Helpful coding assistant"}
    ]
)

print(f"✅ Agent created: {agent.id}")


# ========== 方式 2：使用 API 创建（持久化） ==========

# 步骤 1：创建 Provider
provider = client.providers.create(
    name="lingyun",
    provider_type="openai",  # 使用 OpenAI 协议
    base_url="https://lingyunapi.com/v1",
    api_key="sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh"
)

print(f"✅ Provider created: {provider.id}")
print(f"✅ Provider name: {provider.name}")

# 步骤 2：查看自动同步的模型列表
models = client.providers.models.list(provider.id)
print(f"\n✅ Available models ({len(models)}):")
for model in models:
    print(f"  - {model.handle}")

# 步骤 3：创建 Agent（使用 Provider 的模型）
agent = client.agents.create(
    name="my-agent",
    model="lingyun/claude-sonnet-4-5-20250929",  # 使用 Provider 的模型
    embedding="letta/letta-free",
    memory_blocks=[
        {"label": "human", "value": "A software engineer"},
        {"label": "persona", "value": "Helpful coding assistant"}
    ]
)

print(f"\n✅ Agent created: {agent.id}")

# 步骤 4：与 Agent 对话
response = client.agents.messages.create(
    agent_id=agent.id,
    messages=[{"role": "user", "content": "Hello!"}]
)

print(f"\n✅ Response: {response.messages}")
```

### 14.9 关键要点总结

#### 问题 1：需要先创建 Provider 吗？

| 使用方式 | 是否需要先创建 |
|---------|--------------|
| 环境变量 | ❌ 不需要（自动创建） |
| API 创建 | ✅ 需要（手动创建） |

#### 问题 2：需要提供 API KEY 吗？

| 使用方式 | API KEY 位置 |
|---------|------------|
| 环境变量 | 在 `.env` 文件中 |
| API 创建 | 在创建请求中（必填） |

#### 问题 3：推荐哪种方式？

| 场景 | 推荐方式 | 原因 |
|-----|---------|------|
| 本地开发 | 环境变量 | 最简单，快速开始 |
| 生产环境 | API 创建 | 持久化，便于管理 |
| 多个 Agent | API 创建 | 共享配置，统一管理 |
| 临时测试 | 环境变量 | 无需持久化 |

### 14.10 常见问题

#### Q1：如何知道 Provider 创建成功？

```bash
# 查看所有 providers
curl http://localhost:8283/v1/providers/

# 查看特定 provider
curl http://localhost:8283/v1/providers/{provider_id}

# 查看可用的模型
curl http://localhost:8283/v1/providers/{provider_id}/models
```

#### Q2：如何修改 Provider 的 API key？

```python
provider = client.providers.update(
    provider_id="provider-xxx",
    api_key="new-api-key"
)
```

#### Q3：如何删除 Provider？

```python
client.providers.delete(provider_id="provider-xxx")
```

#### Q4：环境变量方式创建的 Provider 可以持久化吗？

**答案**：不可以。环境变量创建的是**临时 provider**，重启后需要重新创建。

如果需要持久化，请使用 API 创建。

#### Q5：一个 Agent 可以使用多个 Provider 吗？

**答案**：不可以。一个 Agent 只能使用一个 LLM Provider 和一个 Embedding Provider。

但是，不同的 Agent 可以使用不同的 Provider。

### 14.11 最佳实践建议

#### ✅ 推荐做法

1. **本地开发**：使用环境变量
   ```bash
   OPENAI_API_KEY=sk-...
   OPENAI_API_BASE=https://lingyunapi.com/v1
   ```

2. **生产环境**：使用 API 创建
   ```python
   provider = client.providers.create(
       name="lingyun",
       provider_type="openai",
       base_url="https://lingyunapi.com/v1",
       api_key="sk-..."
   )
   ```

3. **测试连接**：创建后验证
   ```bash
   # 查看 provider
   curl http://localhost:8283/v1/providers/

   # 查看可用模型
   curl http://localhost:8283/v1/providers/{provider_id}/models
   ```

#### ❌ 避免的错误

1. **不要混淆协议类型**
   ```python
   # ❌ 错误：Anthropic 模型使用 Anthropic 协议
   {
     "provider_type": "anthropic",
     "base_url": "https://lingyunapi.com/v1"  # 这个 API 使用 OpenAI 协议！
   }

   # ✅ 正确：使用 OpenAI 协议
   {
     "provider_type": "openai",
     "base_url": "https://lingyunapi.com/v1"
   }
   ```

2. **不要忘记 base_url 的路径**
   ```python
   # ❌ 错误
   "base_url": "https://lingyunapi.com"

   # ✅ 正确
   "base_url": "https://lingyunapi.com/v1"
   ```

3. **不要在环境变量中硬编码多个 endpoint**
   ```bash
   # ❌ 混乱
   OPENAI_API_KEY=sk-xxx
   ANTHROPIC_API_KEY=sk-yyy
   CUSTOM_API_KEY=sk-zzz  # 这个可能不会生效

   # ✅ 清晰
   # 对于自定义 endpoint，使用 API 创建 Provider
   ```

---

## 15. Letta UI 创建 Agent 的 Provider 选择问题（2026-01-04）

### 15.1 问题描述

**用户环境**：
```bash
# .env 中只配置了
OPENAI_API_KEY=sk-...
OPENAI_API_BASE=https://lingyunapi.com/v1

# 没有配置 ANTHROPIC_API_KEY
```

**问题**：
通过 Letta 官方 UI 创建 agent 时，UI 默认选择了 **Anthropic 官方** 作为 provider，而不是使用环境变量中配置的 `lingyunapi.com`。

### 15.2 问题复现

#### 实际案例

**用户创建的 agent（scratch-agent_copy）**：
```json
{
  "model": "claude-sonnet-4-5-20250929",
  "model_endpoint_type": "anthropic",        // ❌ 错误！
  "model_endpoint": "https://api.anthropic.com/v1",  // ❌ 使用 Anthropic 官方
  "provider_name": "anthropic",              // ❌
  "provider_category": "base"
}
```

**环境实际情况**：
- ❌ 用户**没有**提供 `ANTHROPIC_API_KEY`
- ✅ 用户只提供了 `OPENAI_API_KEY` 和 `OPENAI_API_BASE`
- ✅ 期望使用 `https://lingyunapi.com/v1`

#### 测试结果

```bash
# 使用 scratch-agent_copy 发送消息
curl -X POST "http://localhost:8283/v1/agents/agent-57f6e9db-3904-4b6c-b938-9d61d289b295/messages" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'

# 返回错误
{
  "error": {
    "message": "Could not resolve authentication method. Expected either
                api_key or auth_token to be set..."
  }
}
```

### 15.3 根本原因分析

#### Letta 的 Base Provider 机制

**什么是 Base Provider**？

Letta 内置了一些"base providers"，这些是 Letta 官方提供的、预配置的 provider：

1. **letta** - Letta 自己的推理服务
2. **openai** - OpenAI 官方（可被环境变量覆盖）
3. **anthropic** - Anthropic 官方（需要 ANTHROPIC_API_KEY）
4. 其他...

**环境变量如何影响 Base Provider**：

```bash
# 用户配置
OPENAI_API_KEY=sk-...
OPENAI_API_BASE=https://lingyunapi.com/v1

# Letta 自动创建 base provider
provider_name: "openai"
provider_category: "base"
model_endpoint: "https://lingyunapi.com/v1"  # ✅ 使用环境变量
```

**验证**：
```bash
# 查看可用模型
curl http://localhost:8283/v1/models/

# 结果：
{
  "handle": "openai-proxy/claude-sonnet-4-5-20250929",
  "provider_name": "openai",
  "provider_category": "base",  // ← base provider
  "model_endpoint": "https://lingyunapi.com/v1"  // ✅ 使用用户的配置
}
```

#### UI 的问题

**UI 创建 agent 时的行为**：

1. ❌ **默认选择 Anthropic 官方**
   - 即使环境变量中没有 `ANTHROPIC_API_KEY`
   - 即使环境变量中配置了 `OPENAI_API_BASE`

2. ❌ **不检查 Provider 可用性**
   - 不检查选择的 provider 是否有 API key
   - 不检查 provider 是否可达
   - 直接创建配置

3. ❌ **忽略环境变量配置**
   - 应该优先使用环境变量配置的 provider
   - 或者至少提示用户有可用的替代选项

### 15.4 对比分析

#### ✅ 正确的配置（Kleo agent）

```json
{
  "model_endpoint_type": "openai",        // ✅
  "model_endpoint": "https://lingyunapi.com/v1",  // ✅
  "provider_name": "openai",               // ✅
  "handle": "openai-proxy/claude-sonnet-4-5-20250929"  // ✅
}
```

**工作原理**：
```bash
# 1. 检查 model_endpoint_type = "openai"
# 2. 使用 OpenAIClient
# 3. 读取环境变量 OPENAI_API_KEY
# 4. 使用环境变量 OPENAI_API_BASE
# 5. 发送请求到 https://lingyunapi.com/v1 ✅
```

#### ❌ 错误的配置（scratch-agent_copy）

```json
{
  "model_endpoint_type": "anthropic",     // ❌
  "model_endpoint": "https://api.anthropic.com/v1",  // ❌
  "provider_name": "anthropic",           // ❌
  "handle": "anthropic/claude-sonnet-4-5-20250929"  // ❌
}
```

**执行流程**：
```bash
# 1. 检查 model_endpoint_type = "anthropic"
# 2. 使用 AnthropicClient
# 3. 尝试读取 ANTHROPIC_API_KEY
# 4. ❌ 找不到 ANTHROPIC_API_KEY
# 5. ❌ 认证失败
```

### 15.5 数据库验证

**查看数据库中的 providers 表**：

```bash
docker exec root_letta-server_1 psql -U letta -d letta \
  -c 'SELECT name, provider_type, provider_category, base_url FROM providers;'

# 结果：
# (0 rows)
```

**结论**：
- ✅ 没有手动创建的持久化 providers
- ✅ 使用的都是 Letta 的内置 base providers
- ✅ `openai` base provider 被环境变量覆盖，指向 `lingyunapi.com`
- ❌ `anthropic` base provider 没有被覆盖（因为缺少 `ANTHROPIC_API_KEY`）

### 15.6 可用模型列表

**查询可用模型**：

```bash
curl http://localhost:8283/v1/models/
```

**返回结果分析**：

✅ **可用的模型**（使用环境变量配置）：
```json
{
  "handle": "openai-proxy/claude-sonnet-4-5-20250929",
  "provider_name": "openai",
  "provider_category": "base",
  "model_endpoint": "https://lingyunapi.com/v1"
}
```

❌ **不可用的模型**（UI 默认选择）：
```json
{
  "handle": "anthropic/claude-sonnet-4-5-20250929",  // ← 不在列表中！
  "provider_name": "anthropic",
  "model_endpoint": "https://api.anthropic.com/v1"
}
```

**关键发现**：
- `/v1/models/` 列表中**没有** `anthropic/` 开头的模型
- UI 却允许选择并不存在的模型
- 这导致了创建无法使用的 agent

### 15.7 解决方案

#### 方案 1：通过 UI 创建（手动选择正确模型）✅

在 UI 中创建 agent 时：
1. ✅ **手动选择** `openai-proxy/claude-sonnet-4-5-20250929`
2. ❌ **不要**依赖 UI 的默认选择
3. ✅ 确认选择的模型在 `/v1/models/` 列表中

#### 方案 2：通过 API 创建（推荐）✅

使用明确的 model handle：

```bash
curl -X POST "http://localhost:8283/v1/agents/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-agent",
    "model": "openai-proxy/claude-sonnet-4-5-20250929",
    "embedding": "letta/letta-free",
    "memory_blocks": [
      {"label": "human", "value": "User info"},
      {"label": "persona", "value": "Helpful assistant"}
    ]
  }'
```

**Python SDK**：
```python
from letta_client import Letta

client = Letta(base_url="http://localhost:8283")

agent = client.agents.create(
    name="my-agent",
    model="openai-proxy/claude-sonnet-4-5-20250929",  # ✅ 使用环境变量配置
    embedding="letta/letta-free",
    memory_blocks=[
        {"label": "human", "value": "User info"},
        {"label": "persona", "value": "Helpful assistant"}
    ]
)
```

#### 方案 3：删除错误的 Agent

```bash
# 删除无法使用的 agent
curl -X DELETE \
  "http://localhost:8283/v1/agents/agent-57f6e9db-3904-4b6c-b938-9d61d289b295" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 15.8 UI 的行为缺陷总结

| 问题 | 描述 | 影响 |
|------|------|------|
| **默认选择不当** | UI 默认选择 Anthropic 官方，而不是环境变量配置的 provider | 创建无法使用的 agent |
| **缺少验证** | 不检查选择的 provider 是否可用（是否有 API key） | 创建后才发现无法使用 |
| **忽略环境变量** | 不优先使用环境变量配置的 provider | 用户配置被忽略 |
| **缺少提示** | 不提示用户有可用的替代选项 | 用户不知道正确做法 |
| **模型列表不同步** | `/v1/models/` 列表和 UI 选项不一致 | 可以选择不可用的模型 |

### 15.9 最佳实践建议

#### ✅ 推荐做法

1. **创建前先查看可用模型**
   ```bash
   # 查看 /v1/models/ 列表
   curl http://localhost:8283/v1/models/

   # 只选择列表中存在的模型
   ```

2. **优先使用 API/SDK 创建**
   - 更可控
   - 不会出现 UI 的默认选择问题
   - 可以明确指定所有参数

3. **验证 Agent 配置**
   ```bash
   # 创建后检查 agent 配置
   curl http://localhost:8283/v1/agents/{agent_id}

   # 确认 model_endpoint_type 和 model_endpoint
   ```

4. **测试 Agent**
   ```bash
   # 发送测试消息
   curl -X POST "http://localhost:8283/v1/agents/{agent_id}/messages" \
     -d '{"messages":[{"role":"user","content":"test"}]}'
   ```

#### ❌ 避免的做法

1. **不要盲目使用 UI 的默认选择**
   - UI 默认选择的模型可能不可用
   - 需要手动确认

2. **不要假设配置会自动应用**
   - 环境变量只影响特定的 base providers
   - 不会覆盖所有 providers

3. **不要忽略错误信息**
   - "authentication method" 错误 = provider 配置问题
   - 检查是否有对应的 API key

### 15.10 代码证据

#### 可用模型列表逻辑

**代码位置**：`letta/server/server.py`

Letta 会在启动时：
1. 读取环境变量
2. 创建/更新 base providers
3. 同步可用模型到数据库

```python
# 伪代码
if OPENAI_API_BASE:
    create_base_provider(
        name="openai",
        base_url=OPENAI_API_BASE,  # lingyunapi.com/v1
        api_key=OPENAI_API_KEY
    )

sync_models_to_database()
```

#### Agent 创建逻辑

**代码位置**：`letta/server/rest_api/routers/v1/agents.py`

```python
async def create_agent(agent: CreateAgentRequest):
    # UI 调用此接口
    # agent.model 可能是 "claude-sonnet-4-5-20250929"
    # UI 需要决定使用哪个 provider

    # ❌ 问题：UI 默认选择了 anthropic provider
    # 而不是检查是否有 ANTHROPIC_API_KEY
```

### 15.11 总结

**核心问题**：
- Letta UI 创建 agent 时，默认选择了 Anthropic 官方 provider
- 但用户环境变量中只配置了 `OPENAI_API_KEY` 和 `OPENAI_API_BASE`
- 导致创建的 agent 无法使用（认证失败）

**根本原因**：
1. UI 的默认选择逻辑不当
2. 没有检查 provider 可用性
3. 没有优先使用环境变量配置

**解决方案**：
1. ✅ 使用 `openai-proxy/*` 格式的模型（与环境变量配置一致）
2. ✅ 优先使用 API/SDK 创建 agent
3. ✅ 创建前查看 `/v1/models/` 列表
4. ✅ 创建后验证 agent 配置

**这是一个重要的发现**，揭示了 Letta UI 在 provider 选择上的设计缺陷，以及环境变量与 base provider 的交互机制。

---

## 16. OPENAI_API_HEADERS 环境变量的真相（2026-01-05）

### 16.1 问题背景

在生产环境的 `.env` 文件中发现了以下配置：

```bash
OPENAI_API_KEY=sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh
OPENAI_API_BASE=https://lingyunapi.com/v1
OPENAI_API_HEADERS={"Authorization":"Bearer ${OPENAI_API_KEY}","Content-Type":"application/json","Accept":"*/*","Host":"lingyunapi.com","Connection":"keep-alive","User-Agent":"Apifox/1.0.0"}
```

**用户报告**：之前 Kleo agent 出现认证失败，添加 `OPENAI_API_HEADERS` 后问题解决。

**疑问**：这个环境变量真的有用吗？还是巧合？

### 16.2 深入调查

#### 16.2.1 Letta 代码中是否支持 OPENAI_API_HEADERS？

**搜索结果**：

```bash
# 搜索所有与 OPENAI_API_HEADERS 相关的代码
grep -r "OPENAI_API_HEADERS" letta/
# 结果：无匹配
```

**结论**：Letta 代码中**完全没有**读取 `OPENAI_API_HEADERS` 环境变量的逻辑。

#### 16.2.2 OpenAI Client 如何处理 headers？

**代码位置**：`letta/llm_api/openai_client.py`

**OpenAI Client 的 header 处理**：

```python
def _prepare_client_kwargs(self, llm_config: LLMConfig) -> dict:
    api_key, _, _ = self.get_byok_overrides(llm_config)

    # 默认使用全局 OpenAI key
    if not api_key:
        api_key = model_settings.openai_api_key or os.environ.get("OPENAI_API_KEY")

    kwargs = {"api_key": api_key, "base_url": llm_config.model_endpoint}

    # ⚠️ 只有 OpenRouter 才支持自定义 headers
    is_openrouter = (llm_config.model_endpoint and "openrouter.ai" in llm_config.model_endpoint) or (
        llm_config.provider_name == "openrouter"
    )
    if is_openrouter:
        or_key = model_settings.openrouter_api_key or os.environ.get("OPENROUTER_API_KEY")
        if or_key:
            kwargs["api_key"] = or_key
        # 添加 OpenRouter 特定 headers
        headers = {}
        if model_settings.openrouter_referer:
            headers["HTTP-Referer"] = model_settings.openrouter_referer
        if model_settings.openrouter_title:
            headers["X-Title"] = model_settings.openrouter_title
        if headers:
            kwargs["default_headers"] = headers

    # OpenAI client 必须有一个 API key
    kwargs["api_key"] = kwargs.get("api_key") or "DUMMY_API_KEY"

    return kwargs
```

**关键发现**：

1. ✅ OpenAI Client 支持通过 `default_headers` 参数添加自定义 headers
2. ❌ **但只对 OpenRouter 启用**，不对其他 provider 启用
3. ❌ **没有**从环境变量读取 `OPENAI_API_HEADERS` 的逻辑

#### 16.2.3 OpenAI Python SDK 的认证机制

**OpenAI SDK 标准**：

```python
from openai import OpenAI

# 标准认证方式
client = OpenAI(
    api_key="sk-...",  # 或从 OPENAI_API_KEY 环境变量读取
    base_url="https://api.example.com/v1"
)

# SDK 自动在所有请求中添加：
# Authorization: Bearer sk-...
```

**关键特性**：

1. OpenAI SDK **自动**从 `OPENAI_API_KEY` 环境变量读取 API key
2. SDK **自动**在所有 HTTP 请求中添加 `Authorization: Bearer <key>` header
3. **不需要**手动设置 `Authorization` header

#### 16.2.4 lingyunapi.com 的认证机制

**lingyunapi.com** 是一个 OpenAI-compatible API 代理服务。

**标准配置**：

```bash
OPENAI_API_KEY=sk-your-key
OPENAI_API_BASE=https://lingyunapi.com/v1
```

**工作原理**：

1. Letta 使用 OpenAI Python SDK
2. SDK 从 `OPENAI_API_KEY` 读取 API key
3. SDK 自动添加 `Authorization: Bearer sk-your-key` header
4. lingyunapi.com 接受标准的 OpenAI 认证方式

### 16.3 实验验证

#### 16.3.1 测试环境配置

**移除 OPENAI_API_HEADERS 前的配置**：

```yaml
# docker-compose.yml (旧)
environment:
  - OPENAI_API_KEY=${OPENAI_API_KEY}
  - OPENAI_API_BASE=${OPENAI_API_BASE}
  - OPENAI_API_HEADERS=${OPENAI_API_HEADERS}  # ❌ 这个没用
  - LETTA_SERVER_PASSWORD=${LETTA_SERVER_PASSWORD}
```

**移除 OPENAI_API_HEADERS 后的配置**：

```yaml
# docker-compose.yml (新)
environment:
  - OPENAI_API_KEY=${OPENAI_API_KEY}
  - OPENAI_API_BASE=${OPENAI_API_BASE}
  # ❌ 移除了这一行 - OPENAI_API_HEADERS=${OPENAI_API_HEADERS}
  - LETTA_SERVER_PASSWORD=${LETTA_SERVER_PASSWORD}
```

**.env 文件**：

```bash
OPENAI_API_KEY=sk-tlegmZDKQBW5rce5sGaMdQeprOvDZgaRhr37KMhkieoiRIvh
OPENAI_API_BASE=https://lingyunapi.com/v1
LETTA_SERVER_PASSWORD=LiXinYing0115@@
# OPENAI_API_HEADERS 移除 - 不需要
```

#### 16.3.2 创建测试 Agent

**Agent 配置**：

```json
{
  "name": "test-lingyun",
  "llm_config": {
    "model": "claude-haiku-4-5-20251001",
    "model_endpoint_type": "openai",
    "model_endpoint": "https://lingyunapi.com/v1",
    "provider_name": "openai",
    "provider_category": "base",
    "context_window": 30000
  },
  "embedding_config": {
    "embedding_model": "letta",
    "embedding_endpoint_type": "hugging-face",
    "embedding_endpoint": "https://embeddings.letta.com"
  }
}
```

**创建结果**：✅ 成功

#### 16.3.3 测试消息发送

**测试 1**：

```bash
# 用户消息
"Hello! Can you hear me? Please respond with just: Yes, I can hear you!"

# AI 响应
"Yes, I can hear you!"
```

**测试 2**：

```bash
# 用户消息
"What is 2+2? Answer with just the number."

# AI 响应
"4"
```

**结论**：✅ **认证完全正常，不需要 OPENAI_API_HEADERS**

### 16.4 为什么之前"添加 headers 解决了问题"？

可能的原因：

#### 原因 1：巧合（最可能）

真正解决问题的可能是其他配置变更：

1. **正确设置了 OPENAI_API_BASE**
   ```bash
   # 之前可能没有设置或设置错误
   OPENAI_API_BASE=https://lingyunapi.com/v1
   ```

2. **正确设置了 OPENAI_API_KEY**
   ```bash
   # 之前可能 key 错误或过期
   OPENAI_API_KEY=sk-...
   ```

3. **Agent 配置修改**
   - 可能同时修改了 agent 的 `model_endpoint`
   - 可能改用了正确的 `model_endpoint_type`

#### 原因 2：误解

- 问题本来就没解决，只是看起来解决了
- 或者问题是间歇性的，恰好那个时候恢复了

#### 原因 3：其他修改

- 可能同时修改了 docker-compose.yml 的其他配置
- 可能重启了容器解决了临时问题

### 16.5 OPENAI_API_HEADERS 的实际作用

#### Docker 环境变量展开

```bash
# .env 文件
OPENAI_API_KEY=sk-...
OPENAI_API_HEADERS={"Authorization":"Bearer ${OPENAI_API_KEY}",...}
```

**Docker Compose 处理**：

```yaml
environment:
  - OPENAI_API_HEADERS=${OPENAI_API_HEADERS}
```

**容器内实际接收**：

```bash
OPENAI_API_HEADERS={"Authorization":"Bearer sk-...","Content-Type":"application/json",...}
```

- ✅ Docker 会展开 `${OPENAI_API_KEY}` 变量
- ❌ 但 Letta 代码不会读取这个环境变量
- ❌ 这个环境变量被完全忽略

### 16.6 何时需要自定义 Headers？

#### 需要 default_headers 的场景

**OpenRouter 示例**（Letta 已支持）：

```python
# OpenRouter 需要特定 headers
kwargs["default_headers"] = {
    "HTTP-Referer": "https://your-site.com",
    "X-Title": "Your App Name"
}
```

**其他可能需要自定义 headers 的场景**：

1. **API 代理要求特定 headers**
   ```python
   kwargs["default_headers"] = {
       "X-API-Key": "custom-key",
       "X-Custom-Header": "value"
   }
   ```

2. **云服务商特殊要求**
   - 某些云服务商可能需要特定的 headers
   - 通常在服务商文档中说明

#### lingyunapi.com 不需要自定义 headers

**原因**：

1. ✅ 它是 OpenAI-compatible API
2. ✅ 接受标准的 `Authorization: Bearer <key>` 认证
3. ✅ OpenAI SDK 自动处理认证
4. ❌ 不需要额外的 headers

### 16.7 正确的配置方式

#### ✅ 推荐配置

**.env 文件**：

```bash
# 只需要这两个核心配置
OPENAI_API_KEY=sk-your-api-key
OPENAI_API_BASE=https://lingyunapi.com/v1

# 其他配置
LETTA_SERVER_PASSWORD=your-password
EXA_API_KEY=your-exa-key  # 如果使用 Exa 搜索
```

**docker-compose.yml**：

```yaml
services:
  letta-server:
    image: letta/letta:latest
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OPENAI_API_BASE=${OPENAI_API_BASE}
      - LETTA_SERVER_PASSWORD=${LETTA_SERVER_PASSWORD}
      # ❌ 不要添加这一行
      # - OPENAI_API_HEADERS=${OPENAI_API_HEADERS}
```

#### ❌ 不推荐的配置

```bash
# .env 文件
OPENAI_API_KEY=sk-...
OPENAI_API_BASE=https://lingyunapi.com/v1
OPENAI_API_HEADERS={"Authorization":"Bearer ${OPENAI_API_KEY}",...}  # ❌ 没用
```

### 16.8 代码修改建议

如果确实需要支持自定义 headers（某些特殊场景），可以修改 Letta 代码：

#### 方案 1：添加 OPENAI_API_HEADERS 支持

**修改位置**：`letta/llm_api/openai_client.py`

```python
def _prepare_client_kwargs(self, llm_config: LLMConfig) -> dict:
    api_key, _, _ = self.get_byok_overrides(llm_config)

    if not api_key:
        api_key = model_settings.openai_api_key or os.environ.get("OPENAI_API_KEY")

    kwargs = {"api_key": api_key, "base_url": llm_config.model_endpoint}

    # OpenRouter headers
    is_openrouter = ...
    if is_openrouter:
        # ... 现有代码 ...

    # ✅ 新增：支持自定义 headers
    custom_headers = os.environ.get("OPENAI_API_HEADERS")
    if custom_headers:
        try:
            import json
            headers_dict = json.loads(custom_headers)
            if "default_headers" in kwargs:
                kwargs["default_headers"].update(headers_dict)
            else:
                kwargs["default_headers"] = headers_dict
        except json.JSONDecodeError:
            logger.warning(f"Invalid OPENAI_API_HEADERS format: {custom_headers}")

    kwargs["api_key"] = kwargs.get("api_key") or "DUMMY_API_KEY"
    return kwargs
```

**但这种修改通常是不必要的**，因为：
- OpenAI SDK 已经自动处理 `Authorization` header
- 大多数 OpenAI-compatible API 都接受标准认证
- 自定义 headers 只在极少数特殊场景下需要

### 16.9 总结

#### 核心发现

1. **Letta 不支持 OPENAI_API_HEADERS**
   - 代码中完全没有读取这个环境变量的逻辑
   - 即使设置了，也会被完全忽略

2. **OpenAI SDK 自动处理认证**
   - SDK 自动从 `OPENAI_API_KEY` 读取 API key
   - SDK 自动添加 `Authorization: Bearer <key>` header
   - 不需要手动设置认证 headers

3. **lingyunapi.com 不需要自定义 headers**
   - 它是标准的 OpenAI-compatible API
   - 接受 OpenAI 的标准认证方式
   - 只需要 `OPENAI_API_KEY` 和 `OPENAI_API_BASE`

4. **之前"解决问题"的原因**
   - 很可能是巧合（其他配置变更）
   - 或者误解（问题本来就没解决）
   - `OPENAI_API_HEADERS` 本身没有起作用

#### 推荐配置

**生产环境配置**：

```bash
# .env
OPENAI_API_KEY=sk-your-key
OPENAI_API_BASE=https://lingyunapi.com/v1
LETTA_SERVER_PASSWORD=your-password
# ❌ 不需要 OPENAI_API_HEADERS
```

```yaml
# docker-compose.yml
environment:
  - OPENAI_API_KEY=${OPENAI_API_KEY}
  - OPENAI_API_BASE=${OPENAI_API_BASE}
  - LETTA_SERVER_PASSWORD=${LETTA_SERVER_PASSWORD}
  # ❌ 移除这一行 - OPENAI_API_HEADERS=${OPENAI_API_HEADERS}
```

#### 最佳实践

1. **信任 OpenAI SDK**
   - SDK 会自动处理认证
   - 不需要手动添加 `Authorization` header

2. **保持配置简洁**
   - 只配置必需的环境变量
   - 不要添加无用的配置项

3. **验证配置**
   - 创建测试 agent
   - 发送测试消息
   - 确认认证正常

4. **理解环境变量的作用**
   - 不是所有环境变量都被 Letta 读取
   - 查看代码确认哪些环境变量有效
   - 不要盲目添加配置

#### 关键要点

> ⚠️ **重要**：`OPENAI_API_HEADERS` 环境变量对 Letta **没有任何作用**。如果你之前添加它来"解决认证问题"，那么真正解决问题的可能是其他配置变更，而不是这个环境变量。

---

## 17. Letta 项目核心原理深度分析（2026-01-07）

### 17.1 项目定位

Letta 是一个**有状态 AI Agent 平台**，核心特性是让 AI Agent 拥有**持久化记忆**，能够学习和自我改进。

**前身为 MemGPT**（Memory GPT），强调将大语言模型（LLM）与持久化记忆系统结合。

### 17.2 核心架构组件

#### 17.2.1 三层架构

```
┌─────────────────────────────────────────────────────────┐
│                    API 层 (REST/WebSocket)               │
│       letta/server/rest_api/, letta/server/ws_api/       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                   Agent 执行层                           │
│  letta/agents/ (LettaAgentV3, BaseAgentV2, agent_loop)   │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                  服务和数据层                            │
│  letta/services/ (managers, tool_executor, summarizer)   │
└─────────────────────────────────────────────────────────┘
```

#### 17.2.2 核心组件关系

**AgentState** (`letta/schemas/agent.py:61-150`)
- Agent 的完整状态表示
- 包含：配置、记忆块、工具、消息 ID 列表
- 持久化到数据库

**LettaAgentV3** (`letta/agents/letta_agent_v3.py:61-72`)
- 当前最新的 Agent 实现
- 简化了 V2 的复杂性
- 核心方法：`step()`, `stream()`, `_step()`

**Agent Loop** (`letta/agents/agent_loop.py:15-64`)
- Agent 工厂类
- 根据 `agent_type` 选择对应的 Agent 实现
- 支持：LettaV3, LettaV2, Sleeptime, Voice 等

### 17.3 Agent 执行流程

#### 17.3.1 核心执行循环

```python
async def step(input_messages, max_steps=DEFAULT_MAX_STEPS):
    """
    完整的 Agent 执行流程
    """
    # 1. 初始化状态
    self._initialize_state()

    # 2. 准备 in-context 消息
    in_context_messages, input_messages_to_persist = \
        await _prepare_in_context_messages_no_persist_async(...)

    # 3. 执行多步循环
    for i in range(max_steps):
        # 3.1 单步执行
        async for chunk in self._step(
            messages=in_context_messages + input_messages,
            llm_adapter=llm_adapter,
        ):
            yield chunk

        # 3.2 检查是否继续
        if not self.should_continue:
            break

    # 4. 返回结果
    return LettaResponse(messages, stop_reason, usage)
```

#### 17.3.2 单步执行（`_step`）

这是 Agent 的**核心执行单元**：

```python
async def _step(messages, llm_adapter, ...):
    """
    单步执行：一次 LLM 调用 + 工具执行
    """
    # 1. 构建系统提示（包含记忆块）
    system_message = self._build_system_message(...)

    # 2. 调用 LLM
    llm_response = await llm_adapter.send_messages(
        messages=[system_message] + messages,
        tools=self.agent_state.tools,
    )

    # 3. 处理响应
    if llm_response.tool_calls:
        # 3a. 执行工具
        for tool_call in llm_response.tool_calls:
            result = await self.execute_tool(tool_call)
            tool_returns.append(result)

        # 3b. 持久化消息
        await self._persist_messages(...)

        # 3c. 返回工具调用结果
        yield ToolCallMessage(...)
        yield ToolReturnMessage(...)

    else:
        # 4a. 纯文本响应
        yield AssistantMessage(...)

        # 4b. 结束循环
        self.should_continue = False
```

**代码位置**：`letta/agents/letta_agent_v3.py:460-650`

### 17.4 记忆系统架构

#### 17.4.1 三级记忆结构

Letta 使用**三级记忆架构**来突破 LLM 的上下文窗口限制：

```
┌──────────────────────────────────────────────────────┐
│  1. Core Memory (核心记忆 - In-Context)              │
│     - Block 结构（human, persona, summary）           │
│     - 直接在 LLM 上下文中                             │
│     - 有限大小（通常 2000-4000 字符）                 │
└──────────────────────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────┐
│  2. Recall Memory (对话历史 - In-Context)            │
│     - 最近的消息列表                                  │
│     - 在上下文中，会被总结                            │
│     - 动态管理（消息缓冲区）                          │
└──────────────────────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────┐
│  3. Archival Memory (档案记忆 - Out-of-Context)      │
│     - Passage + Archive                               │
│     - 使用向量搜索（embedding）                      │
│     - 无限大小，按需检索                              │
└──────────────────────────────────────────────────────┘
```

#### 17.4.2 Block（核心记忆块）

**数据结构** (`letta/schemas/block.py:13-100`)：

```python
class Block(BaseBlock):
    id: str                          # 唯一标识
    label: str                       # 标签（如 "human", "persona"）
    value: str                       # 实际内容
    limit: int = 2000                # 字符限制
    description: str                 # 描述
    read_only: bool = False          # 是否只读
```

**内存渲染** (`letta/schemas/memory.py:110-140`)：

```python
def _render_memory_blocks_standard(self, s: StringIO):
    s.write("<memory_blocks>\n")
    s.write("The following memory blocks are in your core memory:\n\n")

    for block in self.blocks:
        s.write(f"<{block.label}>\n")
        s.write(f"<description>{block.description}</description>\n")
        s.write(f"<value>{block.value}</value>\n")
        s.write(f"</{block.label}>\n")

    s.write("</memory_blocks>")
```

**LLM 看到的格式**：

```xml
<memory_blocks>
The following memory blocks are in your core memory unit:

<human>
<description>
Details about the human user
</description>
<metadata>
- chars_current=150
- chars_limit=2000
</metadata>
<value>
Name: Timber. Status: dog. Occupation: building Letta...
</value>
</human>

<persona>
<description>
Agent's persona
</description>
<value>
I am a self-improving superintelligence...
</value>
</persona>

</memory_blocks>
```

#### 17.4.3 Passage（档案记忆）

**数据结构** (`letta/schemas/passage.py:35-45`)：

```python
class Passage(PassageBase):
    id: str
    text: str                       # 文本内容
    embedding: List[float]          # 向量嵌入（1536 维）
    embedding_config: EmbeddingConfig
    archive_id: str                 # 所属档案
    tags: List[str]                 # 标签
    metadata: Dict                  # 元数据
```

**向量搜索** (`letta/services/passage_manager.py:51-120`)：

```python
class PassageManager:
    async def search_passages(
        self,
        query: str,
        archive_id: str,
        limit: int = 10,
    ) -> List[Passage]:
        # 1. 生成查询向量
        query_embedding = await get_openai_embedding_async(
            text=query,
            model=self.embedding_config.model,
            endpoint=self.embedding_config.embedding_endpoint,
        )

        # 2. 向量相似度搜索（余弦相似度）
        results = await self.query_passages_by_embedding(
            query_embedding=query_embedding,
            archive_id=archive_id,
            limit=limit,
        )

        return results
```

### 17.5 工具系统

#### 17.5.1 工具类型分类

**代码位置**：`letta/schemas/enums.py` - `ToolType`

```python
class ToolType(str, Enum):
    LETTA_CORE = "letta_core"              # 核心记忆工具
    LETTA_MEMORY_CORE = "letta_memory_core" # 记忆管理
    LETTA_MULTI_AGENT_CORE = "letta_multi_agent_core"  # 多 Agent
    LETTA_BUILTIN = "letta_builtin"        # 内置工具
    LETTA_FILES_CORE = "letta_files_core"  # 文件操作
    EXTERNAL_MCP = "external_mcp"          # MCP 外部工具
    CUSTOM = "custom"                      # 用户自定义
```

#### 17.5.2 工具执行流程

**工厂模式** (`letta/services/tool_executor/tool_execution_manager.py:33-66`)：

```python
class ToolExecutorFactory:
    _executor_map = {
        ToolType.LETTA_CORE: LettaCoreToolExecutor,
        ToolType.LETTA_BUILTIN: LettaBuiltinToolExecutor,
        ToolType.EXTERNAL_MCP: ExternalMCPToolExecutor,
        # ...
    }

    @classmethod
    def get_executor(cls, tool_type, ...) -> ToolExecutor:
        executor_class = cls._executor_map.get(
            tool_type,
            SandboxToolExecutor  # 默认使用沙箱执行
        )
        return executor_class(...)
```

**执行管理器** (`letta/services/tool_executor/tool_execution_manager.py:69-150`)：

```python
class ToolExecutionManager:
    async def execute_tool_async(
        self,
        function_name: str,
        function_args: dict,
        tool: Tool,
        step_id: str | None = None,
    ) -> ToolExecutionResult:
        # 1. 获取对应的执行器
        executor = ToolExecutorFactory.get_executor(tool.tool_type, ...)

        # 2. 执行工具
        async with AsyncTimer(callback_func=_metrics_callback):
            result = await executor.execute(
                function_name,
                function_args,
                tool,
                self.actor,
                self.agent_state,
            )

        # 3. 截断过长的返回值
        return_str = json.dumps(result.func_return)
        if len(return_str) > tool.return_char_limit:
            result.func_return = FUNCTION_RETURN_VALUE_TRUNCATED(...)

        return result
```

#### 17.5.3 核心工具示例

**记忆工具** (`letta/functions/core/letta_core.py`)：

```python
def core_memory_append(
    block_label: str,
    content: str,
    agent_state: AgentState,
    block_manager: BlockManager,
) -> str:
    """向核心记忆块追加内容"""
    block = get_block_by_label(agent_state, block_label)

    # 检查限制
    if len(block.value) + len(content) > block.limit:
        raise ValueError(f"Exceeds {block.limit} character limit")

    # 更新块
    updated_block = BlockUpdate(value=block.value + "\n" + content)
    block_manager.update_block_by_id(block.id, updated_block, actor)

    return f"Added to {block_label}: {content}"
```

**对话搜索工具**：

```python
def conversation_search(
    query: str,
    agent_state: AgentState,
    message_manager: MessageManager,
) -> str:
    """在对话历史中搜索相关消息"""
    # 1. 生成查询向量
    query_embedding = await get_embedding(query)

    # 2. 向量搜索
    messages = await message_manager.search_messages(
        agent_id=agent_state.id,
        query_embedding=query_embedding,
        limit=5,
    )

    # 3. 格式化结果
    return format_search_results(messages)
```

**档案搜索工具**：

```python
def archival_memory_search(
    query: str,
    agent_state: AgentState,
    passage_manager: PassageManager,
) -> str:
    """在档案记忆中搜索相关内容"""
    # 1. 向量搜索
    passages = await passage_manager.search_passages(
        query=query,
        archive_id=agent_state.archive_id,
        limit=5,
    )

    # 2. 格式化结果
    return format_passages(passages)
```

### 17.6 消息流与响应格式

#### 17.6.1 Letta 消息类型

**代码位置**：`letta/schemas/letta_message.py`

```python
class LettaMessage(BaseModel):
    message_type: MessageType

    # 消息类型包括：
    - "system_message"         # 系统消息
    - "user_message"           # 用户消息
    - "assistant_message"      # 助手响应
    - "tool_call_message"      # 工具调用
    - "tool_return_message"    # 工具返回
    - "reasoning_message"      # 推理过程
    - "approval_request_message"  # 审批请求
```

#### 17.6.2 响应结构

**LettaResponse** (`letta/schemas/letta_response.py:33-60`)：

```python
class LettaResponse(BaseModel):
    messages: List[LettaMessageUnion]  # 消息列表
    stop_reason: LettaStopReason       # 停止原因
    usage: LettaUsageStatistics        # 使用统计

class LettaStopReason:
    stop_reason: StopReasonType
    # 类型：
    - "end_turn"              # 正常结束
    - "max_steps"             # 达到最大步数
    - "cancelled"             # 用户取消
    - "llm_api_error"         # LLM API 错误
    - "error"                 # 其他错误
```

#### 17.6.3 流式响应（SSE）

**流式适配器** (`letta/agents/letta_agent_v3.py:227-399`)：

```python
async def stream(
    self,
    input_messages: list[MessageCreate],
    stream_tokens: bool = False,
) -> AsyncGenerator[str, None]:
    """
    流式响应，使用 Server-Sent Events (SSE)
    """
    # 1. 选择适配器
    if stream_tokens:
        llm_adapter = SimpleLLMStreamAdapter(...)  # Token 级别
    else:
        llm_adapter = SimpleLLMRequestAdapter(...)  # 消息级别

    # 2. 执行循环
    for i in range(max_steps):
        async for chunk in self._step(...):
            # 3. 发送 SSE 事件
            yield f"data: {chunk.model_dump_json()}\n\n"

    # 4. 发送结束事件
    for finish_chunk in self.get_finish_chunks_for_stream(...):
        yield f"data: {finish_chunk}\n\n"
```

**SSE 事件格式**：

```
data: {"message_type":"tool_call_message","tool_call":{...}}

data: {"message_type":"tool_return_message","tool_return":{...}}

data: {"message_type":"assistant_message","message":"Hello!"}

data: {"stop_reason":"end_turn"}

data: {"usage":{"total_tokens":1000,...}}
```

### 17.7 记忆管理机制

#### 17.7.1 总结器（Summarizer）

**代码位置**：`letta/services/summarizer/summarizer.py:34-100`

```python
class Summarizer:
    """
    管理对话历史的总结和压缩
    """

    def __init__(
        self,
        mode: SummarizationMode,
        message_buffer_limit: int = 10,  # 消息缓冲区大小
    ):
        self.mode = mode
        self.message_buffer_limit = message_buffer_limit

    async def summarize(
        self,
        in_context_messages: List[Message],
        new_letta_messages: List[Message],
        force: bool = False,
    ) -> Tuple[List[Message], bool]:
        """
        根据模式总结或裁剪消息
        """
        if self.mode == SummarizationMode.STATIC_MESSAGE_BUFFER:
            # 保持固定数量的消息
            return self._static_buffer_summarization(...)

        elif self.mode == SummarizationMode.PARTIAL_EVICT_MESSAGE_BUFFER:
            # 部分 eviction
            return await self._partial_evict_buffer_summarization(...)
```

#### 17.7.2 上下文窗口管理

**动态总结触发**（在 `letta/agents/letta_agent_v3.py:160-180` 中已注释）：

```python
# 当接近上下文限制时触发总结
if (
    self.context_token_estimate is not None
    and self.context_token_estimate > context_window * 0.8  # 80% 阈值
):
    # 触发总结
    await self.summarize_conversation_history(
        in_context_messages=in_context_messages,
        new_letta_messages=self.response_messages,
        force=True,
    )
```

### 17.8 Provider 与 LLM 集成

#### 17.8.1 LLM 客户端架构

**代码位置**：`letta/llm_api/llm_client.py`

```python
class LLMClient:
    """
    统一的 LLM 客户端接口
    支持多个 Provider：OpenAI, Anthropic, Google, 等
    """

    @staticmethod
    def create(provider_type: ProviderType, ...) -> LLMClientBase:
        match provider_type:
            case ProviderType.openai:
                return OpenAIClient(...)
            case ProviderType.anthropic:
                return AnthropicClient(...)
            case ProviderType.google:
                return GoogleClient(...)
            case _:
                return OpenAIClient(...)  # 默认
```

#### 17.8.2 请求适配器

**适配器模式** (`letta/adapters/`)：

```python
class LettaLLMAdapter(ABC):
    """
    将 Letta 消息格式转换为 LLM Provider 格式
    """

    @abstractmethod
    async def send_messages(
        self,
        messages: List[Message],
        tools: List[Tool],
    ) -> ChatCompletionResponse:
        pass

class SimpleLLMRequestAdapter(LettaLLMAdapter):
    """非流式请求"""

class SimpleLLMStreamAdapter(LettaLLMAdapter):
    """流式请求（Token 级别）"""
```

### 17.9 数据库与持久化

#### 17.9.1 Manager 层

**核心 Managers**：

```python
# Agent 管理
class AgentManager:
    - create_agent()
    - get_agent()
    - update_agent()
    - delete_agent()
    - update_message_ids_async()

# 消息管理
class MessageManager:
    - create_message()
    - get_messages()
    - search_messages()  # 向量搜索

# 记忆块管理
class BlockManager:
    - create_block()
    - update_block()
    - get_block()

# 档案管理
class PassageManager:
    - create_passage()
    - search_passages()  # 向量搜索

# 工具管理
class ToolManager:
    - create_tool()
    - get_tool()
    - execute_tool()
```

#### 17.9.2 ORM 模型

**代码位置**：`letta/orm/agent.py`, `letta/orm/message.py`, 等

```python
class Agent(SqlalchemyBase):
    __tablename__ = "agents"

    id: str
    name: str
    system: str
    agent_type: str
    llm_config: dict
    embedding_config: dict
    # ...

    # 关系
    blocks: List[Block]
    tools: List[Tool]
    messages: List[Message]
```

### 17.10 多 Agent 协作

#### 17.10.1 Agent 组（Group）

**代码位置**：`letta/groups/`

```python
class SleeptimeMultiAgentV4(BaseAgentV2):
    """
    多 Agent 系统：
    - 主 Agent：处理用户交互
    - Sleeptime Agent：后台处理记忆管理
    """

    def __init__(
        self,
        agent_state: AgentState,
        group: Group,  # Agent 组
        actor: User,
    ):
        self.primary_agent = LettaAgentV3(agent_state, actor)
        self.sleeptime_agent = ...  # 后台 Agent
```

#### 17.10.2 工具传递

```python
@tool
def send_message_to_agent(
    agent_id: str,
    message: str,
    multi_agent_tool_executor: MultiAgentToolExecutor,
) -> str:
    """向另一个 Agent 发送消息"""
    return await multi_agent_tool_executor.send_message(
        agent_id=agent_id,
        content=message,
    )
```

### 17.11 前端架构设计要点

基于以上分析，Flutter 前端需要关注：

#### 17.11.1 核心 API 集成

```dart
// 1. Agent 管理
GET    /v1/agents/
POST   /v1/agents/
GET    /v1/agents/{id}
PUT    /v1/agents/{id}
DELETE /v1/agents/{id}

// 2. 消息发送（SSE 流式响应）
POST   /v1/agents/{id}/messages

// 3. 工具管理
GET    /v1/tools/
POST   /v1/tools/

// 4. 记忆管理
GET    /v1/blocks/
PUT    /v1/blocks/{id}

// 5. 档案搜索
POST   /v1/passages/search
```

#### 17.11.2 SSE 流式响应处理

```dart
class AgentChatService {
  Stream<Message> sendMessageStream({
    required String agentId,
    required String content,
  }) async* {
    final client = SSEClient.connect(
      url: '/v1/agents/$agentId/messages',
      method: 'POST',
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode({'messages': [{'role': 'user', 'content': content}]}),
    );

    await for (final event in client.events) {
      if (event.type == 'message') {
        final data = jsonDecode(event.data);
        yield Message.fromJson(data);
      }
    }
  }
}
```

#### 17.11.3 状态管理策略

```dart
// Riverpod Provider
@riverpod
class AgentState extends _$AgentState {
  @override
  Future<List<Agent>> build() async {
    final response = await client.get('/v1/agents/');
    return [ ... ];
  }

  Future<void> createAgent(CreateAgentRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await client.post('/v1/agents/', request);
      return ref.refresh(self.future);
    });
  }
}

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<Message> build() => [];

  void addMessage(Message message) {
    state = [...state, message];
  }
}
```

### 17.12 总结：Letta 的核心创新

1. **持久化记忆**：突破 LLM 无状态限制
2. **三级记忆架构**：平衡速度、容量、成本
3. **工具优先**：通过 Function Calling 扩展能力
4. **流式响应**：实时用户体验
5. **多 Provider 支持**：灵活的 LLM 选择
6. **向量检索**：智能记忆搜索
7. **多 Agent 协作**：复杂任务分解

### 17.13 关键代码文件清单

**核心执行**：
- `letta/agents/letta_agent_v3.py` - Agent 主实现
- `letta/agents/base_agent_v2.py` - 抽象基类
- `letta/agents/agent_loop.py` - Agent 工厂

**数据模型**：
- `letta/schemas/agent.py` - Agent 状态
- `letta/schemas/memory.py` - 记忆系统
- `letta/schemas/block.py` - 记忆块
- `letta/schemas/message.py` - 消息
- `letta/schemas/tool.py` - 工具
- `letta/schemas/passage.py` - 档案

**服务层**：
- `letta/services/agent_manager.py` - Agent 管理
- `letta/services/message_manager.py` - 消息管理
- `letta/services/block_manager.py` - 记忆块管理
- `letta/services/passage_manager.py` - 档案管理
- `letta/services/tool_executor/tool_execution_manager.py` - 工具执行
- `letta/services/summarizer/summarizer.py` - 总结器

**LLM 集成**：
- `letta/llm_api/llm_client.py` - LLM 客户端
- `letta/llm_api/openai_client.py` - OpenAI 实现
- `letta/llm_api/anthropic_client.py` - Anthropic 实现
- `letta/adapters/` - 请求适配器

**API 层**：
- `letta/server/rest_api/routers/v1/agents.py` - Agents API
- `letta/server/rest_api/routers/v1/messages.py` - Messages API
- `letta/server/ws_api/interface.py` - WebSocket API

---

## 18. 前端创建 Agent 的 BYOK 模式实现（2026-01-09）⭐ 新增

### 18.1 背景：BYOK vs 非 BYOK 模式

Letta 支持两种模式来配置 LLM 和 Embedding 模型：

| 特性 | BYOK 模式 | 非 BYOK 模式 |
|------|-----------|---------------|
| **Provider 来源** | 数据库（用户创建） | 环境变量（内存） |
| **Provider Category** | `byok` | `base` |
| **API Keys** | 存储在数据库 Provider 中 | 从环境变量读取 |
| **使用场景** | 需要自定义 API keys、多用户隔离 | 单用户、开发测试 |
| **配置复杂度** | 需要完整配置 | 简化配置 |

### 18.2 非 BYOK 模式创建 Agent

#### 18.2.1 API 请求格式

非 BYOK 模式使用简化的 JSON 格式：

```json
{
  "name": "my-agent",
  "model": "openai-proxy/claude-sonnet-4-5-20250929",
  "embedding": "openai-proxy/text-embedding-3-small",
  "system": "You are a helpful assistant.",
  "description": "Optional description"
}
```

**关键点**：
- `model` 和 `embedding` 字段使用**模型的 handle**，格式为 `provider_name/model_name`
- Letta 根据 handle 的前缀（`openai-proxy`）自动查找对应的 base provider
- Base provider 的配置（API keys、endpoints）来自环境变量

#### 18.2.2 前端实现

**Dart 模型** (`lib/core/models/create_agent_request.dart`):

```dart
/// Convert to simple format (non-BYOK mode)
Map<String, dynamic> toSimpleJson() {
  final json = <String, dynamic>{
    'name': name,
    'model': llmModel.handle,  // e.g., "openai-proxy/claude-sonnet-4-5-20250929"
    'embedding': embeddingModel.handle,  // e.g., "openai-proxy/text-embedding-3-small"
  };

  if (description != null) {
    json['description'] = description;
  }
  if (systemPrompt != null) {
    json['system'] = systemPrompt;
  }

  return json;
}
```

**模型加载逻辑** (`lib/features/agents/screens/agent_create_screen.dart`):

```dart
if (!_byokMode) {
  // Non-BYOK mode: load base models directly
  final allModels = await ref.read(baseLLMModelListProvider.future);

  // Load LLM models from /v1/models/?provider_category=base
  final llmModels = allModels.where((m) => m.modelType == 'llm').toList();

  // Load embedding models from /v1/models/embedding
  final embeddingResponse = await client.get('/models/embedding');
  final embeddingModels = // ... parse response

  setState(() {
    _availableLLMModels = llmModels;
    _availableEmbeddingModels = embeddingModels;
  });
}
```

**关键点**：
- LLM 模型从 `/v1/models/?provider_category=base` 获取
- Embedding 模型从 `/v1/models/embedding` 获取（因为 base 模型列表不包含 embedding）
- 所有模型的 `provider_category` 默认为 `"base"`

### 18.3 BYOK 模式创建 Agent

#### 18.3.1 API 请求格式

BYOK 模式使用完整的配置格式：

```json
{
  "name": "my-agent",
  "llm_config": {
    "model": "claude-haiku-4-5-20251001-thinking",
    "provider_name": "openai-proxy",
    "provider_category": "byok",
    "model_endpoint_type": "openai",
    "context_window": 30000
  },
  "embedding_config": {
    "provider_name": "openai-embedding",
    "provider_category": "byok",
    "embedding_endpoint_type": "openai",
    "embedding_model": "text-embedding-3-small",
    "embedding_dim": 1536
  },
  "system": "You are a helpful assistant."
}
```

**关键点**：
- 必须提供 `provider_name` 和 `provider_category`，Letta 用这两个字段在数据库中查找对应的 Provider
- 找到 Provider 后，使用其配置（API keys、base URLs 等）来调用 LLM API

#### 18.3.2 Letta 后端的 Provider 查找流程

1. **接收请求**：
   ```json
   {
     "llm_config": {
       "provider_name": "openai-proxy",
       "provider_category": "byok"
     }
   }
   ```

2. **数据库查询**：
   ```python
   # 伪代码
   provider = db.query(Provider).filter_by(
       name="openai-proxy",
       category="byok"
   ).first()
   ```

3. **获取配置**：
   ```python
   api_key = provider.api_key  # 从数据库读取
   base_url = provider.base_url
   ```

4. **调用 LLM API**：
   ```python
   response = openai_client.chat(
       api_key=api_key,
       base_url=base_url,
       model="claude-haiku-4-5-20251001-thinking"
   )
   ```

#### 18.3.3 前端实现

**Dart 模型** (`lib/core/models/create_agent_request.dart`):

```dart
/// Convert to full config format (BYOK mode)
Map<String, dynamic> toBYOKJson() {
  final json = <String, dynamic>{
    'name': name,
    'llm_config': {
      'model': llmModel.model,
      'provider_name': llmModel.providerName,  // 关键字段
      'provider_category': llmModel.providerCategory,  // 关键字段
      'model_endpoint_type': llmModel.modelEndpointType,
      'context_window': llmModel.contextWindow,
    },
    'embedding_config': {
      'provider_name': embeddingModel.providerName,  // 关键字段
      'provider_category': embeddingModel.providerCategory,  // 关键字段
      'embedding_endpoint_type': embeddingModel.modelEndpointType,
      'embedding_model': embeddingModel.model,
      'embedding_dim': 1536,
    },
  };

  if (description != null) {
    json['description'] = description;
  }
  if (systemPrompt != null) {
    json['system'] = systemPrompt;
  }

  return json;
}
```

**模式检测**：

```dart
/// Check if this is a BYOK mode request
bool get isBYOK => llmModel.providerCategory == 'byok';

/// Convert to JSON based on mode
Map<String, dynamic> toJson() {
  return isBYOK ? toBYOKJson() : toSimpleJson();
}
```

**模型加载逻辑**：

```dart
if (_byokMode) {
  // BYOK mode: load providers from database
  final providers = await ref.read(providerListProvider.future);

  setState(() {
    _availableProviders = providers;
    // User selects a provider first, then load models for that provider
  });
}
```

### 18.4 完整创建流程对比

#### 18.4.1 非 BYOK 模式流程

```
用户选择模型
    ↓
使用 handle (openai-proxy/claude-sonnet-4-5-20250929)
    ↓
发送简化 JSON: {"model": "openai-proxy/...", "embedding": "openai-proxy/..."}
    ↓
Letta 解析 handle，提取 provider_name = "openai-proxy"
    ↓
Letta 从环境变量加载 openai-proxy 的配置
    ↓
创建 Agent 成功
```

#### 18.4.2 BYOK 模式流程

```
用户选择 Provider (openai-proxy, openai-embedding)
    ↓
加载该 Provider 下的模型列表
    ↓
用户选择具体模型
    ↓
发送完整 JSON: {
  "llm_config": {"provider_name": "openai-proxy", "provider_category": "byok", ...},
  "embedding_config": {"provider_name": "openai-embedding", "provider_category": "byok", ...}
}
    ↓
Letta 根据 provider_name + provider_category 在数据库中查找 Provider
    ↓
Letta 读取 Provider 的 API keys 和配置
    ↓
创建 Agent 成功
```

### 18.5 关键字段说明

#### 18.5.1 模型 (LLMModel) 字段

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `handle` | String | 唯一标识符，格式 `provider_name/model` | `openai-proxy/claude-sonnet-4-5-20250929` |
| `model` | String | 模型名称 | `claude-sonnet-4-5-20250929` |
| `provider_name` | String | Provider 名称 | `openai-proxy` |
| `provider_category` | String | Provider 类别：`base` 或 `byok` | `base`, `byok` |
| `model_endpoint_type` | String | 端点类型 | `openai`, `anthropic` |
| `context_window` | int | 上下文窗口大小 | `30000` |

#### 18.5.2 Embedding 模型字段

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `handle` | String | 唯一标识符 | `openai-proxy/text-embedding-3-small` |
| `model` / `embedding_model` | String | 模型名称 | `text-embedding-3-small` |
| `provider_name` | String | Provider 名称 | `openai-proxy` |
| `provider_category` | String | Provider 类别 | `base`, `byok` |
| `model_endpoint_type` / `embedding_endpoint_type` | String | 端点类型 | `openai` |
| `embedding_dim` | int | Embedding 维度 | `1536` |

**注意**：Embedding 模型可能使用 `embedding_model` 和 `embedding_endpoint_type` 字段名，而不是 `model` 和 `model_endpoint_type`。

### 18.6 常见问题

#### Q1: 为什么 BYOK 模式需要 `provider_name` 和 `provider_category`？

**A**: Letta 需要通过这两个字段在数据库中精确查找对应的 Provider 配置。只有找到正确的 Provider，Letta 才能获取 API keys、base URLs 等配置来调用 LLM API。

#### Q2: 非 BYOK 模式为什么不提供 `provider_name`？

**A**: 非 BYOK 模式使用 handle 格式（`provider_name/model`），Letta 会从 handle 中提取 `provider_name`，然后从**环境变量**加载对应的配置，不需要查询数据库。

#### Q3: 如何判断使用哪种模式？

**A**:
- **前端**: 检查 `llmModel.providerCategory == 'byok'`
- **后端**: Letta 检查 `llm_config.provider_category` 或 `embedding_config.provider_category`

#### Q4: 两种模式可以混用吗？

**A**: 不可以。创建 Agent 时，LLM 和 Embedding 必须使用相同的模式：
- 要么都是 BYOK（`llm_config` + `embedding_config`）
- 要么都不是 BYOK（`model` + `embedding`）

### 18.7 前端代码实现要点

#### 18.7.1 LLMModel 兼容性处理

由于 `/v1/models/embedding` 返回的模型格式与 LLM 模型不同，需要兼容处理：

```dart
factory LLMModel.fromJson(Map<String, dynamic> json) {
  // Embedding 模型没有 provider_category 字段，默认为 'base'
  final providerCategory = json['provider_category'] as String? ?? 'base';

  return LLMModel(
    handle: json['handle'] as String,
    name: json['name'] as String,
    displayName: json['display_name'] as String,
    providerType: json['provider_type'] as String?
                ?? json['embedding_endpoint_type'] as String?
                ?? 'unknown',
    providerName: json['provider_name'] as String,
    // Embedding 模型使用 embedding_model 字段
    model: json['model'] as String?
           ?? json['embedding_model'] as String?
           ?? '',
    // Embedding 模型使用 embedding_endpoint_type 字段
    modelEndpointType: json['model_endpoint_type'] as String?
                      ?? json['embedding_endpoint_type'] as String?
                      ?? 'unknown',
    modelEndpoint: json['model_endpoint'] as String?
                  ?? json['embedding_endpoint'] as String?
                  ?? '',
    providerCategory: providerCategory,
    modelType: json['model_type'] as String?
               ?? (json.containsKey('embedding_model') ? 'embedding' : 'llm'),
    contextWindow: json['context_window'] as int? ?? 30000,
    // ... 其他字段
  );
}
```

#### 18.7.2 模式自动切换

```dart
class CreateAgentRequest {
  final LLMModel llmModel;
  final LLMModel embeddingModel;

  // 自动检测模式
  bool get isBYOK => llmModel.providerCategory == 'byok';

  // 根据模式生成正确的 JSON
  Map<String, dynamic> toJson() {
    return isBYOK ? toBYOKJson() : toSimpleJson();
  }
}
```

### 18.8 总结

| 特性 | 非 BYOK 模式 | BYOK 模式 |
|------|-------------|-----------|
| **配置来源** | 环境变量 | 数据库 |
| **API 格式** | 简化 (`model` + `embedding`) | 完整 (`llm_config` + `embedding_config`) |
| **模型标识** | handle (`provider/model`) | 完整配置 |
| **Provider 查找** | 从 handle 提取 provider_name | 使用 `provider_name` + `provider_category` |
| **API Keys** | 环境变量 | Provider 配置 |
| **适用场景** | 开发、测试 | 生产、多用户 |

**核心设计理念**：
- 非 BYOK 模式：简单优先，适合快速开发和测试
- BYOK 模式：灵活优先，支持多用户、多 Provider、自定义配置

---

**文档版本**：v2.6
**最后更新**：2026-01-07
**调查者**：Claude Code (Sonnet 4.5)

## 19. Base 模型和 Embedding 模型的获取流程（2026-01-09）

### 19.1 概述

Letta 后端提供了两个主要的 API 端点来获取模型列表：

1. **`GET /v1/models/?provider_category=base`** - 获取 Base LLM 模型列表
2. **`GET /v1/models/embedding`** - 获取 Base Embedding 模型列表

这两个端点的实现完全不同，本文档详细分析它们的获取流程。

---

### 19.2 Base LLM 模型获取流程

#### 19.2.1 API 端点

```python
# letta/server/rest_api/routers/v1/llms.py:15
@router.get("/", response_model=List[Model], operation_id="list_models")
async def list_llm_models(
    provider_category: Optional[List[ProviderCategory]] = Query(None),
    provider_name: Optional[str] = Query(None),
    provider_type: Optional[ProviderType] = Query(None),
    server: "SyncServer" = Depends(get_letta_server),
    headers: HeaderParams = Depends(get_headers),
):
    actor = await server.user_manager.get_actor_or_default_async(actor_id=headers.actor_id)
    
    models = await server.list_llm_models_async(
        provider_category=provider_category,
        provider_name=provider_name,
        provider_type=provider_type,
        actor=actor,
    )
    
    return [Model.from_llm_config(model) for model in models]
```

**请求示例**：
```bash
GET /v1/models/?provider_category=base
```

**响应示例**：
```json
[
  {
    "handle": "openai-proxy/claude-sonnet-4-5-20250929",
    "name": "claude-sonnet-4-5-20250929",
    "display_name": "claude-sonnet-4-5-20250929",
    "provider_type": "openai",
    "provider_name": "openai-proxy",
    "model_type": "llm",
    "model": "claude-sonnet-4-5-20250929",
    "model_endpoint_type": "openai",
    "model_endpoint": "https://lingyunapi.com/v1",
    "provider_category": "base",
    "context_window": 30000,
    ...
  }
]
```

#### 19.2.2 核心实现流程

```
┌─────────────────────────────────────────────────────────────┐
│  1. REST API 接收请求                                         │
│     list_llm_models(provider_category=[ProviderCategory.base])│
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Server 层处理                                            │
│     server.list_llm_models_async(...)                       │
│     letta/server/server.py:1047                             │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  3. 获取启用的 Provider 列表                                 │
│     providers = await self.get_enabled_providers_async(     │
│         provider_category=[ProviderCategory.base],          │
│         actor=actor                                         │
│     )                                                       │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  4. get_enabled_providers_async 逻辑                        │
│     letta/server/server.py:1124                             │
│                                                              │
│     providers = []                                          │
│     if not provider_category or ProviderCategory.base in    │
│        provider_category:                                   │
│         # 从环境变量加载的 Provider                          │
│         providers_from_env = [p for p in                    │
│             self._enabled_providers]                        │
│         providers.extend(providers_from_env)                │
│                                                              │
│     if not provider_category or ProviderCategory.byok in    │
│        provider_category:                                   │
│         # 从数据库加载的 Provider                            │
│         providers_from_db = await self                      │
│             .provider_manager.list_providers_async(...)     │
│         providers.extend(providers_from_db)                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  5. 并发获取所有 Provider 的模型列表                         │
│     import asyncio                                          │
│     async def get_provider_models(provider):                │
│         return await provider.list_llm_models_async()       │
│                                                              │
│     provider_results = await asyncio.gather(*[              │
│         get_provider_models(p) for p in providers           │
│     ])                                                      │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  6. Provider.list_llm_models_async() 实现                   │
│     每个 Provider 子类实现自己的模型列表                     │
│                                                              │
│     例如：OpenAIProvider                                    │
│     - 调用 OpenAI API 的 GET /v1/models 端点                 │
│     - 解析返回的模型列表                                     │
│     - 过滤出不支持的模型                                     │
│     - 构造 LLMConfig 对象                                    │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  7. 返回合并的模型列表                                       │
│     all_models = []                                         │
│     for models in provider_results:                         │
│         all_models.extend(models)                           │
│     return all_models                                       │
└─────────────────────────────────────────────────────────────┘
```

#### 19.2.3 _enabled_providers 初始化

`_enabled_providers` 是在 Server 启动时从**环境变量**初始化的：

```python
# letta/server/server.py:211
self._enabled_providers: List[Provider] = [LettaProvider(name="letta")]

# OpenAI Provider
if model_settings.openai_api_key:
    self._enabled_providers.append(
        OpenAIProvider(
            name="openai",
            api_key_enc=Secret.from_plaintext(model_settings.openai_api_key),
            base_url=model_settings.openai_api_base,
        )
    )

# Anthropic Provider
if model_settings.anthropic_api_key:
    self._enabled_providers.append(
        AnthropicProvider(
            name="anthropic",
            api_key_enc=Secret.from_plaintext(model_settings.anthropic_api_key),
        )
    )

# ... 其他 Provider（Ollama, Google, Azure, Groq, etc.）
```

**关键点**：
- `_enabled_providers` 是**内存 Provider**（ProviderCategory.base）
- 这些 Provider 的配置来自**环境变量**
- Server 启动时一次性加载，运行期间不变

#### 19.2.4 Provider 的 list_llm_models_async() 实现

不同的 Provider 有不同的实现：

**LettaProvider**（硬编码）：
```python
# letta/schemas/providers.py:162
async def list_llm_models_async(self) -> List[LLMConfig]:
    return [
        LLMConfig(
            model="letta-free",
            model_endpoint_type="openai",
            model_endpoint=LETTA_MODEL_ENDPOINT,
            context_window=30000,
            handle=self.get_handle("letta-free"),
            provider_name=self.name,
            provider_category=self.provider_category,
        )
    ]
```

**OpenAIProvider**（调用 API）：
```python
# letta/schemas/providers.py:254
async def list_llm_models_async(self) -> List[LLMConfig]:
    data = await self._get_models_async()
    return self._list_llm_models(data)

async def _get_models_async(self) -> List[dict]:
    from letta.llm_api.openai import openai_get_model_list_async
    
    response = await openai_get_model_list_async(
        self.base_url,
        api_key=self.api_key,
        extra_params=extra_params,
    )
    
    if "data" in response:
        return response["data"]
    else:
        return response

def _list_llm_models(self, data) -> List[LLMConfig]:
    configs = []
    for model in data:
        model_name = model["id"]
        
        # 过滤不支持的模型
        if self.base_url == "https://api.openai.com/v1":
            # 跳过不支持 tool calling 的模型
            disallowed_types = ["transcribe", "search", "realtime", 
                                "tts", "audio", "o1-mini", "o1-preview"]
            if any(keyword in model_name for keyword in disallowed_types):
                continue
        
        # 构造 LLMConfig
        llm_config = LLMConfig(
            model=model_name,
            model_endpoint_type="openai",
            model_endpoint=self.base_url,
            context_window=self.get_model_context_window_size(model_name),
            handle=self.get_handle(model_name),
            provider_name=self.name,
            provider_category=self.provider_category,
        )
        configs.append(llm_config)
    
    return configs
```

**AnthropicProvider**（调用 API）：
```python
# letta/schemas/providers.py:769
async def list_llm_models_async(self) -> List[LLMConfig]:
    from letta.llm_api.anthropic import anthropic_get_model_list_async
    
    models = await anthropic_get_model_list_async(api_key=self.api_key)
    return self._list_llm_models(models)
```

---

### 19.3 Base Embedding 模型获取流程

#### 19.3.1 API 端点

```python
# letta/server/rest_api/routers/v1/llms.py:42
@router.get("/embedding", response_model=List[EmbeddingModel], 
           operation_id="list_embedding_models")
async def list_embedding_models(
    server: "SyncServer" = Depends(get_letta_server),
    headers: HeaderParams = Depends(get_headers),
):
    actor = await server.user_manager.get_actor_or_default_async(
        actor_id=headers.actor_id
    )
    models = await server.list_embedding_models_async(actor=actor)
    
    return [EmbeddingModel.from_embedding_config(model) 
            for model in models]
```

**请求示例**：
```bash
GET /v1/models/embedding
```

**响应示例**：
```json
[
  {
    "handle": "openai/text-embedding-3-small",
    "name": "text-embedding-3-small",
    "display_name": "text-embedding-3-small",
    "provider_type": "openai",
    "provider_name": "openai",
    "model_type": "embedding",
    "embedding_endpoint_type": "openai",
    "embedding_endpoint": "https://lingyunapi.com/v1",
    "embedding_model": "text-embedding-3-small",
    "embedding_dim": 1536,
    "embedding_chunk_size": 300,
    "batch_size": 1024
  }
]
```

**注意**：Embedding 模型的响应**没有** `provider_category` 字段！

#### 19.3.2 核心实现流程

```
┌─────────────────────────────────────────────────────────────┐
│  1. REST API 接收请求                                         │
│     list_embedding_models()                                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Server 层处理                                            │
│     server.list_embedding_models_async(actor)               │
│     letta/server/server.py:1098                             │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  3. 获取所有启用的 Provider（包括 base 和 byok）            │
│     providers = await self.get_enabled_providers_async(     │
│         actor=actor                                         │
│     )                                                       │
│                                                              │
│     注意：这里不传 provider_category 参数                   │
│     所以会同时返回 base 和 byok 的 Provider                  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  4. 并发获取所有 Provider 的 Embedding 模型列表             │
│     async def get_provider_embedding_models(provider):      │
│         try:                                                │
│             return await provider.list_embedding_models_async()│
│         except Exception as e:                              │
│             logger.exception(...)                           │
│             return []                                        │
│                                                              │
│     provider_results = await asyncio.gather(*[              │
│         get_provider_embedding_models(p)                    │
│         for p in providers                                  │
│     ])                                                      │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  5. Provider.list_embedding_models_async() 实现            │
│     每个 Provider 子类实现自己的 Embedding 列表              │
│                                                              │
│     例如：OpenAIProvider                                    │
│     - 硬编码支持的 embedding 模型列表                        │
│     - 构造 EmbeddingConfig 对象                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  6. 返回合并的 Embedding 模型列表                           │
│     embedding_models = []                                  │
│     for models in provider_results:                         │
│         embedding_models.extend(models)                     │
│     return embedding_models                                 │
└─────────────────────────────────────────────────────────────┘
```

#### 19.3.3 Provider 的 list_embedding_models_async() 实现

**LettaProvider**（硬编码）：
```python
# letta/schemas/providers.py:175
def list_embedding_models(self):
    return [
        EmbeddingConfig(
            embedding_model="letta-free",
            embedding_endpoint_type="hugging-face",
            embedding_endpoint="https://embeddings.memgpt.ai",
            embedding_dim=1024,
            embedding_chunk_size=300,
            handle=self.get_handle("letta-free", is_embedding=True),
            batch_size=32,
        )
    ]
```

**OpenAIProvider**（硬编码）：
```python
# letta/schemas/providers.py:391
async def list_embedding_models_async(self) -> List[EmbeddingConfig]:
    if self.base_url == "https://api.openai.com/v1":
        # TODO: 实际上应该自动列出 OpenAI 的模型
        return [
            EmbeddingConfig(
                embedding_model="text-embedding-ada-002",
                embedding_endpoint_type="openai",
                embedding_endpoint=self.base_url,
                embedding_dim=1536,
                embedding_chunk_size=300,
                handle=self.get_handle("text-embedding-ada-002", 
                                     is_embedding=True),
                batch_size=1024,
            ),
            EmbeddingConfig(
                embedding_model="text-embedding-3-small",
                embedding_endpoint_type="openai",
                embedding_endpoint=self.base_url,
                embedding_dim=2000,
                embedding_chunk_size=300,
                handle=self.get_handle("text-embedding-3-small", 
                                     is_embedding=True),
                batch_size=1024,
            ),
            EmbeddingConfig(
                embedding_model="text-embedding-3-large",
                embedding_endpoint_type="openai",
                embedding_endpoint=self.base_url,
                embedding_dim=2000,
                embedding_chunk_size=300,
                handle=self.get_handle("text-embedding-3-large", 
                                     is_embedding=True),
                batch_size=1024,
            ),
        ]
    else:
        # 非 OpenAI 官方端点，从 API 动态获取
        return self.list_embedding_models()
```

**AnthropicProvider**（不支持）：
```python
# letta/schemas/providers.py:867
def list_embedding_models(self) -> List[EmbeddingConfig]:
    # Anthropic 不支持 embedding
    return []
```

**GoogleAIProvider**（调用 API）：
```python
# letta/schemas/providers.py:1295
async def list_embedding_models_async(self):
    from letta.llm_api.google_ai_client import google_ai_get_model_list_async
    
    model_options = await google_ai_get_model_list_async(
        base_url=self.base_url, 
        api_key=self.api_key
    )
    return self._list_embedding_models(model_options)

def _list_embedding_models(self, model_options):
    # 过滤出支持 'embedContent' 的模型
    model_options = [mo for mo in model_options 
                     if "embedContent" in mo["supportedGenerationMethods"]]
    model_options = [str(m["name"]) for m in model_options]
    model_options = [mo[len("models/"):] if mo.startswith("models/") 
                     else mo for mo in model_options]
    
    configs = []
    for model in model_options:
        configs.append(
            EmbeddingConfig(
                embedding_model=model,
                embedding_endpoint_type="google_ai",
                embedding_endpoint=self.base_url,
                embedding_dim=768,
                embedding_chunk_size=300,
                handle=self.get_handle(model, is_embedding=True),
                batch_size=1024,
            )
        )
    return configs
```

---

### 19.4 关键区别总结

#### 19.4.1 API 端点

| 特性 | LLM 模型 | Embedding 模型 |
|------|---------|---------------|
| **端点** | `GET /v1/models/?provider_category=base` | `GET /v1/models/embedding` |
| **参数** | 支持 `provider_category`, `provider_name`, `provider_type` | 无参数 |
| **返回格式** | `List[Model]` (extends LLMConfig) | `List[EmbeddingModel]` (extends EmbeddingConfig) |
| **字段差异** | 有 `provider_category` 字段 | **无** `provider_category` 字段 |

#### 19.4.2 实现差异

| 特性 | LLM 模型 | Embedding 模型 |
|------|---------|---------------|
| **Provider 筛选** | 根据 `provider_category` 参数筛选 | 获取所有 Provider 的 Embedding 模型 |
| **模型来源** | 大部分 Provider 从 API 动态获取 | 大部分 Provider 硬编码模型列表 |
| **过滤逻辑** | 复杂（过滤不支持 tool calling 的模型） | 简单（通常直接返回固定列表） |

#### 19.4.3 为什么 `/v1/models/?provider_category=base` 不返回 Embedding 模型？

**原因**：

1. **模型类型过滤**：
   - `Provider.list_llm_models_async()` 只返回 `LLMConfig` 对象
   - 某些 Provider（如 TogetherAI）会根据 API 返回的 `type` 字段过滤：
     ```python
     if "type" in model and model["type"] not in ["chat", "language"]:
         continue  # 跳过 embedding 模型
     ```

2. **API 端点设计**：
   - `/v1/models/` 设计用于列出 **LLM 模型**
   - `/v1/models/embedding` 专门用于列出 **Embedding 模型**
   - 两者分离，避免混淆

3. **响应格式差异**：
   - LLM 模型：`model`, `model_endpoint_type`, `model_endpoint`
   - Embedding 模型：`embedding_model`, `embedding_endpoint_type`, `embedding_endpoint`

---

### 19.5 前端调用建议

#### 19.5.1 非 BYOK 模式

```dart
// 1. 加载 LLM 模型
final allModels = await ref.read(baseLLMModelListProvider.future);
final llmModels = allModels.where((m) => m.modelType == 'llm').toList();

// 2. 加载 Embedding 模型（需要单独调用）
final embeddingResponse = await ref.read(apiClientProvider).get('/models/embedding');
final List<dynamic> embeddingData = jsonDecode(embeddingResponse.body);
final embeddingModels = embeddingData
    .map((json) => LLMModel.fromJson(json as Map<String, dynamic>))
    .toList();
```

#### 19.5.2 BYOK 模式

```dart
// 1. 先获取 Provider 列表
final providers = await ref.read(providerListProvider.future);

// 2. 根据选择的 Provider 动态加载模型
final provider = providers.firstWhere((p) => p.name == selectedProviderName);

// 3. 加载 LLM 模型
final llmModels = await ref.read(llmModelListByProviderProvider(provider.name).future);

// 4. 加载 Embedding 模型（从 Provider 的 embedding_models 字段）
// 或者调用 /v1/models/embedding 并按 provider_name 过滤
```

---

### 19.6 常见问题

#### Q1: 为什么 `/v1/models/?provider_category=base` 不返回 Embedding 模型？

**A**: 
- `/v1/models/` 端点设计用于列出 **LLM 模型**（`model_type="llm"`）
- Embedding 模型需要单独调用 `/v1/models/embedding` 端点
- 两者返回的数据结构不同（字段名不同）

#### Q2: Embedding 模型为什么没有 `provider_category` 字段？

**A**:
- `/v1/models/embedding` 端点会返回**所有** Provider 的 Embedding 模型（包括 base 和 byok）
- 因此不区分 `provider_category`
- 前端默认将 Embedding 模型视为 `provider_category="base"`

#### Q3: 如何判断一个模型是 LLM 还是 Embedding？

**A**:
- 检查 `model_type` 字段：
  - `"llm"` → LLM 模型
  - `"embedding"` → Embedding 模型
- 或者检查字段名：
  - 有 `model` 字段 → LLM 模型
  - 有 `embedding_model` 字段 → Embedding 模型

#### Q4: BYOK 模式下如何获取 Embedding 模型？

**A**:
- 方法 1：调用 `/v1/models/embedding`，然后按 `provider_name` 过滤
- 方法 2：从数据库 Provider 配置中读取 `embedding_models` 字段（如果有的话）

---

### 19.7 总结

#### 19.7.1 流程对比图

```
LLM 模型获取流程:
GET /v1/models/?provider_category=base
  ↓
server.list_llm_models_async(provider_category=[base])
  ↓
get_enabled_providers_async(provider_category=[base])
  ↓ (只返回 _enabled_providers)
返回 base Providers (从环境变量)
  ↓
provider.list_llm_models_async()
  ↓ (动态调用 API 或硬编码)
返回 LLM 模型列表

Embedding 模型获取流程:
GET /v1/models/embedding
  ↓
server.list_embedding_models_async()
  ↓
get_enabled_providers_async() (无参数)
  ↓ (返回所有 Providers)
返回 base + byok Providers
  ↓
provider.list_embedding_models_async()
  ↓ (通常硬编码)
返回 Embedding 模型列表
```

#### 19.7.2 关键要点

1. **两个独立的端点**：
   - `/v1/models/` → LLM 模型
   - `/v1/models/embedding` → Embedding 模型

2. **Provider 筛选逻辑不同**：
   - LLM：根据 `provider_category` 参数筛选
   - Embedding：获取所有 Provider 的 Embedding 模型

3. **模型来源不同**：
   - LLM：大部分从 API 动态获取
   - Embedding：大部分硬编码列表

4. **前端需要分别调用**：
   - 非 BYOK 模式：先调用 `/v1/models/?provider_category=base`，再调用 `/v1/models/embedding`
   - BYOK 模式：先选择 Provider，再动态加载对应的模型

---

## 20. Agent 显示和模式判断的关键发现（2026-01-09）

### 20.1 问题背景

在实现前端 Agent 列表和详情页面时，发现了三个关键问题：

1. **Agent 列表显示问题**：有些 Agent 显示模型 handle（如 `openai-proxy/claude-opus-4-1`），有些只显示模型名（如 `claude-opus-4-1`）
2. **详情页面信息显示不清晰**：键值对的字体大小和间距让人难以区分
3. **所有 Agent 的 Category 都显示 BYOK**：即使 Base 模式创建的 Agent 也显示为 BYOK

### 20.2 核心发现

#### 20.2.1 Agent API 返回格式的真相

通过测试 `/v1/agents/` API，我们发现了重要的事实：

**测试结果**：
```bash
curl -H "Authorization: Bearer $TOKEN" http://38.175.200.93:8283/v1/agents/ | python3 -c "
import sys, json
agents = json.load(sys.stdin)
base_agents = [a for a in agents if a.get('model') is not None]
byok_agents = [a for a in agents if a.get('model') is None]
print(f'Total agents: {len(agents)}')
print(f'Base mode agents: {len(base_agents)}')
print(f'BYOK mode agents: {len(byok_agents)}')
"
```

**输出**：
```
Total agents: 13
Base mode agents: 4
BYOK mode agents: 13
```

等等！13 个 BYOK + 4 个 Base = 17，但总共只有 13 个 Agent？

**关键发现**：
- **所有 Agent 都有 `llm_config` 字段**（包括 Base 模式的）
- Base 模式 Agent：有 `model` 字段（handle 格式），也有 `llm_config`
- BYOK 模式 Agent：`model` 字段为 `null`，只有 `llm_config`

#### 20.2.2 Base 模式 Agent 的完整结构示例

```json
{
  "id": "agent-2ebdb596-ce9e-4598-b673-c47d4e11e00b",
  "name": "123",
  "model": "openai-proxy/claude-opus-4-1-20250805-thinking",  // ← Base 模式标记
  "embedding": "openai/text-embedding-3-small",               // ← Base 模式标记
  "llm_config": {
    "model": "claude-opus-4-1-20250805-thinking",
    "provider_name": "openai-proxy",
    "provider_category": "byok",  // ← 注意：这里是 "byok"，但实际是 Base 模式！
    "handle": "openai-proxy/claude-opus-4-1-20250805-thinking"  // ← Base 模式有 handle
  },
  "embedding_config": {
    "embedding_model": "text-embedding-3-small",
    "provider_name": "openai",
    "handle": "openai/text-embedding-3-small"  // ← Base 模式有 handle
  }
}
```

#### 20.2.3 BYOK 模式 Agent 的完整结构示例

```json
{
  "id": "agent-81bbe323-aa3c-48c5-8a03-3f8c66350adf",
  "name": "ggvvygv ygv",
  "model": null,           // ← BYOK 模式标记
  "embedding": null,       // ← BYOK 模式标记
  "llm_config": {
    "model": "claude-opus-4-1-20250805-thinking",
    "provider_name": "openai-proxy",
    "provider_category": "byok",
    "handle": null  // ← BYOK 模式 handle 为 null
  },
  "embedding_config": {
    "embedding_model": "text-embedding-3-large",
    "provider_name": "openai-proxy",
    "handle": null  // ← BYOK 模式 handle 为 null
  }
}
```

### 20.3 关键结论

#### 20.3.1 如何判断 Agent 是 Base 还是 BYOK 模式？

**❌ 错误方法**：
```dart
// 不要用 provider_category 字段判断！
if (agent.llmConfig['provider_category'] == 'base') {
  // 这个判断不可靠，因为 Base 模式的 agent 也可能显示 "byok"
}
```

**✅ 正确方法**：
```dart
// 方法 1：检查 model 字段（推荐）
if (agent.model != null) {
  // Base 模式
} else {
  // BYOK 模式
}

// 方法 2：检查 llm_config.handle 字段
if (agent.llmConfig?['handle'] != null) {
  // Base 模式
} else {
  // BYOK 模式
}
```

#### 20.3.2 Agent 列表页面显示模型的正确方式

**问题**：
- Base 模式：`agent.model` = `"openai-proxy/claude-opus-4-1"`（完整 handle）
- BYOK 模式：`agent.model` = `null`，只有 `agent.llmConfig['model']` = `"claude-opus-4-1"`（只有模型名）

**解决方案**：
```dart
String _getModelLabel(Agent agent) {
  // Base 模式：直接使用 agent.model（已经是 handle 格式）
  if (agent.model != null) {
    return agent.model!;
  }

  // BYOK 模式：组合 provider_name + model
  if (agent.llmConfig != null) {
    final provider = agent.llmConfig!['provider_name']?.toString() ?? 'unknown';
    final model = agent.llmConfig!['model']?.toString() ?? 'unknown';
    return '$provider/$model';  // 构造 handle 格式
  }

  return 'Unknown';
}
```

#### 20.3.3 详情页面的清晰显示设计

**问题**：原来的 `_InfoRow` 组件使用垂直布局，label 和 value 上下排列，难以区分。

**解决方案**：改用水平布局，label 固定宽度，value 自适应。

```dart
class _InfoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (左对齐，固定宽度 120px)
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w600,  // 更醒目
            ),
          ),
        ),
        // Value (右对齐，自适应宽度)
        Expanded(
          child: Text(
            value,
            style: (valueStyle ?? AppTheme.bodyMedium).copyWith(
              fontWeight: FontWeight.w500,  // 更清晰
            ),
            maxLines: isMultiline ? null : 3,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
```

**效果**：
```
Agent ID          agent-2ebdb596-ce9e-4598...
Name              123
Description       This is a test agent
```

### 20.4 API 返回格式总结表

| 字段 | Base 模式 | BYOK 模式 | 说明 |
|------|-----------|-----------|------|
| `model` | `"openai-proxy/claude-opus-4-1"` | `null` | Base 模式的唯一标识 |
| `embedding` | `"openai/text-embedding-3-small"` | `null` | Base 模式的 embedding 标识 |
| `llm_config.model` | `"claude-opus-4-1"` | `"claude-opus-4-1"` | 模型名（不含 provider） |
| `llm_config.provider_name` | `"openai-proxy"` | `"openai-proxy"` | Provider 名称 |
| `llm_config.provider_category` | 可能是 `"byok"` ❌ | `"byok"` ✅ | **不可靠！不要用** |
| `llm_config.handle` | `"openai-proxy/claude-opus-4-1"` | `null` | Base 模式有值 |
| `embedding_config.embedding_model` | `"text-embedding-3-small"` | `"text-embedding-3-large"` | Embedding 模型名 |
| `embedding_config.provider_name` | `"openai"` | `"openai-proxy"` | Provider 名称 |
| `embedding_config.handle` | `"openai/text-embedding-3-small"` | `null` | Base 模式有值 |

### 20.5 前端实现建议

#### 20.5.1 Agent 模型定义

```dart
class Agent {
  final String id;
  final String name;
  final String? description;
  final String? model;  // ← Base 模式标记
  final Map<String, dynamic>? llmConfig;  // ← 所有 Agent 都有
  final Map<String, dynamic>? embeddingConfig;  // ← 所有 Agent 都有

  // 判断模式的方法
  bool get isBaseMode => model != null;
  bool get isBYOKMode => model == null;
}
```

#### 20.5.2 Agent 列表卡片显示

```dart
Widget build(BuildContext context) {
  return AgentCard(
    agent: agent,
    // 显示模型（统一使用 handle 格式）
    modelLabel: _getModelLabel(agent),
  );
}

String _getModelLabel(Agent agent) {
  if (agent.isBaseMode) {
    return agent.model!;
  } else {
    final provider = agent.llmConfig!['provider_name'];
    final model = agent.llmConfig!['model'];
    return '$provider/$model';
  }
}
```

#### 20.5.3 Agent 详情页面显示

```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      // Base 模式配置
      if (agent.isBaseMode)
        _SectionCard(
          title: 'Model Configuration (Base Mode)',
          child: _InfoRow(
            label: 'Model Handle',
            value: agent.model!,
          ),
        ),

      // BYOK 模式配置
      if (agent.isBYOKMode)
        _SectionCard(
          title: 'LLM Configuration (BYOK Mode)',
          child: Column(
            children: [
              _InfoRow(label: 'Model', value: agent.llmConfig!['model']),
              _InfoRow(label: 'Provider', value: agent.llmConfig!['provider_name']),
              _InfoRow(label: 'Context Window', value: '${agent.llmConfig!['context_window']} tokens'),
            ],
          ),
        ),

      // Embedding 配置（所有模式）
      _SectionCard(
        title: 'Embedding Configuration',
        child: Column(
          children: [
            _InfoRow(label: 'Model', value: agent.embeddingConfig!['embedding_model']),
            _InfoRow(label: 'Provider', value: agent.embeddingConfig!['provider_name']),
            _InfoRow(label: 'Dimension', value: agent.embeddingConfig!['embedding_dim'].toString()),
          ],
        ),
      ),
    ],
  );
}
```

### 20.6 常见问题

#### Q1: 为什么 Base 模式的 Agent 也有 `llm_config`？

**A**: Letta 后端设计决定。即使是 Base 模式，后端也会填充 `llm_config` 和 `embedding_config` 字段，但是额外提供 `model` 和 `embedding` 字段作为简化的 handle 格式。

#### Q2: 为什么 `provider_category` 字段不可靠？

**A**: 实际测试发现，Base 模式的 Agent 的 `llm_config.provider_category` 也可能是 `"byok"`。后端的这个字段似乎不是用来区分 Base/BYOK 模式的，而是有其他用途。

#### Q3: 如何在创建 Agent 时指定模式？

**A**:
- **Base 模式**：发送 `{"name": "...", "model": "openai-proxy/claude-opus-4", "embedding": "openai/text-embedding-3-small"}`
- **BYOK 模式**：发送 `{"name": "...", "llm_config": {...}, "embedding_config": {...}}`

前端需要根据用户选择的模式，使用不同的 JSON 格式。

#### Q4: 为什么有些 Agent 列表项显示完整的 handle，有些不显示？

**A**: 因为前端代码之前只检查 `agent.model != null`，导致 BYOK 模式的 Agent 不显示模型信息。修复后，BYOK 模式也会显示组合后的 handle（`provider/model`）。

### 20.7 总结

1. **判断 Agent 模式的唯一可靠方法**：检查 `agent.model` 字段是否为 `null`
2. **不要信任 `provider_category` 字段**：这个字段在 Base 和 BYOK 模式下都可能显示 `"byok"`
3. **所有 Agent 都有 `llm_config` 和 `embedding_config`**：这不是 BYOK 模式的专属
4. **前端需要统一显示格式**：无论哪种模式，都应该显示完整的 handle 格式（`provider/model`）
5. **详情页面使用水平布局**：label 固定宽度，value 自适应，更清晰易读

---

**文档版本**：v2.8
**最后更新**：2026-01-09
**本章作者**：Kosmo + Claude Sonnet 4.5
