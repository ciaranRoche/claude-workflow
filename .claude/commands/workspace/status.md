# Workspace Status Command for Claude Code

This command provides an interactive overview of workspace activity, displaying completed tasks and allowing users to select and continue incomplete tasks, with mandatory activity logging integration.

## Prerequisites

- Ensure `workspace-activity.json` exists in the workspace root
- Workspace is properly initialized with activity logging
- User has permissions to read and modify workspace files

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
   - **Conflict Check**: Ensure no conflicts with ongoing status operations

4. **Create Status Check Task**: 
   - **Action**: Generate new task entry with type "workspace-status"
   - **Format**: Follow task structure defined in bootstrap.md
   - **Validation**: Ensure all required fields are populated

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-workspace-status",
  "type": "workspace-status",
  "project": "workspace",
  "title": "Review workspace activity status and manage tasks",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-24T10:00:00Z",
  "last_activity": "2025-07-24T14:30:00Z",
  "context": {
    "operation": "status_review_and_task_management"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "activity-log-read",
    "remaining_steps": ["activity-log-read", "status-analysis", "task-display", "user-interaction", "task-continuation"]
  }
}
```

## Core Workflow Steps

### Step 1: Read and Parse Activity Log

**Log Progress**: Update task progress to "activity-log-read"

Read the `workspace-activity.json` file and parse the current workspace state:
1. Load the complete activity log
2. Extract active tasks, completed tasks, and metrics
3. Validate the structure and identify any inconsistencies
4. Parse task statuses and progress information

**Activity Logging**: Record activity log parsing results and any issues found

### Step 2: Analyze Workspace Status

**Log Progress**: Update task progress to "status-analysis"

Analyze the workspace activity data:
1. **Categorize Tasks by Status**:
   - Completed tasks (status: "completed")
   - Active/In-Progress tasks (status: "in-progress")
   - Paused tasks (status: "paused")
   - Failed tasks (status: "failed")
   - Blocked tasks (status: "blocked")

2. **Identify Task Priorities**:
   - High priority incomplete tasks
   - Tasks that have been stalled for extended periods
   - Tasks with dependencies or conflicts

3. **Calculate Summary Metrics**:
   - Total tasks by type and status
   - Agent activity patterns
   - Task completion rates
   - Time since last activity per task

**Activity Logging**: Record analysis results and task categorization

### Step 3: Display Workspace Status

**Log Progress**: Update task progress to "task-display"

Present a comprehensive status overview:

#### 3A: Workspace Overview
Display high-level metrics:
```
📊 WORKSPACE ACTIVITY STATUS
================================
Total Tasks: {total_tasks}
✅ Completed: {completed_count} ({completed_percentage}%)
🔄 In Progress: {in_progress_count}
⏸️  Paused: {paused_count}
❌ Failed: {failed_count}
🚫 Blocked: {blocked_count}

Active Agents: {active_agents}
Last Updated: {last_updated}
```

#### 3B: Completed Tasks Summary
Show completed tasks with brief details:
```
✅ COMPLETED TASKS
===================
1. [project-setup] Prime workspace with updated project configuration
   └─ Completed: 2025-07-23T13:40:00Z (4 projects configured)

2. [workspace-pull] Pull latest changes from origin main
   └─ Completed: 2025-07-24T14:35:00Z (fast-forward merge, 5 files changed)
```

#### 3C: Incomplete Tasks Details
Display detailed information for incomplete tasks:
```
🔄 INCOMPLETE TASKS
====================
1. [code-review] Review gfreeman/OCM-0003 - black mesa project
   Status: in-progress | Priority: high | Agent: claude-agent-1753280088
   Started: 2025-07-23T15:48:08Z (23 hours ago)
   Progress: bootstrap-initialization → activity-log-initialization
   Remaining: project-validation, directory-navigation, branch-update, fork-configuration, 
             branch-checkout, commit-analysis, code-review, integration-analysis, summary-generation
   
   Description: Comprehensive code review of gfreeman/OCM-0003 branch on black mesa project
   Context: Fork owner: gfreeman, Branch: OCM-0003, Project: black mesa project
```

**Activity Logging**: Record status display generation and task presentation

### Step 4: Interactive Task Selection

**Log Progress**: Update task progress to "user-interaction"

Present interactive options to the user:

#### 4A: Task Selection Menu
```
🎯 TASK MANAGEMENT OPTIONS
===========================
Select a task to continue or manage:

