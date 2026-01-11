# Letta Code 功能完整分析

**Last Updated**: 2026-01-11
**Purpose**: 了解 Letta Code 除了 CLI UI 外还提供了什么能力

---

## 🎯 Letta Code 的核心定位

Letta Code 不是一个简单的 CLI 工具，而是一个**完整的 Agent 开发和交互平台**。

**与 Claude Code/Codex 的本质区别**：
- ❌ Claude Code: Session-based（每次都是新会话）
- ✅ Letta Code: Agent-based（持久化 Agent，跨会话学习）

---

## 📦 Letta Code 提供的七大核心能力

### 1. 🎨 **Terminal UI (TUI)**

**技术栈**: Ink (React for CLI)

**功能**:
- 实时聊天界面
- 消息流式显示
- 工具调用展示
- 批准请求交互
- 错误处理和重试

**文件**: `src/cli/App.tsx` (27KB，约900行)

---

### 2. 🤖 **Headless Mode** (无头模式)

**用途**: 脚本集成、自动化任务

```bash
# 单次提示（无UI）
letta -p "hello world"

# JSON 输出（便于脚本解析）
letta -p "hello" --output-format json

# 流式 JSON（双向通信）
letta -p "hello" --output-format stream-json --input-format stream-json
```

**功能**:
- 无交互界面的纯文本模式
- 支持多种输出格式（text, json, stream-json）
- 支持标准输入输出（pipeline 集成）

**文件**: `src/index.ts` (主入口)
**相关**: `src/headless.ts` (70KB - headless 模式实现)

---

### 3. 🛠️ **本地工具执行系统** (Client-side Tools)

**核心**: 让 Agent 能够执行本地命令和操作文件系统

**工具管理**: `src/tools/`
- `manager.ts` (25KB) - 工具生命周期管理
- `toolDefinitions.ts` (14KB) - 工具定义
- `filter.ts` - 工具过滤器
- `schemas/` - 工具 schema 定义

**内置工具类型**:
1. **Bash** - Shell 命令执行
2. **文件操作** - read, write, edit 文件
3. **搜索** - 代码库搜索
4. **MCP** - Model Context Protocol 集成

**工具规范**:
```typescript
(args, opts?) => Promise<{
  toolReturn: string;
  status: "success" | "error";
  stdout?: string[];
  stderr?: string[];
}>
```

**关键特性**:
- ✅ 序列化执行（避免文件竞争）
- ✅ AbortSignal 支持（可中断）
- ✅ 错误统一处理
- ✅ stdout/stderr 捕获

**对我们 Klui 的启示**:
- Web 版可能不需要本地工具执行
- 但需要处理 Agent 调用 Letta 后端工具的情况
- 工具调用的 UI 展示逻辑可以参考

---

### 4. 🔐 **权限管理系统** (Permission System)

**目录**: `src/permissions/`

**组件**:
1. **analyzer.ts** (16KB) - 分析工具调用的安全性
2. **checker.ts** (13KB) - 检查权限规则
3. **matcher.ts** (6KB) - 匹配权限模式
4. **mode.ts** (7KB) - 权限模式（auto, manual, yolo）
5. **session.ts** - 会话权限状态

**权限模式**:
```typescript
enum PermissionMode {
  AUTO,      // 自动批准安全工具
  MANUAL,    // 每个工具都需要用户确认
  YOLO,      // 全自动（不安全，仅用于沙盒环境）
}
```

**分析维度**:
- 文件路径（读/写敏感文件）
- Shell 命令（删除、修改系统）
- 网络请求（外部API调用）
- 数据库操作

**对我们 Klui 的启示**:
- Web 版可能不需要本地权限检查
- 但需要理解 Letta 后端的 `approval_request` 消息
- 需要实现工具批准的 UI（approve/reject 按钮）

---

### 5. 💾 **持久化和配置管理** (Profiles & Settings)

**目录**: `src/` 根目录

**组件**:
- `settings-manager.ts` (32KB) - 设置管理器
- `settings.ts` (5KB) - 设置定义
- `project-settings.ts` - 项目级设置

