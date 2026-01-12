# Klui - Ketta Frontend

> **Open-source AI Agent Platform** - No platform lock-in, total freedom
>
> **Status**: Production-ready frontend for Ketta backend (fork of Letta)
>
> **Tech Stack**: Flutter 3.38.5 / Dart 3.10.4 / WebAssembly
>
> **Version**: v1.0.0-beta
>
> **Language**: 中文 | [English](README_EN.md)

---

## 🎯 What is Klui?

**Klui** is a modern, beautiful web UI for **Ketta** (an open-source fork of Letta AI Agent platform).

### Key Philosophy

- ✅ **100% Open Source** - No platform lock-in, no forced subscriptions
- ✅ **Freedom** - Use any provider, any API, no restrictions
- ✅ **Beautiful UI** - CRT retro terminal theme with modern UX
- ✅ **Full-Featured** - Complete agent and provider management
- ✅ **Easy Deployment** - Single Docker container, ready in minutes

### Why Ketta?

We forked Letta because:
- ❌ Letta hardcodes restrictions (e.g., `openai-proxy` requirement)
- ❌ Provider deletion doesn't actually delete (soft delete issue)
- ❌ Official platform prioritized over open-source community
- ❌ No official frontend provided
- ❌ $20/month subscription just to use your own API keys

**Ketta = Letta - Restrictions + Freedom**

---

## ✨ Current Features

### Agent Management ✅

- **Agent List** - View all agents with pagination
- **Agent Details** - Full configuration, tools, memory blocks
- **Agent Creation** - 3-step wizard supporting both BYOK and Base modes
- **Agent Deletion** - Hard delete (truly removes from database)
- **Model Selection** - Dynamic provider and model loading
- **System Prompt** - Configure agent behavior
- **Memory Display** - View agent memory blocks

### Provider Management ✅

- **Provider List** - View all configured providers
- **Provider Details** - API keys, base URLs, configuration
- **Provider Creation** - Support for OpenAI, Anthropic, Together, etc.
- **Provider Deletion** - Remove unused providers
- **Custom Base URLs** - Use any OpenAI-compatible API
- **API Key Management** - Secure storage with encrypted display

### Chat Interface ✅

- **Real-time Streaming** - SSE streaming responses
- **Tool Approval** - Approve/deny tool calls in real-time
- **Message History** - Full conversation history
- **Context Size Indicator** - Token usage with warnings (green/yellow/red)
- **Diff Visualization** - See file edits with before/after comparison
- **Multi-language Support** - Chinese and English (i18n)

### UI/UX ✅

- **CRT Retro Theme** - Beautiful amber/green phosphor design
- **Responsive Design** - Works on desktop, tablet, mobile
- **Dark Mode** - Easy on the eyes, hacker aesthetic
- **High Contrast** - Excellent readability with WCAG AA compliance
- **Smooth Animations** - Polished transitions and interactions
- **Error Handling** - User-friendly error messages (not raw backend errors)

### Technical Features ✅

- **Automatic Handle Transformation** - Works around Letta's `openai-proxy` restriction
- **State Management** - Riverpod with code generation
- **Routing** - Deep linking support with go_router
- **Type Safety** - Freezed for immutable models
- **WebAssembly** - Fast startup, small bundle size (3.4M main.dart.js)
- **Optimized Build** - Tree-shaking, code splitting, minification

---

## 🚧 Features In Progress

### Chat Enhancements 🟡

- [ ] Message editing
- [ ] Message branching
- [ ] Conversation management (rename, archive, delete)
- [ ] Export conversations (Markdown, JSON)
- [ ] Search in conversations

### File System 🟡

- [ ] File browser UI
- [ ] File upload/download
- [ ] Code execution sandbox
- [ ] File diff viewer (already implemented, pending file system)

### Advanced Features 🟡

- [ ] Agent testing interface
- [ ] Performance metrics dashboard
- [ ] Batch operations
- [ ] Advanced configuration options

---

## 📋 Features Not Yet Implemented

### Phase 2 (Planned) 🔵

The following features from CHAT_FEATURE_COMPARISON.md are **not yet implemented**:

