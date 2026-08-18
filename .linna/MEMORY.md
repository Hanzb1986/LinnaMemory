# 🧠 Lina 记忆

## 📢 存储架构：workspace 主存储（2026-08-12 韩工 定）

### 当前架构
所有资料以 **workspace 为主存储**，共享文件夹只做**投料口**和**输出镜像**：

```
~/.openclaw/workspace-lina/        ← 主存储（我的工作区）
├── Lina/                          ← 我的资料主存储（原材料、分析笔记、中间产物）
├── output/                        ← 本地输出（韩工取文件窗口）
└── .linna/                        ← 配置与规则

~/NovaShared/OutPut/               ← 【输出镜像】所有 Agent 的输出镜像全放这里（保留不变）
```

### 规则变更（2026-08-12）
1. **我的资料主存储 = `~/.openclaw/workspace-lina/Lina/`**（原共享 Lina 投料口已清空停用）
2. 别人投料给我：文件放入 `~/.openclaw/workspace-lina/Lina/`（投料口）
3. 输出文件：本地写入 `workspace-lina/output/`，同步镜像到 `~/NovaShared/OutPut/`
4. 输出格式约束（与 .linna/TOOLS.md 格式标准一致）：`.html`/`.pdf`/`.csv`（表单类首选）/`.docx`，`.xlsx` 仅韩工明确要求时使用，禁止 `.md` 进入 OutPut
5. 旧 VMWare 共享路径 `/mnt/hgfs/ElliShared/` **已废弃**，不再使用

### 已过期的旧规则（留档备查）

~~2026-07-20 Nova 通知：所有 Agent 统一使用共享目录，其中 Lina 子目录为 input（2026-08-12 起该投料口清空停用）~~

~~`/mnt/hgfs/ElliShared/` 结构（2026-06-29 → 2026-07-20）~~

| 智能体 | 共享 Input | 共享 OutPut |
|:------|:----------|:-----------|
| Nova 🐚 | ~~ElliShared/Nova/Input~~ | ~~ElliShared/Nova/OutPut~~ |
| Lina 🛍️ | ~~ElliShared/Linna/Input~~ | ~~ElliShared/Linna/OutPut~~ |
| Drama 🎬 | ~~ElliShared/Drama/Input~~ | ~~ElliShared/Drama/OutPut~~ |

### 输出文件三步规则（维持）
① 生成文件到自身 `workspace-lina/output/`
② 同步拷贝到共享 `~/NovaShared/OutPut/`
③ 微信渠道时额外用 message 工具发送附件（仅 channel=openclaw-weixin 时触发）

### 📬 智能体通信

四智能体（Nova/Ellie/Drama/Lina）间通过 `sessions_send` 直接通信。不再使用文件总线方式。