**配置层次**:
```
1. 全局配置: ~/.config/letta/settings.json
   - 可用的所有项目
   - OAuth 凭证信息
   - 用户偏好设置

2. 项目配置: .letta/settings.local.json
   - 项目特定的 pinned agents
   - 项目级别的设置

3. Profile 系统:
   /profile save <name>    # 保存当前 agent 为 profile
   /profiles               # 列出所有 profiles
   /pin                    # 固定到当前项目
   /unpin                  # 从项目取消固定
```

**对我们 Klui 的启示**:
- Web 版需要类似的"收藏"或"最近使用"功能
- 需要保存用户偏好的模型设置
- LocalStorage/IndexedDB 存储用户配置

---

### 6. 🧠 **记忆和技能系统** (Memory & Skills)

**记忆管理**:
```
/init                    # 初始化 Agent 记忆
/remember [instruction]  # 添加到记忆
/memory                  # 查看记忆内容
```

**技能系统** (.skills/ 目录):
- `adding-models/` - 添加新模型的技能
- `memory-defrag/` - 记忆整理技能
```
/skill [instruction]    # 从当前轨迹学习技能
```

**技能学习**:
- Agent 可以从使用过程中学习新技能
- 技能是可复用的代码模块
- 可以保存到 `.skills/` 目录

**对我们 Klui 的启示**:
- 初期不需要技能系统（太复杂）
- 但需要理解 Letta 后端的 memory 相关 API
- 记忆查看功能可能很有用

---

### 7. 🔌 **LSP 集成** (Language Server Protocol)

**目录**: `src/lsp/`

**文件**:
- `client.ts` (6KB) - LSP 客户端
- `manager.ts` (7KB) - LSP 管理器
- `servers/` - LSP 服务器配置

**功能**:
- 代码补全
- 诊断信息
- 符号跳转
- 代码格式化

**对我们 Klui 的启示**:
- Web 版不需要 LSP（那是编辑器功能）
- 但可以参考其架构设计

---

## 📊 Letta Code 的完整功能列表

### CLI 命令（34个）

**Agent 管理**:
- `/new` - 创建新 Agent
- `/agents` - 列出所有 Agents
- `/rename` - 重命名当前 Agent
- `/subagents` - 管理 Sub-agents

**会话管理**:
- `/clear` - 清除当前会话消息（保留记忆）
- `/resume` - 恢复之前的对话
- `/exit` - 退出

**配置**:
- `/model <handle>` - 切换模型
- `/system <id>` - 切换系统提示
- `/toolset <name>` - 切换工具集
- `/stream` - 切换流式输出模式

**记忆**:
- `/init` - 初始化记忆
- `/remember` - 添加到记忆
- `/memory` - 查看记忆
- `/description` - 查看描述

**Profiles**:
- `/profile save <name>` - 保存 profile
- `/profiles` - 列出 profiles
- `/pin` - 固定到项目
- `/unpin` - 取消固定
- `/pinned` - 列出固定的 profiles

**认证**:
- `/connect` - 连接到 Letta Cloud
- `/disconnect` - 断开连接
- `/logout` - 登出

**搜索**:
- `/search` - 搜索消息历史
- `/usage` - 查看使用统计

**高级**:
- `/skill` - 学习技能
- `/mcp` - MCP 服务器管理
- `/yolo-ralph` - 调试模式
- `/feedback` - 发送反馈
- `/help` - 帮助
- `/ade` - 管理员模式
- `/bg` - 后台任务
- `/compact` - 紧凑模式
- `/download` - 下载对话

**调试**:
- `/ralph` - Ralph 模式（工具自动执行）
- `/stream` - 切换流式输出

---

## 🎯 对 Klui 的关键启示

### ✅ 我们应该实现的

1. **基本聊天功能** (Phase 1)
   - 消息列表展示
   - 实时流式响应
   - 用户输入框
   - 消息历史

2. **消息类型支持** (Phase 1-2)
   - 用户消息
   - Assistant 消息
   - 工具调用消息
   - 工具返回消息
   - 推理消息（可选展示）
   - 错误消息

3. **批准工作流** (Phase 2)
   - 显示工具调用请求
   - Approve/Reject 按钮
   - 批准理由输入

4. **Agent 管理** (已有)
   - Agent 列表/详情 ✅
   - Agent 创建 ✅
   - Agent 编辑（待实现）

5. **配置管理** (Phase 2-3)
   - 模型选择
   - System prompt 编辑
   - 工具集配置

