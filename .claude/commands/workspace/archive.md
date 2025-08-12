# Archive Completed Tasks Command for Claude Code

This command archives completed tasks from the workspace-activity.json file to reduce its size and maintain focus on active work, while preserving historical records for reporting and analysis.

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
   - **Conflict Check**: Ensure no conflicts with ongoing archive operations

4. **Create Archive Task**: 
   - **Action**: Generate new task entry with type "task-archive"
   - **Format**: Follow task structure defined in bootstrap.md
   - **Validation**: Ensure all required fields are populated

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-task-archive",
  "type": "task-archive",
  "project": "workspace",
  "title": "Archive completed tasks to reduce activity log size",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-24T10:00:00Z",
  "last_activity": "2025-07-24T14:30:00Z",
  "context": {
    "operation": "archive_completed_tasks"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "activity-log-analysis",
    "remaining_steps": ["activity-log-analysis", "completed-task-identification", "archive-file-creation", "task-migration", "activity-log-update", "verification"]
  }
}
```

## Core Workflow Steps

### Step 1: Analyze Current Activity Log

**Log Progress**: Update task progress to "activity-log-analysis"

Read and analyze the current workspace-activity.json file:
1. Load the complete activity log structure
2. Count total tasks by status (completed, in-progress, paused, failed)
3. Calculate file size and identify completed tasks for archiving
4. Determine archive file naming convention based on date range

**Activity Logging**: Record analysis results and archiving plan

### Step 2: Identify Completed Tasks

**Log Progress**: Update task progress to "completed-task-identification"

Extract completed tasks from the active_tasks array:
1. **Filter Completed Tasks**: Identify all tasks with `status: "completed"`
2. **Validate Task Structure**: Ensure each completed task has required fields
3. **Sort by Completion Date**: Order tasks chronologically for organized archiving
4. **Calculate Archive Statistics**: Count tasks and estimate storage savings

**Activity Logging**: Record completed task identification and statistics

### Step 3: Create Archive File

**Log Progress**: Update task progress to "archive-file-creation"

Create or update the archive file with proper structure:
1. **Determine Archive File Path**: Use format `workspace-activity-archive-{YYYY-MM}.json`
2. **Check Existing Archive**: If archive file exists, load current structure
3. **Create Archive Structure**: Initialize proper JSON structure for archived tasks
4. **Set Archive Metadata**: Include creation date, archive period, and task count

Archive file structure:
```json
{
  "archive": {
    "created": "2025-07-24T14:30:00Z",
    "period": "2025-07",
    "total_archived_tasks": 0,
    "archived_by": "claude-agent-{timestamp}"
  },
  "archived_tasks": []
}
```

**Activity Logging**: Record archive file creation and metadata setup

### Step 4: Migrate Tasks to Archive

**Log Progress**: Update task progress to "task-migration"

Move completed tasks from active log to archive:
1. **Copy Tasks to Archive**: Add completed tasks to archive file's `archived_tasks` array
2. **Preserve Task Data**: Ensure complete task structure is maintained
3. **Update Archive Metadata**: Update task count and date range in archive metadata
4. **Validate Archive Structure**: Ensure archive file remains valid JSON

**Activity Logging**: Record task migration progress and any issues encountered

### Step 5: Update Active Activity Log

**Log Progress**: Update task progress to "activity-log-update"

Clean up the active workspace-activity.json file:
1. **Remove Archived Tasks**: Remove completed tasks from `active_tasks` array
2. **Update Workspace Metadata**: Refresh task counts and statistics
3. **Preserve Active Tasks**: Ensure in-progress, paused, and failed tasks remain
4. **Update Last Modified**: Set current timestamp for workspace activity

Updated active log should contain:
- All non-completed tasks (in-progress, paused, failed, blocked)
- Current workspace metadata
- Updated statistics reflecting reduced task count

**Activity Logging**: Record activity log cleanup and updated statistics

### Step 6: Verification and Validation

**Log Progress**: Update task progress to "verification"

Verify the archiving operation completed successfully:
1. **Validate Archive File**: Ensure archive file is valid JSON with all migrated tasks
2. **Validate Active Log**: Ensure active log still contains all non-completed tasks
3. **Check File Sizes**: Compare before/after file sizes to confirm reduction
4. **Verify Task Count**: Ensure total tasks (active + archived) matches original count
5. **Test File Access**: Confirm both files are readable and properly formatted

**Activity Logging**: Record verification results and file size improvements

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 7: Complete Archive Task and Update Metrics

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive archiving summary and statistics
3. **Update Workspace Metrics**: Refresh counters and file size statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Archive Index**: Maintain list of archive files if applicable

### Step 8: Generate Archive Summary

1. **Create Archive Report**: Generate summary of archiving operation
2. **Log Task Completion**: Record final activity entry with outcomes
3. **Display Results**: Show user summary of archived tasks and file size reduction

Archive summary format:
```
📦 TASK ARCHIVING COMPLETED
============================
Archive File: workspace-activity-archive-2025-07.json
Tasks Archived: {count} completed tasks
Date Range: {start_date} to {end_date}
File Size Reduction: {original_size} → {new_size} ({percentage}% reduction)
Active Tasks Remaining: {active_count}

