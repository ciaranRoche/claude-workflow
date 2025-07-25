# Claude Code Multi-Project Workspace

[![Work in Progress](https://img.shields.io/badge/Status-Work%20in%20Progress-yellow.svg)](https://github.com/your-repo/issues)
[![Version](https://img.shields.io/badge/Version-1.0.0--draft-orange.svg)](#)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Optimized-blue.svg)](https://claude.ai/code)

> ⚠️ **Work in Progress**: This workspace configuration is currently in development. Some features may be incomplete or subject to change. See the [Contributing](#-contributing) section for how to help improve this setup.

This repository serves as a centralized workspace for Claude Code development workflows, providing coordinated multi-project management, activity tracking, and automated task coordination.

## 🏗️ Workspace Structure

```
workspace-root/
├── workspace-config.json          # Project and user configuration
├── workspace-activity.json        # Activity log and task tracking
├── claude.md                      # Workspace configuration for Claude Code
├── .claude/
│   ├── bootstrap.md               # Bootstrap instructions for Claude Code
│   ├── config.md                  # Global configuration and protocols
│   ├── context/                   # Additional context files
│   └── commands/                  # Command workflow definitions
│       ├── development/           # Development-focused commands
│       │   ├── review.md          # Code review command
│       │   └── implement-jira.md  # JIRA implementation command
│       ├── deployment/            # Deployment-focused commands
│       │   └── check-migrations.md # Migration check command
│       ├── design/                # Design-focused commands
│       │   └── create-design-document.md # Design document creation
│       └── workspace/             # Workspace management commands
│           ├── prime.md           # Project setup command
│           ├── pull.md            # Workspace update command
│           ├── status.md          # Activity status and task management
│           └── query.md           # User query logging and tracking
├── tasks/                         # Active task workspaces
│   ├── 2025-07-23-1430-feature-development-OCM-456/
│   ├── 2025-07-23-1445-code-review-alice-auth/
│   └── 2025-07-23-1500-migration-check-v1.2-v1.3/
├── projects/                      # Local project repositories
│   ├── uhc-clusters-service/      # Example project
│   │   ├── claude.md              # Project-specific configuration
│   │   └── [project files]
│   └── [other projects]/
└── reports/                       # Generated reports and summaries
    └── weekly-report-YYYY-MM-DD.md
```

## 🚀 Quick Start

### Initial Setup

1. **Clone this workspace repository:**
   ```bash
   git clone <workspace-repo-url>
   cd <workspace-directory>
   ```

2. **Update configuration for your environment:**
   ```bash
   # Edit workspace-config.json to update usernames and projects
   # Update the "user" section with your GitHub/GitLab usernames:
   {
     "user": {
       "github_username": "your-github-username",
       "gitlab_username": "your-gitlab-username"
     }
   }
   # Add/remove projects in the "projects" array as needed
   ```

3. **Prime the workspace:**
   ```bash
   # Using Claude Code
   /prime
   ```
   This will:
   - Clone all configured projects
   - Set up Git remotes (origin + your personal fork)
   - Checkout specified branches
   - Initialize activity tracking

### Daily Usage

**Start a development session:**
```bash
# Launch Claude Code from workspace root
claude
```

**Common commands:**
- `/prime` - Set up or refresh all projects
- `/pull` - Pull latest changes from origin main
- `/status` - Review workspace activity and manage tasks
- `/query` - Submit queries with comprehensive activity logging
- Work on specific projects by navigating to `projects/<project-name>/`
- All activity is automatically tracked in `workspace-activity.json`

## 🔧 Configuration

### Project Configuration

Projects are defined in `workspace-config.json`:

```json
{
  "projects": [
    {
      "alias": "cs",
      "name": "uhc-clusters-service",
      "platform": "gitlab",
      "ssh_url": "git@gitlab.cee.redhat.com:service/uhc-clusters-service.git",
      "branch": "master",
      "local_path": "./projects/uhc-clusters-service",
      "active": true
    }
  ]
}
```

### Git Remote Setup

Each project is configured with:
- **origin**: Points to the upstream/service repository
- **[username]**: Points to your personal fork
  - GitLab projects: `username` remote
  - GitHub projects: `username` remote

This allows:
- `git push origin <branch>` - Push to upstream (for direct commits)
- `git push username <branch>` - Push to your fork (for MRs/PRs)

## 🔄 Workflows

### Project Priming Workflow

Automatically sets up all configured projects:
1. Clones missing repositories
2. Configures Git remotes
3. Checks out specified branches
4. Updates project metadata
5. Initializes activity tracking

### Activity Logging

All development activities are tracked in `workspace-activity.json`:
- Task creation and completion
- Multi-agent coordination
- Progress tracking
- Audit trails

### Code Review Workflow

Integrated code review process:
- Reviews commits from forks
- Security and performance analysis
- Documentation verification
- Testing requirements

## 🛠️ Multi-Agent Coordination

This workspace supports multiple Claude Code agents working simultaneously:

**Features:**
- **Unique Agent IDs**: Each session gets a unique identifier
- **Task Locking**: Prevents conflicts between agents
- **Activity Broadcasting**: All agents see each other's work
- **Clean Handoffs**: Tasks can be transferred between agents

**Best Practices:**
- Check active tasks before starting new work
- Use descriptive task titles and progress updates
- Log significant decisions for other agents
- Complete tasks cleanly or mark for handoff

## 📊 Reporting

### Automatic Reports
- **Daily**: Task completion summaries
- **Weekly**: Comprehensive development reports
- **Monthly**: Productivity and quality metrics

### Manual Reports
Generate custom reports for specific time periods or projects.

## 🔐 Security & Compliance

**Required Standards:**
- All work tracked in activity log
- Complete audit trail of decisions
- Security-focused code reviews
- Documentation updates for all changes

**Git Security:**
- SSH keys required for all remotes
- Fork-based development workflow
- Protected main/master branches

## 🚨 Troubleshooting

### Common Issues

**Project not cloning:**
- Verify SSH keys are configured for GitLab/GitHub
- Check project URLs in `workspace-config.json`

**Remote configuration issues:**
- Run `/prime` to reconfigure remotes
- Verify fork repositories exist

**Activity log conflicts:**
- Check for multiple active Claude Code sessions
- Review `workspace-activity.json` for conflicts

### Getting Help

**Workspace Commands:**
- `/prime` - Reset and configure all projects
- `/pull` - Pull latest changes from origin main
- `/status` - Review workspace activity and manage tasks interactively
- `/query` - Submit queries with comprehensive logging and tracking
- Check `workspace-activity.json` for current tasks
- Review individual project `claude.md` files for specific guidelines

**Debug Information:**
- Git remote status: `git remote -v` in each project
- Current branches: `git branch --show-current`
- Activity log: Check `workspace-activity.json`

## 🎯 Development Best Practices

1. **Always use the workspace root** as your Claude Code working directory
2. **Check activity log** before starting new tasks
3. **Use project aliases** (cs, ocm-cli, ats) for quick reference
4. **Follow fork-based workflow** for all changes
5. **Document significant decisions** in activity log
6. **Run `/prime` regularly** to keep projects synchronized

## 📝 Contributing

When adding new projects:

1. Update `workspace-config.json` with project details
2. Run `/prime` to configure the new project
3. Add project-specific `claude.md` if needed
4. Update this README with project information

## 📄 License

This workspace configuration is for personal development use. Individual projects maintain their own licenses.