### ❌ 我们不需要的

1. **本地工具执行** - Web 无法也不应该执行本地命令
2. **LSP 集成** - 这是编辑器功能
3. **Headless 模式** - Web 应用有 UI
4. **文件系统操作** - 不需要（安全考虑）

### ⏸️ 暂时不需要的

1. **技能系统** - 太复杂，后期再说
2. **记忆管理** - 可以通过 Letta 后端 API
3. **Profiles/Pinning** - 可以简化为"收藏"功能

---

## 📁 重要代码模块分析

### 1. 消息流式处理

**文件**: `src/cli/helpers/stream.ts` (推测)

**核心逻辑**:
```typescript
// 处理 SSE 流
for await (const event of stream) {
  if (event.message_type === 'assistant_message') {
    // 追加到消息内容
    updateMessage(event.content);
  } else if (event.message_type === 'tool_call_message') {
    // 显示工具调用，等待批准
    showApprovalDialog(event);
    const approved = await waitForUserApproval();
    if (approved) {
      sendApproval(event.tool_call_id);
    }
  }
}
```

**对应我们的 Flutter 实现**:
- 使用 `flutter_http_sse` 或自己解析 SSE
- 使用 `StreamBuilder` 或 `StreamController` 更新 UI

### 2. 批准工作流

**Letta Code 的流程**:
```
1. 接收 tool_call_message
2. 分析工具安全性（permission analyzer）
3. 显示批准对话框（InlineApproval 组件）
4. 用户选择 approve/reject
5. 发送 approval_response_message
6. 继续执行
```

**我们需要的简化版本**:
```
1. 接收 tool_call_message
2. 显示工具调用详情
3. 用户点击 approve/reject
4. 发送批准请求到 Letta API
```

### 3. 消息状态管理

**Letta Code 使用 React state**:
```typescript
const [messages, setMessages] = useState<Message[]>([]);
const [isStreaming, setIsStreaming] = useState(false);
const [pendingApprovals, setPendingApprovals] = useState<ApprovalRequest[]>([]);
```

**我们的 Flutter 实现**:
```dart
class ChatNotifier extends StateNotifier<ChatState> {
  final List<LettaMessage> messages;
  final bool isStreaming;
  final List<ApprovalRequest> pendingApprovals;

  Future<void> sendMessage(String content) async {
    // 发送消息
    // 处理流式响应
    // 更新状态
  }
}
```

---

---

## 🧠 5. 记忆系统 (Memory System) - Backend-Managed

### ⚠️ 重要纠正

**之前的误解**：我以为 Letta Code 的记忆系统是在客户端实现的。

**正确理解**：
- ✅ 记忆系统是 **Letta 后端实现** 的
- ✅ Letta Code 通过 **Letta API SDK** 与后端记忆系统交互
- ✅ "本地工具" 指的是运行在 **Letta 服务器端** 的工具（不是 Flutter app 设备）
- ✅ 我们的 Flutter 需要通过 API 管理/控制这些服务端工具

### 5.1 记忆系统架构

**Letta 后端提供的 API**（来自 `@letta-ai/letta-client`）:

```typescript
// 获取 Agent 的所有记忆块
await client.agents.blocks.list(agentId);

// 获取单个记忆块
await client.blocks.retrieve(blockId);

// 创建记忆块
await client.blocks.create({
  label: "project",
  value: "Project description...",
  description: "Project information",
  limit: 1000
});

// 更新记忆块
await client.blocks.update(blockId, {
  value: "Updated content..."
});

// 删除记忆块
await client.blocks.delete(blockId);

// 将记忆块附加到 Agent
await client.agents.blocks.attach(blockId, { agent_id: agentId });

// 从 Agent 分离记忆块
await client.agents.blocks.detach(blockId, { agent_id: agentId });
```

**Agent 检索时会包含记忆**:
```typescript
const agent = await client.agents.retrieve(agentId);
// agent.memory.blocks 包含所有记忆块
```

### 5.2 Letta Code 的记忆命令

**`/init` 命令**（`src/agent/prompts/init_memory.md`）:
- 不是直接操作 API
- 是一个 **系统提示**，告诉 Agent 如何初始化自己的记忆
- Agent 会调用 **backend 的 memory tools**（core_memory, archival_memory）
- Agent 通过工具创建/更新记忆块

