# JIRA CLI Setup Guide

Complete installation and configuration guide for JIRA CLI (`jira`) to work with Claude Code workspace commands.

## Overview

JIRA CLI is required by the `development/implement-jira.md` workspace command for fetching JIRA issues, analyzing requirements, and implementing features based on JIRA tickets. This guide covers installation, authentication, and configuration for all supported platforms.

## Installation

### macOS

#### Option 1: Homebrew (Recommended)
```bash
# Install JIRA CLI
brew install jira-cli

# Verify installation
jira version
```

#### Option 2: Direct Download
1. Visit [JIRA CLI releases](https://github.com/ankitpokhrel/jira-cli/releases)
2. Download the macOS binary for your architecture:
   - `jira_*_darwin_amd64.tar.gz` (Intel)
   - `jira_*_darwin_arm64.tar.gz` (Apple Silicon)
3. Extract and move to PATH:
```bash
tar -xzf jira_*_darwin_*.tar.gz
sudo mv bin/jira /usr/local/bin/
chmod +x /usr/local/bin/jira
```

### Linux

#### Option 1: Package Managers

**Ubuntu/Debian:**
```bash
# Download and install package
wget https://github.com/ankitpokhrel/jira-cli/releases/latest/download/jira-cli_*_linux_amd64.deb
sudo dpkg -i jira-cli_*_linux_amd64.deb
```

**RHEL/CentOS/Fedora:**
```bash
# Download and install RPM
wget https://github.com/ankitpokhrel/jira-cli/releases/latest/download/jira-cli_*_linux_amd64.rpm
sudo rpm -i jira-cli_*_linux_amd64.rpm
```

#### Option 2: Binary Installation
```bash
# Download binary
wget https://github.com/ankitpokhrel/jira-cli/releases/latest/download/jira_*_linux_amd64.tar.gz

# Extract and install
tar -xzf jira_*_linux_amd64.tar.gz
sudo mv bin/jira /usr/local/bin/
chmod +x /usr/local/bin/jira
```

#### Option 3: Go Install
```bash
# If you have Go installed
go install github.com/ankitpokhrel/jira-cli/cmd/jira@latest
```

### Windows

#### Option 1: Chocolatey
```powershell
choco install jira-cli
```

#### Option 2: Scoop
```powershell
scoop install jira-cli
```

#### Option 3: Direct Download
1. Visit [JIRA CLI releases](https://github.com/ankitpokhrel/jira-cli/releases)
2. Download `jira_*_windows_amd64.zip`
3. Extract to a folder in your PATH
4. Rename `jira.exe` if needed

### WSL (Windows Subsystem for Linux)
Follow the Linux installation instructions for your WSL distribution.

## Authentication Setup

### Initial Configuration

```bash
# Initialize JIRA CLI configuration
jira init
```

You'll be prompted for:
1. **JIRA Server URL** (e.g., `https://your-company.atlassian.net`)
2. **Authentication method**:
   - API Token (recommended for Atlassian Cloud)
   - Username/Password (for Atlassian Server)
   - Personal Access Token (for newer versions)

### Atlassian Cloud Setup (API Token)

#### Create API Token
1. Go to [Atlassian Account Settings](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click "Create API token"
3. Give it a descriptive name (e.g., "JIRA CLI Access")
4. Copy the generated token

#### Configure CLI
During `jira init`, provide:
- **Server**: `https://your-company.atlassian.net`
- **Login**: Your Atlassian email address
- **API Token**: The token you created

### Atlassian Server/Data Center Setup

#### Username/Password Authentication
```bash
jira init
# Provide:
# - Server: https://your-jira-server.com
# - Login: your-username
# - Password: your-password
```

#### Personal Access Token (Recommended)
1. In JIRA, go to Profile → Personal Access Tokens
2. Create a new token with appropriate permissions
3. Use token during `jira init`

### Configuration File

JIRA CLI stores configuration in `~/.config/jira-cli/config.yml`:

```yaml
installation: cloud
server: https://your-company.atlassian.net
login: your-email@company.com
project: DEFAULT_PROJECT
board:
  name: Default Board
  id: 123
issue:
  types:
    - Story
    - Task
    - Bug
    - Epic
```

## Configuration Verification

### Test Authentication
```bash
# Test connection and authentication
jira me

# Expected output:
# Account ID: 1234567890abcdef
# Display Name: Your Name
# Email: your-email@company.com
```

### Test Issue Access
```bash
# List recent issues
jira issue list --limit 5

# Search for specific issues
jira issue list --jql "project = YOUR_PROJECT"
```

### Test Project Access
```bash
# List available projects
jira project list

# View specific project
jira project view YOUR_PROJECT
```

## Workspace Integration Setup

### Project Configuration

Set up default project for workspace commands:

```bash
# Set default project
jira config set project YOUR_PROJECT_KEY

# Verify configuration
jira config list
```

### Board Configuration

If using Agile boards:

```bash
# List available boards
jira board list

# Set default board
jira config set board.id YOUR_BOARD_ID
jira config set board.name "Your Board Name"
```

## Claude Code Workspace Command Integration

### JIRA Implementation Command (`development/implement-jira.md`)

This command uses JIRA CLI to:
- **Fetch issue details**: `jira issue view ISSUE-KEY --plain`
- **Get issue comments**: `jira issue view ISSUE-KEY --comments --plain`
- **Parse issue metadata**: Extract title, description, acceptance criteria
- **Analyze requirements**: Transform JIRA data into development requirements

### Required JIRA Permissions

Ensure your JIRA account has:
- **Browse Projects** permission
- **View Issues** permission  
- **View Comments** permission
- Access to specific projects used by workspace

## Advanced Configuration

### Custom Issue Types

```bash
# Configure custom issue types
jira config set issue.types Story,Task,Bug,Epic,Sub-task
```

### Custom Fields

```bash
# Configure custom fields for issue creation
jira config set issue.fields customfield_10001,customfield_10002
```

### Default Assignee

```bash
# Set default assignee for new issues
jira config set issue.assignee your-username
```

### JQL Templates

Create commonly used JQL queries:

```bash
# Save JQL template
jira config set templates.my-issues "assignee = currentUser() AND status != Done"

# Use template
jira issue list --jql "$(jira config get templates.my-issues)"
```

## Configuration Examples

### Multi-Project Setup

For workspaces with multiple JIRA projects:

```yaml
# ~/.config/jira-cli/config.yml
installation: cloud
server: https://company.atlassian.net
login: dev@company.com
projects:
  default: MAIN
  web: WEB
  api: API
  mobile: MOB
```

### Custom Workflow States

```yaml
issue:
  transitions:
    - "To Do"
    - "In Progress" 
    - "Code Review"
    - "Testing"
    - "Done"
```

## Testing Installation

### Complete Verification Script

```bash
#!/bin/bash
echo "Testing JIRA CLI installation..."

# Check installation
echo "1. Checking version..."
jira version

# Check authentication
echo "2. Checking authentication..."
jira me

# Check project access
echo "3. Checking project access..."
jira project list | head -5

# Check issue access
echo "4. Checking issue access..."
jira issue list --limit 3

echo "JIRA CLI verification complete!"
```

### Workspace Command Test

```bash
# Test the actual command pattern used by workspace
ISSUE_KEY="YOUR-PROJECT-123"

# Test issue fetching (as used by implement-jira.md)
jira issue view $ISSUE_KEY --plain > test-jira-issue.txt
jira issue view $ISSUE_KEY --comments --plain > test-jira-comments.txt

echo "Files created successfully - JIRA CLI ready for workspace use"
```

## Troubleshooting

Common issues and solutions:

### Authentication Failures

```bash
# Clear stored credentials
rm ~/.config/jira-cli/config.yml

# Re-initialize
jira init
```

### Server Connection Issues

```bash
# Test server connectivity
curl -I https://your-jira-server.com

# Check proxy settings if needed
export HTTPS_PROXY=http://proxy.company.com:8080
export HTTP_PROXY=http://proxy.company.com:8080
```

### Permission Issues

```bash
# Verify your user permissions
jira me
jira project list

# Test specific project access
jira issue list --project YOUR_PROJECT
```

### API Token Issues

1. Verify token hasn't expired
2. Check token permissions in Atlassian Account Settings
3. Regenerate token if necessary
4. Re-run `jira init` with new token

## Security Best Practices

### Token Management
- Create tokens with descriptive names
- Set reasonable expiration dates (if supported)
- Store tokens securely
- Rotate tokens regularly
- Revoke unused tokens

### Configuration Security

```bash
# Secure config file permissions
chmod 600 ~/.config/jira-cli/config.yml

# Backup configuration securely
cp ~/.config/jira-cli/config.yml ~/.config/jira-cli/config.yml.backup
```

### Network Security

- Always use HTTPS for JIRA server URLs
- Configure proxy settings properly if required
- Verify SSL certificates are valid

## Updates and Maintenance

### Update JIRA CLI

**macOS (Homebrew):**
```bash
brew upgrade jira-cli
```

**Linux (Package Manager):**
```bash
# Download latest package and reinstall
wget https://github.com/ankitpokhrel/jira-cli/releases/latest/download/jira-cli_*_linux_amd64.deb
sudo dpkg -i jira-cli_*_linux_amd64.deb
```

**Go Install:**
```bash
go install github.com/ankitpokhrel/jira-cli/cmd/jira@latest
```

### Check for Updates

```bash
jira version
# Compare with latest version at https://github.com/ankitpokhrel/jira-cli/releases
```

### Configuration Maintenance

```bash
# Review current configuration
jira config list

# Update specific settings
jira config set project NEW_DEFAULT_PROJECT

# Validate configuration
jira me
jira issue list --limit 1
```

## Integration with Development Workflow

### Issue Analysis Workflow

The workspace `implement-jira.md` command follows this pattern:

1. **Fetch Issue**: `jira issue view ISSUE-KEY --plain`
2. **Get Comments**: `jira issue view ISSUE-KEY --comments --plain`
3. **Parse Requirements**: Extract title, description, acceptance criteria
4. **Generate Questions**: Create clarification questions based on issue content
5. **Plan Implementation**: Convert JIRA requirements into development tasks

### Custom Scripts

Create helper scripts for common operations:

```bash
#!/bin/bash
# ~/.local/bin/jira-workspace-fetch
ISSUE_KEY=$1
OUTPUT_DIR=$2

mkdir -p "$OUTPUT_DIR"
jira issue view "$ISSUE_KEY" --plain > "$OUTPUT_DIR/issue.txt"
jira issue view "$ISSUE_KEY" --comments --plain > "$OUTPUT_DIR/comments.txt"
echo "JIRA data fetched for $ISSUE_KEY"
```

## Further Reading

- **[JIRA CLI Documentation](https://github.com/ankitpokhrel/jira-cli#readme)**
- **[JIRA CLI GitHub Repository](https://github.com/ankitpokhrel/jira-cli)**
- **[Atlassian REST API Documentation](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)**
- **[JIRA Query Language (JQL) Guide](https://www.atlassian.com/software/jira/guides/expand-jira/jql)**
- **[Workspace Integration Guide](/home/croche/Work/projects/docs/integration/workspace-integration.md)**
- **[JIRA CLI Troubleshooting](/home/croche/Work/projects/docs/troubleshooting/jira-cli-troubleshooting.md)**

---

**Next Steps**: After completing JIRA CLI setup, review the **[Workspace Integration Guide](/home/croche/Work/projects/docs/integration/workspace-integration.md)** to understand how CLI tools work with Claude Code commands.