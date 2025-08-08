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

### MANDATORY ENFORCEMENT: Protocol Violation Prevention

**FAILURE TO FOLLOW THESE STEPS WILL RESULT IN OPERATION TERMINATION**

1. **Bootstrap Files Must Be Read First**: 
   - `.claude/bootstrap.md` and `.claude/config.md` are MANDATORY
   - If either file cannot be read, STOP immediately and report error
   - No exceptions - these files contain critical protocols

2. **Activity Log Integration is NON-NEGOTIABLE**:
   - `workspace-activity.json` must be initialized/updated before ANY work
   - Task entry MUST be created with proper structure and tracking
   - Progress MUST be logged at each major step
   - Final status MUST be updated with complete results

3. **Step Skipping is PROHIBITED**:
   - Each command defines mandatory steps in sequence
   - ALL steps must be completed in order
   - No shortcuts or "efficiency" optimizations allowed
   - I[.gitignore](.gitignore)f a step fails, log the failure and either fix or abort

### Integration Checklist (MANDATORY - NO EXCEPTIONS)

**Before starting any command (MUST COMPLETE ALL):**
- [ ] **CRITICAL**: Read `.claude/bootstrap.md` for initialization sequence
- [ ] **CRITICAL**: Load global configuration from `.claude/config.md`
- [ ] **CRITICAL**: Initialize or update `workspace-activity.json`
- [ ] **CRITICAL**: Create/resume appropriate task entry with complete context
- [ ] **CRITICAL**: Check for conflicts with other active agents
- [ ] **CRITICAL**: Load project-specific context if applicable

**During command execution (CONTINUOUS MONITORING):**
- [ ] **MANDATORY**: Log significant progress steps in real-time
- [ ] **MANDATORY**: Update task progress indicators at each major step
- [ ] **MANDATORY**: Record findings and decisions with complete context
- [ ] **MANDATORY**: Maintain state for recovery at all times

**After command completion (FINAL REQUIREMENTS):**
- [ ] **CRITICAL**: Update task status (completed/paused/failed) with results
- [ ] **CRITICAL**: Log final results and artifacts created/modified
- [ ] **CRITICAL**: Update workspace metrics and counters
- [ ] **CRITICAL**: Save all state changes to persistent storage

### Enforcement Mechanisms

1. **Pre-Flight Checks**: Before any operation, validate all required files exist
2. **Step Verification**: Each step must be logged and verified before proceeding
3. **Progress Auditing**: Regular checks that progress is being properly recorded
4. **Completion Validation**: Final verification that all requirements are met
5. **Error Recovery**: If any step fails, full rollback and error reporting

## CRITICAL: Fork-Based Git Operations

**MANDATORY USE OF FORK-BASED SCRIPTS FOR ALL GIT OPERATIONS**

This workspace uses a **secure fork-based model** that separates private development from public contributions. ALL git operations MUST use the provided scripts to prevent security violations.

### MANDATORY SCRIPT USAGE - NO EXCEPTIONS

**NEVER use raw git commands for commits or pushes. ALWAYS use these scripts:**

1. **Daily Development (Private Fork)**:
   ```bash
   # WRONG - Direct git commands
   git add .; git commit -m "message"; git push origin main
   
   # CORRECT - Let scripts handle the workflow
   # Just work normally, scripts will handle commits when needed
   ```

2. **Contributing Public Improvements**:
   ```bash
   # MANDATORY - Use sync script for upstream contributions
   ./scripts/sync-upstream.sh
   # This script ensures ONLY public files go to upstream
   ```

3. **Getting Upstream Updates**:
   ```bash
   # MANDATORY - Use update script for pulling upstream changes
   ./scripts/update-from-upstream.sh
   # This script safely merges upstream into your fork
   ```

### SECURITY ENFORCEMENT RULES

**VIOLATION OF THESE RULES WILL TERMINATE OPERATIONS**

1. **Script-First Policy**: 
   - Before ANY git operation, check if a script exists
   - Use `./scripts/sync-upstream.sh` for upstream contributions
   - Use `./scripts/update-from-upstream.sh` for upstream updates
   - NO direct `git push upstream` commands allowed

2. **Private Data Protection**:
   - `workspace-config.json` NEVER goes to upstream (template only)
   - `projects/` directory NEVER goes to upstream
   - `tasks/`, `reviews/`, `reports/` NEVER go to upstream
   - Scripts automatically filter private content

