# my_cc_skills

Claude Code 技能集合，为开发者提供高效的工作流工具。

## 项目简介

这是一个为 Claude Code 创建的自定义技能集合，通过自定义技能增强 Claude Code 的能力。

## 功能特性

### git-report - Git 工作报告生成器

- 自动扫描代码仓库并生成工作报告
- 支持日报、周报、月报等多种时间范围
- 支持指定用户、日期范围、自定义提示词

## 快速开始

### 安装插件

```bash
# 添加 marketplace
/plugin marketplace add git@github.com:singheng1992/my_cc_skills.git

# 安装 git-report 技能
/plugin install git-report
```

### 配置

1. 复制配置示例文件：

```bash
cd skills/git-report/scripts
cp .env.example .env
```

2. 编辑 `.env` 文件，配置代码仓库根目录和输出目录：

```bash
code_root_dir="~/code"
report_output_dir="~/reports"
```

### 使用

在 Claude Code 中直接输入：

```
生成昨天日报
生成本周周报
生成12月月报
```

## 目录结构

```
my_cc_skills/
├── .claude-plugin/          # 插件配置
├── skills/                  # 技能目录
│   └── git-report/         # Git 报告技能
│       ├── SKILL.md         # 技能说明
│       ├── scripts/         # 脚本目录
│       │   ├── git_report.sh
│       │   └── .env.example
│       └── templates/       # 报告模板
└── README.md
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 相关链接

- [Claude Code 官方文档](https://docs.anthropic.com/claude/docs/claude-code)
- [插件开发指南](https://docs.anthropic.com/claude/docs/plugins)

