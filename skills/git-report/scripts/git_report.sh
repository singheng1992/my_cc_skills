#!/bin/bash
# =================================================================
# Git 工作报告生成脚本
# 创建时间：2025-03-09
# 说明：根据 Git 提交日志生成指定时间范围内的工作报告
# 作者：Claude (MiniMax-M2.5)
# =================================================================

set -e

# 脚本所在目录（用于定位模板）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "$0")"

# 默认配置
CONFIG_FILE="${SCRIPT_DIR}/.env"
TEMPLATE_FILE="${SCRIPT_DIR}/../assets/report-template.md"

# 默认参数
DATE_RANGE=""
PROMPT=""
USE_PYTHON=false

# =================================================================
# 函数定义
# =================================================================

# 打印错误信息并退出
error() {
    echo "错误: $1" >&2
    exit 1
}

# 打印使用帮助
usage() {
    echo "使用方法: $SCRIPT_NAME <时间范围> [选项]"
    echo ""
    echo "时间范围 (必填):"
    echo "  today          - 今天"
    echo "  yesterday      - 昨天"
    echo "  week           - 本周"
    echo "  last-week      - 上周"
    echo "  month          - 本月"
    echo "  last-month     - 上月"
    echo "  YYYY-MM-DD~YYYY-MM-DD  - 自定义日期范围"
    echo "  ~YYYY-MM-DD    - 从开始到指定日期"
    echo "  YYYY-MM-DD~    - 从指定日期到现在"
    echo ""
    echo "选项:"
    echo "  -p, --prompt TEXT  附加提示词"
    echo "  -c, --config FILE  配置文件路径 (默认: ${CONFIG_FILE})"
    echo "  -o, --output FILE  输出文件路径"
    echo "  -h, --help         显示帮助"
    echo ""
    exit 0
}

# 解析命令行参数
parse_args() {
    if [[ $# -eq 0 ]]; then
        usage
    fi

    DATE_RANGE="$1"
    shift

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--prompt)
                PROMPT="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            *)
                error "未知参数: $1"
                ;;
        esac
    done
}

# 加载配置文件
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        error "配置文件不存在: $CONFIG_FILE，请复制 .env.example 为 .env 并填写配置"
    fi

    # 读取配置文件
    source "$CONFIG_FILE"

    # 验证必填配置
    if [[ -z "$code_root_dir" ]]; then
        error "请在配置文件中设置 code_root_dir"
    fi

    if [[ -z "$report_output_dir" ]]; then
        error "请在配置文件中设置 report_output_dir"
    fi

    echo "配置文件加载成功"
}

# 检查目录和文件
check_environment() {
    # 检查代码根目录
    if [[ ! -d "$code_root_dir" ]]; then
        error "代码根目录不存在: $code_root_dir"
    fi
    echo "代码根目录存在: $code_root_dir"

    # 检查模板文件
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        error "报告模板文件不存在: $TEMPLATE_FILE"
    fi
    echo "报告模板文件存在: $TEMPLATE_FILE"

    # 检查输出目录
    if [[ ! -d "$report_output_dir" ]]; then
        echo "输出目录不存在，正在创建: $report_output_dir"
        mkdir -p "$report_output_dir" || error "无法创建输出目录: $report_output_dir"
    fi
    echo "输出目录存在: $report_output_dir"
}

# 解析日期范围
parse_date_range() {
    local range="$1"

    case "$range" in
        today)
            START_DATE=$(date +%Y-%m-%d)
            END_DATE=$(date +%Y-%m-%d)
            DATE_LABEL=$(date +%Y年%m月%d日)
            ;;
        yesterday)
            START_DATE=$(date -v-1d +%Y-%m-%d)
            END_DATE=$(date -v-1d +%Y-%m-%d)
            DATE_LABEL=$(date -v-1d +%Y年%m月%d日)
            ;;
        week)
            # 本周从周一开始
            START_DATE=$(date -v-mon +%Y-%m-%d)
            END_DATE=$(date +%Y-%m-%d)
            WEEK_NUM=$(date +%W)
            DATE_LABEL="$(date +%Y)年第${WEEK_NUM}周"
            ;;
        last-week)
            # 上周
            START_DATE=$(date -v-1w -v-mon +%Y-%m-%d)
            END_DATE=$(date -v-1w -v-sun +%Y-%m-%d)
            WEEK_NUM=$(date -v-1w +%W)
            DATE_LABEL="$(date -v-1w +%Y)年第${WEEK_NUM}周"
            ;;
        month)
            # 本月
            START_DATE=$(date +%Y-%m-01)
            END_DATE=$(date +%Y-%m-%d)
            DATE_LABEL=$(date +%Y年%m月)
            ;;
        last-month)
            # 上月
            START_DATE=$(date -v-1m +%Y-%m-01)
            END_DATE=$(date -v-1m -v+1m -v-1d +%Y-%m-%d)
            DATE_LABEL=$(date -v-1m +%Y年%m月)
            ;;
        ~*)
            # ~YYYY-MM-DD 格式
            END_DATE="${range#*~}"
            START_DATE="1970-01-01"
            DATE_LABEL="开始到 ${END_DATE}"
            ;;
        *~)
            # YYYY-MM-DD~ 格式
            START_DATE="${range%~}"
            END_DATE=$(date +%Y-%m-%d)
            DATE_LABEL="${START_DATE}到现在"
            ;;
        *~*)
            # YYYY-MM-DD~YYYY-MM-DD 格式
            START_DATE="${range%%~*}"
            END_DATE="${range#*~}"
            DATE_LABEL="${START_DATE}至${END_DATE}"
            ;;
        *)
            error "无效的日期范围: $range"
            ;;
    esac

    echo "日期范围: $START_DATE ~ $END_DATE ($DATE_LABEL)"
}