Archive Contents:
- Code Reviews: {review_count}
- Project Setups: {setup_count}
- Workspace Operations: {workspace_count}
- Other Tasks: {other_count}
```

## Usage Examples

**Archive All Completed Tasks:**
"Archive completed tasks to reduce the workspace activity log size"

**Monthly Archive:**
"Create monthly archive of completed tasks from July"

**Archive with Status:**
"Archive completed tasks and show me the file size reduction"

## Archive File Management

### Archive File Naming Convention
- **Monthly Archives**: `workspace-activity-archive-{YYYY-MM}.json`
- **Quarterly Archives**: `workspace-activity-archive-{YYYY}-Q{N}.json`
- **Annual Archives**: `workspace-activity-archive-{YYYY}.json`

### Archive Directory Structure
```
workspace-root/
├── workspace-activity.json          # Active tasks only
├── archives/                        # Archive directory
│   ├── workspace-activity-archive-2025-07.json
│   ├── workspace-activity-archive-2025-08.json
│   └── archive-index.json          # Index of all archives
```

### Archive Retention Policy
- **Recent Archives** (last 3 months): Keep full detail
- **Historical Archives** (3-12 months): Maintain summary data
- **Long-term Archives** (>1 year): Consider compression or summary-only

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark archive task as "failed" with error context
- **Preserve Data Integrity**: Ensure no data loss during archiving process
- **Provide Recovery**: Offer steps to restore from backup if needed

### Common Issues and Resolutions

**Corrupted Activity Log:**
- Create backup before archiving
- Validate JSON structure before processing
- Provide recovery options for corrupted files

**Archive File Conflicts:**
- Check for existing archives with same naming
- Merge or append to existing archives as appropriate
- Handle concurrent archive operations

**Insufficient Disk Space:**
- Check available space before creating archives
- Provide cleanup recommendations
- Implement compression options

## Expected Outcomes

After completing this workflow:

1. **Reduced Active Log Size**: workspace-activity.json contains only active tasks
2. **Preserved Historical Data**: All completed tasks safely archived
3. **Improved Performance**: Faster loading and processing of active tasks
4. **Organized Archives**: Structured archive files for historical reference
5. **Complete Audit Trail**: Full audit log of archiving operation
6. **Task Coordination**: Other agents aware of archiving status
7. **File Size Optimization**: Significant reduction in active log file size

## Integration with Other Commands

This archive command integrates with:
- **Status Command**: Shows active tasks without completed clutter
- **Query Command**: Can search both active and archived tasks
- **Reporting**: Uses archived data for historical analysis
- **Activity Logging**: Core integration with all workspace operations

## Usage with Claude Code

To execute this workflow:

> "Archive completed tasks to keep the activity log focused"

> "Create an archive of finished work to reduce file size"

> "/archive" (if configured as slash command)

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the archiving process.

## Recovery and Restoration

### Archive Recovery
If archives need to be restored to active log:
1. Load specific archive file
2. Filter tasks by criteria (date, type, project)
3. Move selected tasks back to active_tasks array
4. Update metadata and timestamps

### Backup Strategy
- **Pre-Archive Backup**: Create backup of workspace-activity.json before archiving
- **Archive Validation**: Verify archive integrity before removing from active log
- **Rollback Capability**: Maintain ability to restore archived tasks if needed