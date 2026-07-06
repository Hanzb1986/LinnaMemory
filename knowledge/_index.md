# 📚 Lina 知识体系索引

> 创建：2026-07-06 | 维护：Lina
> 独立知识体系，事务型可进化知识，不依赖对话上下文。

---

## 目录结构

```
knowledge/
├── _index.md           ← 本文件：全局索引
├── _maintenance.md     ← 维护规则与频率
├── departments/        ← 六部门专业知识库（按领域划分）
├── patterns/           ← 模式库（从错误/成功中学习）
└── people/             ← 人员画像（关键联系人画像）
```

## 快速导航

### 部门知识

| 目录 | 对应部门 | 核心内容 |
|:----|:--------|:--------|
| `departments/market/` | 📊 经营调研部 | 行业动态、竞品分析、市场数据 |
| `departments/legal/` | ⚖️ 法务合规部 | 法规解读、合规校验规则、纠纷预案 |
| `departments/finance/` | 💰 财务审计部 | 财税政策、报税规则、账务模板 |
| `departments/hr/` | 👥 人事行政部 | 用工制度、人事台账、薪酬规则 |
| `departments/operations/` | 🛒 商业运营部 | 店铺运营SOP、供应链规则、客服标准 |
| `departments/risk/` | 🛡️ 风控品控部 | 熔断规则、质量溯源、风控阈值 |

### 模式库

| 文件 | 用途 |
|:----|:-----|
| `patterns/errors.md` | 错误模式（已踩的坑、触发条件、修复方案） |
| `patterns/success.md` | 成功模式（有效策略、最佳实践、可复用SOP） |
| `patterns/decisions.md` | 关键决策记录（背景、选项、结论、理由） |

### 人员画像

| 文件 | 用途 |
|:----|:-----|
| `people/hans.md` | 店主 Hans 画像（偏好、禁忌、沟通方式） |
| `people/nova.md` | Nova 调度画像（派工风格、优先级、反馈偏好） |
| `people/ellie.md` | Ellie 研发画像（能力范围、协作模式） |
| `people/drama.md` | Drama 内容画像（协作边界、素材交接） |
| `people/others.md` | 其他关键外部联系人 |

## 使用规则

1. **写入时机**：每次获得新信息、发现模式、修正认知后写入
2. **查询方式**：通过 `memory_search` 检索，或直接按路径读取
3. **冲突处理**：新知识与旧记录矛盾 → 追加标注「修正于 YYYY-MM-DD」，保留旧记录
4. **版本管理**：随 Git 自动同步备份
