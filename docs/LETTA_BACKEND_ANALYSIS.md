# Letta 后端工具能力分析

**Date**: 2026-01-11
**Purpose**: 分析 Letta 后端是否支持远程开发所需的工具执行能力

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
