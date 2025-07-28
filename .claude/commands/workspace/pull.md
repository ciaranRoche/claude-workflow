# Workspace Pull Workflow for Claude Code

This workflow guides Claude Code through pulling the latest changes from origin main to ensure the workspace is up to date with the remote repository, with mandatory activity logging integration.

## Prerequisites

- Ensure workspace is a valid git repository
- Git is installed and configured
- Remote 'origin' is properly configured
- SSH keys are configured for authentication

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
   - **Conflict Check**: Ensure no conflicts with ongoing workspace pull operations

4. **Create Workspace Pull Task**: 
   - **Action**: Generate new task entry with type "workspace-pull"
   - **Format**: Follow task structure defined in bootstrap.md
   - **Validation**: Ensure all required fields are populated

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-workspace-pull",
  "type": "workspace-pull",
  "project": "workspace",
  "title": "Pull latest changes from origin main",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-24T10:00:00Z",
  "last_activity": "2025-07-24T14:30:00Z",
  "context": {
    "branch": "main",
    "remote": "origin"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "git-status-check",
    "remaining_steps": ["git-status-check", "local-changes-handling", "fetch-remote", "pull-changes", "conflict-resolution", "verification"]
  }
}
```

## Core Workflow Steps

### Step 1: Check Git Status

**Log Progress**: Update task progress to "git-status-check"

Claude, please check the current git status to understand the state of the workspace:
1. Run `git status` to see any uncommitted changes
2. Check the current branch with `git branch --show-current`
3. Verify we're on the main branch (or switch to it if needed)

**Activity Logging**: Record current git status and branch information

### Step 2: Handle Local Changes

**Log Progress**: Update task progress to "local-changes-handling"

If there are uncommitted changes in the workspace:
1. **Option A - Commit Changes**: If changes should be kept, commit them first
2. **Option B - Stash Changes**: If changes are temporary, stash them with `git stash push -m "Pre-pull stash"`
3. **Option C - Discard Changes**: If changes should be discarded, reset them (with user confirmation)

**Activity Logging**: Record how local changes were handled

### Step 3: Fetch Remote Changes

**Log Progress**: Update task progress to "fetch-remote"

Fetch the latest information from the remote repository:
1. Run `git fetch origin` to get the latest remote information
2. Check if there are incoming changes with `git log HEAD..origin/main --oneline`
3. Display a summary of incoming changes if any exist

**Activity Logging**: Record fetch results and incoming changes summary

### Step 4: Pull Changes from Origin Main

**Log Progress**: Update task progress to "pull-changes"

Pull the latest changes from origin main:
1. Run `git pull origin main` to merge remote changes
2. Handle any merge conflicts if they occur
3. Verify the pull completed successfully

**Activity Logging**: Record pull operation results and any conflicts encountered

### Step 5: Conflict Resolution (If Needed)

**Log Progress**: Update task progress to "conflict-resolution"

If merge conflicts occur during the pull:
1. **Identify Conflicts**: Run `git status` to see conflicted files
2. **Analyze Conflicts**: Show the conflicted files and their content
3. **Resolution Strategy**: 
   - For configuration files: Manually review and resolve
   - For documentation: Merge both changes where appropriate
   - For code files: Prioritize incoming changes unless local changes are critical
4. **Complete Resolution**: Add resolved files and complete the merge

**Activity Logging**: Record conflict resolution steps and decisions made

### Step 6: Verification

**Log Progress**: Update task progress to "verification"

After successfully pulling changes, verify the workspace state:
1. Run `git status` to confirm clean working directory
2. Run `git log --oneline -5` to show recent commits
3. Check that we're still on main branch and up to date with origin
4. Verify workspace files are intact and accessible

**Activity Logging**: Record verification results and final workspace state

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 7: Complete Task and Update Metrics

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive pull operation summary
3. **Update Workspace Metrics**: Refresh counters and statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Workspace Timestamp**: Set `last_updated` in workspace config

### Step 8: Generate Summary

1. **Create Summary Report**: Generate brief summary of changes pulled
2. **Log Task Completion**: Record final activity entry with outcomes
3. **Display Results**: Show user summary of pull operation

## Usage Examples

**Standard Pull:**
"Pull the latest changes from origin main to update the workspace"

**Pull with Status Check:**
"Check the workspace status and pull latest changes from origin main"

**Force Update:**
"Update workspace from origin main, handling any local changes as needed"

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark task as "failed" with error context
- **Provide Guidance**: Offer specific steps to resolve issues
- **Maintain State**: Ensure workspace remains in a consistent state

### Common Issues and Resolutions

**Merge Conflicts:**
- Identify conflicted files
- Provide resolution strategies based on file types
- Guide through manual resolution if needed

**Uncommitted Changes:**
- Offer to commit, stash, or discard changes
- Explain implications of each choice
- Ensure user makes informed decision

**Network Issues:**
- Retry fetch/pull operations
- Check connectivity and authentication
- Provide troubleshooting steps

## Expected Outcomes

After completing this workflow:

1. **Updated Workspace**: Workspace contains latest changes from origin main
2. **Clean State**: No uncommitted changes or conflicts remaining
3. **Complete Activity Trail**: Full audit log of pull operation
4. **Task Coordination**: Other agents can see workspace update status
5. **Ready for Work**: Workspace ready for continued development

## Usage with Claude Code

To execute this workflow:

> "Pull the latest changes from origin main to update the workspace"

> "Update the workspace with the latest remote changes"

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the pull operation.