#!/bin/bash
# quality_audit_prep.sh — 每周三 02:00 产品质量巡检数据准备（供 lina-product-quality-audit 只读，替代模型自行盘点）
# 数据源：Lina/quality/（质量台账）、Lina/product/（产品档案）、Lina/运营数据/（订单/退款/售后）、Lina/平台规则/（规则更新）
# 产出：Lina/quality/巡检数据准备.md —— 各数据源状态 + 变化检测，模型只 read 后生成巡检报告
# 改造依据：脚本化改造方法论（2026-08-18 韩工定）§三 阶段2 —— 确定性盘点脚本化，模型只做分析/报告生成
set -uo pipefail
WS=/home/hans/.openclaw/workspace-lina
TODAY=$(date +%Y-%m-%d)
NOW=$(date '+%Y-%m-%d %H:%M')
PREP="$WS/Lina/quality/巡检数据准备.md"

# ---- 质量台账 ----
LEDGER_CNT=$(ls "$WS/Lina/quality/"质量台账*.md 2>/dev/null | wc -l)
LEDGER_LATEST=$(ls -t "$WS/Lina/quality/"质量台账*.md 2>/dev/null | head -1)
LEDGER_LATEST_NAME="（无台账）"
LEDGER_LATEST_TIME="（无）"
LEDGER_DAYS="—"
if [ -n "$LEDGER_LATEST" ]; then
  LEDGER_LATEST_NAME=$(basename "$LEDGER_LATEST")
  LEDGER_LATEST_TIME=$(stat -c '%y' "$LEDGER_LATEST" 2>/dev/null | cut -d. -f1)
  LEDGER_TS=$(stat -c '%Y' "$LEDGER_LATEST" 2>/dev/null)
  [ -n "$LEDGER_TS" ] && LEDGER_DAYS=$(( ( $(date +%s) - LEDGER_TS ) / 86400 ))
fi

# ---- 产品档案 ----
PROD_CNT=$(ls "$WS/Lina/product/"产品档案*.md 2>/dev/null | wc -l)
PROD_LATEST=$(ls -t "$WS/Lina/product/"产品档案*.md 2>/dev/null | head -1)
PROD_LATEST_NAME="（无档案）"
[ -n "$PROD_LATEST" ] && PROD_LATEST_NAME=$(basename "$PROD_LATEST")

# ---- 运营数据（订单/退款/售后信号） ----
OPS_CNT=$(ls "$WS/Lina/运营数据/" 2>/dev/null | wc -l)
OPS_FILES=$(ls "$WS/Lina/运营数据/" 2>/dev/null | head -8)

# ---- 平台规则（合规源） ----
RULE_CNT=$(ls "$WS/Lina/平台规则/"*.md 2>/dev/null | wc -l)

# ---- 历史巡检报告 ----
REPORT_CNT=$(ls "$WS/output/quality/"*巡检报告* 2>/dev/null | wc -l)
LAST_REPORT=$(ls -t "$WS/output/quality/"*巡检报告* 2>/dev/null | head -1)
LAST_REPORT_NAME="（无报告）"
[ -n "$LAST_REPORT" ] && LAST_REPORT_NAME=$(basename "$LAST_REPORT")

{
  echo "# 产品质量巡检数据准备（$NOW 脚本产出，lina-product-quality-audit 只读此文件，数据源状态以本文件为准）"
  echo ""
  echo "## 一、数据源状态盘点"
  echo ""
  echo "| 数据源 | 文件数 | 最新 | 距今天数 |"
  echo "|:------|:------|:-----|:--------|"
  echo "| 质量台账（Lina/quality/） | $LEDGER_CNT | $LEDGER_LATEST_NAME | ${LEDGER_DAYS}天 |"
  echo "| 产品档案（Lina/product/） | $PROD_CNT | $PROD_LATEST_NAME | — |"
  echo "| 平台规则（Lina/平台规则/） | $RULE_CNT | — | — |"
  echo "| 历史巡检报告（output/quality/） | $REPORT_CNT | $LAST_REPORT_NAME | — |"
  echo ""
  echo "## 二、运营数据目录内容（订单/退款/售后信号源）"
  echo ""
  [ -n "$OPS_FILES" ] && echo "$OPS_FILES" | sed 's/^/- /' || echo "（空）"
  echo ""
  echo "## 三、台账最近更新"
  echo ""
  echo "- $LEDGER_LATEST_NAME（$LEDGER_LATEST_TIME）"
  echo ""
  echo "## 四、执行约定（模型部分）"
  echo ""
  echo "1. 基于本文件盘点结果生成《质量巡检报告》：批次质量/售后统计/质检标准/合规风险四维（沿用 output/quality/20260701_v1_质量巡检报告.html 结构）"
  echo "2. 有变化（新台账/新产品/运营数据出现）→ 更新质量台账 + 报告；无变化 → 简报说明状态不变"
  echo "3. 产出 output/quality/巡检报告_今日日期.html（同步 ~/NovaShared/OutPut/）"
  echo "4. 完成后用 message(action=send) 显式投递简报给韩工：channel=openclaw-weixin、target=o9cq807kYZOgi_Ej_2PUcxS1xsJ0@im.wechat（原始混合大小写，小写 ret=-3）、accountId=bb1779004873-im-bot"
} > "$PREP"

echo "巡检数据已产出：$PREP"
exit 0
