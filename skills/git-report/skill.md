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
| `-p, --prompt` | 附加提示词 |
| `-o, --output` | 输出文件路径 |

### 使用示例

```bash
# 生成今天的日报
bash scripts/git_report.sh today

# 生成本周周报
bash scripts/git_report.sh week

# 生成自定义日期范围报告
bash scripts/git_report.sh 2025-03-01~2025-03-07

# 添加附加提示词
bash scripts/git_report.sh week -p "重点关注后端开发"
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
│   └── report-template.md           # 报告模板
```

## 创建时间

2025-03-09
