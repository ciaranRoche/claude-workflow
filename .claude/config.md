# Global Claude Code Configuration

This file defines workspace-wide settings and protocols that apply to all Claude Code operations.

## MANDATORY: Activity Logging Protocol

**Every Claude Code command MUST follow the Activity Logging workflow.**

### Pre-Execution Requirements (ALWAYS DO FIRST):

1. **Initialize Activity Log**: 
   - Read or create `workspace-activity.json`
   - Validate structure and load current state

2. **Register Agent Session**:
   - Generate unique agent ID: `claude-agent-{timestamp}`
   - Register session start in activity log

3. **Check Active Tasks**:
   - Review `active_tasks` array for conflicts
   - Identify tasks that can be resumed
   - Prevent duplicate work on same task

4. **Create or Resume Task**:
   - For new operations: Create new task entry
   - For continued work: Resume existing task
   - Update task assignment to current agent

5. **Load Project Context**:
   - Read `workspace-config.json` for project details
   - If project-specific: Load project's `claude.md`
   - Apply project-specific guidelines and constraints

### During-Execution Requirements (CONTINUOUS):

1. **Progress Logging**:
   - Log completion of each major step
   - Record significant findings or decisions
   - Update task progress indicators

2. **State Persistence**:
   - Save intermediate results to prevent data loss
   - Update activity log at regular intervals
   - Maintain recovery capability

3. **Conflict Prevention**:
   - Check for other agent activity periodically
   - Coordinate shared resource access
   - Leave clear activity breadcrumbs

### Post-Execution Requirements (ALWAYS DO LAST):

1. **Task Status Update**:
   - Mark task as completed, paused, or failed
   - Record final outcomes and results
   - Move completed tasks to appropriate section

2. **Activity Logging**:
   - Log final summary of work performed
   - Record any artifacts created or modified
   - Note any issues or recommendations

3. **Metrics Update**:
   - Update workspace-level metrics
   - Refresh project-specific counters
   - Calculate productivity indicators

4. **State Cleanup**:
   - Save all changes to `workspace-activity.json`
   - Update workspace `last_updated` timestamp
   - Clean up any temporary files or state

## Workspace Structure Requirements

### Required Files:
- `workspace-config.json` - Project and user configuration
- `workspace-activity.json` - Activity log and task tracking
- `activity-log-workflow.md` - Detailed workflow instructions
- `.claude/bootstrap.md` - Bootstrap instructions (this file)
- `.claude/config.md` - Global configuration (this file)

### Required Directories:
- `.claude/` - Claude Code configuration and context
- `projects/` - Local project repositories
- `reports/` - Generated reports and summaries

## Project Integration Protocol

When working with specific projects:

1. **Project Identification**:
   - Use project alias from `workspace-config.json`
   - Validate project exists and is active
   - Navigate to project's `local_path`

2. **Context Loading**:
   - Read project's `claude.md` for specific guidelines
   - Load project-specific coding standards
   - Apply project-specific workflows

3. **Activity Scoping**:
   - Tag all activities with project identifier
   - Maintain project-specific metrics
   - Integrate with project's development processes

## Multi-Agent Coordination Rules

### Conflict Prevention:
- Always check `active_tasks` before starting new work
- Use agent IDs to track ownership
- Implement task locking for exclusive operations

### Task Handoffs:
- Support clean task transfers between agents
- Maintain complete context during handoffs
- Log all ownership changes

### Shared Resources:
- Coordinate access to shared files and repositories
- Prevent concurrent modifications to same resources
- Use file-level locking where appropriate

## Error Handling and Recovery

### Initialization Failures:
- Attempt graceful degradation
- Log failures for investigation
- Provide clear error messages and recovery steps

### Runtime Failures:
- Save partial progress before failing
- Log error context for debugging
- Enable recovery from last known good state

### Coordination Failures:
- Detect and resolve agent conflicts
- Implement timeout mechanisms for stuck tasks
- Provide manual override capabilities

## Quality and Compliance

### Mandatory Checks:
- Validate all required files exist
- Verify workspace structure integrity
- Confirm activity log consistency

### Standards Enforcement:
- Apply consistent coding standards across projects
- Enforce documentation requirements
- Validate test coverage and quality

### Audit Trail:
- Maintain complete history of all activities
- Enable forensic analysis of development work
- Support compliance reporting requirements

## Performance and Optimization

### Efficiency Guidelines:
- Minimize activity log write operations
- Batch updates where possible
- Use efficient data structures for large workspaces

### Resource Management:
- Clean up temporary files automatically
- Limit log file sizes with rotation
- Optimize for concurrent agent operation

---

**Failure to follow this configuration will result in coordination issues and data loss. All Claude Code operations must integrate with this system.**