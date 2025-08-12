# Workspace Priming Scripts

This directory contains automation scripts for the Claude Code workspace priming workflow. These scripts work together to set up and manage 11+ projects across GitHub and GitLab platforms.

## Quick Start

Run the scripts in this order for complete workspace setup:

```bash
# 1. Configure Git remotes for all projects
./configure_remotes.sh

# 2. Fetch latest changes and checkout target branches  
./fetch_and_checkout.sh

# 3. Update workspace metadata with sync timestamps
./update_metadata.sh

# 4. Verify all setup operations completed successfully
./verification_report.sh

# 5. Log the completed task in activity system
./add_project_setup_task.sh
```

## Scripts Overview

| Script | Purpose | Dependencies |
|--------|---------|--------------|
| `configure_remotes.sh` | Set up origin and fork remotes | `jq`, SSH keys |
| `fetch_and_checkout.sh` | Fetch remotes and checkout branches | `jq`, configured remotes |
| `update_metadata.sh` | Update workspace timestamps | `jq`, `workspace-config.json` |
| `verification_report.sh` | Comprehensive setup verification | `jq`, project directories |
| `add_project_setup_task.sh` | Activity log integration | `jq`, `workspace-activity.json` |

## Prerequisites

- **Required Tools:** `jq`, `git`, `bash`
- **Configuration Files:** `workspace-config.json`, `workspace-activity.json`
- **SSH Access:** Valid SSH keys for GitHub and GitLab
- **Permissions:** Execute permissions on all scripts (`chmod +x *.sh`)

## Supported Platforms

### GitHub
- Organization: `openshift-online`
- Fork remote: `ciaranRoche`
- Example: `ocm-cli`, `ocm-api-model`

### GitLab  
- Organizations: `service/`, `ocm/`
- Fork remote: `croche`
- Example: `uhc-clusters-service`, `access-transparency-service`

## Verification

After running all scripts, check the verification report output:
- ✅ All checks pass: Workspace ready for development
- ❌ Some checks fail: Review specific error messages and resolve issues

## Troubleshooting

- **SSH Issues:** Test connections with `ssh -T git@github.com` and `ssh -T git@gitlab.cee.redhat.com`
- **Missing Projects:** Check `workspace-config.json` and ensure repositories exist
- **Branch Problems:** Verify target branches exist in remote repositories
- **Permission Errors:** Ensure scripts have execute permissions

## Documentation

For detailed documentation including error handling, platform support, and integration details, see:
[/docs/automation/workspace-priming-scripts.md](../docs/automation/workspace-priming-scripts.md)

## Integration

These scripts integrate with the Claude Code workspace management system:
- Read configuration from `workspace-config.json`
- Update activity log in `workspace-activity.json`
- Follow Claude Code bootstrap and activity logging protocols
- Support multi-agent coordination with unique task IDs