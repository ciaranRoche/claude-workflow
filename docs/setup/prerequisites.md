# CLI Prerequisites for Claude Code Workspace

This document outlines all Command Line Interface (CLI) tools required for the Claude Code workspace commands to function properly.

## Overview

The Claude Code workspace uses several CLI tools to interact with external services and perform development operations. These tools must be installed and properly configured before using workspace commands.

## Required CLI Tools

### GitHub CLI (`gh`)
**Purpose**: Interacts with GitHub repositories, pull requests, and issues
**Used by**: 6 workspace commands
**Installation Guide**: [GitHub CLI Setup](/home/croche/Work/projects/docs/setup/github-cli-setup.md)

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
**Installation Guide**: [JIRA CLI Setup](/home/croche/Work/projects/docs/setup/jira-cli-setup.md)

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

Recommended installation sequence:

1. **Start with GitHub CLI** - Most commands depend on it
2. **Configure GitHub authentication** - Test basic functionality
3. **Install JIRA CLI** - Only if you plan to use JIRA integration
4. **Configure JIRA authentication** - Test issue access
5. **Verify both tools** - Run test commands

## Verification Commands

After installation, verify each tool works:

### GitHub CLI Verification
```bash
# Check installation
gh --version

# Check authentication
gh auth status

# Test repository access
gh repo list --limit 5
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

## Next Steps

Once you understand the requirements:

1. **[Install GitHub CLI](/home/croche/Work/projects/docs/setup/github-cli-setup.md)** - Comprehensive setup guide
2. **[Install JIRA CLI](/home/croche/Work/projects/docs/setup/jira-cli-setup.md)** - Complete configuration guide
3. **[Review Integration Guide](/home/croche/Work/projects/docs/integration/workspace-integration.md)** - Understand workspace usage

## Troubleshooting Resources

If you encounter issues:
- **[GitHub CLI Troubleshooting](/home/croche/Work/projects/docs/troubleshooting/github-cli-troubleshooting.md)**
- **[JIRA CLI Troubleshooting](/home/croche/Work/projects/docs/troubleshooting/jira-cli-troubleshooting.md)**

---

**Note**: These CLI tools are external dependencies. Keep them updated to ensure compatibility with the latest GitHub and JIRA APIs.