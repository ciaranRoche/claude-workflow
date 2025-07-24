# Project Priming Workflow for Claude Code

This workflow guides Claude Code through setting up all projects from the workspace configuration, with mandatory activity logging integration. Each step is idempotent and checks for existing repositories before attempting operations.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
- SSH keys are configured for both GitHub and GitLab
- Git is installed and configured

## MANDATORY FIRST STEPS: Activity Log Integration

### Step 0A: Bootstrap Initialization
1. **Read Bootstrap Instructions**: Load `.claude/bootstrap.md` for mandatory setup
2. **Load Global Configuration**: Read `.claude/config.md` for workspace protocols
3. **Validate Workspace Structure**: Confirm all required files and directories exist

### Step 0B: Activity Log Initialization
1. **Initialize Activity Log**: Read or create `workspace-activity.json`
2. **Register Agent Session**: Create unique agent ID (`claude-agent-{timestamp}`)
3. **Check Active Tasks**: Review existing tasks to prevent conflicts
4. **Create Project Setup Task**: Generate new task with type "project-setup"

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-project-setup",
  "type": "project-setup",
  "project": "workspace",
  "title": "Prime all workspace projects",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-23T10:00:00Z",
  "last_activity": "2025-07-23T14:30:00Z",
  "context": {
    "workspace_config": "workspace-config.json",
    "projects_count": "{total-projects}"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "workspace-config-read",
    "remaining_steps": ["workspace-config-read", "directory-structure", "project-cloning", "remote-configuration", "branch-checkout", "metadata-update", "verification"]
  }
}
```

## Core Workflow Steps

### Step 1: Read Workspace Configuration

**Log Progress**: Update task progress to "workspace-config-read"

Claude, please read the `workspace-config.json` file to understand the project structure and user configuration. Extract the user's GitHub and GitLab usernames, and identify all active projects that need to be set up.

**Activity Logging**: Record workspace configuration loading and project inventory

### Step 2: Create Project Directory Structure

**Log Progress**: Update task progress to "directory-structure"

For each active project in the configuration, create the necessary directory structure. Check if the `projects` directory exists, and create it if it doesn't. Then create subdirectories for each project based on their `local_path` configuration.

**Activity Logging**: Record directory creation results for each project

### Step 3: Clone Projects (Idempotent)

**Log Progress**: Update task progress to "project-cloning"

For each active project, perform the following idempotent clone operation:

1. Check if the project directory already contains a `.git` folder
2. If the project doesn't exist locally:
   - Clone the repository using the `ssh_url` from the configuration
   - Set the cloned repository as the `origin` remote
3. If the project already exists:
   - Verify the `origin` remote points to the correct SSH URL
   - Update the remote URL if necessary

**Activity Logging**: Record clone/validation results for each project

### Step 4: Configure Project Remotes

**Log Progress**: Update task progress to "remote-configuration"

For each project, set up the remote configuration based on the workspace config:

1. Set `origin` to point to the original/upstream repository (the main service repository)
2. Add a remote named after your platform username (from workspace config) that points to your fork
   - For GitLab projects: use `gitlab_username` from config (e.g., "croche")
   - For GitHub projects: use `github_username` from config (e.g., "ciaranRoche")
3. Your fork remote gets named after your username, making it clear when pushing to your fork vs upstream
4. Use the SSH URLs from the project configuration for secure authentication

**Activity Logging**: Record remote configuration results for each project

### Step 5: Fetch and Checkout Branches

**Log Progress**: Update task progress to "branch-checkout"

For each project:

1. Fetch all remote branches: `git fetch --all`
2. Check out the branch specified in the project's `branch` field
3. If the branch doesn't exist locally but exists on the remote, create and track it
4. If neither local nor remote branch exists, stay on the default branch

**Activity Logging**: Record branch checkout results for each project

### Step 6: Update Project Metadata

**Log Progress**: Update task progress to "metadata-update"

For each successfully configured project, update its metadata in the workspace configuration:

1. Set the `last_synced` field to the current timestamp (ISO format)
2. Update any project status information if applicable
3. Save the updated configuration back to `workspace-config.json`

**Activity Logging**: Record metadata updates and configuration saves

### Step 7: Update Workspace Metadata

Update the workspace-level metadata section:

1. Recalculate `total_projects` based on the current project count
2. Recalculate `active_projects` based on projects with `active: true`
3. Set `last_updated` to the current timestamp
4. Save the updated workspace configuration

### Step 8: Verification

**Log Progress**: Update task progress to "verification"

After setting up each project, verify the configuration:

1. List all remotes for each project to confirm correct setup
2. Show the current branch for each project
3. Display a summary of successfully configured projects
4. Confirm the workspace metadata has been updated correctly

**Activity Logging**: Record verification results and final setup summary

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 9: Complete Task and Update Metrics

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive project setup summary and results
3. **Update Workspace Metrics**: Refresh counters and statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Workspace Timestamp**: Set `last_updated` in workspace config

### Step 10: Generate Artifacts

1. **Save Setup Report**: Create `project-setup-{timestamp}.md` in reports directory
2. **Update Project Metadata**: Update `last_synced` for all projects
3. **Log Task Completion**: Record final activity entry with outcomes

## Usage Examples

**Initial Setup:**
"Prime all workspace projects using the project setup workflow"

**Specific Project Setup:**
"Set up the web-app project from the workspace config"

**Verification:**
"Check the git remote configuration for all projects in the workspace"

**Update Existing Projects:**
"Update all existing projects to match the current workspace configuration"

## Project-Specific Instructions

### For GitLab Projects (like uhc-clusters-service)
- Set `origin` to the service repository: `git@gitlab.cee.redhat.com:service/uhc-clusters-service.git`
- Set `croche` remote to your fork: `git@gitlab.cee.redhat.com:croche/uhc-clusters-service.git`
- This allows `git push origin` for upstream and `git push croche` for your fork

### For GitHub Projects  
- Set `origin` to the original repository: `git@github.com:original-owner/repository.git`
- Set `ciaranRoche` remote to your fork: `git@github.com:ciaranRoche/repository.git`
- This allows `git push origin` for upstream and `git push ciaranRoche` for your fork

### Branch Handling
- Respect the `branch` field from the project configuration
- For projects with `develop` branch, check it exists before switching
- Fall back to `main` if specified branch doesn't exist

## Expected Outcomes

After completing this workflow:

1. **Complete Project Setup**: All active projects cloned and configured correctly
2. **Complete Activity Trail**: Full audit log of project setup process and results
3. **Task Coordination**: Other agents can see project setup status and results
4. **Ready Workspace**: All projects ready for multi-project development
5. **Workspace Integration**: Project setup integrated with overall development metrics
6. **Report Generation**: Structured report available for workspace status
7. **Idempotent Operations**: All operations safe to re-run

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark task as "failed" with error context
- **Continue Where Possible**: Complete remaining project setups
- **Provide Recovery Guidance**: Offer specific steps to resolve issues
- **Maintain State**: Ensure partial progress is not lost

## Usage with Claude Code

To execute this workflow:

> "Prime all workspace projects using the project setup workflow"

> "Set up the development workspace according to workspace-config.json"

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the project setup process.