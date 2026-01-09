# Git 工作流黄金规则 - 避免文件丢失灾难

**创建时间**: 2026-01-09
**作者**: Kosmo & Claude
**目的**: 基于三次灾难的教训，建立永不丢失代码的工作流

---

## 📋 三次灾难总结

### 灾难 1: Git Stash 误用
- **原因**: 使用 `git stash` 作为备份机制
- **后果**: 所有代码丢失，变成粉色主题
- **教训**: ❌ stash 不是备份，✅ commit 才是备份

### 灾难 2: 部署链不同步
- **原因**: Git commit 内容 ≠ 构建输出 ≠ HTTP 服务内容 ≠ 浏览器缓存
- **后果**: 看到旧版本，以为代码丢失
- **教训**: 必须验证完整部署链，不能只看 Git

### 灾难 3: 选择性文件恢复
- **原因**: 只恢复部分文件（`git checkout stash -- lib/features/agents/`）
- **后果**: main.dart 未恢复，功能不完整
- **教训**: 要么恢复全部，要么不恢复，不要选择性恢复

---

## 🚨 核心原则

### 原则 1: Commit 是唯一备份
```
✅ 正确: 开发 → commit → push → 继续开发
❌ 错误: 开发 → stash → reset → stash 丢失
```

### 原则 2: 三步验证法
每次"恢复"操作后，必须验证三步：
1. **Git 状态**: `git status` 和 `git diff`
2. **文件内容**: `cat lib/main.dart` (不要相信 commit message)
3. **构建输出**: 检查 `build/web/` 时间戳

### 原则 3: 完整部署链验证
```
源代码 → 构建 → HTTP 服务器 → 浏览器
  ↓       ↓        ↓          ↓
 Git    build/  进程ID   硬刷新
```

---

## 📖 黄金规则 (必须遵守)

### 规则 1: 永远不要用 stash 作为备份
```bash
# ❌ 禁止
git stash
git reset --hard HEAD
# stash 可能丢失，reset 无法撤销

# ✅ 正确
git commit -m "WIP: work in progress"
git push
# commit 永久保存，push 远程备份
```

**原因**:
- stash 是临时保存，容易被覆盖
- stash 不记录在 reflog 之外
- reset --hard 会丢弃未 commit 的内容

### 规则 2: 每次 commit 前必须检查内容
```bash
# ❌ 错误: 只看 commit message
git commit -m "feat: restore all files"  # 撒谎了！

# ✅ 正确: 验证实际内容
git add -A
git diff --cached  # 检查暂存区内容
git commit -m "feat: restore all files"
```

**原因**:
- Commit message 可能撒谎（cd91bcf 就是例子）
- 必须用 `git diff` 验证实际变化
- 不要信任任何标签，只信任实际内容

### 规则 3: 恢复文件要么全部，要么不恢复
```bash
# ❌ 禁止: 选择性恢复
git checkout stash -- lib/features/agents/
# 容易遗漏关键文件（main.dart）

# ✅ 正确: 恢复整个目录
git checkout stash -- lib/
git stash pop  # 或者直接恢复所有

# ✅ 更好: 使用 commit，不用 stash
git revert <commit>
git reset --hard <commit>
```

**原因**:
- 选择性恢复容易遗漏依赖文件
- 例如：恢复 agent screens 但忘记 main.dart
- 导致功能不完整且难以发现

### 规则 4: 每次构建后必须验证三个时间戳
```bash
# 1. 构建时间
ls -lah build/web/main.dart.js

# 2. HTTP 服务器启动时间
ps aux | grep "python3.*8080"

# 3. 如果服务器是旧的，必须重启
pkill -f "python3.*8080"
python3 -m http.server 8080 --directory build/web &
```

**原因**:
- Python HTTP 服务器会缓存旧文件
- 服务器进程可能运行了几天
- 必须重启才能看到新构建

### 规则 5: 遇到问题立即 commit，不要等
```bash
# ❌ 错误: 继续开发，等一下一起 commit
开发功能 A → 发现问题 → 继续开发 B → 灾难！

# ✅ 正确: 每个里程碑都 commit
开发功能 A → git commit → 发现问题 → 立即停止
```

**原因**:
- 问题可能复杂，不能预测
- 每个安全点都应该 commit
- commit 是你的安全网

### 规则 6: Commit message 必须描述实际变化
```bash
# ❌ 错误: Commit message 撒谎
git commit -m "restore all files"  # 实际只恢复文档

# ✅ 正确: Commit message 诚实
git commit -m "add git workflow documentation"
# 或者描述不完整: "restore: docs only, code still missing"
```

