# Claude Code JIRA Team Report Workflow

This workflow generates comprehensive team status reports from JIRA, providing insights into recent activity, blockers, and team velocity over the last 7 days.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
- JIRA CLI tool is installed and configured with authentication
- Git is installed and configured with access to target repositories
- Target project must be accessible through workspace configuration

## MANDATORY FIRST STEPS: Activity Log Integration

### Step 0A: Bootstrap Initialization

**CRITICAL: These files MUST exist and be readable. If any file cannot be read, STOP and inform the user.**

1. **Read Bootstrap Instructions**:
    - **File Path**: `.claude/bootstrap.md` (relative to current working directory)
    - **Action**: Use Read tool to load this file
    - **Error Handling**: If file doesn't exist or cannot be read, STOP execution and display: "ERROR: Cannot read .claude/bootstrap.md - Bootstrap file is missing or inaccessible. Please ensure this file exists in the workspace."

2. **Load Global Configuration**:
    - **File Path**: `.claude/config.md` (relative to current working directory)
    - **Action**: Use Read tool to load this file
    - **Error Handling**: If file doesn't exist or cannot be read, STOP execution and display: "ERROR: Cannot read .claude/config.md - Global configuration file is missing or inaccessible. Please ensure this file exists in the workspace."

3. **Validate Workspace Structure**:
    - **File Path**: `workspace-activity.json` (relative to current working directory)
    - **Action**: Use Read tool to check if file exists and is valid JSON
    - **Error Handling**: If file doesn't exist, create it with empty structure. If file exists but is invalid JSON, STOP execution and display: "ERROR: workspace-activity.json exists but contains invalid JSON. Please fix or delete this file."

### Step 0B: Activity Log Initialization

**MANDATORY: Follow the exact activity logging protocol defined in the bootstrap and config files.**

1. **Initialize Activity Log**:
    - **Action**: Read `workspace-activity.json` (already validated in Step 0A)
    - **Purpose**: Load current workspace state and existing tasks
    - **Error Handling**: If JSON parsing fails after validation, STOP execution and display: "ERROR: workspace-activity.json format is corrupted. Please restore from backup or recreate."

2. **Register Agent Session**:
    - **Action**: Create unique agent ID using format: `claude-agent-{timestamp}`
    - **Purpose**: Identify this specific Claude Code session for coordination
    - **Record**: Log agent registration in workspace activity

3. **Check Active Tasks**:
    - **Action**: Review `active_tasks` array in workspace-activity.json
    - **Purpose**: Identify conflicts with other active agents and resumable tasks
    - **Conflict Check**: Ensure no conflicts with ongoing report generation operations

4. **Create Team Report Task**:
    - **Action**: Generate new task entry with type "team-reporting"
    - **Format**: Follow task structure defined in bootstrap.md
    - **Validation**: Ensure all required fields are populated

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-team-reporting",
  "type": "team-reporting",
  "project": "{project-alias}",
  "title": "Generate JIRA Team Report for {project-alias} - Last 7 Days",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-31T10:00:00Z",
  "last_activity": "2025-07-31T10:00:00Z",
  "context": {
    "report_period": "7_days",
    "jira_project": "{jira-project}",
    "project_alias": "{project-alias}",
    "report_type": "team_status"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "project-setup",
    "remaining_steps": ["project-setup", "data-collection", "metrics-analysis", "report-generation", "report-delivery"]
  }
}
```

```claude-code
# Autonomous JIRA team reporting and status analysis
# Usage: claude-code jira-team-report [PROJECT-ALIAS] [DAYS=7]

# Context: @.claude/context/jira-cli-usage.md
# Generate comprehensive team status report: $ARGUMENTS

