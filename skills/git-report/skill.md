---
name: git-report
description: 生成Git提交记录的工作报告，支持日报/周报/月报等时间形式。触发方式："生成日报"、"生成周报"、"生成月报"、"生成昨天日报"、"生成本周周报"、"生成12月月报"、"生成周报 @用户名"、"生成最近N天的周报"......支持指定用户、日期范围、天数
---

# Git 工作报告生成技能

自动扫描代码仓库，生成指定时间范围内的 Git 工作报告。

## 工作流程

1. **检查配置**：读取 `.env` 配置文件
2. **收集日志**：扫描代码根目录下所有 Git 仓库，收集指定时间范围的提交记录
3. **生成报告**：基于模板生成工作报告

## 配置要求

在 `scripts/.env` 中配置以下环境变量：

```bash
# 代码仓库根目录（必填）
code_root_dir="/path/to/code/root"

# 报告输出目录（必填）
report_output_dir="/path/to/output/dir"

# =================================================================
# 报告总结配置（灵活总结功能）
# =================================================================

# 总结模式：template（模板）、ai（AI生成）、custom（自定义文本）
summary_mode="template"

# 总结模板类型：default、daily、weekly、monthly、simple
# 当 summary_mode=template 时生效
summary_template="default"

# AI 生成总结的提示词模板
# 当 summary_mode=ai 时生效，Claude 将根据提交记录生成总结
ai_summary_prompt="请根据以上Git提交记录，生成一份简洁的工作总结，突出主要工作内容和成果。"

# 自定义总结文本
# 当 summary_mode=custom 时生效
custom_summary="这是自定义总结内容"
```

## 使用方法

### 通过 Claude Code 调用

```
生成昨天日报
生成本周周报
生成12月月报
生成周报 @用户名
生成最近7天的周报
```

### 直接运行脚本

```bash
bash scripts/git_report.sh <时间范围> [选项]
```

### 参数说明

| 参数 | 说明 |
|------|------|
| `today` | 今天 |
| `yesterday` | 昨天 |
| `week` | 本周 |
| `last-week` | 上周 |
| `month` | 本月 |
| `last-month` | 上月 |
| `YYYY-MM-DD~YYYY-MM-DD` | 自定义日期范围 |

### 可选参数

| 参数 | 说明 |
|------|------|
| `-p, --prompt` | 自定义总结内容（覆盖配置文件设置） |
| `-s, --summary-mode` | 总结模式：`template`/`ai`/`custom` |
| `-t, --template` | 总结模板名称：`default`/`daily`/`weekly`/`monthly`/`simple` |
| `-o, --output` | 输出文件路径 |

### 使用示例

```bash
# 生成今天的日报（使用默认总结模板）
bash scripts/git_report.sh today

# 生成本周周报
bash scripts/git_report.sh week

# 使用周报总结模板
bash scripts/git_report.sh week -t weekly

# 使用 AI 生成总结（需要通过 Claude Code 调用）
bash scripts/git_report.sh week -s ai

# 使用自定义总结
bash scripts/git_report.sh week -s custom -p "本周主要完成了后端API开发"

# 生成自定义日期范围报告
bash scripts/git_report.sh 2025-03-01~2025-03-07
```

## 错误处理

| 错误信息 | 解决方法 |
|----------|----------|
| 请配置代码根目录 | 在 `.env` 中设置 `code_root_dir` |
| 报告模板不存在 | 确认 `templates/report.md` 存在 |
| 输出目录不存在 | 创建 `report_output_dir` 配置的目录 |
| 配置文件不存在 | 复制 `.env.example` 为 `.env` |

## 项目结构

```
git-report/
├── SKILL.md                 # 技能说明文档
├── scripts/
│   ├── git_report.sh        # 主脚本
│   ├── .env.example         # 配置示例
│   └── .env                 # 配置文件（需创建）
├── assets/
│   ├── report-template.md   # 报告模板
│   └── summary-templates.md # 总结模板集合
```

## 灵活总结功能详解

### 总结模式

本技能支持三种总结模式，可通过 `.env` 配置或命令行参数指定：

#### 1. Template 模式（默认）

使用预定义的总结模板，支持变量插值。

**可用模板：**
- `default` - 通用默认模板
- `daily` - 日报专用模板
- `weekly` - 周报专用模板
- `monthly` - 月报专用模板
- `simple` - 简洁模板

**支持的变量：**
- `{{date_label}}` - 日期范围标签
- `{{project_count}}` - 有提交的项目数
- `{{total_commits}}` - 总提交数
- `{{start_date}}` - 开始日期
- `{{end_date}}` - 结束日期
- `{{generated_at}}` - 生成时间

**自定义模板：**

编辑 `assets/summary-templates.md` 文件，添加自定义模板：

```markdown
my_template: |
  这是我的自定义总结，项目数：{{project_count}}，提交数：{{total_commits}}
```

#### 2. AI 模式

通过 Claude AI 根据提交记录智能生成总结。

**特点：**
- 自动分析提交信息
- 提取工作重点和趋势
- 生成个性化总结

**使用方式：**
```bash
# 命令行指定
bash scripts/git_report.sh week -s ai

# 或在 .env 中设置
summary_mode="ai"
```

#### 3. Custom 模式

使用固定的自定义文本作为总结。

**使用方式：**
```bash
# 命令行指定
bash scripts/git_report.sh week -s custom -p "本周主要工作：完成用户认证模块开发"

# 或在 .env 中设置
summary_mode="custom"
custom_summary="这是固定的总结内容"
```

### 优先级规则

1. 命令行 `-p` 参数优先级最高
2. 命令行 `-s` 和 `-t` 参数次之
3. `.env` 配置文件中的设置优先级最低

## 创建时间

2025-03-09

## 更新时间

- 2025-03-09：添加灵活总结功能，支持模板/AI/自定义三种模式
