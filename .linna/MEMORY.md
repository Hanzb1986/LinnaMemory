# 🧠 Lina 记忆

## 📢 共享目录统一升级（2026-07-20 Nova 通知）

### 新目录结构
所有 Agent 统一使用 `~/NovaShared/`：

```
~/NovaShared/
├── Lina/        ← 你的 input（别人放给你的文件）
├── Drama/
├── Ellie/
├── Nova/
└── OutPut/      ← 【统一输出目录】所有 Agent 的输出全放这里
```

### 规则变更（2026-07-20）
1. 旧 VMWare 共享路径 `/mnt/hgfs/ElliShared/` **已废弃**，不再使用
2. 所有输出文件统一写入 `~/NovaShared/OutPut/`
3. 输出格式约束不变：仅写 .html → .pdf → .xlsx → .docx，禁止 .md 进入 OutPut
4. 你的 input 文件夹机制不变，别人找你共享文件会放 `~/NovaShared/Lina/`

### 之前的旧规则（已过期，留档备查）

~~`/mnt/hgfs/ElliShared/` 结构（2026-06-29 → 2026-07-20）~~

| 智能体 | 共享 Input | 共享 OutPut |
|:------|:----------|:-----------|
| Nova 🐚 | ~~ElliShared/Nova/Input~~ | ~~ElliShared/Nova/OutPut~~ |
| Lina 🛍️ | ~~ElliShared/Linna/Input~~ | ~~ElliShared/Linna/OutPut~~ |
| Drama 🎬 | ~~ElliShared/Drama/Input~~ | ~~ElliShared/Drama/OutPut~~ |

### 输出文件三步规则（维持）
① 生成文件到自身 `workspace-lina/output/`
② 同步拷贝到共享 `~/NovaShared/OutPut/`
③ 微信渠道时额外发 MEDIA（仅 channel=openclaw-weixin 时触发）

### 📬 智能体通信

三智能体（Nova/Drama/Lina）间通过 `sessions_send` 直接通信。不再使用文件总线方式。