**`/remember` 命令**（`src/agent/prompts/remember.md`）:
- 同样是 **系统提示**，告诉 Agent 记住某些信息
- Agent 通过 **backend 的 memory tools** 存储信息

**`/memory` 命令**（显示记忆）:
- Letta Code 调用 `client.agents.retrieve()` 获取 Agent 数据
- 从 `agent.memory.blocks` 读取记忆块
- 使用 `MemoryViewer` 组件展示（`src/cli/components/MemoryViewer.tsx`）

### 5.3 记忆块类型

**全局记忆块**（Global blocks，跨项目共享）:
```typescript
- persona      // Agent 行为指导
- human        // 用户偏好
```

**项目记忆块**（Project blocks，项目特定）:
```typescript
- project           // 项目信息
- skills            // 已加载的技能列表（read-only）
- loaded_skills     // 技能描述（read-only）
```

**自定义块**（Agent 可创建任意数量的自定义块）:
```typescript
- ticket      // 当前工单上下文
- context     // 调试笔记
- decisions   // 架构决策记录
```

### 5.4 Letta Code 的 MemoryViewer UI

**展示内容**:
```typescript
interface Block {
  id: string;
  label: string;          // 块名称
  value: string;          // 块内容
  description?: string;   // 描述（重要！）
  limit?: number;         // 字符限制
  count?: number;         // 当前字符数
  read_only?: boolean;    // 是否只读
}
```

**UI 功能**:
- 📄 分页显示（每页 3 个块）
- 🔍 搜索/过滤
- 📖 详细视图（显示完整内容，可滚动）
- 🔗 跳转到 Letta Cloud Web UI（`app.letta.com/agents/{id}?view=memory`）

**代码示例**（`src/cli/App.tsx:7091`）:
```typescript
<MemoryViewer
  blocks={agentState?.memory?.blocks || []}
  agentId={agentId}
  agentName={agentName}
  onClose={closeOverlay}
/>
```

### 5.5 对我们的 Flutter 实现的意义

**我们需要实现**:

1. **获取 Agent 记忆**:
```dart
// lib/core/providers/memory_providers.dart (新建)
@riverpod
Future<List<Block>> agentBlocks(Ref ref, String agentId) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/$agentId/blocks');
  return ApiHelper.parseList(response, Block.fromJson);
}

@riverpod
Future<AgentWithBlocks> agentWithMemory(Ref ref, String agentId) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/$agentId');
  return ApiHelper.parseSingle(response, AgentWithBlocks.fromJson);
}
```

2. **记忆管理 UI**（后期功能）:
   - 记忆列表页面（类似 Provider 列表）
   - 记忆详情页面（显示 label, description, value, limit）
   - 创建/编辑/删除记忆块的表单

3. **API 端点**（需要在 Letta 后端确认）:
```
GET    /agents/{agent_id}/blocks          # 获取所有块
GET    /blocks/{block_id}                 # 获取单个块
POST   /agents/{agent_id}/blocks          # 创建块（attach）
PUT    /blocks/{block_id}                 # 更新块内容
DELETE /agents/{agent_id}/blocks/{block_id} # 分离块
```

**当前优先级**:
- ⏸️ **Phase 1**: 不实现记忆管理 UI（先做聊天功能）
- ✅ **Phase 2**: 只读显示记忆块（在 Agent 详情页）
- ⏸️ **Phase 3**: 完整的记忆管理功能（创建/编辑/删除）

**为什么不是优先级**:
- 聊天功能是核心
- 记忆管理是高级功能
- 可以在 Letta Cloud Web UI 上管理记忆（通过链接跳转）

---

## 🧩 6. 工具系统 (Tool System) - Hybrid Architecture ⚠️ 重要纠正

### 6.1 Letta Code 是**混合架构**

**之前完全误解了！** 你的质疑是正确的！

**正确理解**：Letta Code 有 **两种工具**：

#### **类型 1: 服务端工具**（Server-Side Tools）
在 Letta 后端服务器执行，通过 `baseTools` 附加到 Agent：
```typescript
// src/agent/create.ts:135
const defaultBaseTools = [
  "memory",              // 记忆管理
  "web_search",          // 网页搜索
  "conversation_search", // 对话搜索
  "fetch_webpage",       // 获取网页
];
```

