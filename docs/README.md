# Claude Code Workspace Documentation

This documentation directory provides comprehensive guides for setting up and using the Claude Code workspace system.

## Quick Start

**New to the workspace?** Start with the setup guides:

1. **[Prerequisites](/home/croche/Work/projects/docs/setup/prerequisites.md)** - Overview of all CLI requirements
2. **[GitHub CLI Setup](/home/croche/Work/projects/docs/setup/github-cli-setup.md)** - Complete GitHub CLI installation and configuration
3. **[JIRA CLI Setup](/home/croche/Work/projects/docs/setup/jira-cli-setup.md)** - Complete JIRA CLI installation and configuration

## Documentation Structure

### Core Guides
- **[Claude Code Agents](/home/croche/Work/projects/docs/claude-code-agents.md)** - Complete guide to using specialized Claude Code agents for focused tasks

### Setup Guides
- **[Prerequisites](/home/croche/Work/projects/docs/setup/prerequisites.md)** - All CLI tools required by workspace commands
- **[GitHub CLI Setup](/home/croche/Work/projects/docs/setup/github-cli-setup.md)** - GitHub CLI installation, authentication, and configuration
- **[JIRA CLI Setup](/home/croche/Work/projects/docs/setup/jira-cli-setup.md)** - JIRA CLI installation, authentication, and project setup

### Troubleshooting
- **[GitHub CLI Troubleshooting](/home/croche/Work/projects/docs/troubleshooting/github-cli-troubleshooting.md)** - Common GitHub CLI issues and solutions
- **[JIRA CLI Troubleshooting](/home/croche/Work/projects/docs/troubleshooting/jira-cli-troubleshooting.md)** - Common JIRA CLI issues and solutions

### Integration
- **[Workspace Integration](/home/croche/Work/projects/docs/integration/workspace-integration.md)** - How CLI tools integrate with Claude Code commands

## Commands That Require CLI Tools

### GitHub CLI Commands
The following workspace commands require GitHub CLI (`gh`):
- **Code Review** (`development/review.md`) - Reviews pull requests and manages GitHub interactions
- **Workspace Pull** (`workspace/pull.md`) - Pulls latest changes from GitHub repositories
- **Workspace Prime** (`workspace/prime.md`) - Sets up GitHub repository connections
- **Migration Check** (`deployment/check-migrations.md`) - Checks GitHub for migration-related changes
- **Design Document Creation** (`design/create-design-document.md`) - Creates and manages design documents in GitHub
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

**Learn more**: See the complete [Claude Code Agents Guide](/home/croche/Work/projects/docs/claude-code-agents.md) for detailed usage instructions and best practices.

## Support

If you encounter issues not covered in the troubleshooting guides:

1. Check the specific CLI tool's official documentation
2. Verify your authentication and permissions
3. Test CLI commands independently before using with Claude Code
4. Review the workspace command files for specific requirements

## Contributing

When adding new workspace commands that require CLI tools:

1. Update the prerequisites documentation
2. Add specific setup instructions if needed
3. Include troubleshooting scenarios you encounter
4. Update this README with the new command requirements

---

**Note**: This documentation is automatically maintained to stay synchronized with workspace command requirements. All file paths in this documentation use absolute paths for clarity and reliability.