**原因**:
- 其他人（包括未来的你）会相信 commit message
- 撒谎的 commit message 导致误判
- cd91bcf 就是因为 commit message 说"恢复了所有文件"，但实际上没有

### 规则 7: 使用标签标记"测试成功"的状态
```bash
# 测试成功后立即打标签
git tag -a v1.0-working -m "Tested and verified working version"
git push origin v1.0-working

# 包含的验证:
# - 深色主题 ✅
# - 所有功能正常 ✅
# - 构建成功 ✅
# - 浏览器测试通过 ✅
```

**原因**:
- commit 可能被回滚或覆盖
- tag 是永久的标记
- 可以快速回到测试成功的版本

### 规则 8: 部署后必须硬刷新浏览器
```bash
# 1. 正常刷新 (可能看到缓存)
F5 或 Ctrl+R

# 2. 硬刷新 (清除缓存)
Ctrl+Shift+R (Windows/Linux)
Cmd+Shift+R (Mac)

# 3. 清除所有缓存
F12 → Network 标签 → Disable cache
```

**原因**:
- 浏览器可能缓存旧版本
- 硬刷新确保看到最新代码
- 避免误判"代码丢失"

---

## 🔧 标准工作流

### 日常开发流程
```bash
# 1. 拉取最新代码
git pull origin main

# 2. 创建功能分支（可选）
git checkout -b feature/new-feature

# 3. 开发
# ... 写代码 ...

# 4. 每个里程碑都 commit
git add -A
git diff --cached  # 验证内容
git commit -m "feat: add feature X"

# 5. 推送到远程（频繁 push）
git push origin feature/new-feature

# 6. 构建测试
flutter build web --release --wasm

# 7. 验证部署链
ls -lah build/web/main.dart.js  # 检查时间戳
ps aux | grep "python3.*8080"    # 检查服务器
# 如果服务器旧，重启：
pkill -f "python3.*8080"
python3 -m http.server 8080 --directory build/web &

# 8. 硬刷新浏览器测试
Ctrl+Shift+R

# 9. 测试成功后打标签
git tag -a v1.x-working -m "Tested and working"
git push origin v1.x-working
```

### 恢复/回滚流程
```bash
# ⚠️ 危险操作，必须三思！

# 1. 查看可回退的版本
git log --oneline --graph
git tag  # 查看所有标签

# 2. 验证目标版本内容
git show <commit-hash>:lib/main.dart  # 检查关键文件
git diff <current> <target>          # 对比差异

# 3. 回滚（选择一种方式）

# 方式 A: Soft reset（保留工作目录）
git reset --soft <commit>
# 优点: 可以重新编辑
# 缺点: 需要手动解决冲突

# 方式 B: Hard reset（丢弃所有更改）
git reset --hard <commit>
# 优点: 干净利落
# 缺点: 丢失所有未提交的更改

# 方式 C: Revert（创建新 commit）
git revert <commit>
# 优点: 保留历史
# 缺点: 可能产生冲突

# 4. 立即验证
git status
git diff
cat lib/main.dart

# 5. 重新构建
flutter build web --release --wasm

# 6. 重启服务器
pkill -f "python3.*8080"
python3 -m http.server 8080 --directory build/web &

# 7. 硬刷新浏览器
Ctrl+Shift+R
```

### 紧急救援流程
如果发现代码丢失：

```bash
# 1. 不要慌，不要执行任何 git 操作

# 2. 检查 reflog（救命稻草）
git reflog show --date=format:'%m-%d %H:%M:%S' | head -50

# 3. 找到丢失代码的 commit
git log --oneline --all --source --remotes

# 4. 检查 stash（如果有）
git stash list

# 5. 恢复到目标版本
git reset --hard <target-commit>
# 或
git stash apply stash@{0}

# 6. 立即 commit 和 push
git commit -m "EMERGENCY: restore lost code"
git push origin main --force

# 7. 验证完整性
git diff <target-commit> HEAD
cat lib/main.dart
```

---

## 🚫 禁止的操作

### 绝对禁止
```bash
# ❌ 禁止 1: 用 stash 作为备份
git stash  # 危险！

# ❌ 禁止 2: Selective reset
git reset --hard HEAD  # 可能丢失未 commit 的工作

# ❌ 禁止 3: Selective file restoration
git checkout stash -- lib/some/path/  # 容易遗漏

# ❌ 禁止 4: 相信 commit message 而不验证内容
git revert <commit>  # 必须先用 git show 验证

# ❌ 禁止 5: Force push 到远程（除非确认）
git push --force  # 危险！
# 只在紧急救援时使用

# ❌ 禁止 6: 不检查部署链就认为代码丢失
# 看到"粉色主题"不要慌，检查:
# - Git 状态
# - 构建时间戳
# - 服务器进程
# - 浏览器缓存
```

