#!/bin/bash
# business_ops_prep.sh — 周五 04:00 业务运营巡检数据准备（供 lina-business-operations 只读，替代模型自行盘点台账）
# 数据源：Lina/ 各业务子目录（运营数据/商品资料/供应商资料/finance/hr/product/quality/business）、output/business/ 历史简报
# 产出：Lina/运营数据/业务巡检数据准备.md —— 全台账状态盘点 + 变化检测，模型只 read 后生成运营简报
# 改造依据：脚本化改造方法论（2026-08-18 韩工定）§三 阶段2 —— 确定性盘点脚本化，模型只做分析/简报生成
set -uo pipefail
WS=/home/hans/.openclaw/workspace-lina
TODAY=$(date +%Y-%m-%d)
NOW=$(date '+%Y-%m-%d %H:%M')
PREP="$WS/Lina/运营数据/业务巡检数据准备.md"

# ---- 业务台账目录盘点 ----
declare -a DIRS=("运营数据" "商品资料" "供应商资料" "finance" "hr" "product" "quality" "business" "法规监测")
echo "## 台账盘点中…"

{
  echo "# 业务运营巡检数据准备（$NOW 脚本产出，lina-business-operations 只读此文件，台账状态以本文件为准）"
  echo ""
  echo "## 一、业务台账目录盘点"
  echo ""
  echo "| 目录 | 文件数 | 最新文件 | 最近修改 |"
  echo "|:-----|:------|:--------|:--------|"
  for d in "${DIRS[@]}"; do
    DIR="$WS/Lina/$d"
    if [ -d "$DIR" ]; then
      CNT=$(find "$DIR" -maxdepth 1 -type f 2>/dev/null | wc -l)
      LATEST=$(ls -t "$DIR" 2>/dev/null | head -1)
      L_TS=$(stat -c '%y' "$DIR/$LATEST" 2>/dev/null | cut -d. -f1)
      [ -z "$LATEST" ] && LATEST="（空）"
      echo "| $d | $CNT | $LATEST | $L_TS |"
    else
      echo "| $d | —（目录不存在） | — | — |"
    fi
  done
  echo ""
  echo "## 二、历史运营简报"
  echo ""
  BRIEFS=$(ls "$WS/output/business/"*简报* 2>/dev/null | sed "s|$WS/output/business/||")
  if [ -n "$BRIEFS" ]; then
    echo "$BRIEFS" | sed 's/^/- /'
  else
    echo "（无历史简报）"
  fi
  echo ""
  echo "## 三、开店准备状态（关键待办）"
  echo ""
  echo "- 店铺平台：待韩工确认（抖店/淘宝/拼多多/京东/Shopee）"
  echo "- 供应商：待韩工提供（1688/义乌购/自有货源）"
  echo "- 收款账户：待韩工配置"
  echo "- 平台参数：待设置（毛利率/广告预算/退款阈值等）"
  echo ""
  echo "## 四、执行约定（模型部分）"
  echo ""
  echo "1. 基于本文件盘点结果生成《业务运营简报》（沿用 output/business/20260703_v1_业务运营简报.html 结构：台账状态/系统就绪度/风险与待办）"
  echo "2. 有变化 → 更新对应台账 + 简报；无变化 → 简报说明状态不变（筹备期侧重就绪进度）"
  echo "3. 产出 output/business/业务运营简报_今日日期.html（同步 ~/NovaShared/OutPut/）"
  echo "4. 完成后用 message(action=send) 显式投递简报给韩工：channel=openclaw-weixin、target=o9cq807kYZOgi_Ej_2PUcxS1xsJ0@im.wechat（原始混合大小写，小写 ret=-3）、accountId=bb1779004873-im-bot"
} > "$PREP"

echo "业务巡检数据已产出：$PREP"
exit 0