3. **Pre-Operation Validation**:
   - Check git status before any script execution
   - Verify remote configuration is correct
   - Confirm script exists and is executable
   - Validate no security violations will occur

### SCRIPT VERIFICATION CHECKLIST

**Before any git operation, VERIFY:**
- [ ] **CRITICAL**: Script exists for the operation (`ls scripts/`)
- [ ] **CRITICAL**: Script is executable (`chmod +x scripts/*.sh`)
- [ ] **CRITICAL**: Current working directory is workspace root
- [ ] **CRITICAL**: Git remotes are correctly configured
- [ ] **CRITICAL**: No sensitive data in staging area for upstream operations

### GIT OPERATION VIOLATIONS

**These actions are PROHIBITED and will terminate operations:**
- Direct `git push upstream main`
- Direct `git commit` without considering security model
- Manual `git remote` modifications
- Bypassing script-based workflow
- Committing sensitive data to public branches

**Recovery from violations requires manual intervention and security audit.**

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
│       │   ├── create-design-document.md # Design document creation
│       │   └── review-design-document.md # Design document review
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
├── reviews/                       # Design document review outputs
│   └── YYYY-MM-DD-HHMM-design-review-{feature}/
│       ├── 00-review-request.md   # Original review request
│       ├── 01-original-design.md  # Copy of design document being reviewed
│       ├── 02-analysis-findings.md # Structural and technical analysis
│       ├── 03-alternative-research.md # Industry best practices and alternatives
│       ├── 04-improvement-analysis.md # Gap analysis and improvements
│       ├── 05-expert-questions.md # Review questions for stakeholders
│       ├── 06-expert-answers.md   # Stakeholder responses
│       ├── 07-recommendations.md  # Prioritized improvement recommendations
│       ├── 08-review-report.md    # Comprehensive final report
│       └── metadata.json          # Review tracking and progress
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

### 7. Design Document Creation (`design/create-design-document.md`)
- Creates comprehensive design documents for new features
- Integrates with GitHub for issue tracking and collaboration
- Uses structured templates and requirements analysis
- **Always creates**: "design-document" task type

### 8. Design Document Review (`design/review-design-document.md`)
- Comprehensive review of existing design documents with alternative research
- Generates structured review reports with improvement recommendations
- Creates expert consultation workflows for stakeholder input
- Outputs detailed analysis in timestamped `/reviews` directories
- **Always creates**: "design-review" task type

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

## PROTOCOL COMPLIANCE AND CONSEQUENCES

### Zero Tolerance Policy for Step Skipping

**This workspace enforces a zero-tolerance policy for skipping mandatory steps.**

#### Immediate Consequences for Violations:
1. **Task Termination**: Any operation that skips required steps will be immediately terminated
2. **Error Logging**: All violations are logged in the activity log for audit purposes
3. **Agent Flagging**: Repeated violations result in agent performance flags
4. **Manual Override Required**: Recovery requires manual intervention and verification

#### Common Violations and Prevention:
- **Skipping Bootstrap**: Attempting work without reading `.claude/bootstrap.md` and `.claude/config.md`
- **Missing Activity Log**: Starting work without proper task creation in `workspace-activity.json`
- **Progress Gaps**: Failing to log intermediate steps and progress updates
- **Incomplete Finalization**: Not properly updating final task status and metrics

#### Recovery Procedures:
1. **Immediate Stop**: Halt all current operations
2. **State Assessment**: Review what steps were completed vs. required
3. **Rollback**: Undo any partial work that lacks proper tracking
4. **Proper Restart**: Begin again following complete protocol
5. **Verification**: Confirm all mandatory steps are completed before proceeding

### Protocol Validation Checkpoints

**Every operation must pass these validation points:**

1. **Initialization Checkpoint**: 
   - Bootstrap files successfully read ✓
   - Activity log properly initialized ✓
   - Task entry created with complete context ✓

2. **Progress Checkpoint** (repeated throughout execution):
   - Current step clearly identified and logged ✓
   - Progress indicators updated in real-time ✓
   - Intermediate results properly recorded ✓

3. **Completion Checkpoint**:
   - Final task status updated with results ✓
   - All artifacts and changes documented ✓
   - Workspace metrics updated ✓
   - State changes persisted ✓

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