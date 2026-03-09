---
name: git-report
description: 生成 Git 提交周报/月报。触发方式："生成周报"、"生成月报"、"生成本周周报"、"生成12月月报"、"生成周报 @用户名"、"生成最近N天的周报"。支持指定用户、日期范围、天数
---

# Git 工作报告生成技能

## 功能描述
根据 Git 提交日志生成指定时间范围内的代码工作报告。

## 使用方式
```
/git-report [时间范围] [附加提示词]
```

### 参数说明
- **时间范围**（必填）：支持以下格式
  - `today` - 今天
  - `yesterday` - 昨天
  - `week` - 本周
  - `last-week` - 上周
  - `month` - 本月
  - `last-month` - 上月
  - `YYYY-MM-DD~YYYY-MM-DD` - 自定义日期范围
  - `~YYYY-MM-DD` - 从开始到指定日期
  - `YYYY-MM-DD~` - 从指定日期到现在

- **附加提示词**（可选）：用于定制报告内容的提示词

## 配置要求

### 1. 配置文件 `config.json`
```json
{
  "root_dir": "/path/to/code/root",
  "template_dir": "./templates",
  "default_template": "report.md",
  "output_dir": "./reports"
}
```

### 2. 配置项说明
- `root_dir`：代码仓库根目录，必填
- `template_dir`：报告模板目录，默认为 `./templates`
- `default_template`：默认模板文件名，默认为 `report.md`
- `output_dir`：报告输出目录，必填，如果目录不存在会提示错误

## 工作流程

1. **检查配置**：读取配置文件，验证根目录和输出目录是否配置
2. **检查模板**：验证报告模板是否存在
3. **检查输出目录**：验证输出目录是否存在
4. **扫描项目**：扫描根目录下所有包含 `.git` 文件夹的项目
5. **收集日志**：从各个项目收集指定时间范围内的 Git 提交日志
6. **生成报告**：基于模板和日志生成工作报告并保存到输出目录

## 报告模板

模板支持以下变量：
- `{{date_range}}` - 时间范围描述
- `{{projects}}` - 项目列表
- `{{total_commits}}` - 总提交数
- `{{commits_by_project}}` - 按项目分组的提交信息

## 创建时间
2025-03-09

## 创建作者
Claude (GLM-4.7)
