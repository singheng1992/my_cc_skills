#!/usr/bin/env python3
"""
Git 工作报告生成器

创建时间：2025-03-09
功能说明：扫描代码仓库并生成工作报告
创建作者：Claude (GLM-4.7)
"""

import argparse
import json
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Any


class GitReportGenerator:
    """Git 报告生成器"""

    def __init__(self, config_path: str):
        """
        初始化生成器

        Args:
            config_path: 配置文件路径
        """
        self.config_path = Path(config_path)
        self.skill_dir = self.config_path.parent
        self.config = self._load_config()

    def _load_config(self) -> Dict[str, Any]:
        """加载配置文件"""
        if not self.config_path.exists():
            raise FileNotFoundError(f"配置文件不存在：{self.config_path}")

        with open(self.config_path, "r", encoding="utf-8") as f:
            config = json.load(f)

        # 检查根目录配置
        if not config.get("root_dir"):
            raise ValueError("请配置代码根目录（root_dir）")

        # 转换为绝对路径
        config["root_dir"] = Path(config["root_dir"]).expanduser().resolve()
        config["template_dir"] = self.skill_dir / config.get("template_dir", "templates")

        # 输出目录（相对于技能目录）
        output_dir = config.get("output_dir", "reports")
        config["output_dir"] = self.skill_dir / output_dir

        return config

    def _check_template(self) -> Path:
        """检查报告模板是否存在"""
        template_name = self.config.get("default_template", "report.md")
        template_path = self.config["template_dir"] / template_name

        if not template_path.exists():
            raise ValueError(f"请创建工作报告模版目录：{self.config['template_dir']}")

        return template_path

    def _check_output_dir(self) -> Path:
        """检查输出目录是否存在"""
        output_dir = self.config["output_dir"]

        if not output_dir.exists():
            raise ValueError(f"输出目录不存在：{output_dir}")

        return output_dir

    def _scan_git_projects(self) -> List[Path]:
        """扫描根目录下所有包含 .git 文件夹的项目"""
        root_dir = self.config["root_dir"]
        projects = []

        for path in root_dir.iterdir():
            if path.is_dir() and not path.name.startswith("."):
                git_dir = path / ".git"
                if git_dir.exists():
                    projects.append(path)

        return sorted(projects)

    def _parse_date_range(self, date_range: str) -> tuple[datetime, datetime]:
        """
        解析时间范围

        Args:
            date_range: 时间范围字符串

        Returns:
            (开始时间, 结束时间)
        """
        now = datetime.now()
        today = now.replace(hour=0, minute=0, second=0, microsecond=0)

        if date_range == "today":
            return today, now
        elif date_range == "yesterday":
            yesterday = today - timedelta(days=1)
            return yesterday, today
        elif date_range == "week":
            # 本周一
            week_start = today - timedelta(days=today.weekday())
            return week_start, now
        elif date_range == "last-week":
            # 上周一
            week_start = today - timedelta(days=today.weekday() + 7)
            week_end = week_start + timedelta(days=7)
            return week_start, week_end
        elif date_range == "month":
            # 本月1号
            month_start = today.replace(day=1)
            return month_start, now
        elif date_range == "last-month":
            # 上月1号
            month_start = (today.replace(day=1) - timedelta(days=1)).replace(day=1)
            # 本月1号
            month_end = today.replace(day=1)
            return month_start, month_end
        elif "~" in date_range:
            parts = date_range.split("~")
            if parts[0]:
                start_date = datetime.strptime(parts[0], "%Y-%m-%d")
            else:
                start_date = datetime(1970, 1, 1)

            if parts[1]:
                end_date = datetime.strptime(parts[1], "%Y-%m-%d")
            else:
                end_date = now

            return start_date, end_date
        else:
            raise ValueError(f"无法识别的时间范围：{date_range}")

    def _get_git_logs(self, project_path: Path, start_date: datetime, end_date: datetime) -> List[Dict[str, str]]:
        """
        获取项目的 Git 日志

        Args:
            project_path: 项目路径
            start_date: 开始时间
            end_date: 结束时间

        Returns:
            提交记录列表
        """
        # 格式化时间范围
        since = start_date.strftime("%Y-%m-%d %H:%M:%S")
        until = end_date.strftime("%Y-%m-%d %H:%M:%S")

        try:
            result = subprocess.run(
                [
                    "git",
                    "log",
                    f"--since={since}",
                    f"--until={until}",
                    "--pretty=format:%H|%an|%ad|%s",
                    "--date=iso"
                ],
                cwd=project_path,
                capture_output=True,
                text=True,
                check=True
            )

            commits = []
            for line in result.stdout.strip().split("\n"):
                if line:
                    parts = line.split("|", 3)
                    if len(parts) == 4:
                        commits.append({
                            "hash": parts[0][:8],
                            "author": parts[1],
                            "date": parts[2],
                            "message": parts[3]
                        })

            return commits

        except subprocess.CalledProcessError as e:
            print(f"警告：获取 {project_path} 的 Git 日志失败：{e}")
            return []

    def generate_report(self, date_range: str, prompt: str = "") -> str:
        """
        生成工作报告

        Args:
            date_range: 时间范围
            prompt: 用户附加提示词

        Returns:
            报告内容
        """
        # 检查模板
        template_path = self._check_template()

        # 解析时间范围
        start_date, end_date = self._parse_date_range(date_range)

        # 扫描项目
        projects = self._scan_git_projects()

        if not projects:
            return f"在 {self.config['root_dir']} 下未找到任何 Git 项目。"

        # 收集日志
        project_data = []
        total_commits = 0

        for project_path in projects:
            commits = self._get_git_logs(project_path, start_date, end_date)

            if commits:
                project_data.append({
                    "name": project_path.name,
                    "path": str(project_path.relative_to(self.config["root_dir"])),
                    "commit_count": len(commits),
                    "commits": commits
                })
                total_commits += len(commits)

        # 生成报告
        date_range_desc = f"{start_date.strftime('%Y-%m-%d')} 至 {end_date.strftime('%Y-%m-%d')}"

        report = f"""# Git 工作报告

**时间范围**：{date_range_desc}
**生成时间**：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## 概览

- **扫描项目数**：{len(projects)}
- **有提交的项目数**：{len(project_data)}
- **总提交数**：{total_commits}
"""

        if project_data:
            report += f"- **涉及项目**：{', '.join([p['name'] for p in project_data])}\n\n"
        else:
            report += "- **涉及项目**：无\n\n"

        if prompt:
            report += f"## 用户提示\n\n{prompt}\n\n"

        if project_data:
            report += "## 项目详情\n\n"

            for project in project_data:
                report += f"### {project['name']}\n\n"
                report += f"- **路径**：`{project['path']}`\n"
                report += f"- **提交数**：{project['commit_count']}\n\n"
                report += "#### 提交记录\n\n"

                for commit in project['commits']:
                    report += f"- **{commit['hash']}** {commit['message']}\n"
                    report += f"  - 作者：{commit['author']}\n"
                    report += f"  - 时间：{commit['date']}\n\n"
        else:
            report += "## 提示\n\n在指定时间范围内没有找到任何提交记录。\n"

        return report


