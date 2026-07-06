#!/bin/bash
# git-autosync.sh — Linna 自动 Git 推送脚本
# 检测工作区变更后自动 commit + push
# 部署方式：cron 每5分钟执行一次

WORKSPACE="/home/hans/.openclaw/workspace-lina"
cd "$WORKSPACE" || exit 1

# 检查是否有变更
if ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet HEAD 2>/dev/null; then
    # 有变更需要提交
    CHANGED=$(git diff --name-only HEAD 2>/dev/null | head -5 | tr '\n' ' ')
    
    git add -A
    git commit -m "autosync: $(date '+%Y-%m-%d %H:%M') — ${CHANGED:-未跟踪文件}"
    git push --quiet 2>&1
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ autosync pushed: $CHANGED" >> "$WORKSPACE/.git/autosync.log"
fi

# 检查是否有未跟踪文件（新建文件）
UNTACKED=$(git ls-files --others --exclude-standard)
if [ -n "$UNTACKED" ]; then
    git add -A
    git commit -m "autosync: $(date '+%Y-%m-%d %H:%M') — 新文件"
    git push --quiet 2>&1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ autosync new files pushed" >> "$WORKSPACE/.git/autosync.log"
fi
