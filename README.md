# Letta Flutter Frontend Project

> **项目名称**: Letta Agent Management UI
> **技术栈**: Flutter 3.32+ / Dart 3.6+
> **创建时间**: 2026-01-05
> **版本**: v1.0.0-alpha

## 项目概述

基于 Flutter 开发的跨平台 Letta Agent 管理界面，支持 Web、iOS、Android、macOS、Windows、Linux 六大平台。

## 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter SDK | 3.32+ | UI 框架 |
| Dart | 3.6+ | 编程语言 |
| Riverpod | 3.0+ | 状态管理 |
| go_router | 16.x | 路由管理 |
| flutter_http_sse | 1.1+ | SSE 流式响应 |

## 核心功能

- [x] Agent 管理（列表、创建、编辑、删除）
- [x] 实时聊天（流式响应）
- [x] 记忆管理（核心记忆、档案记忆）
- [x] 工具管理
- [x] Provider 管理
- [ ] Source 管理
- [ ] Archive 管理
- [ ] 运行监控

## 项目结构

```
frontend-project/
├── docs/                          # 项目文档
│   ├── FLUTTER_PLAN_2026.md       # 技术方案
│   ├── LETTA_API_OVERVIEW.md      # API 文档
│   └── CLAUDE_INSTRUCTIONS.md     # 开发指令
├── lib/                           # Flutter 源代码（待创建）
├── test/                          # 测试代码（待创建）
└── README.md                      # 本文件
```

## 快速开始

### 前置要求

- Flutter SDK >= 3.32
- Dart >= 3.6
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
# Web 构建
flutter build web --release --wasm

# 移动端构建
flutter build apk --release
flutter build ipa --release

# 桌面端构建
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

## 开发进度

- [ ] Phase 1: 基础架构（2 周）
  - [ ] 项目初始化
  - [ ] Riverpod + go_router 配置
  - [ ] API 客户端
- [ ] Phase 2: Agents 功能（3 周）
- [ ] Phase 3: 聊天功能（2 周）
- [ ] Phase 4: 其他功能（4 周）
- [ ] Phase 5: 优化和发布（2 周）

## 相关链接

- [Letta 官方文档](https://docs.letta.com)
- [Letta GitHub](https://github.com/letta-ai/letta)
- [Flutter 官方文档](https://docs.flutter.dev)
- [Riverpod 文档](https://riverpod.dev)

---

**开发者**: Kosmo & Claude Code (Sonnet 4.5)
**最后更新**: 2026-01-05
**项目地址**: https://github.com/kosmoli/klui