def _generate_output_filename(date_range: str) -> str:
    """
    根据时间范围生成输出文件名

    Args:
        date_range: 时间范围字符串

    Returns:
        文件名
    """
    now = datetime.now()
    date_str = now.strftime("%Y-%m-%d")

    # 根据时间范围生成文件名
    if date_range == "today":
        return f"daily-{date_str}.md"
    elif date_range == "yesterday":
        return f"daily-{date_str}.md"
    elif date_range == "week":
        return f"week-{now.strftime('%Y-W%U')}.md"
    elif date_range == "last-week":
        last_week = now - timedelta(days=7)
        return f"week-{last_week.strftime('%Y-W%U')}.md"
    elif date_range == "month":
        return f"month-{now.strftime('%Y-%m')}.md"
    elif date_range == "last-month":
        last_month = now.replace(day=1) - timedelta(days=1)
        return f"month-{last_month.strftime('%Y-%m')}.md"
    elif "~" in date_range:
        # 自定义日期范围
        parts = date_range.split("~")
        if parts[0] and parts[1]:
            return f"custom-{parts[0]}_to_{parts[1]}.md"
        elif parts[0]:
            return f"custom-from-{parts[0]}.md"
        elif parts[1]:
            return f"custom-to-{parts[1]}.md"
    else:
        return f"report-{date_str}.md"


def main():
    """主函数"""
    parser = argparse.ArgumentParser(description="Git 工作报告生成器")
    parser.add_argument("date_range", help="时间范围（today/yesterday/week/month/last-week/last-month/YYYY-MM-DD~YYYY-MM-DD）")
    parser.add_argument("--prompt", "-p", default="", help="附加提示词")
    parser.add_argument("--config", "-c", default="config.json", help="配置文件路径")
    parser.add_argument("--output", "-o", help="输出文件路径（不指定则使用配置中的 output_dir）")

    args = parser.parse_args()

    try:
        # 获取脚本所在目录
        script_dir = Path(__file__).parent
        config_path = script_dir / args.config

        generator = GitReportGenerator(config_path)
        report = generator.generate_report(args.date_range, args.prompt)

        # 输出报告
        if args.output:
            # 使用指定的输出路径
            output_path = Path(args.output)
            # 确保目录存在
            output_path.parent.mkdir(parents=True, exist_ok=True)
        else:
            # 使用配置中的输出目录
            output_dir = generator._check_output_dir()
            filename = _generate_output_filename(args.date_range)
            output_path = output_dir / filename

        # 写入文件
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(report)
        print(f"报告已保存到：{output_path}")

    except (FileNotFoundError, ValueError) as e:
        print(f"错误：{e}")
        return 1
    except Exception as e:
        print(f"生成报告时发生错误：{e}")
        return 1

    return 0


if __name__ == "__main__":
    exit(main())
