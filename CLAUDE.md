# Klui Dev Instructions for AI

**Project**: Letta Flutter UI (klui)
**Owner**: Kosmo
**Repo**: https://github.com/kosmoli/klui

## Priority Rules

### 1. Git Golden Rules (CRITICAL - Follow Strictly)
- ✅ **Commit ONLY** - Never use stash as backup
- ✅ **Verify content** - `git diff --cached` before every commit
- ✅ **Complete restoration** - Never selective file restore
- ✅ **Deploy chain verify** - Git → Build → Server → Browser
- ❌ **No stash backup** - Use commit, not stash
- ❌ **No selective restore** - Restore all or nothing
- ❌ **No trust in labels** - Verify actual content only

**Emergency if code lost**:
```bash
git reflog show --date=format='%m-%d %H:%M:%S' | head -50
git reset --hard <target-commit>
git commit -m "EMERGENCY: restore"
git push --force
```

**Full rules**: `docs/GIT_WORKFLOW_GOLDEN_RULES.md`

### 2. Problem Solving Priority
1. **Check docs first**: `klui/docs/` (DEPLOYMENT_TEST_STEPS.md, FLUTTER_WEB_PITFALLS.md, LETTA_PROJECT_ANALYSIS.md)
2. **Try standard solutions**: Check code, logs, debug tools
3. **Search internet**: Use WebSearch tool for errors/best practices
4. **Update docs**: Record findings in relevant docs

**Search examples**: "Flutter Web CORS error", "Letta API provider configuration"

### 3. Tech Stack
- Flutter 3.38.5, Dart 3.10.4, WebAssembly compilation
- Riverpod 3.0.3 (code generation with `@riverpod`)
- go_router 16.x for routing
- flutter_http_sse for streaming (planned)

### 4. API Integration
**API Base**: http://38.175.200.93:8283/v1
**All requests need**: Bearer Token authentication
**Key endpoints**: Agents (52), Tools (21), Providers (7), Models (3)
**Full API docs**: `docs/LETTA_API_OVERVIEW.md`

**Provider modes**:
- **Base**: Memory providers from env vars (non-BYOK)
- **BYOK**: Database providers, user-created (requires Provider management UI)

### 5. Current Status
**Phase**: Phase 0 - Project initialization
**Latest working commit**: 0507713 (restored from stash@{0})
**Features**:
- ✅ Agent list (with delete)
- ✅ Agent create screen (1303 lines, BYOK mode)
- ✅ Agent detail screen (484 lines)
- ✅ Dark theme (Neo-Brutalist design)
- ⏳ Real-time chat (SSE streaming)
- ⏳ Provider management
- ⏳ Tools management

### 6. Core Models
**Agent**: id, name, description, systemPrompt, tools[], createdAt
**LLMModel**: handle, name, displayName, providerName, model, modelType ("llm"/"embedding")
**ProviderConfig**: name, providerType, isBase, isDefault, tags[]
**EmbeddingModel**: Similar to LLMModel

**Key**: `modelType` field distinguishes LLM vs embedding models

### 7. Build & Deploy
**CRITICAL: Always verify working directory before running commands!**

**Working Directory**: `/root/work/klui` (NEVER run from /root/work)

**After code changes, ALWAYS build and deploy**:
```bash
cd /root/work/klui  # MUST be in klui directory!
./deploy.sh
```

**Verify directory before deploy**:
```bash
pwd  # Should show: /root/work/klui
ls deploy.sh  # Should exist
```

**Full paths** (to avoid directory confusion):
- Flutter: `/opt/flutter/bin/flutter`
- Project root: `/root/work/klui`
- Deploy script: `/root/work/klui/deploy.sh`

**Deploy script does**:
- Build Flutter web app
- Stop old HTTP server
- Start new HTTP server on port 8080
- Show verification info

**Manual build** (if script fails):
```bash
export PATH="$PATH:/opt/flutter/bin"
flutter build web --release --dart-define=API_BASE_URL=http://38.175.200.93:8283
cd build/web && python3 -m http.server 8080
```

**Important**: Browser hard refresh required (Ctrl+Shift+R)

**Note**: Keep this file concise. Follow brief style when adding new requirements.

### 8. Letta Backend Analysis
**Location**: `/root/work/letta/`
**Analysis**: `docs/LETTA_PROJECT_ANALYSIS.md` (16 chapters)
**Key findings**:
- Provider selection: Base (env vars) vs BYOK (database)
- Embedding API key: Cannot separate from LLM API key in base mode
- letta-free model: Has inconsistent `model_type` across endpoints

