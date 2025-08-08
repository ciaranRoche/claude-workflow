# Workspace Priming Automation Scripts

This documentation covers the automation scripts used during the workspace priming workflow. These scripts work together to set up and manage multiple projects across GitHub and GitLab platforms within the Claude Code workspace management system.

## Overview

The workspace priming process consists of five coordinated shell scripts that handle:
- Git remote configuration for upstream and fork repositories
- Branch fetching and checkout operations
- Workspace metadata updates with sync timestamps
- Comprehensive verification and reporting
- Activity log integration for task tracking

## Scripts

### 1. configure_remotes.sh

**Purpose:** Configures Git remotes for all projects in the workspace, setting up both upstream (origin) and user fork remotes based on platform-specific conventions.

**Functionality:**
- Reads project configuration from `workspace-config.json`
- Sets `origin` remote to upstream repository URL
- Adds platform-specific user fork remotes:
  - GitHub projects: adds `ciaranRoche` remote
  - GitLab projects: adds `croche` remote
- Handles both GitHub (`openshift-online`) and GitLab (`service/`, `ocm/`) organizations
- Provides status feedback for each remote configuration

**Usage:**
```bash
./scripts/configure_remotes.sh
```

**Example Output:**
```
=== Configuring cs (gitlab) ===
  ✅ Origin: git@gitlab.cee.redhat.com:service/uhc-clusters-service.git
  ✅ Fork (croche): git@gitlab.cee.redhat.com:croche/uhc-clusters-service.git

=== Configuring ocm-cli (github) ===
  ✅ Origin: git@github.com:openshift-online/ocm-cli.git
  ✅ Fork (ciaranRoche): git@github.com:ciaranRoche/ocm-cli.git
```

**Dependencies:**
- `jq` for JSON parsing
- `workspace-config.json` in working directory
- Valid SSH keys for GitHub and GitLab access

**Error Handling:**
- Removes existing fork remotes before adding new ones
- Uses `2>/dev/null || true` to suppress non-critical errors
- Continues processing even if individual remote operations fail

### 2. fetch_and_checkout.sh

**Purpose:** Fetches latest changes from all remotes and ensures each project is on the correct target branch as specified in the workspace configuration.

**Functionality:**
- Fetches all remote branches for each project
- Compares current branch with target branch from configuration
- Handles three branch scenarios:
  - Already on target branch: no action needed
  - Local target branch exists: checkout existing branch
  - Remote target branch exists: create and checkout tracking branch
- Provides detailed status information for each operation

**Usage:**
```bash
./scripts/fetch_and_checkout.sh
```

**Example Output:**
```
=== Processing cs ===
  Fetching all remotes...
  Current branch: master
  Target branch: master
  ✅ Already on target branch: master

=== Processing ocm-cli ===
  Fetching all remotes...
  Current branch: feature-branch
  Target branch: main
  ✅ Checking out existing local branch: main
```

**Dependencies:**
- `jq` for JSON parsing
- `workspace-config.json` in working directory
- Git repositories with configured remotes

**Error Handling:**
- Uses `--quiet` flag to suppress verbose output
- Falls back gracefully if branches don't exist
- Warns when target branch is not found

### 3. update_metadata.sh

**Purpose:** Updates workspace configuration metadata with current timestamps and project statistics.

**Functionality:**
- Generates ISO 8601 timestamp for synchronization tracking
- Updates `last_synced` field for all projects
- Updates workspace-level metadata:
  - `last_updated`: current timestamp
  - `total_projects`: count of all projects
  - `active_projects`: count of active projects only
- Atomically replaces configuration file

**Usage:**
```bash
./scripts/update_metadata.sh
```

**Example Output:**
```
✅ Updated workspace configuration with:
  - Last synced: 2025-07-31T11:37:44Z
  - Total projects: 11
  - Active projects: 11
```

**Dependencies:**
- `jq` for JSON manipulation
- `date` command for timestamp generation
- `workspace-config.json` in working directory

**Error Handling:**
- Uses temporary file for atomic updates
- Preserves original file structure and formatting

### 4. verification_report.sh

**Purpose:** Provides comprehensive verification of workspace setup with detailed status reporting across multiple validation categories.

**Functionality:**
- **Project Count Verification:** Ensures expected number of projects exist
- **Git Repository Verification:** Validates `.git` directories for all projects
- **Remote Configuration Verification:** Checks origin and fork remotes
- **Branch Verification:** Confirms each project is on the expected branch
- **Metadata Verification:** Reports workspace configuration statistics
- **Final Summary:** Overall pass/fail status with actionable feedback

**Usage:**
```bash
./scripts/verification_report.sh
```

**Example Output:**
```
=======================================
    WORKSPACE PRIMING VERIFICATION
=======================================

📊 PROJECT COUNT VERIFICATION
   Expected: 11 projects
   Actual: 11 projects
   Status: ✅ PASS

🔧 GIT REPOSITORY VERIFICATION
   ✅ uhc-clusters-service: Git repository exists
   ✅ ocm-cli: Git repository exists
   ...
   Status: ✅ ALL PASS

🌐 REMOTE CONFIGURATION VERIFICATION
   ✅ cs: origin configured
   ✅ cs: croche fork configured
   ...
   Status: ✅ ALL PASS

🌿 BRANCH VERIFICATION
   ✅ cs: on master (expected: master)
   ✅ ocm-cli: on main (expected: main)
   ...
   Status: ✅ ALL PASS

📋 METADATA VERIFICATION
   Total projects: 11
   Active projects: 11
   Last updated: 2025-07-31T11:37:44Z
   Status: ✅ METADATA UPDATED

=======================================
           FINAL SUMMARY
=======================================
   🎉 WORKSPACE PRIMING COMPLETED SUCCESSFULLY!
   All 11 projects are properly configured and ready for development.
```