---

## ✅ 推荐的操作

### 每日习惯
```bash
# 1. 每天开始前
git pull origin main
git status  # 确认工作目录干净

# 2. 每个功能完成后
git add -A
git diff --cached  # 验证内容
git commit -m "feat: clear description"
git push origin main

# 3. 每次构建后
ls -lah build/web/  # 检查时间戳
pkill -f "python3.*8080"  # 重启服务器
python3 -m http.server 8080 --directory build/web &

# 4. 每次测试后
git tag -a v1.x-working -m "Tested"
git push origin v1.x-working

# 5. 每天结束前
git push origin main  # 确保所有工作已备份
git status  # 确认工作目录干净
```

### 最佳实践
```bash
# 1. 使用分支进行实验
git checkout -b experiment/try-something
# 实验成功后合并，失败后直接删除分支

# 2. 使用标签标记里程碑
git tag -a milestone-1 -m "Feature complete"
git tag -a tested-1 -m "All tests passing"
git tag -a deployed-1 -m "Deployed to production"

# 3. 定期清理 stash
git stash clear  # 删除不需要的 stash
# 或使用更好的：commit 所有工作

# 4. 定期检查远程仓库
git remote -v
git branch -vv  # 查看分支跟踪状态

# 5. 使用 .gitignore 避免误提交
# 确保 build/、.dart_tool/ 等已忽略
```

---

## 📊 故障排查检查清单

如果发现"代码丢失"或"功能不工作"，按顺序检查：

### 第 1 步: 检查 Git 状态
```bash
git status  # 工作目录状态
git log --oneline -5  # 最近 5 个 commit
git diff HEAD  # 工作目录变化
```

### 第 2 步: 检查构建输出
```bash
ls -lah build/web/  # 文件时间戳
stat build/web/main.dart.js  # 详细时间
```

### 第 3 步: 检查 HTTP 服务器
```bash
ps aux | grep "python3.*8080"  # 进程启动时间
# 如果进程旧，重启服务器
```

### 第 4 步: 检查浏览器
```bash
# 硬刷新
Ctrl+Shift+R

# 或清除缓存
F12 → Application → Clear storage
```

### 第 5 步: 检查代码内容
```bash
cat lib/main.dart  # 实际文件内容
git show HEAD:lib/main.dart  # Git 中的内容
# 对比是否一致
```

### 第 6 步: 检查 reflog（救命）
```bash
git reflog show --date=format:'%m-%d %H:%M:%S' | head -50
# 找到正确的版本，恢复
```

---

## 🎯 总结

### 三条铁律
1. **Commit 是唯一备份** - 永远不要用 stash 作为备份
2. **验证实际内容** - 不要相信 commit message，用 git diff 验证
3. **完整部署链验证** - Git → 构建 → 服务器 → 浏览器，每步都要验证

### 三个不要
1. **不要**选择性恢复文件 - 要么全部，要么不恢复
2. **不要**相信标签 - 只相信 `git diff` 和 `cat` 的结果
3. **不要**急于操作 - 遇到问题先停下来，检查完整状态

### 三个必须
1. **必须**频繁 commit - 每个里程碑都 commit
2. **必须**立即验证 - commit 后立即验证内容
3. **必须**打标签 - 测试成功后立即打标签

---

## 📚 附录

### 常用命令速查
```bash
# 查看状态
git status
git diff
git diff --cached

# 查看历史
git log --oneline --graph
git reflog show
git show <commit>

# 恢复操作
git reset --soft <commit>  # 保留工作目录
git reset --hard <commit>  # 丢弃更改
git revert <commit>  # 创建新 commit

# 远程操作
git push origin main
git push --force  # 只在紧急时使用
git fetch --all  # 更新远程信息

# 标签操作
git tag  # 列出所有标签
git tag -a v1.0 -m "message"  # 创建标签
git push origin v1.0  # 推送标签
```

### 检查时间戳
```bash
# Git commit 时间
git log --format='%h %ai %s' | head -5

# 构建文件时间
ls -lah build/web/ --time-style=full-iso

# 服务器进程时间
ps aux | grep "python3" | grep -v grep
```

---

**版本**: v1.0
**最后更新**: 2026-01-09
**状态**: ✅ 基于三次灾难的经验总结
**下次审查**: 每次灾难后更新
