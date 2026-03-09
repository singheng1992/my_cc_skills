---
name: git-report
description: 生成git提交记录的工作报告，支持日报/周报/月报等时间形式。触发方式："生成日报"、"生成周报"、"生成月报"、"生成昨天日报"、"生成本周周报"、"生成12月月报"、"生成周报 @用户名"、"生成最近N天的周报"......支持指定用户、日期范围、天数
---

# Git 工作报告生成技能

## 功能描述
根据 Git 提交日志生成指定时间范围内的代码工作报告。

## 配置要求

### 1. 配置文件 `config.json`
```json
{
  "root_dir": "/path/to/code/root",
  "template_dir": "./assets",
  "default_template": "report-template.md",
  "output_dir": "/path/to/reports/"
}
```

### 2. 配置项说明
- `root_dir`：代码仓库根目录，必填，如果目录不存在会提示错误
- `template_dir`：报告模板目录，默认为 `./assets`
- `default_template`：默认模板文件名，默认为 `report-template.md`
- `output_dir`：报告输出目录，必填，如果目录不存在会提示错误

## 工作流程

1. **检查配置**：读取配置文件，验证根目录和输出目录是否配置
2. **检查模板**：验证报告模板是否存在
3. **检查输出目录**：验证输出目录是否存在
4. **扫描项目**：扫描根目录下所有包含 `.git` 文件夹的项目
5. **收集日志**：从各个项目收集指定时间范围内的 Git 提交日志
6. **生成报告**：基于模板和日志生成工作报告并保存到输出目录

## 依赖要求

- Python 3
- Git 命令行工具

## 脚本使用

### 基本用法

脚本位置：`scripts/git_report.py`

```bash
# 直接运行脚本生成报告
python3 scripts/git_report.py <时间范围> [选项]
```

### 命令行参数

**必填参数：**
- `date_range` - 时间范围（支持以下格式）
  - `today` - 今天
  - `yesterday` - 昨天
  - `week` - 本周
  - `last-week` - 上周
  - `month` - 本月
  - `last-month` - 上月
  - `YYYY-MM-DD~YYYY-MM-DD` - 自定义日期范围
  - `~YYYY-MM-DD` - 从开始到指定日期
  - `YYYY-MM-DD~` - 从指定日期到现在

**可选参数：**
- `--prompt` / `-p` - 附加提示词，用于定制报告内容
- `--config` / `-c` - 配置文件路径（默认：`config.json`）
- `--output` / `-o` - 输出文件路径（不指定则使用配置中的 `output_dir`）

### 使用示例

```bash
# 生成今天的日报
python3 scripts/git_report.py today

# 生成本周周报
python3 scripts/git_report.py week

# 生成上周周报
python3 scripts/git_report.py last-week

# 生成本月月报
python3 scripts/git_report.py month

# 生成自定义日期范围的报告
python3 scripts/git_report.py 2025-03-01~2025-03-07

# 添加附加提示词
python3 scripts/git_report.py week -p "重点关注后端API开发"

# 指定输出文件路径
python3 scripts/git_report.py week -o ~/reports/weekly.md

# 使用自定义配置文件
python3 scripts/git_report.py month -c /path/to/config.json
```

### 输出文件命名规则

脚本会根据时间范围自动生成输出文件名：
- `today` / `yesterday`：`daily-YYYY-MM-DD.md`
- `week`：`week-YYYY-WNN.md`
- `last-week`：`week-YYYY-WNN.md`（上周的周数）
- `month`：`month-YYYY-MM.md`
- `last-month`：`month-YYYY-MM.md`（上月的月份）
- 自定义日期范围：`custom-YYYY-MM-DD_to_YYYY-MM-DD.md`

## 错误处理

如果遇到以下错误：

- **请配置代码根目录**：请在 `config.json` 中设置 `root_dir`
- **请创建工作报告模版目录**：请确认 `templates/` 目录和 `report.md` 文件存在
- **输出目录不存在**：请创建 `output_dir` 配置的目录（如 `mkdir -p reports`）
- **配置文件不存在**：请复制 `config.json.example` 为 `config.json` 并填写配置

## 项目结构

```
git-report/
├── skill.md              # 技能说明文档
├── config.json.example   # 配置文件示例
├── config.json           # 实际配置文件（需自行创建）
├── scripts/
│   └── git_report.py     # Git 报告生成脚本
└── assets/
    └── report-template.md # 报告模板
```

## 创建时间
2025-03-09

## 更新时间
2025-03-09（添加脚本使用说明）

## 创建作者
Claude (GLM-4.7)