## Workflow Overview:
This command autonomously generates comprehensive team status reports from JIRA, analyzing activity, velocity, blockers, and progress over the specified time period.
```

---

## Core Workflow Steps

### Step 1: Read Workspace Configuration and Validate Project

**Log Progress**: Update task progress to "project-setup"

1. Read the `workspace-config.json` file and validate project exists
2. Extract project's JIRA project key, repository info, and team configuration
3. Navigate to project directory using the `local_path` from workspace configuration
4. **Load Project Context**: Read the project's `claude.md` file for team-specific configurations

**Activity Logging**: Record project validation results and configuration loading

### Step 2: Report Setup & Date Calculations

**Log Progress**: Update task progress to "data-collection"

**Goal**: Establish reporting workspace and calculate date ranges

1. **Create timestamped report workspace**:
   ```bash
   mkdir -p "reports/$(date +%Y-%m-%d-%H%M)-team-report-${PROJECT_KEY}"
   cd "reports/$(date +%Y-%m-%d-%H%M)-team-report-${PROJECT_KEY}"
   ```

2. **Calculate date ranges**:
   ```bash
   # Current date and 7 days ago
   END_DATE=$(date +%Y-%m-%d)
   START_DATE=$(date -d "7 days ago" +%Y-%m-%d)
   
   # Save to metadata
   echo "{\"report_period\": {\"start\": \"$START_DATE\", \"end\": \"$END_DATE\", \"days\": 7}}" > report-metadata.json
   ```

3. **Initialize tracking**:
    - Create `report-progress.json` with data collection status
    - Set phase: "data-collection"

**Activity Logging**: Record report setup and date range calculations

---

### Step 3: Comprehensive Data Collection

**Goal**: Gather all relevant JIRA data for the reporting period

4. **Fetch new issues (last 7 days)**:
   ```bash
   # New issues created in the last 7 days
   jira issue list --project $PROJECT_KEY --created ">=-7d" --plain > new-issues-7d.txt
   jira issue list --project $PROJECT_KEY --created ">=-7d" --json > new-issues-7d.json
   ```

5. **Fetch recently updated issues**:
   ```bash
   # All issues updated in the last 7 days (for status changes)
   jira issue list --project $PROJECT_KEY --updated ">=-7d" --plain > updated-issues-7d.txt
   jira issue list --project $PROJECT_KEY --updated ">=-7d" --json > updated-issues-7d.json
   ```

6. **Fetch current status snapshots**:
   ```bash
   # Issues currently in specific statuses
   jira issue list --project $PROJECT_KEY --status "In Progress" --plain > current-in-progress.txt
   jira issue list --project $PROJECT_KEY --status "Code Review" --plain > current-code-review.txt
   jira issue list --project $PROJECT_KEY --status "Blocked" --plain > current-blocked.txt
   
   # JSON versions for detailed analysis
   jira issue list --project $PROJECT_KEY --status "In Progress" --json > current-in-progress.json
   jira issue list --project $PROJECT_KEY --status "Code Review" --json > current-code-review.json
   jira issue list --project $PROJECT_KEY --status "Blocked" --json > current-blocked.json
   ```

7. **Fetch closed/completed issues**:
   ```bash
   # Issues resolved/closed in the last 7 days
   jira issue list --project $PROJECT_KEY --resolved ">=-7d" --plain > closed-issues-7d.txt
   jira issue list --project $PROJECT_KEY --resolved ">=-7d" --json > closed-issues-7d.json
   ```

8. **Fetch high priority and blocker issues**:
   ```bash
   # Critical and blocker priority issues
   jira issue list --project $PROJECT_KEY --priority "Critical,Blocker" --plain > critical-blockers.txt
   jira issue list --project $PROJECT_KEY --priority "Critical,Blocker" --json > critical-blockers.json
   ```

**Activity Logging**: Record data collection results and file generation status

---

### Step 4: Data Analysis and Metrics Calculation

**Log Progress**: Update task progress to "metrics-analysis"

**Goal**: Process raw JIRA data into meaningful insights

9. **Analyze new issues**:
    - Parse JSON data to extract: issue keys, titles, story points, assignees, labels
    - Calculate: total new issues, total story points added, issue type breakdown
    - Identify: new high-priority items, unassigned issues
    - Save analysis to: `analysis-new-issues.md`

10. **Analyze story points and velocity**:
    - Extract story points from all relevant issues
    - Calculate: points added (new), points completed (closed), points in progress
    - Track: team velocity trends, capacity analysis
    - Save analysis to: `analysis-story-points.md`

11. **Analyze status changes and workflow**:
    - Process updated issues to identify status transitions
    - Track: items moved to "In Progress", items moved to "Code Review", items completed
    - Identify: workflow bottlenecks, longest items in each status
    - Save analysis to: `analysis-workflow.md`

12. **Analyze blockers and critical items**:
    - Process high-priority issues for impact assessment
    - Identify: new blockers since last week, resolved blockers, aging critical items
    - Track: blocker resolution time, critical item aging
    - Save analysis to: `analysis-blockers-critical.md`

**Activity Logging**: Record analysis completion and insights generated

---

### Step 5: Team Performance Insights

**Goal**: Generate team-focused metrics and insights

13. **Assignee and workload analysis**:
    - Group issues by assignee across all categories
    - Calculate: individual velocity, current workload, completion rates
    - Identify: team members with heavy loads, unassigned work
    - Save analysis to: `analysis-team-workload.md`

14. **Sprint/milestone progress**:
    - Identify active sprints or milestones
    - Calculate: sprint burndown, milestone progress, risk assessment
    - Track: scope changes, commitment vs. delivery
    - Save analysis to: `analysis-sprint-progress.md`

15. **Quality and efficiency metrics**:
    - Analyze: time in code review, rework rates, defect rates
    - Track: cycle time trends, throughput metrics
    - Identify: process improvement opportunities
    - Save analysis to: `analysis-quality-efficiency.md`

**Activity Logging**: Record team performance analysis results

---

### Step 6: Report Generation

**Log Progress**: Update task progress to "report-generation"

**Goal**: Create comprehensive, actionable team status report

16. **Generate executive summary**:
    - Create high-level overview with key metrics and trends
    - Include: velocity summary, critical issues, team capacity status
    - Highlight: achievements, concerns, recommendations
    - Format: Executive-friendly with clear action items
    - Save to: `00-executive-summary.md`

17. **Generate detailed team report**:
    - Combine all analyses into comprehensive team status document
    - Include: detailed breakdowns, trend analysis, individual contributions
    - Add: charts and visualizations using text-based formats
    - Format: Technical team-friendly with actionable insights
    - Save to: `01-detailed-team-report.md`

18. **Generate action items and recommendations**:
    - Extract actionable items from analysis
    - Prioritize: blockers to address, process improvements, capacity adjustments
    - Include: specific next steps and ownership assignments
    - Save to: `02-action-items.md`

**Activity Logging**: Record report generation completion and artifact creation

---

### Step 7: Report Formatting and Delivery

**Goal**: Format reports for easy consumption and sharing

19. **Create visual summaries**:
    - Generate ASCII charts for key metrics using simple text formatting
    - Create: velocity trends, status distribution, team workload charts
    - Include: progress bars for sprint/milestone completion
    - Save to: `03-visual-summaries.md`

20. **Generate one-page dashboard**:
    - Create condensed view with most critical information
    - Include: key metrics, top blockers, immediate action items
    - Format: Single page for quick team standup reference
    - Save to: `04-team-dashboard.md`

21. **Create shareable formats**:
    - Generate email-friendly summary for stakeholder updates
    - Create Slack/Teams-ready status update format
    - Include: attachment-ready comprehensive report
    - Save to: `05-shareable-formats.md`

**Activity Logging**: Record report formatting and delivery preparation

---

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 8: Complete Task and Update Metrics

**Log Progress**: Update task progress to "report-delivery"

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Report Metrics**: Log report generation statistics and insights summary
3. **Update Workspace Metrics**: Refresh team reporting counters and history
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Project Metadata**: Set `last_report_generated` timestamp in project config

### Step 9: Generate Artifacts and Notifications

1. **Save Master Report**: Create `team-report-{timestamp}.md` in reports directory
2. **Update Report History**: Maintain rolling history of team reports for trend analysis
3. **Generate Notification**: Create summary for team communication channels
4. **Log Final Activity**: Record completion with key metrics and next report due date

---

## Report Structure Template

### Executive Summary Format:
```markdown
# Team Status Report - Week of {START_DATE} to {END_DATE}

