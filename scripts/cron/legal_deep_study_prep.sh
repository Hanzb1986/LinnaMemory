#!/bin/bash
# legal_deep_study_prep.sh — 每日 00:30 法律深度学习数据准备（供 lina-legal-deep-study 只读，替代模型自行盘点进度）
# 数据源：Lina/学习笔记/（首轮七批次+二轮笔记）、Lina/法规文件/法规（pdf版）/（原文定位）、memory/kb-index/（法规索引）
# 产出：Lina/学习笔记/深度学习任务单.md —— 当前进度 + 今日待学建议 + 原文定位
# 改造依据：脚本化改造方法论（2026-08-18 韩工定）§三 阶段2 —— 确定性盘点脚本化，模型只做精读/拆解/生成
set -uo pipefail
WS=/home/hans/.openclaw/workspace-lina
TODAY=$(date +%Y-%m-%d)
NOW=$(date '+%Y-%m-%d %H:%M')
PREP="$WS/Lina/学习笔记/深度学习任务单.md"
NOTES_DIR="$WS/Lina/学习笔记"
PDF_DIR="$WS/Lina/法规文件/法规（pdf版）"

# ---- 首轮进度：七批次笔记 ----
BATCH_COUNT=$(ls "$NOTES_DIR"/每日批量学习_2026-06-30*.md 2>/dev/null | wc -l)
BATCHES=$(ls "$NOTES_DIR"/每日批量学习_2026-06-30*.md 2>/dev/null | sed "s|$NOTES_DIR/||")

# ---- 第二轮进度：核心法精读 ----
SECOND_ROUND_FILE=$(ls -t "$WS/output/学习笔记/每日批量学习_2026-07-04.md" 2>/dev/null | head -1)
SECOND_BASE="电子商务法/消费者权益保护法/广告法/产品质量法/反不正当竞争法/个人信息保护法/数据安全法/网络安全法/民法典·合同侵权/民事诉讼法"
# 已精读判定：以 output/学习笔记 已产出精读笔记的标题为准（确定性来源、跨日累计不丢失）。
# 注：原「仅看任务单上一日 ✅」方案在任务单每日重建后会遗忘历史，导致重复建议已学法（2026-08-21 修复）。
DONE_LAWS=$(grep -hE '^# ' "$WS/output/学习笔记"/每日批量学习_2026-08-*.md 2>/dev/null | grep -oE '食品安全法|商标法|著作权法|专利法' | sort -u || true)
DONE_STR=$(echo "$DONE_LAWS" | tr '\n' ' ' | sed 's/^ *//; s/ *$//; s/  */ /g' | sed 's/ / \/ /g')
DONE_COUNT=$(( 10 + $(echo "$DONE_LAWS" | grep -c . || true) ))
REMAIN_LAWS=""
for law in 食品安全法 商标法 著作权法 专利法; do
  if echo "$DONE_LAWS" | grep -q "$law"; then continue; fi
  [ -n "$REMAIN_LAWS" ] && REMAIN_LAWS="${REMAIN_LAWS} / "
  REMAIN_LAWS="${REMAIN_LAWS}${law}"
done
SECOND_DONE="${DONE_COUNT}/14（${SECOND_BASE}${DONE_STR:+ / ${DONE_STR}}）"
SECOND_REMAIN="${REMAIN_LAWS:-（无，14 部已全部精读，建议进入第三轮或韩工指定方向）}"

# ---- 今日待学建议：从剩余 4 部中取（按固定顺序，每日 1 部；全部完成后提示进入下一轮） ----
# 已精读判定：同上 DONE_LAWS（笔记标题），模型完成后再在任务单对应法名后追加 ✅（供人工/日志核对）
SUGGEST=""
for law in 食品安全法 商标法 著作权法 专利法; do
  if echo "$DONE_LAWS" | grep -q "$law"; then
    continue
  fi
  SUGGEST="$law"
  break
done
[ -z "$SUGGEST" ] && SUGGEST="（第二轮 14 部已全部精读，建议进入第三轮或韩工指定方向）"

# ---- 原文定位：PDF 中查找今日待学法 ----
PDF_PATH="（未找到 PDF，需 web 检索原文）"
if [ "$SUGGEST" != "（第二轮 14 部已全部精读，建议进入第三轮或韩工指定方向）" ]; then
  FOUND=$(ls "$PDF_DIR"/*"$SUGGEST"*.pdf 2>/dev/null | head -1)
  [ -n "$FOUND" ] && PDF_PATH="$FOUND"
fi

{
  echo "# 法律深度学习任务单（$NOW 脚本产出，lina-legal-deep-study 只读此文件，进度盘点以本文件为准）"
  echo ""
  echo "## 一、首轮进度（308 部）"
  echo ""
  echo "- 已学批次：$BATCH_COUNT 批"
  echo "$BATCHES" | sed 's/^/- /'
  echo ""
  echo "## 二、第二轮深度精读进度（14 部核心法）"
  echo ""
  echo "- 已完成：$SECOND_DONE"
  echo "- 剩余：$SECOND_REMAIN"
  echo ""
  echo "## 三、今日待学建议"
  echo ""
  echo "**$SUGGEST**"
  echo ""
  echo "## 四、原文定位"
  echo ""
  echo "- $PDF_PATH"
  echo ""
  echo "## 五、执行约定（模型部分）"
  echo ""
  echo "1. 精读今日待学法（条款级风险拆解/司法解释联动/罚则量化/业务 SOP），沿用 output/学习笔记/每日批量学习_2026-07-04.md 格式"
  echo "2. 产出：output/学习笔记/每日批量学习_\${TODAY}.md（仅本地留存，不同步 ~/NovaShared/OutPut/；OutPut 只放交付文档 .html/.pdf/.csv/.docx。如需共享走共享知识中枢登记：material_index.py add --agent lina --domain business --share_level shared + 通知 Nova）"
  echo "3. 完成后在本文档「今日待学建议」对应法名后追加 ✅，供明日脚本跳过"
} > "$PREP"

echo "任务单已产出：$PREP"
exit 0
