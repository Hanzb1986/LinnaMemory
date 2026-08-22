#!/bin/bash
# finance_monitor_prep.sh — 周二 01:00 财税政策监测数据准备（供 lina-finance-monitor 只读，替代模型自行盘点）
# 数据源：output/finance/（财税简报/档案库）、Lina/finance/（财税台账）、memory/kb-index/（法规索引）、Lina/运营数据/（收支信号）
# 产出：Lina/finance/财税监测数据准备.md —— 本地档案状态 + 历史简报 + 监测要点，模型只 read 后生成财税简报
# 改造依据：脚本化改造方法论（2026-08-18 韩工定）§三 阶段2 —— 确定性盘点脚本化，模型只做分析/简报生成
set -uo pipefail
WS=/home/hans/.openclaw/workspace-lina
TODAY=$(date +%Y-%m-%d)
NOW=$(date '+%Y-%m-%d %H:%M')
PREP="$WS/Lina/finance/财税监测数据准备.md"

# ---- 财税档案（output/finance/） ----
BRIEF_CNT=$(ls "$WS/output/finance/"*简报*.md 2>/dev/null | wc -l)
ARCHIVE_CNT=$(ls "$WS/output/finance/"*档案* 2>/dev/null | wc -l)
LAST_BRIEF=$(ls -t "$WS/output/finance/"*简报*.md 2>/dev/null | head -1)
LAST_BRIEF_NAME="（无简报）"
LAST_BRIEF_TIME="（无）"
BRIEF_DAYS="—"
if [ -n "$LAST_BRIEF" ]; then
  LAST_BRIEF_NAME=$(basename "$LAST_BRIEF")
  LAST_BRIEF_TIME=$(stat -c '%y' "$LAST_BRIEF" 2>/dev/null | cut -d. -f1)
  B_TS=$(stat -c '%Y' "$LAST_BRIEF" 2>/dev/null)
  [ -n "$B_TS" ] && BRIEF_DAYS=$(( ( $(date +%s) - B_TS ) / 86400 ))
fi

# ---- 财税台账（Lina/finance/） ----
LEDGER_CNT=$(ls -A "$WS/Lina/finance/" 2>/dev/null | wc -l)
LEDGER_FILES=$(ls -A "$WS/Lina/finance/" 2>/dev/null | head -5)

# ---- 相关法规索引 ----
LAW_KB=$(ls "$WS/memory/kb-index/"kb-index-finance* 2>/dev/null | wc -l)

# ---- 运营数据（收支信号，筹备期为 0） ----
OPS_CNT=$(find "$WS/Lina/运营数据/" -maxdepth 1 -type f 2>/dev/null | wc -l)

{
  echo "# 财税政策监测数据准备（$NOW 脚本产出，lina-finance-monitor 只读此文件，档案状态以本文件为准）"
  echo ""
  echo "## 一、财税档案状态（output/finance/）"
  echo ""
  echo "- 历史简报：$BRIEF_CNT 份（最近：$LAST_BRIEF_NAME，$LAST_BRIEF_TIME，距 ${BRIEF_DAYS}天）"
  echo "- 档案库更新：$ARCHIVE_CNT 份"
  echo ""
  echo "## 二、财税台账（Lina/finance/）"
  echo ""
  [ -n "$LEDGER_FILES" ] && echo "$LEDGER_FILES" | sed 's/^/- /' || echo "（空，筹备期无台账）"
  echo ""
  echo "## 三、监测要点（模型部分）"
  echo ""
  echo "- 税务总局/财政部/海关等官方源政策更新（06-30 首检实测：5 源 JS 渲染需 web 检索补充）"
  echo "- 历史关注点（07-14 二检）：电商偷税专项执法/以数治税推进/税前扣除标准核验/失效政策标记"
  echo "- 分级：A 直接影响记账报税 → 立即适配；B 财税风险提示 → 周内；C 跟踪 → 月度"
  echo ""
  echo "## 四、执行约定（模型部分）"
  echo ""
  echo "1. 基于本文件 + web_search/web_fetch 生成《财税政策更新简报》（沿用 output/finance/财税政策更新简报_2026-07-14.md 格式）"
  echo "2. 更新《财税档案库更新》（output/finance/，.md 仅本地留存，不同步 ~/NovaShared/OutPut/；OutPut 只放交付文档 .html/.pdf/.csv/.docx）。如需共享走共享知识中枢登记：material_index.py add --agent lina --domain business --share_level shared + 通知 Nova（README_共享知识中枢.md）"
  echo "3. 筹备期无收支数据时，简报侧重政策监测结果与适用性提示"
  echo "4. 完成后用 message(action=send) 显式投递简报给韩工：channel=openclaw-weixin、target=o9cq807kYZOgi_Ej_2PUcxS1xsJ0@im.wechat（原始混合大小写，小写 ret=-3）、accountId=bb1779004873-im-bot"
} > "$PREP"

echo "财税监测数据已产出：$PREP"
exit 0
