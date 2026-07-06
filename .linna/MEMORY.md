# 🧠 Linna 记忆

## 📢 全局共享文件夹升级通知（2026-06-29 Nova 转达）

### 新目录结构
顶层挂载 `/mnt/hgfs/NovaShared/` 已拆分三个独立子目录：

| 智能体 | 共享 Input | 共享 OutPut | 本地 Workspace |
|:------|:----------|:-----------|:--------------|
| Nova 🐚 | `NovaShared/Nova/Input` | `NovaShared/Nova/OutPut` | workspace/input + workspace/output |
| Drama 🎬 | `NovaShared/Drama/Input` | `NovaShared/Drama/OutPut` | workspace-drama/input + workspace-drama/output |
| Linna 🛍️ | **`NovaShared/Linna/Input`** | **`NovaShared/Linna/OutPut`** | **workspace-lina/input + workspace-lina/output** |

### 给你的规则变化
1. **投递入口：** 你用的共享 Input 是 `NovaShared/Linna/Input/`，不是老的 `NovaShared/Input/`
2. **成品出口：** 同步到 `NovaShared/Linna/OutPut/`
3. **本地不变：** 你本地 `workspace-lina/input/` 和 `workspace-lina/output/` 照旧
4. **流程不变：** 检测 Input → 拷贝到本地 → 删除共享源文件 → 本地处理 → 成品同步到共享 OutPut
5. **隔离：** 你不能读写 Nova/Drama 的目录，反之亦然

### ⚠️ 注意：你的工作区路径已修复
之前 openclaw.json 里配的是 `workspace-gain`（不存在），后改为 `workspace-linna`。本日已迁移至 `workspace-lina`。

### 输出文件三步规则（你也要执行）
① 生成文件到自身 `workspace-lina/output/`
② 同步拷贝到共享 `NovaShared/Linna/OutPut/`
③ 微信渠道时额外发 MEDIA（仅 channel=openclaw-weixin 时触发）

> 完整规则见 Nova 的 01_BUSINESS_CONFIG.md §1.2，三智能体复用同一套

### 📬 智能体通信

三智能体（Nova/Drama/Linna）间通过 `sessions_send` 直接通信。不再使用文件总线方式。
