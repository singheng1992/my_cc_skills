# my_cc_skills

Claude Code 常用技能收集

## 📖 项目简介

这是一个为 Claude Code 创建的自定义技能集合，旨在提升开发效率和代码质量。

## ✨ 功能特性

- [git-report](./skills/git-report/) - Git 工作报告生成器
  - 自动扫描代码仓库并生成工作报告
  - 支持日报、周报、月报等多种时间范围
  - 可自定义报告模板和输出目录

## 🚀 安装方法

### 方式一：通过 Marketplace 安装（推荐）

```bash
# 添加 marketplace
/plugin marketplace add git@github.com:singheng1992/my_cc_skills.git

# 安装插件
/plugin install git-report
```

### 方式二：本地安装

```bash
# 克隆仓库
git clone https://github.com/singheng1992/my_cc_skills.git

# 在 Claude Code 中使用插件目录启动
claude --plugin-dir ./my_cc_skills/.claude-plugin
```

## 📂 目录结构

```
my_cc_skills/
├── .claude-plugin/          # Claude Code 插件配置
│   └── marketplace.json     # Marketplace 配置文件
├── skills/                  # 技能目录
│   └── git-report/         # Git 报告技能
│       ├── git_report.py    # 主程序
│       ├── skill.md         # 技能说明
│       ├── README.md        # 使用文档
│       ├── config.json.example  # 配置示例
│       └── templates/       # 报告模板
│           └── report.md    # 默认模板
└── README.md               # 项目说明
```

## 📝 使用说明

### git-report 技能

1. **配置环境**
   ```bash
   cd skills/git-report
   cp config.json.example config.json
   # 编辑 config.json 设置你的代码根目录和输出目录
   mkdir -p reports
   ```

2. **生成报告**
   ```bash
   # 生成今天的日报
   ./git_report.py today

   # 生成本周周报
   ./git_report.py week

   # 生成上月月报
   ./git_report.py last-month

   # 自定义时间范围
   ./git_report.py 2025-03-01~2025-03-07
   ```

详细使用说明请参考 [git-report README](./skills/git-report/README.md)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 🔗 相关链接

- [Claude Code 官方文档](https://docs.anthropic.com/claude/docs/claude-code)
- [插件开发指南](https://docs.anthropic.com/claude/docs/plugins)

---

**创建时间**：2025-03-09
**维护者**：singheng1992

