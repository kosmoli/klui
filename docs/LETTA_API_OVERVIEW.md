# Letta REST API 完整概览

> **生成时间**: 2026-01-05
> **API 总数**: 235 个 endpoints
> **API 标签**: 33 个

## 目录

- [1. API 统计概览](#1-api-统计概览)
- [2. 核心 API 模块](#2-核心-api-模块)
- [3. Agents API 详细说明](#3-agents-api-详细说明)
- [4. 其他关键 API](#4-其他关键-api)
- [5. 数据模型](#5-数据模型)
- [6. 前端功能需求分析](#6-前端功能需求分析)

---

## 1. API 统计概览

### 1.1 按 Tag 分类的 Endpoint 数量

| Tag | Endpoints | 描述 |
|-----|-----------|------|
| **agents** | 52 | Agent 管理（核心） |
| **tools** | 21 | 工具管理 |
| **sources** | 14 | 数据源管理 |
| **templates** | 17 | 模板管理（Cloud-only） |
| **identities** | 18 | 身份管理 |
| **folders** | 13 | 文件夹管理 |
| **groups** | 13 | Agent 组管理 |
| **archives** | 8 | 档案管理 |
| **runs** | 9 | 运行管理 |
| **blocks** | 9 | 记忆块管理 |
| **messages** | 7 | 消息管理 |
| **mcp-servers** | 10 | MCP 服务器管理 |
| **providers** | 7 | Provider 管理 |
| **tags** | 1 | 标签管理 |
| **steps** | 6 | 步骤管理 |
| **projects** | 3 | 项目管理 |
| **models** | 3 | 模型列表 |
| **chat** | 1 | 聊天接口 |
| **embeddings** | 1 | Embedding 接口 |
| **health** | 1 | 健康检查 |
| **llms** | 2 | LLM 相关 |
| **passages** | 1 | 段落管理 |
| **voice** | 1 | 语音接口 |
| **jobs** | 5 | 任务管理 |
| **telemetry** | 1 | 遥测 |
| **metadata** | 2 | 元数据 |
| **clientSideAccessTokens** | 3 | 客户端令牌 |
| **scheduledMessages** | 3 | 定时消息 |
| **admin** | 2 | 管理接口 |
| **_internal_agents** | 2 | 内部 Agent |
| **_internal_blocks** | 4 | 内部 Blocks |
| **_internal_runs** | 1 | 内部 Runs |
| **_internal_templates** | 6 | 内部 Templates |

### 1.2 核心功能优先级

**高优先级**（MVP 必需）：
- ✅ Agents - 52 endpoints
- ✅ Messages - 7 endpoints
- ✅ Tools - 21 endpoints
- ✅ Providers - 7 endpoints
- ✅ Models - 3 endpoints

**中优先级**（增强功能）：
- Sources (14) - 数据源管理
- Archives (8) - 档案管理
- Runs (9) - 运行历史
- Blocks (9) - 记忆块

**低优先级**（高级功能）：
- Templates (17) - Cloud-only
- Folders (13) - 文件组织
- Groups (13) - Agent 组
- MCP Servers (10) - 集成

---

## 2. 核心 API 模块

### 2.1 Agents API (52 endpoints)

**用途**: Agent 的完整生命周期管理

**核心功能**：

#### 基础 CRUD
```
GET    /v1/agents/                    # 列出所有 agents
POST   /v1/agents/                    # 创建新 agent
GET    /v1/agents/{agent_id}          # 获取 agent 详情
PATCH  /v1/agents/{agent_id}          # 修改 agent
DELETE /v1/agents/{agent_id}          # 删除 agent
GET    /v1/agents/count              # 统计 agent 数量
```

#### 消息交互
```
POST   /v1/agents/{agent_id}/messages            # 发送消息
POST   /v1/agents/{agent_id}/messages/stream     # 流式发送
POST   /v1/agents/{agent_id}/messages/async      # 异步发送
GET    /v1/agents/{agent_id}/messages            # 列出消息
POST   /v1/agents/{agent_id}/messages/cancel     # 取消发送
```

#### 记忆管理
```
GET    /v1/agents/{agent_id}/core-memory              # 获取核心记忆
GET    /v1/agents/{agent_id}/core-memory/blocks       # 列出记忆块
GET    /v1/agents/{agent_id}/core-memory/blocks/{label} # 获取特定块
PATCH  /v1/agents/{agent_id}/core-memory/blocks/{label} # 修改记忆块

GET    /v1/agents/{agent_id}/archival-memory          # 列出档案记忆
POST   /v1/agents/{agent_id}/archival-memory          # 创建档案
GET    /v1/agents/{agent_id}/archival-memory/search   # 搜索档案
DELETE /v1/agents/{agent_id}/archival-memory/{id}     # 删除档案
```

#### 工具管理
```
GET    /v1/agents/{agent_id}/tools               # 列出工具
PATCH  /v1/agents/{agent_id}/tools/attach/{id}  # 附加工具
PATCH  /v1/agents/{agent_id}/tools/detach/{id}  # 分离工具
POST   /v1/agents/{agent_id}/tools/{name}/run   # 运行工具
```

#### 数据源和档案
```
GET    /v1/agents/{agent_id}/sources             # 列出数据源
PATCH  /v1/agents/{agent_id}/sources/attach/{id} # 附加数据源
PATCH  /v1/agents/{agent_id}/sources/detach/{id} # 分离数据源

PATCH  /v1/agents/{agent_id}/archives/attach/{id} # 附加档案
PATCH  /v1/agents/{agent_id}/archives/detach/{id} # 分离档案
```

#### 高级功能
```
POST   /v1/agents/{agent_id}/summarize              # 总结消息
PATCH  /v1/agents/{agent_id}/reset-messages         # 重置消息
GET    /v1/agents/{agent_id}/context                # 获取上下文
GET    /v1/agents/{agent_id}/export                 # 导出 agent
POST   /v1/agents/import                            # 导入 agent
POST   /v1/agents/search                            # 搜索 agents
```

### 2.2 Tools API (21 endpoints)

**用途**: 管理可用的工具（Functions）

**核心功能**：

```
GET    /v1/tools/                  # 列出所有工具
POST   /v1/tools/                  # 创建工具
PUT    /v1/tools/                  # 更新或创建工具
GET    /v1/tools/{tool_id}         # 获取工具详情
PATCH  /v1/tools/{tool_id}         # 修改工具
DELETE /v1/tools/{tool_id}         # 删除工具
POST   /v1/tools/search            # 搜索工具
POST   /v1/tools/run               # 运行工具
GET    /v1/tools/count             # 统计工具数量
POST   /v1/tools/add-base-tools    # 添加基础工具
```

**MCP 服务器集成**：
```
GET    /v1/tools/mcp/servers                    # 列出 MCP 服务器
PUT    /v1/tools/mcp/servers                    # 添加 MCP 服务器
PATCH  /v1/tools/mcp/servers/{name}             # 更新 MCP 服务器
DELETE /v1/tools/mcp/servers/{name}             # 删除 MCP 服务器
POST   /v1/tools/mcp/servers/test               # 测试 MCP 服务器
POST   /v1/tools/mcp/servers/connect            # 连接 MCP 服务器
GET    /v1/tools/mcp/servers/{name}/tools       # 列出 MCP 工具
POST   /v1/tools/mcp/servers/{name}/resync      # 重新同步工具
POST   /v1/tools/mcp/servers/{name}/{tool}      # 添加 MCP 工具
POST   /v1/tools/mcp/servers/{name}/{t}/execute # 执行 MCP 工具
```

### 2.3 Providers API (7 endpoints)

**用途**: 管理模型 providers（OpenAI, Anthropic, etc.）

```
GET    /v1/providers/              # 列出所有 providers
POST   /v1/providers/              # 创建 provider
GET    /v1/providers/{id}          # 获取 provider 详情
PATCH  /v1/providers/{id}          # 修改 provider
DELETE /v1/providers/{id}          # 删除 provider
POST   /v1/providers/check         # 检查 provider 配置
POST   /v1/providers/{id}/check    # 检查现有 provider
```

### 2.4 Models API (3 endpoints)

**用途**: 列出可用的 LLM 和 Embedding 模型

```
GET    /v1/models/                 # 列出 LLM 模型
GET    /v1/models/embedding        # 列出 Embedding 模型
GET    /v1/models/embeddings       # 获取 embedding 模型列表
```

### 2.5 Messages API (7 endpoints)

**用途**: 全局消息管理（跨 agents）

```
GET    /v1/messages/               # 列出所有消息
POST   /v1/messages/search        # 搜索消息
POST   /v1/messages/batches       # 创建批量消息
GET    /v1/messages/batches       # 列出批量任务
GET    /v1/messages/batches/{id}  # 获取批量任务详情
PATCH  /v1/messages/batches/{id}/cancel  # 取消批量任务
GET    /v1/messages/batches/{id}/messages # 获取批量消息
```

---

## 3. Agents API 详细说明

### 3.1 创建 Agent

**Endpoint**: `POST /v1/agents/`

**核心参数**：

```json
{
  "name": "agent-name",
  "model": "openai/gpt-4.1",                    // 或使用 llm_config
  "embedding": "openai/text-embedding-3-small", // 或使用 embedding_config
  "memory_blocks": [
    {"label": "human", "value": "User details..."},
    {"label": "persona", "value": "AI persona..."}
  ],
  "system": "You are a helpful assistant.",
  "tools": ["web_search", "run_code"],
  "temperature": 0.7,
  "max_tokens": 4096
}
```

**详细配置（使用 llm_config）**：

```json
{
  "name": "agent-name",
  "llm_config": {
    "model": "gpt-4.1",
    "model_endpoint_type": "openai",
    "model_endpoint": "https://api.openai.com/v1",
    "provider_name": "openai",
    "context_window": 128000,
    "temperature": 0.7,
    "max_tokens": 4096
  },
  "embedding_config": {
    "embedding_endpoint_type": "openai",
    "embedding_endpoint": "https://api.openai.com/v1",
    "embedding_model": "text-embedding-3-small",
    "embedding_dim": 1536
  },
  "memory_blocks": [...],
  "tools": [...]
}
```

### 3.2 发送消息

**Endpoint**: `POST /v1/agents/{agent_id}/messages`

**请求**：
```json
{
  "messages": [
    {"role": "user", "content": "Hello!"}
  ],
  "stream": false,
  "stream_options": {}
}
```

**响应**：
```json
{
  "messages": [
    {
      "id": "msg-xxx",
      "role": "assistant",
      "content": "Hello! How can I help you?",
      "date": "2026-01-05T..."
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 20,
    "total_tokens": 30
  },
  "stop_reason": "end_turn"
}
```

**流式响应**：
- 使用 `POST /v1/agents/{agent_id}/messages/stream`
- 返回 Server-Sent Events (SSE)
- 需要 EventSource 或 fetch stream 处理

### 3.3 获取和修改记忆

**获取核心记忆**：
```
GET /v1/agents/{agent_id}/core-memory
```

**修改记忆块**：
```
PATCH /v1/agents/{agent_id}/core-memory/blocks/{label}
{
  "value": "Updated content"
}
```

**获取档案记忆**：
```
GET /v1/agents/{agent_id}/archival-memory
```

**搜索档案**：
```
POST /v1/agents/{agent_id}/archival-memory/search
{
  "query": "search text",
  "limit": 10
}
```

---

## 4. 其他关键 API

### 4.1 Sources API (14 endpoints)

**用途**: 管理数据源（文件、文档等）

```
GET    /v1/sources/                      # 列出数据源
POST   /v1/sources/                      # 创建数据源
GET    /v1/sources/{id}                  # 获取详情
DELETE /v1/sources/{id}                  # 删除数据源
POST   /v1/sources/{id}/upload           # 上传文件
GET    /v1/sources/{id}/files            # 列出文件
GET    /v1/sources/{id}/passages         # 列出段落
GET    /v1/sources/{id}/agents           # 列出使用此源的 agents
```

### 4.2 Archives API (8 endpoints)

**用途**: 长期记忆档案管理

```
POST   /v1/archives/                     # 创建档案
GET    /v1/archives/                     # 列出档案
GET    /v1/archives/{id}                 # 获取详情
DELETE /v1/archives/{id}                 # 删除档案
POST   /v1/archives/{id}/passages        # 添加段落
DELETE /v1/archives/{id}/passages/{pid}  # 删除段落
```

### 4.3 Runs API (9 endpoints)

**用途**: 运行历史和监控

```
GET    /v1/runs/                          # 列出运行
GET    /v1/runs/active                    # 列出活跃运行
GET    /v1/runs/{id}                      # 获取运行详情
GET    /v1/runs/{id}/messages             # 获取运行消息
GET    /v1/runs/{id}/metrics              # 获取指标
GET    /v1/runs/{id}/steps                # 获取步骤
GET    /v1/runs/{id}/usage                # 获取使用统计
POST   /v1/runs/{id}/stream               # 流式获取运行
DELETE /v1/runs/{id}                      # 删除运行
```

### 4.4 Blocks API (9 endpoints)

**用途**: 记忆块管理（全局，非 agent 特定）

```
GET    /v1/blocks/                        # 列出所有块
POST   /v1/blocks/                        # 创建块
GET    /v1/blocks/{id}                    # 获取块详情
PATCH  /v1/blocks/{id}                    # 修改块
DELETE /v1/blocks/{id}                    # 删除块
GET    /v1/blocks/{id}/agents             # 列出使用此块的 agents
```

---

## 5. 数据模型

### 5.1 Agent 对象

```json
{
  "id": "agent-uuid",
  "name": "agent-name",
  "created_at": "2026-01-05T...",
  "llm_config": {
    "model": "gpt-4.1",
    "model_endpoint": "...",
    "provider_name": "openai",
    "context_window": 128000,
    "temperature": 0.7
  },
  "embedding_config": {...},
  "memory": {
    "blocks": [
      {
        "id": "block-uuid",
        "label": "human",
        "value": "User details...",
        "limit": 2000
      }
    ]
  },
  "tools": [...],
  "system": "System prompt..."
}
```

### 5.2 Message 对象

```json
{
  "id": "msg-uuid",
  "role": "assistant|user|tool",
  "content": "Message content",
  "date": "2026-01-05T...",
  "step_info": {...},
  "usage": {...}
}
```

### 5.3 Provider 对象

```json
{
  "id": "provider-uuid",
  "name": "openai",
  "provider_type": "openai|anthropic|...",
  "provider_category": "base|byok",
  "base_url": "https://...",
  "models": [...]
}
```

### 5.4 Tool 对象

```json
{
  "id": "tool-uuid",
  "name": "web_search",
  "description": "Search the web",
  "source_code": "...",
  "json_schema": {...},
  "tags": ["letta_core"],
  "default_requires_approval": false
}
```

---

## 6. 前端功能需求分析

### 6.1 核心功能模块（MVP）

#### 1. Agent 管理界面
- [ ] Agent 列表（分页、搜索、筛选）
- [ ] 创建 Agent 向导
- [ ] Agent 详情页
- [ ] 编辑 Agent 配置
- [ ] 删除 Agent
- [ ] Agent 导入/导出

#### 2. 聊天界面
- [ ] 实时聊天（支持流式响应）
- [ ] 消息历史显示
- [ ] 工具调用可视化
- [ ] 记忆块显示和编辑
- [ ] 消息搜索

#### 3. 记忆管理
- [ ] 核心记忆块管理
- [ ] 档案记忆搜索
- [ ] 段落 CRUD
- [ ] 记忆可视化

#### 4. 工具管理
- [ ] 工具列表
- [ ] 创建/编辑工具
- [ ] 工具测试
- [ ] MCP 服务器管理

#### 5. Provider 管理
- [ ] Provider 列表
- [ ] 创建 Provider
- [ ] 检查 Provider 连接
- [ ] 模型列表查看

#### 6. 运行监控
- [ ] 运行历史
- [ ] 实时日志
- [ ] 使用统计
- [ ] 性能指标

### 6.2 UI/UX 设计要点

#### 布局设计
- **侧边栏导航**: Agents, Tools, Providers, Sources, Runs
- **主内容区**: 根据选择动态加载
- **聊天窗口**: 固定在右侧或独立页面

#### 交互模式
- **Agent 卡片**: 显示名称、模型、最后更新时间
- **创建向导**: 多步骤表单（基本信息 → 记忆 → 工具 → 高级配置）
- **聊天界面**: 类似 ChatGPT，但增强工具调用可视化
- **记忆编辑**: 侧边抽屉或模态框

#### 响应式设计
- 支持桌面、平板、手机
- 移动端聊天界面全屏
- 桌面端三栏布局（列表 | 聊天 | 详情）

### 6.3 技术栈建议

**前端框架**:
- React / Vue / Svelte
- 推荐使用组件库：shadcn/ui, Ant Design, Material-UI

**状态管理**:
- Zustand / Redux / Pinia

**HTTP 客户端**:
- Fetch API / Axios
- 流式响应：EventSource 或 fetch with ReadableStream

**实时通信**:
- WebSocket（可选）
- Server-Sent Events（SSE）

**构建工具**:
- Vite / Next.js / Nuxt

### 6.4 关键技术挑战

#### 1. 流式响应处理
```typescript
// SSE 示例
const eventSource = new EventSource('/v1/agents/{id}/messages/stream');
eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data);
  // 更新 UI
};
```

#### 2. 认证处理
- Bearer Token 认证
- 请求头注入：`Authorization: Bearer {token}`

#### 3. 错误处理
- 网络错误重试
- 友好的错误提示
- 表单验证

#### 4. 性能优化
- 虚拟滚动（长列表）
- 代码分割
- 懒加载
- 缓存策略

---

## 附录

### A. 完整 API 端点列表

235 个 endpoints 的完整列表见 `fern/openapi.json`

### B. 认证方式

所有 API 请求需要认证：

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8283/v1/agents/
```

### C. 错误处理

标准错误响应格式：

```json
{
  "detail": "Error message",
  "trace_id": "...",
  "error_code": "INVALID_ARGUMENT"
}
```

---

**文档版本**: v1.0
**最后更新**: 2026-01-05
**作者**: Claude Code (Sonnet 4.5)
