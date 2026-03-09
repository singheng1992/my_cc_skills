# 工作报告

**时间范围**：{{date_range}}
**生成时间**：{{generated_at}}

## 概览

- **扫描项目数**：{{project_count}}
- **总提交数**：{{total_commits}}
- **涉及项目**：{{project_names}}

## 项目详情

{{#each projects}}
### {{name}}

**路径**：`{{path}}`
**提交数**：{{commit_count}}

#### 提交记录

{{#each commits}}
- **[{{hash}}]**({{url}}) {{message}}
  - 作者：{{author}}
  - 时间：{{date}}
{{/each}}

{{/each}}

## 总结

{{summary}}
