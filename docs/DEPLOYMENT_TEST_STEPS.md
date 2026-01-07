# Letta Klui 部署测试完整步骤

**创建时间**: 2026-01-07
**作者**: Kosmo
**目的**: 记录完整的部署测试流程，避免重复踩坑

---

## 前提条件

### 系统要求
- **操作系统**: Linux (Ubuntu/Debian 推荐)
- **Docker**: 已安装并运行
- **Docker Compose**: 已安装
- **Python**: 3.8+ (用于 HTTP 服务器)
- **Flutter SDK**: 3.38.5+ (用于构建前端)

### API 凭证
- **OpenAI API Key** (用于 LLM)
- **OpenAI API Base URL**
- **Embedding API Key** (可选，推荐使用 Letta 免费服务)

---

## 第一阶段：Letta 后端部署

### 1.1 创建 Letta 目录并配置

```bash
# 克隆或拉取 Letta 代码
cd /path/to/work
git clone https://github.com/letta-ai/letta.git
cd letta

# 或更新已有代码
git pull origin main
```

### 1.2 创建环境变量文件

创建 `.env` 文件：

```bash
# OpenAI Configuration
OPENAI_API_KEY=sk-your-llm-api-key
OPENAI_API_BASE=https://your-api-base.com/v1

# Database Configuration
LETTA_PG_USER=letta
LETTA_PG_PASSWORD=letta
LETTA_PG_DB=letta
LETTA_PG_PORT=5432

# Debug Mode
LETTA_DEBUG=True

# CORS Configuration
# 重要：必须包含前端访问地址，否则浏览器会报 CORS 错误
ACCEPTABLE_ORIGINS=http://localhost:8080,http://localhost:8081,http://localhost:3000,http://localhost:4200,http://YOUR_IP:8080,http://YOUR_IP:8081
```

**关键点**：
- ⚠️ **CORS 配置至关重要**：必须将前端地址加入 `ACCEPTABLE_ORIGINS`
- ⚠️ **IP 地址 vs localhost**：如果前端和后端不在同一机器，必须使用实际 IP，不能用 localhost

### 1.3 修改 Docker Compose 配置

编辑 `compose.yaml`，在 `letta_server` 服务的 `environment` 部分添加：

```yaml
- ACCEPTABLE_ORIGINS=${ACCEPTABLE_ORIGINS:-http://localhost:8080,http://localhost:8081}
```

**为什么需要这一步**：
- `.env` 文件的 `ACCEPTABLE_ORIGINS` 不会自动传递到容器
- 必须在 `compose.yaml` 中显式声明环境变量

### 1.4 启动 Letta 容器

```bash
docker compose down  # 停止旧容器（如果有）
docker compose up -d  # 启动新容器
```

### 1.5 验证容器状态

```bash
docker compose ps
```

应该看到三个容器都在运行：
- `letta-letta_db-1` - PostgreSQL 数据库 (状态: healthy)
- `letta-letta_server-1` - Letta API 服务器 (状态: running)
- `letta-letta_nginx-1` - Nginx 反向代理 (状态: running)

端口映射：
- `8283` - API 端口
- `8083` - WebSocket 端口
- `80` - Nginx 端口
- `5432` - PostgreSQL 端口

### 1.6 测试 API 连接

```bash
# 等待服务完全启动（约 10 秒）
sleep 10

# 测试 API
curl http://localhost:8283/v1/agents/
```

应该返回 `[]` (空的 agent 列表)。

**重要发现**：
- ✅ API 路径是 `/v1/` **不是** `/api/v1/`
- ❌ 前端配置必须使用正确的路径

---

## 第二阶段：创建 Provider

### 2.1 理解 Provider 架构

Letta 使用两个独立的 Provider：
1. **LLM Provider** - 用于对话生成
2. **Embedding Provider** - 用于向量嵌入

**为什么需要两个 Provider**：
- LLM 和 Embedding 可能使用不同的 API Key
- 可以使用不同的服务（如 LLM 用第三方，Embedding 用官方）
- 提供更好的配额管理和监控

### 2.2 创建 LLM Provider

```bash
curl -X POST http://localhost:8283/v1/providers/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "openai-proxy",
    "provider_type": "openai",
    "base_url": "https://your-api-base.com/v1",
    "api_key": "sk-your-llm-api-key"
  }'
```

### 2.3 创建 Embedding Provider

**选项 A：使用 Letta 免费服务（推荐）**

不需要创建，Letta 自动提供。

**选项 B：使用自定义 Embedding API**

