# GitHub CLI Setup Guide

Complete installation and configuration guide for GitHub CLI (`gh`) to work with Claude Code workspace commands.

## Overview

GitHub CLI is required by 7 workspace commands for repository management, pull request operations, and GitHub API interactions. This guide covers installation, authentication, and configuration for all supported platforms.

## Installation

### macOS

#### Option 1: Homebrew (Recommended)
```bash
# Install GitHub CLI
brew install gh

# Verify installation
gh --version
```

#### Option 2: MacPorts
```bash
sudo port install gh
```

#### Option 3: Direct Download
1. Visit [GitHub CLI releases](https://github.com/cli/cli/releases)
2. Download the macOS package (`.pkg` file)
3. Double-click to install
4. Restart terminal

### Linux

#### Ubuntu/Debian
```bash
# Add GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Update and install
sudo apt update
sudo apt install gh
```

#### RHEL/CentOS/Fedora
```bash
# Add repository
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

# Install
sudo yum install gh
```

#### Arch Linux
```bash
pacman -S github-cli
```

#### Alpine Linux
```bash
apk add github-cli
```

### Windows

#### Option 1: Winget (Windows 10/11)
```powershell
winget install --id GitHub.cli
```

#### Option 2: Chocolatey
```powershell
choco install gh
```

#### Option 3: Scoop
```powershell
scoop install gh
```

#### Option 4: Direct Download
1. Visit [GitHub CLI releases](https://github.com/cli/cli/releases)
2. Download Windows installer (`.msi` file)
3. Run installer and follow prompts
4. Restart PowerShell/Command Prompt

### WSL (Windows Subsystem for Linux)
Follow the Linux installation instructions for your WSL distribution.

## Authentication Setup

### Interactive Authentication (Recommended)

```bash
# Start authentication flow
gh auth login
```

You'll be prompted to:
1. **Select account type**: GitHub.com or GitHub Enterprise
2. **Choose protocol**: HTTPS (recommended) or SSH
3. **Authentication method**: 
   - Browser login (easiest)
   - Personal Access Token (PAT)
4. **Complete authentication** in browser or paste token

### Personal Access Token (PAT) Method

#### Create PAT on GitHub
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Set expiration and select scopes:
   - **repo** (full repository access)
   - **workflow** (workflow permissions)
   - **read:org** (organization access)
   - **user:email** (email access)
4. Copy the generated token

#### Configure CLI with PAT
```bash
# Set token via environment variable
export GITHUB_TOKEN="your_token_here"

# Or authenticate directly
gh auth login --with-token < token.txt
```

### GitHub Enterprise Setup

For GitHub Enterprise Server:

```bash
# Login to enterprise instance
gh auth login --hostname your-github-enterprise.com
```

## Configuration Verification

### Check Authentication Status
```bash
# Verify authentication
gh auth status

# Expected output:
# ✓ Logged in to github.com as username
# ✓ Git operations for github.com configured to use https protocol.
# ✓ Token: *******************
```

### Test Repository Access
```bash
# List your repositories
gh repo list --limit 5

# View repository details
gh repo view owner/repository
```

### Test Pull Request Operations
```bash
# List pull requests in current directory (if it's a git repo)
gh pr list

# View specific pull request
gh pr view 123
```

## Workspace Integration Configuration

### Repository Access Setup

Ensure GitHub CLI can access repositories used by workspace commands:

```bash
# Clone and setup workspace repositories
gh repo clone organization/repository
cd repository

# Verify CLI can access repository data
gh pr list
gh issue list
```

### Organization Access

For organization repositories, ensure you have proper permissions:

```bash
# Check organization membership
gh api user/orgs
```

## Advanced Configuration

### Set Default Editor
```bash
# Set preferred editor for PR/issue creation
gh config set editor "code --wait"  # VS Code
gh config set editor "vim"          # Vim
gh config set editor "nano"         # Nano
```

### Configure Git Protocol
```bash
# Use HTTPS (default)
gh config set git_protocol https

# Or use SSH (requires SSH key setup)
gh config set git_protocol ssh
```

### Set Default Browser
```bash
gh config set browser "firefox"
gh config set browser "chrome"
```

## Claude Code Workspace Commands Using GitHub CLI

Once configured, these workspace commands will use GitHub CLI:

### Code Review (`development/review.md`)
- Fetches pull request data
- Comments on pull requests
- Updates PR status and labels

### Workspace Pull (`workspace/pull.md`)
- Pulls latest changes from origin
- Handles branch synchronization
- Manages merge conflicts

### Workspace Prime (`workspace/prime.md`)
- Clones repositories from GitHub
- Sets up remote connections
- Configures repository metadata

### Migration Check (`deployment/check-migrations.md`)
- Checks for migration-related PRs
- Validates deployment readiness
- Reviews database schema changes

### Design Document Creation (`design/create-design-document.md`)
- Creates GitHub issues for design docs
- Manages design review workflow
- Links documentation to code changes

### Design Document Review (`design/review-design-document.md`)
- Searches GitHub for design document examples and best practices
- Analyzes existing design documents from repositories
- Generates comprehensive review reports with improvement recommendations
- Creates structured review output in the `/reviews` directory

### Workspace Status (`workspace/status.md`)
- Reports repository synchronization status
- Shows pending pull requests
- Displays branch information

## Troubleshooting

Common issues and solutions:

### Authentication Issues
```bash
# Clear stored credentials
gh auth logout

# Re-authenticate
gh auth login
```

### Network/Proxy Issues
```bash
# Configure proxy if needed
export HTTPS_PROXY=http://proxy.company.com:8080
export HTTP_PROXY=http://proxy.company.com:8080
```

### Permission Issues
```bash
# Check token scopes
gh auth status

# Refresh token with additional scopes
gh auth refresh --scopes repo,workflow,read:org
```

### Repository Access Issues
```bash
# Verify repository exists and you have access
gh repo view owner/repo

# Check organization membership
gh api user/orgs
```

## Security Best Practices

### Token Management
- Use tokens with minimal required scopes
- Set reasonable expiration dates
- Store tokens securely (environment variables or credential managers)
- Rotate tokens regularly

### SSH Keys (if using SSH protocol)
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to SSH agent
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub account
cat ~/.ssh/id_ed25519.pub
```

## Updates and Maintenance

### Update GitHub CLI

**macOS (Homebrew):**
```bash
brew upgrade gh
```

**Linux (apt):**
```bash
sudo apt update && sudo apt upgrade gh
```

**Windows (Winget):**
```powershell
winget upgrade --id GitHub.cli
```

### Check for Updates
```bash
gh --version
# Compare with latest version at https://github.com/cli/cli/releases
```

## Further Reading

- **[GitHub CLI Documentation](https://cli.github.com/manual/)**
- **[GitHub CLI GitHub Repository](https://github.com/cli/cli)**
- **[GitHub API Documentation](https://docs.github.com/en/rest)**
- **[Workspace Integration Guide](/home/croche/Work/projects/docs/integration/workspace-integration.md)**
- **[GitHub CLI Troubleshooting](/home/croche/Work/projects/docs/troubleshooting/github-cli-troubleshooting.md)**

---

**Next Steps**: After completing GitHub CLI setup, consider installing JIRA CLI if you plan to use JIRA integration features. See the **[JIRA CLI Setup Guide](/home/croche/Work/projects/docs/setup/jira-cli-setup.md)**.