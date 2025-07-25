# Claude Code Bootstrap Instructions

**READ THIS FIRST FOR EVERY COMMAND**

This file is automatically loaded by Claude Code and contains critical setup instructions that must be followed for every operation.

## Mandatory Initialization Sequence

1. **Load Global Configuration**: Read `.claude/config.md` for workspace-wide settings
2. **Initialize Activity Logging**: Follow the activity log protocol defined below
3. **Read Workspace Configuration**: Load project and user settings from `workspace-config.json`
4. **Create Agent Session**: Generate unique agent ID and register in activity log
5. **Check Active Tasks**: Review current tasks to avoid conflicts with other agents
6. **Load Project Context**: If working on specific project, read its `claude.md` file

## Activity Log Format and Protocol

### Activity Log Structure (`workspace-activity.json`)

```json
{
  "workspace": {
    "name": "My Development Workspace",
    "created": "2025-07-23T00:00:00Z",
    "last_updated": "2025-07-23T14:30:00Z"
  },
  "active_tasks": [
    {
      "id": "task-{YYYY-MM-DD-HHmm}-{command-type}",
      "type": "code-review|project-setup|feature-development|bug-fix|refactor",
      "project": "{project-alias}",
      "title": "Human-readable task description",
      "status": "in-progress|paused|blocked",
      "assigned_agent": "claude-agent-{timestamp}",
      "created": "2025-07-23T10:00:00Z",
      "last_activity": "2025-07-23T14:30:00Z",
      "context": {
        // Command-specific context data
      },
      "progress": {
        "completed_steps": ["step1", "step2"],
        "current_step": "step3",
        "remaining_steps": ["step4", "step5"]
      }
    }
  ],
  "completed_tasks": [],
  "activities": [
    {
      "id": "activity-{timestamp}",
      "timestamp": "2025-07-23T14:30:00Z",
      "agent_id": "claude-agent-{timestamp}",
      "task_id": "task-{id}",
      "type": "step-completion|progress-update|error|decision",
      "project": "{project-alias}",
      "summary": "Brief description of what happened",
      "details": {
        // Activity-specific details
      }
    }
  ],
  "metrics": {
    "total_tasks": 1,
    "active_tasks": 1,
    "completed_tasks": 0,
    "tasks_by_type": {
      "code-review": 1,
      "project-setup": 0
    },
    "tasks_by_project": {
      "cs": 1
    }
  }
}
```

### Standard Task Types

- **code-review**: Reviewing commits from forks
- **project-setup**: Setting up/priming projects
- **feature-development**: Implementing new features
- **bug-fix**: Fixing reported issues
- **refactor**: Code refactoring and improvements
- **deployment**: Deployment and release activities
- **documentation**: Documentation updates

### Mandatory Activity Logging Steps

**EVERY Claude Code command must integrate with this system.**

#### Before Starting Any Command:
- Read or create `workspace-activity.json`
- Generate unique agent ID: `claude-agent-{Date.now()}`
- Create new task or resume existing task
- Check for conflicts with other active agents
- Load relevant project context

#### During Command Execution:
- Log significant progress at each major step
- Update task progress indicators in real-time
- Record findings, decisions, and intermediate results
- Save state regularly to prevent data loss

#### After Command Completion:
- Update task status (completed/paused/failed)
- Log final results and outcomes
- Update workspace metrics
- Save all changes to activity log

## Available Commands

All commands are located in `.claude/commands/` directory and must integrate with activity logging:

### Workspace Management
- **Project Priming**: `workspace/prime.md` - Setup all projects from workspace configuration
- **Workspace Pull**: `workspace/pull.md` - Pull latest changes from origin main
- **Workspace Status**: `workspace/status.md` - Review activity and manage tasks
- **Query Logging**: `workspace/query.md` - Process user queries with activity tracking

### Development Operations
- **Code Review**: `development/review.md` - Comprehensive code review workflow
- **JIRA Implementation**: `development/implement-jira.md` - JIRA issue analysis and implementation

### Design Operations
- **Design Documents**: `design/create-design-document.md` - Requirements gathering and design creation

### Deployment Operations
- **Migration Check**: `deployment/check-migrations.md` - Database migration analysis

### Core System
- **Activity Logging**: `activity-log-workflow.md` (core system supporting all commands)

## Agent Coordination Protocol

### Unique Agent IDs
Generate using format: `claude-agent-{timestamp}`
```javascript
const agentId = `claude-agent-${Date.now()}`;
```

### Task ID Format
Use format: `task-{YYYY-MM-DD-HHmm}-{command-type}`
```javascript
const taskId = `task-${new Date().toISOString().slice(0,16).replace(/[:T]/g,'-')}-${commandType}`;
```

### Conflict Prevention
- Always check `active_tasks` before starting new work
- Verify no other agent is working on same task
- Use task locking for exclusive operations
- Support clean handoffs between agents

## Error Handling

If any initialization step fails:
1. Report the specific failure clearly
2. Attempt to continue with reduced functionality
3. Log the failure in the activity log
4. Provide guidance for manual resolution

## Command Integration Template

Every command should follow this structure:

```markdown
# {Command Name} for Claude Code

## MANDATORY: Activity Log Integration

### Pre-Execution (Step 0):
1. Follow bootstrap initialization sequence
2. Create task with type "{command-type}"
3. Set up progress tracking with command-specific steps

### During Execution:
- Log completion of each major step
- Update progress indicators
- Record significant findings

### Post-Execution:
- Mark task as completed/failed
- Log final outcomes
- Update workspace metrics
- Save all state changes

## Command-Specific Steps
[Command implementation here]
```

---

**This bootstrap process and activity logging format is mandatory for maintaining workspace coordination and activity tracking across all Claude Code commands.**