```bash
curl -X POST http://localhost:8283/v1/providers/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "openai-embedding",
    "provider_type": "openai",
    "base_url": "https://your-api-base.com/v1",
    "api_key": "sk-your-embedding-api-key"
  }'
```

### 2.4 验证 Provider 创建

```bash
curl http://localhost:8283/v1/providers/
```

应该看到刚创建的 provider。

---

## 第三阶段：创建测试 Agent

### 3.1 创建 Agent

```bash
curl -X POST http://localhost:8283/v1/agents/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Agent",
    "description": "A test agent from Klui",
    "model": "openai-proxy/YOUR_MODEL_NAME",
    "system": "You are a helpful assistant.",
    "embedding_config": {
      "embedding_provider_name": "openai-embedding",
      "embedding_endpoint_type": "openai",
      "embedding_model": "text-embedding-3-small",
      "embedding_dim": 1536
    }
  }'
```

**关键点**：
- ✅ `model` 格式：`provider-name/model-name`
- ✅ `embedding_config` 必须包含 `embedding_endpoint_type` 和 `embedding_dim`
- ❌ 如果使用 Letta 免费 embedding，参考文档第 7.2 节

### 3.2 验证 Agent 创建

```bash
curl http://localhost:8283/v1/agents/ | python3 -m json.tool
```

应该看到刚创建的 agent。

---

## 第四阶段：前端构建

### 4.1 配置 API 地址

**关键概念**：
- 前端代码中使用 `localhost:8283` 仅适用于本地开发
- 远程部署时必须使用服务器的**实际 IP 地址**
- **不要把 IP 写死在代码里**，使用构建时参数

### 4.2 构建前端

```bash
cd /path/to/klui

# 使用构建时参数传入 API 地址
flutter build web --release --dart-define=API_BASE_URL=http://YOUR_IP:8283
```

**为什么使用 `--dart-define`**：
- ✅ IP 地址不会写死在源代码中
- ✅ 可以在不同环境使用不同配置
- ✅ 代码仍然是 `String.fromEnvironment`，保持灵活性

### 4.3 验证构建

```bash
# 检查构建输出中是否包含正确的 IP
grep -o "http://YOUR_IP:8283/v1" build/web/main.dart.js

# 检查构建文件
ls -lh build/web/
```

应该看到 `main.dart.js` (约 2.4MB) 和其他资源文件。

---

## 第五阶段：部署前端

### 5.1 启动 HTTP 服务器

```bash
cd build/web
python3 -m http.server 8080
```

或者后台运行：

```bash
nohup python3 -m http.server 8080 > /dev/null 2>&1 &
```

### 5.2 测试 CORS

**重要**：在浏览器中测试，而不是 curl。

创建测试页面 `/tmp/test_cors.html`：

```html
<!DOCTYPE html>
<html>
<head><title>CORS Test</title></head>
<body>
<h1>Testing Letta API CORS</h1>
<button onclick="testAPI()">Test API</button>
<pre id="result"></pre>
<script>
async function testAPI() {
  try {
    const response = await fetch('http://YOUR_IP:8283/v1/agents/', {
      method: 'GET',
      headers: {'Content-Type': 'application/json'}
    });
    const data = await response.json();
    document.getElementById('result').textContent =
      `Success! Found ${data.length} agents:\n` +
      data.map(a => `- ${a.name}`).join('\n');
  } catch (error) {
    document.getElementById('result').textContent = `Error: ${error.message}`;
  }
}
</script>
</body>
</html>
```

在浏览器中访问 `http://YOUR_IP:8080/test_cors.html`，点击按钮测试。

**如果 CORS 正确**：
- ✅ 显示 "Success! Found X agents"
- ✅ 浏览器 Console 无 CORS 错误

**如果 CORS 错误**：
- ❌ Console 显示: "No 'Access-Control-Allow-Origin' header"
- 🔧 解决：检查 `ACCEPTABLE_ORIGINS` 环境变量，重启容器

### 5.3 访问主应用

在浏览器中访问：`http://YOUR_IP:8080`

**应该看到**：
- ✅ Agent 列表显示 "Test Agent"
- ✅ 点击右上角刷新按钮可以重新加载
- ✅ 无 Console 错误

---

## 常见问题和解决方案

### 问题 1: 前端一直转圈加载

**症状**: 浏览器显示 loading spinner，永不停止

**原因**: API 地址错误
- ❌ 前端使用 `localhost:8283`，但浏览器在远程机器
- ✅ 必须使用服务器实际 IP 地址

**解决**:
```bash
# 重新构建，使用正确的 IP
flutter build web --release --dart-define=API_BASE_URL=http://ACTUAL_IP:8283
```

