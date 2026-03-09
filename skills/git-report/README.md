# Git 工作报告生成技能

根据 Git 提交日志生成指定时间范围内的代码工作报告。

## 功能特性

- ✅ 自动扫描根目录下所有 Git 项目
- ✅ 支持多种时间范围格式
- ✅ 生成结构化的工作报告
- ✅ 可自定义报告模板
- ✅ 支持用户自定义提示词

## 安装配置

### 1. 配置代码根目录和输出目录

编辑 `config.json` 文件：

```json
{
  "root_dir": "/Users/yourname/code",
  "template_dir": "./templates",
  "default_template": "report.md",
  "output_dir": "./reports"
}
```

**配置项说明**：
- `root_dir`：代码仓库根目录（必填）
- `output_dir`：报告输出目录（必填），如果目录不存在会提示错误

### 2. 创建输出目录

```bash
mkdir -p reports
```

### 3. 确认报告模板

报告模板位于 `templates/report.md`，你可以根据需要修改模板格式。

## 使用方法

### 基本用法

```bash
# 生成今天的报告
./git_report.py today

# 生成昨天的报告
./git_report.py yesterday

# 生成本周的报告
./git_report.py week

# 生成上周的报告
./git_report.py last-week

# 生成本月的报告
./git_report.py month

# 生成上月的报告
./git_report.py last-month
```

### 自定义时间范围

```bash
# 指定日期范围
./git_report.py 2025-03-01~2025-03-07

# 从开始到指定日期
./git_report.py ~2025-03-07

# 从指定日期到现在
./git_report.py 2025-03-01~
```

**说明**：
- 报告默认保存到 `output_dir` 配置的目录
- 文件名根据时间范围自动生成（如 `week-2025-W10.md`）

### 自定义输出路径

```bash
# 保存到指定文件（覆盖默认输出目录）
./git_report.py week -o /path/to/custom-report.md

# 保存到相对路径
./git_report.py month -o ../reports/march.md

# 保存到绝对路径
./git_report.py today -o ~/reports/daily.md
```

**说明**：
- 使用 `-o` 参数可以覆盖默认的输出目录和文件名
- 如果指定路径的目录不存在，会自动创建

### 添加提示词

```bash
./git_report.py week --prompt "重点关注前端相关的提交"
```

## 输出示例

```markdown
# Git 工作报告

**时间范围**：2025-03-01 至 2025-03-07
**生成时间**：2025-03-07 15:30:00

## 概览

- **扫描项目数**：5
- **有提交的项目数**：3
- **总提交数**：15
- **涉及项目**：project-a, project-b, project-c

## 项目详情

### project-a

- **路径**：`project-a`
- **提交数**：8

#### 提交记录

- **abc12345** 修复登录页面的样式问题
  - 作者：张三
  - 时间：2025-03-05 14:30:00 +0800

...
```

## 时间范围格式说明

| 格式 | 说明 |
|------|------|
| `today` | 今天（从 00:00 到现在） |
| `yesterday` | 昨天（昨天 00:00 到今天 00:00） |
| `week` | 本周（从本周一到现在的） |
| `last-week` | 上周（从上周一到上周日） |
| `month` | 本月（从本月1号到现在的） |
| `last-month` | 上月（从上月1号到本月1号） |
| `YYYY-MM-DD~YYYY-MM-DD` | 自定义日期范围 |
| `~YYYY-MM-DD` | 从开始到指定日期 |
| `YYYY-MM-DD~` | 从指定日期到现在 |

## 错误处理

如果遇到以下错误：

- **请配置代码根目录**：请在 `config.json` 中设置 `root_dir`
- **请创建工作报告模版目录**：请确认 `templates/` 目录和 `report.md` 文件存在
- **输出目录不存在**：请创建 `output_dir` 配置的目录（如 `mkdir -p reports`）

## 依赖要求

- Python 3.7+
- Git 命令行工具

## 创建时间

2025-03-09

## 创建作者

Claude (GLM-4.7)
