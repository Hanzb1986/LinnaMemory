#!/bin/bash
# legal_monitor_prep.sh — 每周一 00:00 法规监测数据准备（供 lina-legal-monitor 只读，替代模型自行抓取）
# 数据源：5 个官方源（01 §9.2）、本地历史库（Lina/法规监测/ 历史报告 + memory/kb-index/）
# 产出：Lina/法规监测/监测数据准备.md —— 源站可达性 + 抓取摘要 + 本地库状态，模型只 read 后做分析/分级/报告
# 改造依据：脚本化改造方法论（2026-08-18 韩工定）§三 —— 确定性抓取脚本化（curl 带间隔），模型只做理解/分析/生成
# 合规：≤2次/60秒、夜间低峰执行（00:00）、单 IP 间隔 ≥30 秒（01 §9.3 + 07-06 报告实测约定）
set -uo pipefail
WS=/home/hans/.openclaw/workspace-lina
TODAY=$(date +%Y-%m-%d)
NOW=$(date '+%Y-%m-%d %H:%M')
PREP="$WS/Lina/法规监测/监测数据准备.md"
OUT_DIR="$WS/Lina/法规监测"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

# 源站清单（01 §9.2：名称|用途|URL|可抓取性——07-06 报告实测）
declare -a SITES=(
  "国家法律法规数据库|flk.npc.gov.cn|https://flk.npc.gov.cn/|JS渲染SPA，静态页仅导航结构"
  "中国人大网|npc.gov.cn|http://www.npc.gov.cn/|首页/立法动态/常委会公告可抓静态，详情页JS渲染"
  "中国政府网|gov.cn|https://www.gov.cn/|静态可完整抓取，含最新政策列表"
  "市场监管总局|samr.gov.cn|https://www.samr.gov.cn/|首页/新闻可抓，法规库搜索界面JS渲染"
  "国家网信办|cac.gov.cn|https://www.cac.gov.cn/|静态可抓"
)

# ---- 本地历史库状态 ----
HIST_COUNT=$(ls "$OUT_DIR"/法规变更对比报告_*.md 2>/dev/null | wc -l)
LAST_REPORT=$(ls -t "$OUT_DIR"/法规变更对比报告_*.md 2>/dev/null | head -1)
LAST_REPORT_NAME="（无历史报告）"
LAST_REPORT_TIME="（无）"
if [ -n "$LAST_REPORT" ]; then
  LAST_REPORT_NAME=$(basename "$LAST_REPORT")
  LAST_REPORT_TIME=$(stat -c '%y' "$LAST_REPORT" 2>/dev/null | cut -d. -f1)
fi
KB_LAWS=$(ls "$WS/memory/kb-index/"kb-index-laws* 2>/dev/null | wc -l)

# ---- 源站可达性检测（HEAD/GET 首页，间隔 30 秒） ----
echo "## 源站探测中（$(date '+%H:%M:%S') 开始，遵守间隔 ≥30s）"
REACH=""
for entry in "${SITES[@]}"; do
  IFS='|' read -r NAME DOMAIN URL TYPE <<< "$entry"
  CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 15 -A "$UA" -L "$URL" 2>/dev/null)
  if [ "$CODE" = "200" ] || [ "$CODE" = "301" ] || [ "$CODE" = "302" ]; then
    REACH="$REACH| $NAME: ✅ 可达(HTTP $CODE) — $TYPE"
  else
    REACH="$REACH| $NAME: ❌ 不可达(HTTP $CODE) — $TYPE"
  fi
  sleep 30
done

{
  echo "# 法规监测数据准备（$NOW 脚本产出，lina-legal-monitor 只读此文件，抓取与可达性以本文件为准）"
  echo ""
  echo "## 一、本地历史库状态"
  echo ""
  echo "- 历史监测报告：$HIST_COUNT 份"
  echo "- 最近报告：$LAST_REPORT_NAME（$LAST_REPORT_TIME）"
  echo "- 法规索引：kb-index-laws 相关 $KB_LAWS 份"
  echo ""
  echo "## 二、源站可达性探测（$(date '+%H:%M:%S')，间隔 30 秒）"
  echo ""
  echo "$REACH" | tr '|' '\n' | sed '/^$/d' | sed 's/^/- /'
  echo ""
  echo "## 三、本次监测说明"
  echo ""
  echo "- 脚本已执行源站可达性探测（确定性步骤）；JS 渲染页面无法自动提取正文，需模型 web_fetch/web_search 补充分析"
  echo "- 对比维度（01 §9.3）：新增/修订/废止识别 → 模型基于抓取摘要 + web 检索完成"
  echo "- 分级（01 §9.5）：A 类(直接影响运营)→立即适配；B 类→周内适配；C 类→月度跟踪"
  echo ""
  echo "## 四、执行约定（模型部分）"
  echo ""
  echo "1. 基于本文件 + web 检索，生成《法规变更对比报告》至 output/法规监测/法规变更对比报告_\${TODAY}.md（格式沿用 2026-07-06 报告）"
  echo "2. 同步 ~/NovaShared/OutPut/；变更分级 P0-P3 + 影响店铺运营动作"
  echo "3. 完成后用 message(action=send) 显式投递简报给韩工：channel=openclaw-weixin、target=o9cq807kYZOgi_Ej_2PUcxS1xsJ0@im.wechat（原始混合大小写，小写 ret=-3）、accountId=bb1779004873-im-bot"
} > "$PREP"

echo "监测数据已产出：$PREP"
exit 0
