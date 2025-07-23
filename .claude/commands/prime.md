# Project Priming Workflow for Claude Code

This workflow guides Claude Code through setting up all projects from the workspace configuration. Each step is idempotent and checks for existing repositories before attempting operations.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
- SSH keys are configured for both GitHub and GitLab
- Git is installed and configured

## Workflow Instructions

### Step 1: Read Workspace Configuration

Claude, please read the `workspace-config.json` file to understand the project structure and user configuration. Extract the user's GitHub and GitLab usernames, and identify all active projects that need to be set up.

### Step 2: Create Project Directory Structure

For each active project in the configuration, create the necessary directory structure. Check if the `projects` directory exists, and create it if it doesn't. Then create subdirectories for each project based on their `local_path` configuration.

### Step 3: Clone Projects (Idempotent)

For each active project, perform the following idempotent clone operation:

1. Check if the project directory already contains a `.git` folder
2. If the project doesn't exist locally:
   - Clone the repository using the `ssh_url` from the configuration
   - Set the cloned repository as the `origin` remote
3. If the project already exists:
   - Verify the `origin` remote points to the correct SSH URL
   - Update the remote URL if necessary

### Step 4: Configure Project Remotes

For each project, set up the remote configuration based on the workspace config:

1. Set `origin` to point to the original/upstream repository (the main service repository)
2. Add a remote named after your platform username (from workspace config) that points to your fork
   - For GitLab projects: use `gitlab_username` from config (e.g., "croche")
   - For GitHub projects: use `github_username` from config (e.g., "ciaranRoche")
3. Your fork remote gets named after your username, making it clear when pushing to your fork vs upstream
4. Use the SSH URLs from the project configuration for secure authentication

### Step 5: Fetch and Checkout Branches

For each project:

1. Fetch all remote branches: `git fetch --all`
2. Check out the branch specified in the project's `branch` field
3. If the branch doesn't exist locally but exists on the remote, create and track it
4. If neither local nor remote branch exists, stay on the default branch

### Step 6: Update Project Metadata

For each successfully configured project, update its metadata in the workspace configuration:

1. Set the `last_synced` field to the current timestamp (ISO format)
2. Update any project status information if applicable
3. Save the updated configuration back to `workspace-config.json`

### Step 7: Update Workspace Metadata

Update the workspace-level metadata section:

1. Recalculate `total_projects` based on the current project count
2. Recalculate `active_projects` based on projects with `active: true`
3. Set `last_updated` to the current timestamp
4. Save the updated workspace configuration

### Step 8: Verification

After setting up each project, verify the configuration:

1. List all remotes for each project to confirm correct setup
2. Show the current branch for each project
3. Display a summary of successfully configured projects
4. Confirm the workspace metadata has been updated correctly

## Example Commands for Claude Code

Here are example commands you can give to Claude Code to execute this workflow:

**Initial Setup:**
"Read the workspace-config.json file and set up all active projects. For each project, clone it using SSH if it doesn't exist, or verify the remote configuration if it does exist."

**Specific Project Setup:**
"Set up the 'web-app' project from the workspace config. Clone it to the specified local path using SSH, and configure the origin remote."

**Verification:**
"Check the git remote configuration for all projects in the workspace and show me a status summary."

**Update Existing Projects:**
"For all existing projects in the workspace, update their remote URLs to match the current workspace configuration and fetch the latest changes."

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

1. All active projects are cloned to their specified local paths
2. Each project has correctly configured `origin` (service/upstream) and username remotes (your personal fork)
3. Projects are on their specified branches
4. Project-level `last_synced` timestamps are updated in the workspace config
5. Workspace metadata (`total_projects`, `active_projects`, `last_updated`) is refreshed
6. The workspace is ready for multi-project development
7. All operations are idempotent and safe to re-run

## Error Handling

If any step fails:
- Continue with remaining projects
- Report which projects were successfully configured
- Note any projects that encountered issues
- Provide specific error details for troubleshooting

## Usage with Claude Code

To execute this workflow, simply tell Claude Code:

> "Follow the project priming workflow to set up my development workspace. Read the claude-workspace.json configuration and clone/configure all active projects according to the specifications."

Claude Code will then work through each step, providing updates on progress and any issues encountered.