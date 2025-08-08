# Claude Code Workspace Documentation

Comprehensive guides for the **fork-based Claude Code workspace system** that separates public workflow tools from private project data.

## 🚀 Quick Start

**New to the workspace?** Follow the fork-based setup:

1. **[Fork Setup Guide](#fork-setup)** - Initialize your private fork with secure configuration
2. **[Prerequisites](setup/prerequisites.md)** - CLI tools required for workspace commands
3. **[GitHub CLI Setup](setup/github-cli-setup.md)** - GitHub CLI installation and authentication
4. **[JIRA CLI Setup](setup/jira-cli-setup.md)** - JIRA CLI setup for issue management

## 🏗️ Fork-Based Architecture

This workspace uses a **dual-remote model**:

### **Public Repository** (claude-workflow)
- 🌍 **Shared workflow tools**: `.claude/`, `docs/`, scripts
- 🌍 **Community contributions**: Improvements to workflow system
- 🌍 **Templates**: Configuration templates without personal data

### **Private Fork** (your-fork)
- 🔒 **Personal projects**: Your development work in `projects/`
- 🔒 **Activity history**: Task tracking in `workspace-activity.json`
- 🔒 **Personal config**: Your `workspace-config.json` settings

## 📋 Documentation Structure

### 🔧 Fork Setup
- **[Fork Setup Guide](#fork-setup)** - Complete fork initialization and configuration
- **[Contributing Guide](../CONTRIBUTING.md)** - How to contribute workflow improvements
- **[Security Model](#security--privacy)** - Understanding public vs private content

### 🛠️ Setup Guides  
- **[Prerequisites](setup/prerequisites.md)** - CLI tools required for workspace commands
- **[GitHub CLI Setup](setup/github-cli-setup.md)** - GitHub CLI installation and authentication
- **[JIRA CLI Setup](setup/jira-cli-setup.md)** - JIRA CLI setup for issue management

### 🎯 Usage Guides
- **[Claude Code Agents](claude-code-agents.md)** - Specialized agents for focused tasks
- **[Workspace Integration](integration/workspace-integration.md)** - CLI tool integration with workspace

### 🚨 Troubleshooting
- **[GitHub CLI Troubleshooting](troubleshooting/github-cli-troubleshooting.md)** - GitHub CLI issues and solutions
- **[JIRA CLI Troubleshooting](troubleshooting/jira-cli-troubleshooting.md)** - JIRA CLI issues and solutions

## Commands That Require CLI Tools

### GitHub CLI Commands
The following workspace commands require GitHub CLI (`gh`):
- **Code Review** (`development/review.md`) - Reviews pull requests and manages GitHub interactions
- **Design Document Creation** (`design/create-design-document.md`) - Creates and manages design documents in GitHub
- **Design Document Review** (`design/review-design-document.md`) - Comprehensive review of design documents with alternative research and improvements
- **Workspace Pull** (`workspace/pull.md`) - Pulls latest changes from GitHub repositories
- **Workspace Prime** (`workspace/prime.md`) - Sets up GitHub repository connections
- **Migration Check** (`deployment/check-migrations.md`) - Checks GitHub for migration-related changes
- **Workspace Status** (`workspace/status.md`) - Displays GitHub repository status information

### JIRA CLI Commands
The following workspace commands require JIRA CLI (`jira`):
- **JIRA Implementation** (`development/implement-jira.md`) - Fetches JIRA issues and implements requirements

## Available Claude Code Agents

The workspace includes specialized agents for focused tasks:

### Documentation Agents
- **docs-sync-specialist** - Ensures documentation stays synchronized with recent code changes
  - Use after implementing new features or APIs
  - Automatically identifies and updates outdated documentation
  - Maintains consistency across all documentation files

### Productivity Agents  
- **conversation-note-taker** - Captures and organizes key information from conversations
  - Creates structured notes from technical discussions
  - Documents architectural decisions and trade-offs
  - Preserves important insights for future reference

**Learn more**: See the complete [Claude Code Agents Guide](claude-code-agents.md) for detailed usage instructions and best practices.

## Support

If you encounter issues not covered in the troubleshooting guides:

1. Check the specific CLI tool's official documentation
2. Verify your authentication and permissions
3. Test CLI commands independently before using with Claude Code
4. Review the workspace command files for specific requirements

## 🔧 Fork Setup

### Initial Setup
```bash
# 1. Fork claude-workflow repository on GitHub
# 2. Clone YOUR fork (not the original)
git clone git@github.com:YOUR-USERNAME/your-fork-name.git
cd your-fork-name

# 3. Initialize your fork
./scripts/init-fork.sh
```

### Configure Your Workspace
```bash
# Edit your personal configuration
nano workspace-config.json
```

### Daily Usage
```bash
# Work on your private projects normally
git add .; git commit -m "feat: my changes"; git push origin main

# Contribute workflow improvements
./scripts/sync-upstream.sh

# Get latest workflow updates  
./scripts/update-from-upstream.sh
```

## 🛡️ Security & Privacy

### What Stays Private
- ✅ Your `workspace-config.json` with personal details
- ✅ All projects in `projects/` directory
- ✅ Task history in `tasks/`, `reviews/`, `reports/`
- ✅ Any files matching `.gitignore` patterns

### What Gets Shared (when contributing)
- 🌍 Workflow improvements to `.claude/commands/`
- 🌍 Documentation enhancements in `docs/`
- 🌍 Setup script improvements in `scripts/`
- 🌍 Template configurations (sanitized)

## 📝 Contributing

See the complete **[Contributing Guide](../CONTRIBUTING.md)** for:
- Fork-based contribution workflow
- Security guidelines and best practices
- Pull request process
- Troubleshooting help

---

**Note**: This documentation reflects the fork-based architecture. All workflow improvements are welcome via the secure contribution model.