#### **类型 2: 客户端工具**（Client-Side Tools）✅
在 **Letta Code 客户端**（用户机器）执行，通过 `client_tools` 在运行时传递：
```typescript
// 客户端工具列表（src/tools/manager.ts）
const ANTHROPIC_DEFAULT_TOOLS = [
  "Read",    // 读取本地文件
  "Write",   // 写入本地文件
  "Edit",    // 编辑本地文件
  "Bash",    // 执行本地命令
  "Grep",    // 搜索本地文件
  "Glob",    // 查找本地文件
  "Skill",   // 技能管理
  "Task",    // 子任务
  // ... 等等
];
```

**关键证据**（`src/agent/create.ts:129`）：
```typescript
// Only attach server-side tools to the agent.
// Client-side tools (Read, Write, Bash, etc.) are passed via client_tools at runtime,
// NOT attached to the agent. This is the new pattern - no more stub tool registration.
```

### 6.2 客户端工具的实现

**文件操作工具**（`src/tools/impl/Read.ts`, `Write.ts`）：
```typescript
import { promises as fs } from "node:fs";

// 操作用户本地文件系统
const userCwd = process.env.USER_CWD || process.cwd();
const resolvedPath = path.resolve(userCwd, file_path);

// 读取本地文件
const content = await fs.readFile(resolvedPath, "utf-8");
```

**命令执行工具**（`src/tools/impl/Bash.ts`）：
```typescript
import { spawn } from "node:child_process";

// 在用户本地环境执行命令
const userCwd = process.env.USER_CWD || process.cwd();
const childProcess = spawn(executable, args, {
  cwd: userCwd,  // 当前工作目录
  env: process.env,  // 用户环境变量
});
```

**工具 README 标题**（`src/tools/README.md:1`）：
```
# Client-side tool guidelines
How to implement tools that run locally in Letta Code.
```

### 6.3 Letta Code 的工具执行流程（完整版）

**混合执行流程**：
```
1. 用户在终端输入消息（如 "帮我修改 src/main.ts"）
2. Letta Code 发送到 Letta 后端
3. 后端 Agent 决定调用客户端工具（如 Read, Edit）
4. 后端返回 tool_call_message（指定调用哪个客户端工具）
5. Letta Code 接收 tool_call_message
6. Letta Code 分析工具安全性（permission analyzer）
7. 显示批准对话框（InlineApproval 组件）
8. 用户批准/拒绝
9. ✅ 批准后，Letta Code 在**客户端本地**执行工具
   - Read: 读取用户本地文件（Node.js fs.readFile）
   - Write: 写入用户本地文件（Node.js fs.writeFile）
   - Bash: 在用户机器执行命令（Node.js child_process.spawn）
10. Letta Code 将工具返回结果（tool_return_message）发送给后端
11. 后端 Agent 继续处理并返回最终响应
12. Letta Code 显示最终结果
```

**关键点（已纠正）**：
- ✅ Read/Write/Edit 操作的是 **Letta Code 客户端所在机器的文件**
- ✅ Bash 执行的是 **Letta Code 客户端所在机器的命令**
- ✅ 工具执行在 **客户端进程**中进行（Node.js runtime）
- ✅ 这就是为什么 Letta Code 能像 Claude Code 一样操作本地文件！
- ⚠️ 不是所有工具都在服务器执行！

### 6.4 客户端工具的工作目录

**环境变量 `USER_CWD`**：
```typescript
// 所有文件/命令工具都使用这个目录
const userCwd = process.env.USER_CWD || process.cwd();
```

- `USER_CWD` 由 Letta Code 在启动时设置
- 默认为用户运行 `letta` 命令的当前目录
- 所有客户端工具都相对于这个目录操作文件

**证据**（所有工具文件中都有这行）：
```typescript
// src/tools/impl/Read.ts:135
// src/tools/impl/Write.ts:16
// src/tools/impl/Bash.ts:222
const userCwd = process.env.USER_CWD || process.cwd();
```

### 6.5 对我们的 Flutter Web 应用的影响

**我们的架构与 Letta Code 的区别**：

