# CLI Prerequisites for Fork-Based Claude Code Workspace

This document outlines all CLI tools required for the **fork-based Claude Code workspace** to function properly across both private development and public contribution workflows.

## Overview

The fork-based Claude Code workspace uses CLI tools for:
- **Private Development**: Managing your personal projects and tasks
- **Public Contributions**: Syncing workflow improvements to upstream
- **External Integrations**: GitHub and JIRA API interactions

These tools must be installed and configured before using workspace commands.

## Required CLI Tools

### GitHub CLI (`gh`)
**Purpose**: Interacts with GitHub repositories, pull requests, and issues
**Used by**: 6 workspace commands
**Installation Guide**: [GitHub CLI Setup](github-cli-setup.md)

**Commands that require GitHub CLI**:
- `development/review.md` - Code review operations
- `workspace/pull.md` - Repository synchronization
- `workspace/prime.md` - Repository setup and configuration
- `deployment/check-migrations.md` - Migration validation
- `design/create-design-document.md` - Design document management
- `workspace/status.md` - Repository status reporting

### JIRA CLI (`jira`)
**Purpose**: Fetches and manages JIRA issues and project data
**Used by**: 1 workspace command
**Installation Guide**: [JIRA CLI Setup](jira-cli-setup.md)

**Commands that require JIRA CLI**:
- `development/implement-jira.md` - JIRA issue analysis and implementation

## System Requirements

### Operating System Support
Both CLI tools support:
- **macOS** (Intel and Apple Silicon)
- **Linux** (various distributions)
- **Windows** (Windows 10/11, WSL recommended)

### Network Requirements
- Internet connectivity for authentication and API calls
- Access to your organization's GitHub instance
- Access to your organization's JIRA instance
- Proper firewall/proxy configuration if required

## Authentication Requirements

### GitHub CLI Authentication
- Personal Access Token (PAT) or GitHub App
- Repository access permissions
- Organization membership (if applicable)

### JIRA CLI Authentication
- JIRA API token or username/password
- Project access permissions
- Valid JIRA server URL

## Installation Order

Recommended installation sequence for fork-based setup:

1. **Fork claude-workflow** - Create your private fork first
2. **Install GitHub CLI** - Required for fork initialization and sync
3. **Configure GitHub authentication** - Test access to both fork and upstream
4. **Run fork initialization** - `./scripts/init-fork.sh` sets up remotes
5. **Install JIRA CLI** (optional) - Only if using JIRA integration  
6. **Configure JIRA authentication** - Test issue access
7. **Verify setup** - Test both CLI tools and fork sync

## Verification Commands

After installation, verify each tool works:

### GitHub CLI Verification
```bash
# Check installation
gh --version

# Check authentication
gh auth status

# Test fork access
gh repo list --limit 5

# Test upstream access (after fork setup)
gh repo view ciaranRoche/claude-workflow
```

### JIRA CLI Verification
```bash
# Check installation
jira version

# Check authentication and server connection
jira issue list --limit 5
```

## Common Installation Issues

### GitHub CLI
- **Package manager conflicts**: Use official installation methods
- **PATH issues**: Ensure `gh` is in your system PATH
- **Authentication failures**: Check token permissions and expiration

### JIRA CLI
- **Server connectivity**: Verify JIRA URL and network access
- **Authentication format**: Ensure correct token/credential format
- **Project permissions**: Verify access to required JIRA projects

## Fork-Specific Verification

After setting up CLI tools, test the fork-based workflow:

```bash
# Test fork initialization script
./scripts/init-fork.sh

# Test upstream sync capability
./scripts/sync-upstream.sh --dry-run

# Test upstream update capability  
./scripts/update-from-upstream.sh --dry-run
```

## Next Steps

Once you have the CLI tools installed:

1. **[Install GitHub CLI](github-cli-setup.md)** - Complete setup guide
2. **[Install JIRA CLI](jira-cli-setup.md)** - Optional JIRA integration
3. **[Review Integration Guide](../integration/workspace-integration.md)** - Understand workspace usage
4. **[Contributing Guide](../../CONTRIBUTING.md)** - Fork-based contribution workflow

## Troubleshooting Resources

If you encounter issues:
- **[GitHub CLI Troubleshooting](../troubleshooting/github-cli-troubleshooting.md)**
- **[JIRA CLI Troubleshooting](../troubleshooting/jira-cli-troubleshooting.md)**

---

**Note**: These CLI tools are external dependencies. Keep them updated to ensure compatibility with the latest GitHub and JIRA APIs.