[1] Continue: Review gfreeman/OCM-0003 - black mesa project
    └─ Resume code review from activity-log-initialization step

[2] Mark Complete : Review gfreeman/OCM-0003 - black mesa project
    
[3] View Details: Show complete task context and progress history

[4] Modify Task: Update task priority, status, or assignment

[5] Create New Task: Start a new workspace operation

[6] Archive Completed: Move completed tasks to archive

[7] Generate Report: Create detailed workspace activity report

[0] Exit: Return to normal operation

Enter your choice (0-6): 
```

#### 4B: Task Selection Processing
Based on user selection:
- **Continue Task**: Load task context and resume from last checkpoint
- **View Details**: Display comprehensive task information and history
- **Modify Task**: Allow status, priority, or assignment changes
- **Create New Task**: Guide through new task creation
- **Archive Completed**: Move completed tasks to completed_tasks array
- **Generate Report**: Create detailed activity report

**Activity Logging**: Record user selections and task management actions

### Step 5: Task Continuation or Management

**Log Progress**: Update task progress to "task-continuation"

Execute the selected action:

#### 5A: Resume Selected Task
If user chooses to continue a task:
1. **Load Task Context**: Retrieve complete task state and progress
2. **Validate Resumption**: Ensure task can be safely resumed
3. **Update Task Assignment**: Assign to current agent if needed
4. **Resume Execution**: Continue from the last completed step
5. **Coordinate Handoff**: Ensure clean transition from previous agent

#### 5B: Task Management Actions
For other selections:
- **Archive Tasks**: Move completed tasks to archive section
- **Update Task Status**: Modify task properties as requested
- **Generate Reports**: Create requested documentation
- **Create New Tasks**: Guide through task creation workflow

**Activity Logging**: Record task continuation or management actions taken

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 6: Complete Status Command and Update Metrics

1. **Mark Status Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive status review summary
3. **Update Workspace Metrics**: Refresh counters and statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Last Activity**: Set current timestamp for workspace activity

### Step 7: Generate Status Summary

1. **Create Status Report**: Generate brief summary of workspace status
2. **Log Command Completion**: Record final activity entry with outcomes
3. **Display Results**: Show user summary of status review and actions taken

## Task Resumption Protocol

When a user selects to continue a task, follow this protocol:

### Resumption Steps:
1. **Validate Task State**: Ensure task is in a resumable state
2. **Load Task Context**: Retrieve all task-specific information
3. **Check Dependencies**: Verify any dependencies are met
4. **Update Assignment**: Assign task to current agent
5. **Resume from Checkpoint**: Continue from the last completed step
6. **Coordinate Transition**: Handle any necessary state transitions

### Context Transfer:
- Load all task-specific context data
- Restore any temporary files or state
- Verify project directories and file access
- Ensure proper tool configurations

## Usage Examples

**Basic Status Check:**
"Show me the workspace activity status"

**Interactive Task Management:**
"Review workspace status and let me select tasks to continue"

**Status with Task Selection:**
"Display workspace status and help me resume incomplete tasks"

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark status task as "failed" with error context
- **Provide Guidance**: Offer specific steps to resolve issues
- **Maintain State**: Ensure workspace remains in consistent state

### Common Issues and Resolutions

**Corrupted Activity Log:**
- Attempt to repair and validate structure
- Create backup of current state
- Guide user through manual recovery

**Task State Conflicts:**
- Identify conflicting agents or tasks
- Provide conflict resolution options
- Ensure clean task ownership

**Missing Task Context:**
- Identify missing information
- Guide user through context reconstruction
- Provide fallback options for task continuation

## Expected Outcomes

After completing this workflow:

1. **Clear Status Overview**: Complete understanding of workspace activity
2. **Task Management**: Ability to resume, modify, or manage existing tasks
3. **Complete Activity Trail**: Full audit log of status review and actions
4. **Task Coordination**: Clean handoffs and agent coordination
5. **Workspace Optimization**: Improved task management and productivity

## Integration with Other Commands

This status command integrates with:
- **Project Prime**: Shows project setup status and results
- **Workspace Pull**: Displays pull operation history and results
- **Code Review**: Enables resumption of code review tasks
- **Activity Logging**: Core integration with all workspace operations

## Usage with Claude Code

To execute this workflow:

> "Show workspace status and let me manage tasks"

> "Review activity log and help me continue incomplete work"

> "/status" (if configured as slash command)

Claude Code will automatically integrate with the activity logging system and provide complete workspace status management.