**Dependencies:**
- `jq` for JSON parsing
- `workspace-config.json` in working directory
- All project directories under `projects/`

**Error Handling:**
- Counts and reports specific failures in each category
- Provides clear pass/fail status for each verification type
- Continues verification even when individual checks fail

### 5. add_project_setup_task.sh

**Purpose:** Integrates the workspace priming operation with the Claude Code activity logging system by creating a completed task entry.

**Functionality:**
- Generates unique agent ID with timestamp
- Creates comprehensive task entry with:
  - Task metadata (ID, type, status, timestamps)
  - Context information (workspace config, project count)
  - Progress tracking (completed steps)
  - Results summary (projects configured, statistics)
- Updates workspace activity metrics
- Atomically updates `workspace-activity.json`

**Usage:**
```bash
./scripts/add_project_setup_task.sh
```

**Example Output:**
```
✅ Added project setup task to workspace-activity.json
   Task ID: task-2025-07-31-1140-project-setup
   Agent ID: claude-agent-1753962329000
   Status: completed
```

**Dependencies:**
- `jq` for JSON manipulation
- `date` command for timestamp generation
- `workspace-activity.json` in working directory

**Error Handling:**
- Uses temporary file for atomic updates
- Generates unique identifiers to prevent conflicts
- Preserves existing activity log structure

## Workflow Integration

### Execution Order

The scripts are designed to be executed in sequence during workspace priming:

1. **configure_remotes.sh** - Set up Git remotes
2. **fetch_and_checkout.sh** - Update branches and checkout target branches
3. **update_metadata.sh** - Update workspace configuration timestamps
4. **verification_report.sh** - Verify all setup operations
5. **add_project_setup_task.sh** - Log the completed task

### Claude Code Integration

These scripts integrate with the Claude Code workspace management system through:

- **Configuration Integration:** All scripts read from `workspace-config.json`
- **Activity Logging:** Task completion is recorded in `workspace-activity.json`
- **Bootstrap Compliance:** Follows mandatory activity logging protocols
- **Multi-Agent Coordination:** Generates unique agent IDs for task tracking

### Project Configuration Format

The scripts expect projects to be defined in `workspace-config.json` with this structure:

```json
{
  "projects": [
    {
      "alias": "cs",
      "name": "uhc-clusters-service",
      "platform": "gitlab",
      "ssh_url": "git@gitlab.cee.redhat.com:service/uhc-clusters-service.git",
      "local_path": "./projects/uhc-clusters-service",
      "branch": "master",
      "active": true
    }
  ]
}
```

## Platform Support

### GitHub Projects
- **Organization:** `openshift-online`
- **Fork Pattern:** `openshift-online` → `ciaranRoche`
- **Remote Name:** `ciaranRoche`
- **Example:** `git@github.com:openshift-online/ocm-cli.git` → `git@github.com:ciaranRoche/ocm-cli.git`

### GitLab Projects
- **Organizations:** `service/`, `ocm/`
- **Fork Patterns:** 
  - `service/` → `croche/`
  - `ocm/` → `croche/`
- **Remote Name:** `croche`
- **Example:** `git@gitlab.cee.redhat.com:service/uhc-clusters-service.git` → `git@gitlab.cee.redhat.com:croche/uhc-clusters-service.git`

## Error Handling and Recovery

### Common Issues and Solutions

1. **SSH Key Problems:**
   - Ensure SSH keys are properly configured for both GitHub and GitLab
   - Test connection: `ssh -T git@github.com` and `ssh -T git@gitlab.cee.redhat.com`

2. **Missing Repositories:**
   - Clone missing repositories manually
   - Update `workspace-config.json` with correct paths

3. **Branch Conflicts:**
   - Use `git status` to check for uncommitted changes
   - Stash changes before running `fetch_and_checkout.sh`

4. **Permission Issues:**
   - Ensure script files have execute permissions: `chmod +x scripts/*.sh`
   - Check directory permissions for project creation

### Verification and Debugging

The `verification_report.sh` script provides comprehensive diagnostics:
- Run after any manual changes to verify workspace state
- Check specific failure categories for targeted troubleshooting
- Use detailed output to identify configuration problems

## Performance Considerations

- **Parallel Processing:** Scripts process projects sequentially for stability
- **Network Operations:** Fetching operations may take time with many remotes
- **File Operations:** Atomic updates prevent corruption during concurrent access
- **Resource Usage:** Minimal CPU/memory footprint with efficient shell scripting

## Maintenance and Updates

### Adding New Projects
1. Update `workspace-config.json` with new project configuration
2. Run the complete script sequence to set up the new project
3. Verify setup with `verification_report.sh`

### Modifying Remote Patterns
1. Update URL transformation logic in `configure_remotes.sh`
2. Test with a single project before running on all projects
3. Update documentation to reflect new patterns

### Extending Verification
1. Add new verification categories to `verification_report.sh`
2. Follow existing pattern: count failures, report status
3. Update final summary logic to include new checks

## Security Considerations

- **SSH Key Management:** Scripts rely on properly configured SSH keys
- **File Permissions:** Configuration files should have appropriate read/write permissions
- **Network Access:** Requires access to GitHub and GitLab over SSH (port 22)
- **Atomic Operations:** Temporary files ensure configuration integrity during updates

This automation framework provides a robust, maintainable approach to managing multiple Git repositories across different platforms while integrating seamlessly with the Claude Code workspace management system.