# 扫描代码根目录下的所有 Git 项目
scan_git_projects() {
    local root_dir="$1"
    local temp_projects=()

    while IFS= read -r -d '' git_dir; do
        # 获取项目目录（去掉 .git 后缀）
        local project_path="${git_dir%.git}"
        # 获取项目相对路径
        local rel_path="${project_path#$root_dir/}"
        # 获取项目名称
        local project_name=$(basename "$project_path")
        temp_projects+=("$project_name|$rel_path|$project_path")
    done < <(find "$root_dir" -name ".git" -type d -print0 2>/dev/null)

    # 返回项目数组
    PROJECTS=("${temp_projects[@]}")
    echo "扫描到 ${#PROJECTS[@]} 个 Git 项目"
}

# 收集指定项目的 Git 提交日志
collect_git_logs() {
    local project_path="$1"
    local start_date="$2"
    local end_date="$3"

    # 使用 git log 获取提交记录
    # 格式: hash|author|date|message
    git -C "$project_path" log \
        --after="$start_date 00:00:00" \
        --until="$end_date 23:59:59" \
        --pretty=format:"%H|%an|%ad|%s" \
        --date=iso \
        2>/dev/null || echo ""
}

# 生成报告内容
generate_report() {
    local date_range="$1"
    local prompt="$2"

    local temp_file=$(mktemp)
    local project_count=0
    local total_commits=0
    local project_details=""

    # 遍历所有项目
    for proj in "${PROJECTS[@]}"; do
        local project_name="${proj%%|*}"
        local rel_path="${proj%|*}"
        rel_path="${rel_path#*|}"
        local project_path="${proj##*|}"

        # 收集日志
        local logs=$(collect_git_logs "$project_path" "$START_DATE" "$END_DATE")

        if [[ -n "$logs" ]]; then
            project_count=$((project_count + 1))

            # 统计提交数
            local commit_count=$(echo "$logs" | grep -c "^" || echo 0)
            total_commits=$((total_commits + commit_count))

            # 生成项目提交记录
            local commit_list=""
            while IFS='|' read -r hash author date message; do
                commit_list+="- **[\`${hash:0:7}\`]** ${message}
  - 作者：${author}
  - 时间：${date}
"
            done <<< "$logs"

            # 添加项目详情
            project_details+="### ${project_name}

**路径**: \`${rel_path}\`
**提交数**: ${commit_count}

#### 提交记录

${commit_list}
"
        fi
    done

    # 准备输出文件名
    if [[ -z "$OUTPUT_FILE" ]]; then
        local filename
        case "$DATE_RANGE" in
            today|yesterday)
                filename="daily-${END_DATE}.md"
                ;;
            week|last-week)
                filename="week-${START_DATE}_to_${END_DATE}.md"
                ;;
            month|last-month)
                filename="month-${START_DATE}.md"
                ;;
            *)
                filename="custom-${START_DATE}_to_${END_DATE}.md"
                ;;
        esac
        OUTPUT_FILE="${report_output_dir}/${filename}"
    fi

    # 生成时间
    local generated_at=$(date "+%Y-%m-%d %H:%M:%S")

    # 生成项目名称列表
    local project_names=$(echo "${PROJECTS[@]}" | tr ' ' ',' | sed 's/|/,/g' | sed 's/,$//')

    # 生成报告内容
    cat > "$temp_file" << EOF
# 工作报告
- **时间范围**：${DATE_LABEL}
- **生成时间**：${generated_at}

## 概览

- **扫描项目数**：${#PROJECTS[@]}
- **有提交的项目数**：${project_count}
- **总提交数**：${total_commits}

## 项目详情

${project_details}

## 总结

${prompt:-根据上述提交记录，本周期内主要完成了项目开发工作。}
EOF

    # 复制到输出文件
    cp "$temp_file" "$OUTPUT_FILE"
    rm -f "$temp_file"

    echo ""
    echo "========================================"
    echo "报告生成成功！"
    echo "========================================"
    echo "输出文件: $OUTPUT_FILE"
    echo "扫描项目: ${#PROJECTS[@]} 个"
    echo "有提交的项目: ${project_count} 个"
    echo "总提交数: ${total_commits} 条"
    echo "========================================"
}

# 主函数
main() {
    echo "========================================"
    echo "Git 工作报告生成器"
    echo "========================================"
    echo ""

    # 解析参数
    parse_args "$@"

    # 加载配置
    echo ">> 1. 加载配置文件..."
    load_config

    # 检查环境
    echo ""
    echo ">> 2. 检查环境..."
    check_environment

    # 解析日期范围
    echo ""
    echo ">> 3. 解析日期范围..."
    parse_date_range "$DATE_RANGE"

    # 扫描项目
    echo ""
    echo ">> 4. 扫描 Git 项目..."
    scan_git_projects "$code_root_dir"

    # 生成报告
    echo ""
    echo ">> 5. 生成报告..."
    generate_report "$DATE_RANGE" "$PROMPT"
}

# 执行主函数
main "$@"
