
## Git工作流规则（重要！）

### ⚠️ 绝对禁止

1. **不要使用`git stash`作为备份机制**
   - `git stash`只用于临时切换上下文（几分钟，不是几小时）
   - 不要用stash保存"成功的构建"
   - 不要依赖stash作为版本控制

2. **不要在没有commit的情况下进行构建**
   ```bash
   # ❌ 错误做法
   flutter build web  # 如果失败，文件可能丢失
   
   # ✅ 正确做法
   git add -A
   git commit -m "WIP: before build"
   flutter build web
   ```

### ✅ 必须遵守的工作流

#### 1. 每次成功构建后立即commit
```bash
git add lib/
git commit -m "feat: agent creation screen with BYOK mode"
```

#### 2. 使用feature分支开发
```bash
git checkout -b feature/agent-creation
# ... work on feature ...
git checkout main
git merge feature/agent-creation
```

#### 3. 构建前checkpoint
```bash
git add -A
git commit -m "WIP: checkpoint before risky operation"
```

#### 4. 定期推送到远程
```bash
git push origin main
```

### 灾难恢复命令

如果再次丢失工作：

```bash
# 1. 检查reflog找到丢失的commit
git reflog

# 2. 恢复丢失的commit
git checkout SHA_OF_LOST_COMMIT

# 3. 查看所有stash
git stash list

# 4. 从stash恢复（如果还在）
git stash pop stash@{n}
```

### 为什么会丢失文件？

1. **Stash不包含所有文件**：如果文件不在工作区（被删除或未跟踪），`git add -A`不会添加到stash
2. **编译失败清理文件**：Flutter编译失败时可能删除有问题的文件
3. **Stash覆盖**：多次stash会覆盖之前的stash

### 解决方案

**使用Git commit，不是stash！**

- Commit永久保存在git历史中
- Commit可以被reflog找回
- Commit可以被push到远程备份
- Commit有明确的message说明改动

参考文档：`DEVELOPMENT_WORKFLOW.md`
