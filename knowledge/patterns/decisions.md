# 🎯 关键决策记录

> 记录关键决策的背景、选项、结论、理由。
> 以后遇到类似问题直接查，不需要重复思考。

---

## 2026-07

| 日期 | 决策 | 背景 | 选项 | 结论 | 理由 |
|:----|:----|:----|:----|:----|:----|
| 07-06 | 名称统一 | Hans 改 config 为 `Lina`/`linna`，内部文件仍为 `Linna`/`gain` | A=跟config B=改config | **A：以 config 为准** | Hans 上手改的就是最终状态 |
| 07-06 | 通信机制 | .comm 文件总线 + sessions_send 双机制 | 保留/删除 .comm | **删除 .comm，仅用 sessions_send** | NovaShared 未挂载，sessions_send 更实时有回执 |
| 07-06 | 共享 OutPut 目录结构 | 之前嵌套 business/product/quality 子目录 | 保留嵌套/展平 | **展平，文件直放根目录** | Nova 统一规范要求 |
