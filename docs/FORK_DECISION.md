# Ketta Project: Fork Decision and Strategy

**Date**: 2026-01-12
**Purpose**: Document the decision to fork Letta into Ketta and the strategic rationale

---

## 🎯 Decision: Fork Letta → Ketta

After months of working with the Letta backend while building Klui, we have decided to fork Letta into a new project: **Ketta**.

This document explains WHY we made this decision and HOW we plan to execute it.

---

## 😤 Frustrations with Letta

### 1. Hard-coded Limitations

**OpenAI Proxy Hard-coding**
```python
# /root/work/letta/letta/schemas/providers/openai.py:153-157
if self.base_url != "https://api.openai.com/v1":
    handle = self.get_handle(model_name, base_name="openai-proxy")
else:
    handle = self.get_handle(model_name)
```

**Problem**:
- All OpenAI-compatible APIs forced to use `openai-proxy` prefix
- Cannot use custom provider names in handles
- Requires ugly workarounds in frontend code
- Makes provider management confusing for users

**Impact**: Users create "CC Test" provider, but backend expects "openai-proxy"

### 2. Soft Delete Issues

**Provider Deletion**:
```python
# Soft delete - record remains in database
await existing_provider.delete_async(session, actor=actor)
```

**Problems**:
- Database record persists with `is_deleted=True`
- Unique constraint still enforced
- Cannot create new provider with same name
- Confusing UX: "I deleted it, why does it still exist?"

**Agent Deletion** (different!):
```python
# Hard delete - record permanently removed
logger.debug(f"Hard deleting Agent with ID: {agent_id}")
```

**Why inconsistent?** No good reason. Just technical debt.

### 3. Hostile to Third-Party Platforms

**Personal Experience**:
- Contributed PR for "automatic Anthropic URL redirect"
- Waited 1 month - **no response**
- No interest in supporting third-party platforms
- Official platform clearly prioritized

**Letta Code** ($20/month subscription):
- Cannot use your own API without paying
- Forces users to official platform
- Defeats purpose of self-hosted software

### 4. No Official Frontend

**Letta's Strategy**:
- No open-source frontend provided
- Must use official platform (login required)
- Cannot self-host without restrictions
- Forces vendor lock-in

**Result**:
- Had to build Klui from scratch
- Constant fighting against backend limitations
- Every feature requires workarounds

---

## 💡 Why Fork Now?

### 1. Klui Frontend is Mature ✅

**Already Implemented**:
- Complete CRT-themed UI
- Agent management (create, list, detail, delete)
- Provider management (create, list, delete)
- Chat interface with streaming
- Context size warnings
- Diff visualization for file edits
- BYOK and non-BYOK modes
- i18n support (Chinese, English)

**Code Quality**:
- Clean architecture
- Well-documented
- Production-ready

### 2. Deep Understanding of Letta Backend ✅

**We've Analyzed**:
- Provider system (`letta/schemas/providers/`)
- Agent execution (`letta/agents/`)
- Tool system (`letta/functions/`)
- Database models
- API endpoints
- Handle generation logic

**We Know**:
- What needs to be changed
- How to change it
- What can be removed

### 3. Clear Vision ✅

**What We Want**:
- Open-source AI agent platform
- No platform lock-in
- Support all providers equally
- Beautiful, functional UI
- Easy to deploy and maintain

**Letta Won't Provide**:
- Official continues prioritizing their platform
- No interest in third-party improvements
- Commercial interests > open-source community

---

## 📋 Ketta Project Goals

### Vision

> "A truly open-source AI agent platform with no platform lock-in,
> built for developers who want control and freedom."

### Core Principles

1. **Freedom** - Use any provider, any API, no restrictions
2. **Simplicity** - Easy to deploy, easy to use, easy to understand
3. **Transparency** - Open development, clear decisions, no hidden agendas
4. **Quality** - Beautiful UI, robust backend, thorough testing
5. **Community** - Welcome contributions, respect users, prioritize needs

### Non-Goals

❌ Commercial platform or SaaS
❌ Vendor lock-in or forced subscriptions
❌ Hiding features behind paywalls
❌ Prioritizing "enterprise" over "community"
❌ Complex deployment requiring Kubernetes

---

## 🔧 Technical Strategy

### Fork Scope

**What We Keep** (from Letta):
- ✅ Agent execution logic
- ✅ Tool calling system
- ✅ Memory management
- ✅ LLM abstraction layer
- ✅ Basic provider interfaces

**What We Remove** (from Letta):
- ❌ Platform-specific code (login, billing, etc.)
- ❌ Hard-coded `openai-proxy` logic
- ❌ Soft delete (use hard delete everywhere)
- ❌ Platform-specific optimizations
- ❌ Vendor lock-in mechanisms

**What We Add** (new features):
- ✅ Proper provider name handling
- ✅ Hard delete for all entities
- ✅ Simplified deployment
- ✅ Better third-party provider support
- ✅ Performance optimizations
- ✅ Modern web UI (Klui)

### Modification Priorities

#### Phase 1: Critical Fixes (Week 1-2)

