#!/bin/bash
# lina_morning_brief_prep.sh — 每日 09:00 早报数据准备（供 lina-morning-brief 只读，替代模型自行查询）
# 数据源：memory/entities/（实体库）、memory/kb-index/（法规同步）、Lina/法规文件/（法规库）、
#         Lina/法规监测/（监测报告）、.linna/02_RUNTIME_INDEX_LOG.md（待办）、Lina/配置/（API密钥）
# 改造依据：脚本化改造方法论（2026-08-18 韩工定）§三 阶段2 —— 确定性查询脚本化，模型只做生成
set -uo pipefail
WS=/home/hans/.openclaw/workspace-lina
TODAY=$(date +%Y-%m-%d)
NOW=$(date '+%Y-%m-%d %H:%M')
PREP="$WS/Lina/运营数据/早报数据准备.md"

# ---- ① 系统就绪状态 ----
ENTITIES=$(ls "$WS/memory/entities/"*.md 2>/dev/null | wc -l)
KBIDX=$(ls "$WS/memory/kb-index/"*.md 2>/dev/null | wc -l)
LAW_DIRS=$(ls -d "$WS/Lina/法规文件/"*/ 2>/dev/null | wc -l)
SNAPSHOTS=$(ls "$WS/memory/snapshots/"*.md 2>/dev/null | wc -l)
# API 密钥就绪情况：Lina/配置/ 下应有密钥/配置类文件；空 = 未就绪（等待韩工）
CONFIG_CNT=$(ls -A "$WS/Lina/配置/" 2>/dev/null | wc -l)

# ---- ② 法规监测：最新报告 + 是否近 24h 更新 ----
LATEST_MONITOR=$(ls -t "$WS/Lina/法规监测/"*.md 2>/dev/null | head -1)
LATEST_MONITOR_NAME="（无）"
LATEST_MONITOR_TIME="（无）"
MONITOR_24H="否（近 24 小时无新监测报告）"
if [ -n "$LATEST_MONITOR" ]; then
  LATEST_MONITOR_NAME=$(basename "$LATEST_MONITOR")
  LATEST_MONITOR_TIME=$(stat -c '%y' "$LATEST_MONITOR" 2>/dev/null | cut -d. -f1)
  if [ "$(stat -c '%Y' "$LATEST_MONITOR" 2>/dev/null)" -ge "$(( $(date +%s) - 86400 ))" ]; then
    MONITOR_24H="是（近 24 小时内有更新）"
  fi
fi

# ---- ③ 待办（02_RUNTIME_INDEX_LOG 未完成项） ----
TODOS=$(grep -n "^- \[ \]" "$WS/.linna/02_RUNTIME_INDEX_LOG.md" 2>/dev/null | sed 's/^[0-9]*:- \[ \] /- /')
[ -z "$TODOS" ] && TODOS="（无未完成待办）"

# ---- ④ git 状态（最近提交） ----
GIT_LAST=$(git -C "$WS" log --oneline -1 2>/dev/null || echo "（无提交记录）")

{
  echo "# 早报数据准备（$NOW 脚本产出，lina-morning-brief 只读此文件，不再自行查询）"
  echo ""
  echo "## ① 系统就绪状态"
  echo ""
  echo "| 检查项 | 状态 |"
  echo "|:------|:-----|"
  echo "| 实体库完整性 | $ENTITIES 个实体文件（memory/entities/） |"
  echo "| 法规同步索引 | $KBIDX 个 kb-index 索引文件 |"
  echo "| 法规库 | $LAW_DIRS 大类法规目录（Lina/法规文件/） |"
  echo "| 记忆快照 | $SNAPSHOTS 份（memory/snapshots/） |"
  echo "| API 密钥/配置 | $([ "$CONFIG_CNT" -gt 0 ] && echo "已就绪（Lina/配置/ 含 $CONFIG_CNT 项）" || echo "⏳ 未就绪（Lina/配置/ 为空，等待韩工提供平台密钥）") |"
  echo ""
  echo "## ② 近 24 小时法规监测摘要"
  echo ""
  echo "- 最新监测报告：$LATEST_MONITOR_NAME"
  echo "- 报告时间：$LATEST_MONITOR_TIME"
  echo "- 近 24h 更新：$MONITOR_24H"
  [ -n "$LATEST_MONITOR" ] && echo "- 报告路径：$LATEST_MONITOR"
  echo ""
  echo "## ③ 待办任务提醒（02_RUNTIME_INDEX_LOG.md 未完成项）"
  echo ""
  echo "$TODOS"
  echo ""
  echo "## ④ Git 最近提交"
  echo ""
  echo "- $GIT_LAST"
} > "$PREP"

echo "早报数据已产出：$PREP"
exit 0