| 特性 | Letta Code (CLI) | 我们的 Flutter Web App |
|------|------------------|----------------------|
| 运行环境 | 用户本地终端 (Node.js) | Web 浏览器 |
| 文件访问 | ✅ 可以访问用户本地文件 | ❌ 无法直接访问用户文件系统 |
| 命令执行 | ✅ 可以执行本地命令 | ❌ 无法执行本地命令 |
| 工具执行 | ✅ 客户端工具 + 服务端工具 | ⚠️ 只有服务端工具 |

**我们的 Flutter 实现重点**：
1. ✅ **显示工具调用消息**（tool_call_message）
2. ✅ **显示工具返回结果**（tool_return_message）
3. ✅ **批准/拒绝工作流**（UI + API）
4. ❌ **不需要实现客户端工具**（Web 无法访问本地文件系统）
5. ✅ **只支持服务端工具**（memory, web_search, etc.）

**为什么我们不实现客户端工具**：
- Flutter Web 运行在浏览器沙盒中
- 无法直接访问用户本地文件系统（安全限制）
- 无法执行用户本地的 shell 命令
- File System Access API 需要用户显式授权每个文件
- 不适合作为通用编程工具的客户端

**Letta Code = CLI 工具**（可以访问本地文件）
**我们的 Klui = Web UI**（只能通过 API 操作后端）

这是一个根本的架构差异！

---

## 🚀 总结：Letta Code = CLI + Client Tools + Server Tools + Permissions + Memory

**核心价值（已纠正）**:
1. ✅ **CLI UI** - 参考其消息展示和工具调用 UI
2. ✅ **客户端工具** - Letta Code 特有（操作本地文件），我们不需要（Web 限制）
3. ✅ **服务端工具** - 我们只支持这些（memory, web_search, etc.）
4. ✅ **权限系统** - 理解批准工作流（客户端和服务端工具都需要批准）
5. ⏸️ **记忆系统** - 后端管理，后期实现 UI（先只读显示）
6. ❌ **LSP** - 不需要

**架构差异（关键）**:

| 特性 | Letta Code | Klui (Flutter Web) |
|------|-----------|-------------------|
| **客户端工具** | ✅ Read, Write, Bash（操作本地文件） | ❌ 无法实现（浏览器沙盒） |
| **服务端工具** | ✅ memory, web_search | ✅ 支持 |
| **运行环境** | Node.js（本地终端） | Web 浏览器 |
| **文件访问** | ✅ 用户本地文件系统 | ❌ 无法直接访问 |

**最重要的学习资源**:
1. `src/cli/App.tsx` - 完整的聊天 UI 实现
2. `src/cli/components/Inline*Approval.tsx` - 批准 UI 组件
3. `src/agent/message.ts` - SSE 流式处理逻辑
4. `src/permissions/` - 权限分析和检查逻辑
5. `src/cli/components/MemoryViewer.tsx` - 记忆查看器 UI（后期参考）
6. `src/tools/` - 客户端工具实现（了解即可，我们不需要）

**关键 API 调用**（来自 `@letta-ai/letta-client`）:
```typescript
// Agent 管理
client.agents.retrieve(agentId)          // 获取 Agent（包含 memory.blocks）
client.agents.blocks.list(agentId)        // 获取记忆块列表
client.blocks.retrieve(blockId)           // 获取单个记忆块

// 消息和工具调用
client.agents.messages.create(agentId, {
  messages: [{ role: "user", content: "..." }],
  // Letta Code: client_tools (Read, Write, Bash, etc.)
  // Klui: 不传递 client_tools（我们没有客户端工具）
})
client.agents.messages.stream(agentId, {...})  // SSE 流式响应

// 工具批准（服务端和客户端工具都通过这个 API 批准）
client.agents.runs.submitToolOutputs(runId, {
  tool_outputs: [{ tool_call_id, output }]
})
```

**我们的 Flutter 实现重点**:
1. ✅ 聊天 UI（发送消息、显示响应）
2. ✅ SSE 流式响应处理
3. ✅ 工具调用显示（tool_call_message）
4. ✅ 工具返回显示（tool_return_message）
5. ✅ 批准/拒绝 UI（InlineApproval）
6. ⏸️ 记忆查看 UI（Phase 2）
7. ❌ 客户端工具（不实现 - Web 限制）

---

**下一步行动**: 参考这些组件实现我们的 Flutter Web 聊天功能！
