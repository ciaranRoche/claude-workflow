# Claude Code Multi-Project Workspace

[![Version](https://img.shields.io/badge/Version-1.0.0-green.svg)](#)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Optimized-blue.svg)](https://claude.ai/code)
[![Fork-Based](https://img.shields.io/badge/Workflow-Fork--Based-orange.svg)](#)

A comprehensive workspace for Claude Code development workflows with **secure fork-based contribution model**. Provides coordinated multi-project management, activity tracking, and automated task coordination while keeping your private projects separate from public workflow tools.

## 🎯 **Fork-Based Architecture**

This repository uses a **dual-remote model** that separates:
- **Public workflow tools** (this repository) - Shareable with the community
- **Private project data** (your fork) - Keeps your personal projects secure

## 🏗️ Repository Structure

### **Public Content** (claude-workflow repository)
```
claude-workflow/                    # 🌍 Public workflow tools
├── CLAUDE.md                      # Main workspace configuration
├── README.md                      # This file
├── CONTRIBUTING.md                # Contribution guide
├── .gitignore                     # Public file patterns
├── workspace-config.template.json # Configuration template
├── .claude/                       # Claude Code configurations
│   ├── bootstrap.md               # Initialization instructions
│   ├── config.md                  # Global protocols
│   └── commands/                  # Workflow command definitions
│       ├── development/           # Development commands
│       ├── design/                # Design document commands
│       └── workspace/             # Workspace management
├── docs/                          # Documentation
│   ├── setup/                     # Setup guides
│   ├── integration/               # Integration docs
│   └── troubleshooting/           # Help guides
└── scripts/                       # Setup and sync scripts
    ├── init-fork.sh               # Fork initialization
    ├── sync-upstream.sh           # Sync to upstream
    └── update-from-upstream.sh    # Update from upstream
```

### **Private Content** (your fork only)
```
your-fork/                         # 🔒 Your private workspace
├── [all public files above]      # Inherited from upstream
├── workspace-config.json         # Your personal configuration
├── workspace-activity.json       # Activity tracking
├── projects/                      # Your private projects
│   ├── home-lab/                  # Infrastructure projects
│   ├── personal-app/              # Personal development
│   └── client-work/               # Client projects
├── tasks/                         # Task execution history
├── reviews/                       # Design reviews
└── reports/                       # Generated reports
```

## 🚀 Quick Start

### 1. **Fork the Repository**
```bash
# Fork claude-workflow on GitHub to your account
# Then clone YOUR fork (not the original)
git clone git@github.com:YOUR-USERNAME/your-fork-name.git
cd your-fork-name
```

### 2. **Initialize Your Fork**
```bash
# Run the initialization script
./scripts/init-fork.sh
```
This automatically:
- ✅ Configures upstream remote to claude-workflow
- ✅ Sets up workspace configuration from template
- ✅ Installs git hooks for contribution safety
- ✅ Creates proper .gitignore patterns
- ✅ Fetches latest upstream changes

### 3. **Configure Your Workspace**
```bash
# Edit your personal configuration
nano workspace-config.json
```
Update with your details:
```json
{
  "user": {
    "name": "Your Name",
    "github_username": "your-github-username"
  },
  "projects": [
    {
      "alias": "my-project",
      "name": "My Project",
      "repository": "git@github.com:you/my-project.git",
      "local_path": "./projects/my-project"
    }
  ]
}
```

### 4. **Start Using Claude Code**
```bash
# Launch Claude Code from workspace root
claude
```

## 🔄 **Workflow Usage**

### **Daily Development**
```bash
# Work normally on your fork - everything is private
git add .
git commit -m "feat: add new project configuration"
git push origin main
```

### **Contributing Improvements**
When you improve the **public workflow tools**:
```bash
# Sync only public files to upstream
./scripts/sync-upstream.sh
```
This safely pushes only `.claude/`, `docs/`, `CLAUDE.md`, etc. to claude-workflow.

### **Getting Updates**
Pull latest workflow improvements into your fork:
```bash
# Update your fork with upstream changes
./scripts/update-from-upstream.sh
```

### **Available Commands**
- `/prime` - Set up or refresh all projects  
- `/pull` - Pull latest changes from origin main
- `/status` - Review workspace activity and manage tasks
- `/query` - Submit queries with comprehensive logging
- All activity is automatically tracked in `workspace-activity.json`

## 🔧 **Configuration**

### **Workspace Configuration**
Your `workspace-config.json` (private, not synced to upstream):

```json
{
  "user": {
    "name": "Your Name",
    "github_username": "your-github-username",
    "jira_domain": "your-domain.atlassian.net"
  },
  "projects": [
    {
      "alias": "home-lab",
      "name": "Home Lab Infrastructure",
      "platform": "github",
      "ssh_url": "git@github.com:you/home-lab.git",
      "local_path": "./projects/home-lab",
      "tags": ["infrastructure", "k8s", "ansible"]
    },
    {
      "alias": "web-app",
      "name": "Personal Web App",
      "ssh_url": "git@github.com:you/web-app.git",
      "local_path": "./projects/web-app",
      "jira_project_key": "WEB"
    }
  ]
}
```

### **Security Model**
- **Private Data**: `workspace-config.json`, `projects/`, `tasks/`, etc. stay in your fork
- **Public Tools**: `.claude/`, `docs/`, templates sync to upstream
- **Git Hooks**: Prevent accidental upstream pushes of private data
- **Template System**: `workspace-config.template.json` for public sharing

## 🛡️ **Security & Privacy**

### **What Stays Private**
- ✅ Your `workspace-config.json` with personal details
- ✅ All projects in `projects/` directory
- ✅ Task execution history in `tasks/`
- ✅ Generated reports and reviews
- ✅ Any files matching patterns in `.gitignore`

### **What Gets Shared**
- 🌍 Workflow improvements to `.claude/commands/`
- 🌍 Documentation enhancements in `docs/`
- 🌍 Setup script improvements
- 🌍 Template configurations (sanitized)

### **Safety Features**
- **Git Hooks**: Warn before pushing to upstream
- **Path Filtering**: Only approved paths sync to upstream  
- **Template System**: Share configurations without personal data
- **Automatic Sanitization**: Scripts remove sensitive information

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

## 📝 **Contributing**

We welcome contributions to improve the Claude workflow experience! 

### **Quick Contribution**
1. **Fork** the repository to your GitHub account
2. **Initialize** your fork with `./scripts/init-fork.sh`
3. **Improve** public workflow tools (`.claude/`, `docs/`, etc.)
4. **Sync** changes with `./scripts/sync-upstream.sh`
5. **Create PR** on the upstream claude-workflow repository

### **Detailed Guide**
See [CONTRIBUTING.md](./CONTRIBUTING.md) for:
- Complete setup instructions
- Security guidelines
- Development workflows
- Troubleshooting help

### **What to Contribute**
- 🔧 New Claude Code commands
- 📚 Documentation improvements
- 🐛 Bug fixes in setup scripts
- 🎯 Workflow enhancements
- 💡 Template improvements

## 📄 License

This workspace configuration is for personal development use. Individual projects maintain their own licenses.