**When investigating backend**:
1. Use Read/Grep/Glob tools in `/root/work/letta/`
2. Update `docs/LETTA_PROJECT_ANALYSIS.md` with findings
3. Include code evidence and examples

### 9. Documentation Structure
`klui/docs/`:
- DEPLOYMENT_TEST_STEPS.md (11,883 bytes)
- FLUTTER_PLAN_2026.md (19,795 bytes)
- LETTA_API_OVERVIEW.md (15,987 bytes)
- LETTA_PROJECT_ANALYSIS.md (166,733 bytes)
- GIT_WORKFLOW_GOLDEN_RULES.md (new)
- FLUTTER_WEB_PITFALLS.md (backup only)

### 10. Commit & Workflow
**Commit message format** (Must use standard English):
```
type: description

[optional body]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>
```

**Types**: feat, fix, docs, style, refactor, test, chore
**Examples**:
- `feat: implement BYOK mode agent creation`
- `fix: handle embedding model display with handle`
- `docs: update API documentation`

**Important**: Always use English for commits, Chinese for conversation only

**After testing succeeds**:
```bash
git tag -a v1.x-working -m "Tested and working"
git push origin main
git push origin v1.x-working
```

### 11. Code Quality
- Use `const` constructors
- Use `ListView.builder` not `ListView()`
- Delay load routes with `import ... deferred`
- Error handling: try-catch with user-friendly messages
- Riverpod: Use `@riverpod` annotation with code generation

### 11.1 Semantics (MANDATORY - Accessibility & Testing)
**CRITICAL**: ALL interactive components MUST have Semantics annotations

**Why Semantics?**:
1. **Accessibility**: Enables screen readers for visually impaired users
2. **Automated Testing**: Playwright/Puppeteer can use semantic selectors
3. **Code Clarity**: Self-documenting UI structure
4. **WCAG 2.0 Compliance**: Legal requirement for many applications

**Required Semantics for**:

**Interactive Buttons/Cards**:
```dart
Semantics(
  label: 'Descriptive action or item name',
  button: true,
  hint: 'Double tap to [action]',
  selected: isSelected, // For toggle/select items
  child: InkWell(...),
)
```

**Text Input Fields**:
```dart
Semantics(
  label: 'Field purpose',
  hint: 'Enter format/example',
  textField: true,
  child: TextFormField(...),
)
```

**Navigation Items**:
```dart
Semantics(
  label: 'Page name (selected/)',
  button: true,
  selected: isSelected,
  hint: 'Double tap to navigate to [page]',
  child: InkWell(...),
)
```

**Information Containers**:
```dart
Semantics(
  label: 'Container purpose',
  value: 'Current value',
  container: true,
  child: Container(...),
)
```

**Examples**:
- Provider card: `'Provider card: ${provider.name}, type: ${provider.type}'`
- Agent card: `'Agent card: ${agent.name}, status: ${agent.status}'`
- Delete button: `'Delete provider (destructive action)'`
- Form field: `'API key input field', hint: 'Enter your OpenAI API key'`

**Verification**:
- Check aria-labels in browser DevTools
- Test with screen reader (VoiceOver/TalkBack)
- Use semantic selectors in Playwright tests

**References**:
- [Flutter Web Accessibility](https://blog.flutter.dev/accessibility-in-flutter-on-the-web-51bfc558b7d3)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

### 12. DO NOT
- ❌ Modify Letta backend code (unless necessary)
- ❌ Use Freezed for Web (compilation issues)
- ❌ Hide advanced options (this is for power users)
- ❌ Over-engineer simple features
- ❌ Add comments/docs unless requested
- ❌ Forget error handling at system boundaries
- ❌ **Skip Semantics annotations (blocks accessibility & testing)**

### 13. Project Goals
**Core定位**: Serve professional users who need full API access
**Difference from official UI**: Official = simplified for beginners, klui = complete for experts
**Design philosophy**: Expose ALL API functionality, don't hide advanced options

**BYOK mode**: Full provider management UI required
**Non-BYOK mode**: Use Letta defaults, no database provider needed

---

**Last Updated**: 2026-01-09
**Claude Version**: Sonnet 4.5
**Mode**: Frontend Development 🚀