### 问题 2: CORS 错误

**症状**: Console 显示 "No 'Access-Control-Allow-Origin' header"

**原因**: Letta 服务器没有配置允许的源

**解决**:
1. 检查 `.env` 文件中的 `ACCEPTABLE_ORIGINS`
2. 检查 `compose.yaml` 中是否声明了环境变量
3. 重启容器：
```bash
docker compose down
docker compose up -d
```

4. 验证环境变量：
```bash
docker exec letta-letta_server-1 printenv | grep ACCEPTABLE
```

### 问题 3: "No agents found"

**症状**: API 有数据，但前端显示空列表

**原因**: 前端代码没有解析 JSON 响应

**解决**:
- ✅ 检查 `api_providers.dart` 中的 `agentList` provider
- ✅ 确保使用了 `jsonDecode()` 和 `Agent.fromJson()`
- ✅ 重新生成代码：`dart run build_runner build`
- ✅ 重新构建前端

### 问题 4: API 路径错误 (404)

**症状**: 所有 API 请求返回 404

**原因**: API 路径配置错误
- ❌ 使用了 `/api/v1/agents/`
- ✅ 应该使用 `/v1/agents/`

**解决**:
检查 `app_config.dart` 中的 `fullApiBaseUrl`：
```dart
static String get fullApiBaseUrl => '$apiBaseUrl/$apiVersion';
// 不要写成 '$apiBaseUrl/api/$apiVersion'
```

### 问题 5: Provider 格式错误

**症状**: "Provider not supported" 或 "Model not found"

**原因**: Model 格式不正确

**正确格式**:
- ✅ `openai-proxy/gpt-4o-mini` (provider/model-name)
- ❌ `gpt-4o-mini` (缺少 provider 前缀)
- ❌ `openai/gpt-4o-mini` (provider 不存在)

**解决**:
1. 检查已创建的 providers：`curl http://localhost:8283/v1/providers/`
2. 使用正确的 provider name
3. 检查可用的 models：`curl http://localhost:8283/v1/models/`

---

## 部署检查清单

### Letta 后端
- [ ] `.env` 文件已配置，包含 API Keys
- [ ] `compose.yaml` 添加了 `ACCEPTABLE_ORIGINS` 环境变量
- [ ] 容器全部启动并 healthy
- [ ] API 本地测试成功：`curl http://localhost:8283/v1/agents/`
- [ ] Provider 已创建
- [ ] 测试 Agent 已创建

### 前端构建
- [ ] 使用正确的 IP 地址构建：`--dart-define=API_BASE_URL=http://IP:8283`
- [ ] 构建成功，无编译错误
- [ ] `main.dart.js` 包含正确的 API URL

### 部署和测试
- [ ] HTTP 服务器运行在端口 8080
- [ ] CORS 测试通过
- [ ] 浏览器访问主页面成功
- [ ] Agent 列表正常显示
- [ ] Console 无错误

---

## 架构原理

### 1. API 路径结构

```
http://YOUR_IP:8283/v1/agents/
                   ^   ^
                   |   |
                   |   +-- API endpoint
                   +------ API version (不是 /api/v1/)
```

### 2. CORS 工作原理

```
浏览器 (http://YOUR_IP:8080)
        ↓
    Fetch 请求
        ↓
Letta API (http://YOUR_IP:8283)
        ↓
    检查 Origin 头
        ↓
  是否在 ACCEPTABLE_ORIGINS 中？
        ↓
    是 → 返回数据 + Access-Control-Allow-Origin
    否 → CORS 错误
```

### 3. Provider 选择机制

```
Agent 创建时的 model 字段: "openai-proxy/claude-haiku-4-5-20251001"
                                      ^             ^
                                      |             |
                                  provider     model name
                                      |
                    根据 provider name 查找数据库中的 Provider
                                      |
                    使用 Provider 的 api_key 和 base_url
```

### 4. 前端构建流程

```
源代码 (app_config.dart)
    ↓
String.fromEnvironment('API_BASE_URL')
    ↓
构建时传入 --dart-define=API_BASE_URL=http://...
    ↓
编译后的代码包含实际 IP
    ↓
部署到服务器
```

---

## 下一步

完成基础部署后，可以继续：

1. **实现 Agent 详情页面** - 查看和编辑 Agent
2. **实现聊天功能** - 与 Agent 对话
3. **实现创建 Agent 表单** - 用户自定义 Agent
4. **添加认证功能** - 用户登录和权限管理
5. **优化 UI/UX** - 更好的用户体验

---

**更新历史**:
- 2026-01-07: 初始版本，记录第一次成功部署
