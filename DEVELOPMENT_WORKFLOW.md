# Klui Development Workflow

## Git Workflow Rules

### NEVER USE `git stash` FOR LONG-TERM STORAGE

`git stash` is only for:
- Temporary context switches (minutes, not hours)
- Quick experiments you want to discard
- NEVER as a backup mechanism

### ALWAYS COMMIT WORKING CODE

```bash
# After EVERY successful build:
git add lib/
git commit -m "feat: description of changes"

# Even if it's not perfect, commit with "WIP" prefix
git commit -m "WIP: working on feature X"
```

### Branch Strategy

```bash
# Main branch: stable builds only
git checkout main

# Feature branches: development work
git checkout -b feature/agent-creation
git checkout -b fix/theme-dark-mode
```

### Before Major Operations

```bash
# Before any risky operation:
git status                    # Check what's changed
git diff                      # Review changes
git commit -am "WIP: checkpoint"  # Always commit first!
```

## Build Workflow

### Safe Build Process

```bash
# 1. Check current state
git status

# 2. Commit any changes
git add -A
git commit -m "WIP: before build"

# 3. Build
flutter build web --release --wasm --dart-define=API_BASE_URL=http://38.175.200.93:8283

# 4. If build succeeds, commit with proper message
git add -A
git commit -m "build: successful - description"

# 5. If build fails, DO NOT stash - instead:
git checkout .  # Revert to last commit
# Then fix the issue
```

### NEVER DO THIS

❌ `git add -A && git stash save "Build successful"`  
❌ Relying on stash as backup  
❌ Building without checking git status first  
❌ Deleting files without checking git status  

### ALWAYS DO THIS

✅ Commit before building  
✅ Commit after successful build  
✅ Use feature branches for new work  
✅ Review changes before committing  

## Recovery Commands

```bash
# If you lose work, check all refs:
git reflog

# See all stashes (but don't rely on them):
git stash list

# Recover from stash:
git stash pop stash@{n}

# Recover lost commit:
git reflog
git checkout SHA_OF_LOST_COMMIT
```

## Backup Strategy

### Local Backups
```bash
# Tag important milestones:
git tag -a v1.0 -m "Agent creation working"
git tag -a v1.1 -m "Dark theme implemented"
```

### Remote Backup
```bash
# Push to GitHub regularly:
git push origin main
git push --tags
```

## Code Quality

### Before Committing
```bash
# Format code:
flutter format .

# Analyze code:
flutter analyze

# Run tests:
flutter test
```

---

**Golden Rule**: If you can't afford to lose it, COMMIT IT!
