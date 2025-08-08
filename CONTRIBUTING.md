# Contributing to Claude Workflow

Welcome! This repository uses a **fork-based contribution model** that keeps public workflow tools separate from private project data.

## 🏗️ Repository Structure

### Public Content (Upstream: claude-workflow)
- `.claude/` - Claude Code agent configurations and commands
- `docs/` - Documentation and guides
- `CLAUDE.md` - Main workspace configuration
- `README.md` - Project overview
- `.gitignore` - Git ignore patterns
- `workspace-config.template.json` - Configuration template
- `scripts/` - Setup and sync scripts

### Private Content (Your Fork Only)
- `projects/` - Your personal projects
- `home-lab/` - Infrastructure configurations
- `tasks/` - Task execution history
- `reviews/` - Design document reviews
- `reports/` - Generated reports
- `workspace-config.json` - Your personal configuration

## 🚀 Getting Started

### 1. Fork the Repository

```bash
# Fork claude-workflow on GitHub, then clone your fork
git clone git@github.com:YOUR-USERNAME/home-lab-claude.git
cd home-lab-claude
```

### 2. Initialize Your Fork

```bash
# Run the initialization script
./scripts/init-fork.sh
```

This script will:
- Configure upstream remote to claude-workflow
- Set up workspace configuration from template
- Install git hooks for contribution safety
- Create proper .gitignore patterns

### 3. Configure Your Workspace

Edit `workspace-config.json` with your personal details:

```json
{
  "user": {
    "name": "Your Name",
    "email": "your.email@example.com",
    "github_username": "your-github-username"
  },
  "projects": {
    "my-project": {
      "name": "My Project",
      "repository": "git@github.com:your-username/my-project.git",
      "local_path": "./projects/my-project"
    }
  }
}
```

## 🔄 Development Workflow

### Daily Development
```bash
# Work normally on your fork
git add .
git commit -m "feat: add new project configuration"
git push origin main
```

### Contributing Back to claude-workflow
When you've improved the **public workflow tools**:

```bash
# Sync only public files to upstream
./scripts/sync-upstream.sh
```

This script:
- ✅ Extracts only public files
- ✅ Creates clean workspace-config template
- ✅ Pushes to upstream claude-workflow
- ✅ Keeps your private data secure

### Updating Your Fork
Get latest workflow improvements:

```bash
# Pull upstream changes into your fork
./scripts/update-from-upstream.sh
```

## 📋 Contribution Guidelines

### What to Contribute
**✅ Contribute these to upstream:**
- New Claude Code commands in `.claude/commands/`
- Documentation improvements in `docs/`
- Workflow enhancements in `CLAUDE.md`
- Setup script improvements
- Bug fixes in public tooling

**❌ Keep private in your fork:**
- Personal project configurations
- Infrastructure manifests
- Task execution history
- Private credentials or secrets
- Personal workflow customizations

### Pull Request Process
1. Make changes to public files in your fork
2. Test the changes work with your setup
3. Run `./scripts/sync-upstream.sh` to push to upstream
4. Create PR on claude-workflow repository
5. Include clear description of the improvement

### Code Standards
- **Shell Scripts**: Follow bash best practices, include error handling
- **Documentation**: Use clear markdown with examples
- **Claude Commands**: Follow existing command structure in `.claude/commands/`
- **Configuration**: Use JSON schema for validation

## 🔒 Security Guidelines

### Private Data Protection
- **Never commit secrets** to either repository
- **Use templates** for configuration files with sensitive data
- **Review changes** before running sync-upstream.sh
- **Use .gitignore** patterns for local-only files

### Git Hooks
The init script installs a pre-push hook that warns when pushing to upstream. This prevents accidental exposure of private data.

### Safe Practices
```bash
# ✅ Good: Sync public changes
./scripts/sync-upstream.sh

# ❌ Avoid: Direct push to upstream
git push upstream main  # Hook will warn you

# ✅ Good: Regular fork development  
git push origin main
```

## 🛠️ Advanced Usage

### Multiple Projects
Add projects to your `workspace-config.json`:

```json
{
  "projects": {
    "web-app": {
      "name": "My Web App",
      "repository": "git@github.com:me/web-app.git",
      "local_path": "./projects/web-app",
      "jira_project_key": "WEB"
    },
    "api-service": {
      "name": "API Service", 
      "repository": "git@github.com:me/api-service.git",
      "local_path": "./projects/api-service"
    }
  }
}
```

### Custom Commands
Create project-specific commands in `.claude/commands/`:

```bash
# Add your command
.claude/commands/custom/my-workflow.md

# Test it works
# (Claude Code will find it automatically)

# Contribute it back
./scripts/sync-upstream.sh
```

### Workspace Customization
Override global settings in your fork:

```json
{
  "settings": {
    "default_branch": "develop",
    "auto_sync": true,
    "task_retention_days": 90,
    "custom_command_paths": [
      ".claude/commands/custom/"
    ]
  }
}
```

## 🆘 Troubleshooting

### Common Issues

**"upstream remote not configured"**
```bash
./scripts/init-fork.sh
```

**"Merge conflicts when updating"**
```bash
git status
# Resolve conflicts manually
git commit
./scripts/update-from-upstream.sh
```

**"Accidentally pushed private data to upstream"**
```bash
# Contact maintainer immediately
# Force push corrected version
git push upstream main --force
```

### Getting Help
- Check existing [issues](https://github.com/ciaranRoche/claude-workflow/issues)
- Review [documentation](./docs/)
- Join discussions in repository discussions

## 📝 License

This project is licensed under MIT License - see LICENSE file for details.

## 🤝 Community

We welcome contributions that improve the Claude workflow experience for everyone while respecting privacy and security.

### Recognition
Contributors to public workflow improvements will be:
- Listed in release notes
- Mentioned in documentation
- Invited to reviewer status for significant contributions

---

**Thank you for contributing to Claude Workflow!** 🚀