# Claude Workspace Configuration

This is the master configuration file for the Claude development workspace. It defines the overall structure, protocols, and workflows that govern all development activities.

## Workspace Overview

This workspace manages multiple development projects with coordinated Claude Code agents, comprehensive activity logging, and automated task management.

### Key Components:
- **Multi-project management** via `workspace-config.json`
- **Activity tracking** via `workspace-activity.json` 
- **Task coordination** between multiple Claude Code agents
- **Weekly reporting** and productivity metrics
- **Project-specific contexts** via individual project `claude.md` files

## CRITICAL: Activity Logging Integration

**EVERY Claude Code operation must follow the Activity Log & Task Management Workflow.**

This is not optional - it's required for:
- Coordination between multiple agents
- Task continuity and resumption
- Audit trails and reporting
- Conflict prevention and resolution

### Integration Checklist

Before starting any command:
- [ ] Read `.claude/bootstrap.md` for initialization sequence
- [ ] Load global configuration from `.claude/config.md`
- [ ] Initialize or update `workspace-activity.json`
- [ ] Create/resume appropriate task entry
- [ ] Check for conflicts with other active agents
- [ ] Load project-specific context if applicable

During command execution:
- [ ] Log significant progress steps
- [ ] Update task progress indicators  
- [ ] Record findings and decisions
- [ ] Maintain state for recovery

After command completion:
- [ ] Update task status (completed/paused/failed)
- [ ] Log final results and artifacts
- [ ] Update workspace metrics
- [ ] Save all state changes

## Project Structure

The workspace follows this directory structure:

```
workspace-root/
├── workspace-config.json          # Project and user configuration
├── workspace-activity.json        # Activity log and task tracking
├── claude.md                      # This file - workspace configuration
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

### Available Commands

All commands integrate with the activity logging system:

### 1. Project Priming (`workspace/prime.md`)
- Sets up all projects from workspace configuration
- Clones repositories and configures remotes  
- Updates project metadata and sync status
- **Always creates**: "project-setup" task type

### 2. Workspace Pull (`workspace/pull.md`)
- Pulls latest changes from origin main
- Handles local changes and merge conflicts
- Ensures workspace is up to date with remote
- **Always creates**: "workspace-pull" task type

### 3. Workspace Status (`workspace/status.md`)
- Displays comprehensive workspace activity overview
- Shows completed tasks and interactive task management
- Enables resumption of incomplete tasks
- Provides task selection and continuation interface
- **Always creates**: "workspace-status" task type

### 4. Code Review (`development/review.md`)
- Reviews commits from forks with comprehensive analysis
- Handles security, performance, testing, and documentation
- Integrates with workspace project configuration
- **Always creates**: "code-review" task type

### 5. Activity Logging (`activity-log-workflow.md`)
- Manages task lifecycle and agent coordination
- Tracks all development activities and metrics
- Generates reports and summaries
- **Core system**: Supports all other commands

### 6. Query Logging (`workspace/query.md`)
- Processes user queries with comprehensive activity logging
- Tracks query patterns and knowledge gaps
- Enables learning progression analysis
- **Always creates**: "user-query" task type

## Multi-Agent Coordination

This workspace supports multiple Claude Code agents working simultaneously:

### Coordination Mechanisms:
- **Unique Agent IDs**: Each Claude Code session gets unique identifier
- **Task Locking**: Prevents multiple agents working on same task
- **Activity Broadcasting**: All agents can see each other's work
- **Clean Handoffs**: Tasks can be transferred between agents
- **Conflict Resolution**: Automatic detection and resolution of conflicts

### Best Practices:
- Always check active tasks before starting new work
- Use descriptive task titles and clear progress updates
- Log significant decisions for other agents to understand
- Complete tasks cleanly or mark them for handoff

## Project-Specific Integration

When working on individual projects:

### Context Loading:
1. Read workspace config to get project details
2. Navigate to project's local directory
3. Load project's `claude.md` for specific guidelines
4. Apply project-specific coding standards and workflows

### Project Claude.md Structure:
Each project should have its own `claude.md` with:
- Project description and architecture
- Coding standards and conventions
- Testing requirements and strategies
- Deployment and release processes
- Task-specific guidelines (code review focus areas, etc.)

## Reporting and Metrics

### Automatic Reporting:
- **Daily**: Task completion summaries
- **Weekly**: Comprehensive development reports
- **Monthly**: Productivity and quality metrics
- **On-demand**: Custom reports for specific time periods

### Tracked Metrics:
- Task completion rates and times
- Code review findings and patterns
- Project activity distribution
- Agent productivity and collaboration
- Quality indicators and trends

## Error Handling and Recovery

### Robust Operation:
- **Graceful Degradation**: Continue operation even if some components fail
- **State Recovery**: Resume work from last known good state
- **Conflict Resolution**: Automatic detection and resolution of agent conflicts
- **Audit Trail**: Complete history for troubleshooting and analysis

### Manual Overrides:
- Force task completion or cancellation
- Resolve agent conflicts manually
- Reset workspace state if needed
- Generate recovery reports for investigation

## Usage Examples

### Starting New Work:
```
"Initialize the workspace and start a code review for alice's auth-refactor branch on the cs project"
```

### Resuming Work:
```
"Show me active tasks and resume the most recent code review"
```

### Switching Projects:
```
"Switch to the mobile project and start working on the user-authentication feature"
```

### Generating Reports:
```
"Generate this week's development report including all completed tasks and metrics"
```

## Compliance and Standards

### Required Standards:
- All work must be tracked in the activity log
- Code reviews must follow security and performance guidelines
- Documentation must be updated for all changes
- Testing requirements must be met for all code changes

### Audit Requirements:
- Complete trail of all development activities
- Timestamped records of all decisions and changes
- Cross-agent coordination and handoff documentation
- Regular reporting for management and compliance

---

**This workspace configuration is mandatory for all Claude Code operations. Failure to follow these protocols will result in coordination issues, data loss, and audit trail gaps.**