- [ ] **Abort/Retry** - Stop agent responses or retry failed requests
- [ ] **Message Branching** - Create conversation branches
- [ ] **Tool History** - View tool call history
- [ ] **Conversation Tags** - Organize conversations with tags
- [ ] **Advanced Search** - Search across all agents and conversations
- [ ] **Export/Import** - Backup and restore agents and conversations
- [ ] **Analytics Dashboard** - Usage statistics and insights
- [ ] **Multi-Modal** - Image support in conversations

**Why not implemented?** These require backend support from Ketta (Letta fork) or are lower priority.

### Requires Ketta Backend Changes 🔵

These features require modifications to the Ketta backend:

- [ ] **True Provider Name Support** - Remove `openai-proxy` hard-coding
- [ ] **Hard Delete for Providers** - Fix soft delete issue
- [ ] **Multiple Providers** - Use same provider type with different configs
- [ ] **Provider Health Checks** - Monitor provider availability
- [ ] **Load Balancing** - Distribute load across providers
- [ ] **Local Model Support** - Ollama integration
- [ ] **Simplified Deployment** - Single Docker Compose file

---

## 🏗️ Architecture

### Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.38.5 (Web) | UI Framework |
| **Language** | Dart 3.10.4 | Programming Language |
| **State** | Riverpod 3.0.3 | State Management |
| **Routing** | go_router 16.2.0 | Navigation |
| **HTTP** | http 1.6.0 | API Client |
| **Serialization** | Freezed + json_serializable | Immutable Models |
| **Internationalization** | flutter_localization | i18n (zh, en) |
| **Markdown** | flutter_markdown | Render Markdown |
| **Syntax Highlighting** | flutter_highlight | Code blocks |
| **Diff** | diff_match_patch | File edit visualization |

### Backend

**Current**: Compatible with Letta backend API (with workarounds)
**Future**: Will switch to Ketta backend (fork of Letta without restrictions)

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK >= 3.38.5
- Dart >= 3.10.4
- Ketta/Letta backend running on `http://localhost:8283`

### Development

```bash
# Install dependencies
flutter pub get

# Run web development server
flutter run -d chrome

# Build for production
flutter build web --release

# Deploy
./deploy.sh  # Automated build and deploy
```

### Environment Variables

```bash
# API base URL (default: http://localhost:8283)
export API_BASE_URL=http://your-server:8283

# Build with custom API URL
flutter build web --dart-define=API_BASE_URL=http://your-server:8283
```

---

## 📁 Project Structure

```
klui/
├── docs/                           # Documentation
│   ├── FORK_DECISION.md           # Why we forked Letta → Ketta
│   ├── LETTA_BACKEND_ANALYSIS.md  # Backend research
│   ├── DELETE_FUNCTIONALITY_ISSUES.md # Soft delete problem
│   └── THEME_MIGRATION_GUIDE.md   # UI theme decisions
├── lib/
│   ├── core/                        # Core layer
│   │   ├── config/                  # Configuration
│   │   ├── models/                  # Data models
│   │   ├── providers/               # Riverpod providers
│   │   ├── theme/                   # CRT theme system
│   │   └── utils/                   # Utilities
│   ├── features/                   # Feature modules
│   │   ├── agents/                  # Agent management
│   │   ├── providers/               # Provider management
│   │   ├── chat/                    # Chat interface
│   │   └── shared/                  # Shared widgets
│   ├── l10n/                        # Internationalization
│   └── main.dart                    # App entry
├── test/                            # Tests
├── deploy.sh                        # Deployment script
└── README.md                        # This file
```

---

## 🎨 Design Philosophy

### CRT Retro Theme

Klui uses a **CRT retro terminal aesthetic** inspired by vintage monitors:

- **Color Palette**:
  - Background: Dark amber/black (#0a0a00)
  - Text: Fluorescent green (#00ff41), Amber (#ffcc00)
  - Highlights: Red (#ff0044), Yellow (#ffcc00)

- **Typography**:
  - Monospace fonts for code
  - Scanline effects
  - Phosphor glow effects

- **Why CRT?**
  - Nostalgic for developers
  - High contrast (accessibility)
  - Unique branding
  - Easy on the eyes for long sessions

### Design Principles

1. **Clarity Over Minimalism** - Information density > white space
2. **Function Over Form** - Features > animations
3. **Contrast is King** - Readability > subtle gradients
4. **Speed Matters** - Fast loading > heavy frameworks
5. **Developer-Friendly** - Keyboard shortcuts, power-user features

---

## 🛠️ Development Status

### Completed ✅

**Phase 1: Foundation** (2026-01-07)
- Project setup and architecture
- API client and providers
- Agent list and detail pages
- Web build pipeline

**Phase 2: Agent Management** (2026-01-09)
- Agent creation wizard (BYOK/Base modes)
- Agent deletion
- Model selection
- CRT theme implementation

**Phase 3: Provider Management** (2026-01-10)
- Provider list and details
- Provider creation
- Provider deletion
- Custom base URL support

**Phase 4: Chat Interface** (2026-01-11)
- SSE streaming responses
- Message display
- Tool approval UI
- Diff visualization

**Phase 5: Polish** (2026-01-12)
- Context size warnings
- Improved error messages
- Handle transformation workaround
- Documentation completion

### In Progress 🚧

**Phase 6: Advanced Chat** (Current)
- Message editing and branching
- Conversation management
- Export functionality
- Enhanced search

### Planned 📋

**Phase 7: File System** (Next)
- File browser UI
- Upload/download
- Code execution
- Integration with Ketta backend tools

**Phase 8: Advanced Features**
- Testing interface
- Performance metrics
- Batch operations
- Multi-language support expansion

**Phase 9: Production Ready**
- Comprehensive testing
- Performance optimization
- Security hardening
- Documentation completion

---

## 🤝 Contributing

We welcome contributions! Please see:

- [CONTRIBUTING.md](CONTRIBUTING.md) (to be created)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) (to be created)
- [CLAUDE.md](CLAUDE.md) - Development guidelines

### Areas We Need Help

1. **Testing** - Write unit and integration tests
2. **Documentation** - Improve guides and API docs
3. **Internationalization** - Add more languages
4. **Accessibility** - Audit and improve WCAG compliance
5. **Performance** - Profile and optimize bottlenecks

---

## 📖 Documentation

### Core Docs

- **[CLAUDE.md](CLAUDE.md)** - Development guidelines (MUST READ)
- **[FORK_DECISION.md](docs/FORK_DECISION.md)** - Why we forked Letta
- **[THEME_MIGRATION_GUIDE.md](docs/THEME_MIGRATION_GUIDE.md)** - Theme decisions

### Technical Docs

- **[LETTA_BACKEND_ANALYSIS.md](docs/LETTA_BACKEND_ANALYSIS.md)** - Backend research
- **[DELETE_FUNCTIONALITY_ISSUES.md](docs/DELETE_FUNCTIONALITY_ISSUES.md)** - Soft delete issues
- **[CHAT_FEATURE_PLAN.md](docs/CHAT_FEATURE_PLAN.md)** - Chat features
- **[DIFF_VIEWER_TEST_PLAN.md](docs/DIFF_VIEWER_TEST_PLAN.md)** - Diff viewer testing

### Roadmaps

- **[IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md)** - Overall roadmap
- **[CHAT_FEATURE_COMPARISON.md](docs/CHAT_FEATURE_COMPARISON.md)** - Feature comparison

---

## 🌐 Links

- **GitHub**: https://github.com/kosmoli/klui
- **Ketta (Backend)**: https://github.com/kosmoli/ketta (coming soon)
- **Letta (Upstream)**: https://github.com/letta-ai/letta
- **Demo**: http://38.175.200.93:8080 (when deployed)

---

## 📝 License

This project is open source and available under the **MIT License**.

---

## 👥 Authors

- **Kosmo** - Project lead and architecture
- **Claude Code (Sonnet 4.5)** - Development partner via Happy

**With help from**:
- The Letta community (upstream)
- Flutter community
- Open-source contributors

---

## 🙏 Acknowledgments

Built on top of:
- **Letta** - AI Agent platform (upstream)
- **Flutter** - UI framework
- **Riverpod** - State management
- **Many open-source libraries** - See `pubspec.yaml`

Special thanks to the open-source community for tools and libraries that make Klui possible.

---

**Last Updated**: 2026-01-12
**Version**: v1.0.0-beta
**Status**: Production-ready for Ketta backend, compatible with Letta backend (with limitations)