## 🎯 Key Metrics
- **New Issues**: {count} ({story_points} points)
- **Completed**: {count} ({story_points} points)
- **Team Velocity**: {current_velocity} (vs {previous_velocity} last week)
- **Active Blockers**: {blocker_count}

## 🚨 Immediate Attention Required
- {critical_item_1}
- {critical_item_2}

## 📈 Team Performance
- **In Progress**: {in_progress_count} items
- **Code Review**: {code_review_count} items
- **Capacity Utilization**: {utilization_percentage}%

## 🎉 Achievements
- {achievement_1}
- {achievement_2}

## 🔧 Recommended Actions
1. {action_item_1}
2. {action_item_2}
```

### Detailed Report Sections:
1. **New Work Added** (Issues created in last 7 days)
2. **Work Completed** (Issues resolved in last 7 days)
3. **Current Sprint/Milestone Status**
4. **Blockers and Critical Items**
5. **Team Workload Distribution**
6. **Code Review Queue Status**
7. **Quality and Process Metrics**
8. **Trend Analysis and Recommendations**

## Smart Analysis Features

- **Automatic Trend Detection**: Compare current week to previous periods
- **Anomaly Identification**: Flag unusual patterns in team performance
- **Capacity Planning**: Analyze team load and suggest optimizations
- **Risk Assessment**: Identify potential delivery risks early
- **Process Insights**: Highlight workflow bottlenecks and improvements

## Usage Examples

**Basic Team Report:**
```bash
claude-code jira-team-report cs
```

**Custom Time Period:**
```bash
claude-code jira-team-report web-app 14
```

**Specific Project Report:**
```bash
claude-code jira-team-report api-service
```

## Expected Outcomes

After completing this workflow:

1. **Executive Summary**: High-level team status for leadership
2. **Detailed Team Report**: Comprehensive analysis for team members
3. **Action Items**: Prioritized list of immediate actions needed
4. **Visual Dashboard**: Quick-reference team status summary
5. **Shareable Formats**: Ready-to-send updates for stakeholders
6. **Activity Trail**: Complete audit log of report generation process
7. **Trend Analysis**: Week-over-week performance insights
8. **Recommendations**: Data-driven suggestions for team improvement

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log with specific JIRA query that failed
- **Continue Analysis**: Complete remaining data collection where possible
- **Partial Reports**: Generate reports with available data, noting missing sections
- **Retry Mechanisms**: Attempt failed JIRA queries with different parameters
- **Fallback Options**: Use cached data or previous reports to fill gaps

## Team Integration Features

This workflow provides:
- **Automated Scheduling**: Can be run on regular intervals
- **Historical Tracking**: Maintains trend data across multiple reports
- **Customizable Metrics**: Adapts to team-specific KPIs and priorities
- **Multi-Project Support**: Can generate consolidated reports across projects
- **Integration Ready**: Outputs compatible with team communication tools

## Usage with Claude Code

To execute this workflow:

> "Generate team report for the cs project"

> "Create JIRA status report for web-app project covering last 14 days"

> "Run weekly team report for all active projects"

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the report generation process, including metrics on report usage and team insights over time.