1. **Remove OpenAI Proxy Hard-coding**
   - File: `schemas/providers/openai.py:153-157`
   - Change: Use provider name directly
   - Impact: Providers can use custom names

2. **Fix Soft Delete**
   - File: `services/provider_manager.py:156-178`
   - Change: Use hard delete like agents
   - Impact: Can reuse provider names

3. **Simplify Authentication**
   - Remove official platform integration
   - Simple API key or token auth
   - Impact: Easier self-hosting

#### Phase 2: Quality Improvements (Week 3-4)

4. **Provider System Overhaul**
   - Support multiple providers of same type
   - Provider name uniqueness per org
   - Better error messages
   - Impact: Better UX

5. **Database Schema Cleanup**
   - Remove soft delete flags
   - Remove platform-specific fields
   - Add proper constraints
   - Impact: Cleaner data model

6. **Deployment Simplification**
   - Single Docker container
   - Docker Compose for production
   - Environment variable config
   - Impact: Easier to deploy

#### Phase 3: Feature Additions (Month 2-3)

7. **Enhanced Provider Support**
   - Load balancing across providers
   - Fallback providers
   - Health checks
   - Impact: Better reliability

8. **Local Model Support**
   - Ollama integration
   - Local embedding models
   - Impact: No API costs for testing

9. **File System Tools**
   - File browser
   - Upload/download
   - Code execution sandbox
   - Impact: Full development environment

### Maintaining Sync with Letta

**Strategy**: Selective Cherry-picking

```bash
# Letta repository
git remote add letta https://github.com/letta-ai/letta.git

# Ketta repository
git remote add origin https://github.com/kosmoli/ketta.git

# Sync strategy
git fetch letta main
# Review changes
git cherry-pick <bug-fix-commit>  # Only bug fixes
# Reject feature changes (may introduce restrictions)
```

**What to Sync**:
- ✅ Bug fixes
- ✅ Security patches
- ✅ Performance improvements
- ✅ Documentation updates

**What to Reject**:
- ❌ Platform features
- ❌ Provider restrictions
- ❌ Commercial features
- ❌ Lock-in mechanisms

---

## 📊 Risk Assessment

### Risks

1. **Maintenance Burden**
   - Need to maintain backend code
   - Mitigation: Start small, grow gradually
   - Community contributions help

2. **Divergence from Letta**
   - May miss upstream improvements
   - Mitigation: Strategic cherry-picking
   - Document all changes

3. **Adoption**
   - Letta has brand recognition
   - Mitigation: Focus on quality and freedom
   - Clear differentiation

### Opportunities

1. **Better Product**
   - No artificial limitations
   - Focus on user needs
   - Can iterate faster

2. **Community**
   - Attract developers frustrated with Letta
   - Build around open-source values
   - Transparent development

3. **Innovation**
   - Not constrained by Letta's business model
   - Can experiment with new features
   - Respond to user feedback

---

## 🎯 Success Criteria

### Technical

- [ ] Deploys with single `docker-compose up`
- [ ] Supports any OpenAI-compatible API
- [ ] Can reuse provider names after deletion
- [ ] No platform lock-in mechanisms
- [ ] Passes all existing Klui tests

### User Experience

- [ ] Setup time < 5 minutes
- [ ] Clear documentation
- [ ] Helpful error messages
- [ ] Responsive to feedback

### Community

- [ ] Active GitHub issues
- [ ] Regular releases
- [ ] Growing contributor base
- [ ] Positive user sentiment

---

## 📅 Timeline

### Month 1: Foundation
- Fork repository
- Critical fixes (proxy, soft delete)
- Setup CI/CD
- Initial documentation

### Month 2: Quality
- Provider system overhaul
- Deployment simplification
- Comprehensive testing
- Beta release

### Month 3: Features
- Enhanced provider support
- File system tools
- Performance optimizations
- v1.0 release

---

## 🤝 Contributing

**For Developers**:
- We welcome PRs!
- Clear contribution guidelines
- Code review process
- Friendly community

**For Users**:
- Report issues
- Suggest features
- Share feedback
- Spread the word

---

## 📖 References

- **Letta Repository**: https://github.com/letta-ai/letta
- **Klui Repository**: https://github.com/kosmoli/klui
- **Ketta Repository**: https://github.com/kosmoli/ketta (to be created)
- **Related Docs**:
  - `LETTA_BACKEND_ANALYSIS.md` - Deep dive into Letta architecture
  - `DELETE_FUNCTIONALITY_ISSUES.md` - Soft delete vs hard delete analysis
  - `THEME_MIGRATION_GUIDE.md` - UI theme decisions

---

## ✨ Conclusion

**Why Ketta?**

Because we believe:
- Open source should be truly open
- No platform lock-in
- Developers deserve better tools
- Community matters more than commerce

**The name "Ketta"**:
- Sounds like "Letta" but distinct
- Short, memorable, easy to spell
- Can be written with Latin characters
- Domain likely available

**Our commitment**:
- Always open-source
- Always free to use
- Always community-focused
- Always transparent

---

**Let's build something better. Together.**

**Date**: 2026-01-12
**Status**: Decision made - Execution begins
**Next Step**: Create Ketta repository and begin Phase 1 fixes
