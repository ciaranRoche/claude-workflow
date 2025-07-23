# Claude Code Pre-Production Migration Check Workflow

This workflow guides Claude Code through comprehensive database migration analysis between commits, with mandatory activity logging integration.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
- Git is installed and configured with access to target repositories
- Database migration files follow established naming conventions
- Target project must be accessible through workspace configuration

## MANDATORY FIRST STEPS: Activity Log Integration

### Step 0A: Bootstrap Initialization
1. **Read Bootstrap Instructions**: Load `.claude/bootstrap.md` for mandatory setup
2. **Load Global Configuration**: Read `.claude/config.md` for workspace protocols
3. **Validate Workspace Structure**: Confirm all required files and directories exist

### Step 0B: Activity Log Initialization
1. **Initialize Activity Log**: Read or create `workspace-activity.json`
2. **Register Agent Session**: Create unique agent ID (`claude-agent-{timestamp}`)
3. **Check Active Tasks**: Review existing tasks to prevent conflicts
4. **Create Migration Check Task**: Generate new task with type "migration-check"

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-migration-check",
  "type": "migration-check",
  "project": "{project-alias}",
  "title": "Migration check {from-commit} to {to-commit}",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-23T10:00:00Z",
  "last_activity": "2025-07-23T14:30:00Z",
  "context": {
    "from_commit": "{from-commit}",
    "to_commit": "{to-commit}",
    "project_alias": "{project-alias}"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "project-setup",
    "remaining_steps": ["project-setup", "commit-validation", "migration-discovery", "risk-assessment", "impact-analysis", "validation", "summary-generation"]
  }
}
```

```claude-code
# Autonomous database migration detection and analysis for production deployments
# Usage: claude-code check-migrations FROM_COMMIT TO_COMMIT

# Context: @.claude/development/migration-check.md
# Begin comprehensive migration analysis: $ARGUMENTS

## Workflow Overview:
This command autonomously analyzes changes between two commits to identify database migrations and assess their production readiness, providing comprehensive deployment guidance.
```

---

## Core Workflow Steps

### Step 1: Read Workspace Configuration and Validate Project

**Log Progress**: Update task progress to "project-setup"

1. Read the `workspace-config.json` file and validate project exists
2. Extract project's platform, repository URLs, and local path
3. Navigate to project directory using the `local_path` from workspace configuration
4. **Load Project Context**: Read the project's `claude.md` file for specific guidelines

**Activity Logging**: Record project validation results and directory navigation

### Step 2: Project Setup & Commit Validation

**Log Progress**: Update task progress to "commit-validation"

**Goal**: Establish workspace and validate input commits

1. **Create timestamped workspace**:
   ```bash
   mkdir -p ".claude/migrations/$(date +%Y-%m-%d-%H%M)-migration-check-${FROM_COMMIT:0:7}-to-${TO_COMMIT:0:7}"
   cd ".claude/migrations/$(date +%Y-%m-%d-%H%M)-migration-check-${FROM_COMMIT:0:7}-to-${TO_COMMIT:0:7}"
   ```

2. **Initialize tracking**:
    - Create `metadata.json` with progress tracking
    - Set phase: "setup"

3. **Validate commits**:
   ```bash
   # Verify commits exist and are accessible
   git show --stat $FROM_COMMIT > from-commit-info.txt
   git show --stat $TO_COMMIT > to-commit-info.txt
   
   # Get commit details
   git log --oneline --no-merges $FROM_COMMIT..$TO_COMMIT > commit-range.txt
   ```

4. **Document commit analysis**:
    - Extract: commit messages, authors, timestamps, file counts
    - Identify: scope of changes, potential risk indicators
    - Save to: `00-commit-analysis.md`

**Activity Logging**: Record commit validation results and workspace setup

---

### Step 3: Migration Discovery

**Log Progress**: Update task progress to "migration-discovery"

**Goal**: Identify all database migrations in the change set

5. **Scan for migration files**:
   ```bash
   # Get all changes in migrations directory
   git diff --name-status $FROM_COMMIT..$TO_COMMIT -- pkg/database/migrations/ > migration-file-changes.txt
   
   # Get detailed diff for migration directory
   git diff $FROM_COMMIT..$TO_COMMIT -- pkg/database/migrations/ > migration-diff-details.txt
   ```

6. **Catalog migration files**:
    - Identify: new migrations, modified migrations, deleted migrations
    - Extract: migration names, timestamps, file sizes
    - Classify: DDL vs DML, schema vs data migrations
    - Save to: `01-migration-inventory.md`

7. **Content analysis**:
    - Use `mcp__RepoPrompt__get_file_contents` to read each migration
    - Parse: SQL statements, migration types, table dependencies
    - Identify: destructive operations, data transformations, index changes
    - Save to: `02-migration-content-analysis.md`

**Activity Logging**: Record migration discovery results and file inventory

---

### Step 4: Risk Assessment & Dependencies

**Log Progress**: Update task progress to "risk-assessment"

**Goal**: Evaluate migration safety and identify potential issues

8. **Risk classification**:
    - **Critical Risk**: Operations requiring table locks, schema locks, or long-running transactions
    - **High Risk**: DROP statements, large table alterations, data deletions, ADD COLUMN with NOT NULL
    - **Medium Risk**: ADD COLUMN with constraints, index modifications, foreign keys
    - **Low Risk**: ADD COLUMN nullable, new tables, new indexes (with CONCURRENTLY where applicable)
    - Document risk level per migration with specific lock and transaction concerns
    - Save to: `03-risk-assessment.md`

9. **Dependency analysis**:
    - Map table relationships affected by migrations
    - Identify cascade effects and constraint dependencies
    - Check for migration ordering requirements
    - Use `mcp__RepoPrompt__search` to find code references to affected tables
    - Save to: `04-dependency-analysis.md`

10. **Idempotency validation**:
    - Verify each migration can be run multiple times safely
    - Check for proper IF NOT EXISTS / IF EXISTS conditions
    - Identify operations that could fail on re-execution
    - Ensure migrations handle existing state gracefully
    - Save to: `05-idempotency-assessment.md`

**Activity Logging**: Record risk assessment findings and dependency analysis

---

### Step 5: Production Impact Analysis

**Log Progress**: Update task progress to "impact-analysis"

**Goal**: Evaluate deployment timing and performance implications

11. **Lock and transaction analysis**:
    - Identify operations that acquire table-level or schema locks
    - Estimate lock duration based on table size and operation type
    - Check for operations that block concurrent reads/writes
    - Analyze transaction boundaries and potential for long-running transactions
    - Flag migrations that could cause service disruption due to locking
    - Save to: `06-lock-analysis.md`

12. **Application compatibility check**:
    - Use `mcp__RepoPrompt__search` to find code that uses affected database objects
    - Identify potential breaking changes to application code
    - Check for missing migrations that code changes might require
    - Save to: `07-application-compatibility.md`

13. **Environment considerations**:
    - Check for environment-specific migration requirements
    - Identify data seeding or configuration changes needed
    - Document any manual steps required alongside migrations
    - Save to: `08-environment-considerations.md`

**Activity Logging**: Record production impact analysis and compatibility findings

---

### Step 6: Migration Validation

**Log Progress**: Update task progress to "validation"

**Goal**: Verify migration syntax and best practices

14. **Syntax and idempotency validation**:
    - Validate SQL syntax in migration files
    - Check migration file naming conventions
    - Verify proper transaction handling
    - **Critical**: Ensure all migrations are idempotent (can be run multiple times safely)
    - Validate use of IF NOT EXISTS, IF EXISTS, and conditional logic
    - Save findings to: `09-migration-validation.md`

15. **Best practices audit**:
    - Check for proper indexing strategies (using CONCURRENTLY where possible)
    - Validate constraint naming conventions
    - Review data type choices and lengths
    - Ensure migrations avoid long-running operations during peak hours
    - Identify potential optimization opportunities to minimize lock time
    - Save to: `10-best-practices-audit.md`

**Activity Logging**: Record validation findings and best practices audit results

---

### Step 7: Migration Summary & Risk Report

**Log Progress**: Update task progress to "summary-generation"

**Goal**: Deliver concise migration overview with actionable risk details

16. **Migration risk summary**:
    - Create consolidated view of all migrations with risk levels
    - **Focus on lock-related risks**: highlight operations that could cause service disruption
    - Include specific risk reasons, lock duration estimates, and handling recommendations
    - Provide idempotency validation results for each migration
    - Flag any migrations that are not safe for production due to locking or non-idempotent operations
    - Save to: `11-migration-risk-summary.md`

17. **Final report generation**:
    - Generate executive summary with go/no-go recommendation
    - List all migrations with their risk classification and key concerns
    - Include overall deployment readiness assessment
    - Save to: `12-final-migration-report.md`

18. **Update tracking**:
    - Finalize metadata.json with complete analysis results
    - Set phase: "completed"
    - Generate summary statistics

**Activity Logging**: Record final summary generation and analysis completion

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 8: Complete Task and Update Metrics

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive migration analysis summary and recommendations
3. **Update Workspace Metrics**: Refresh counters and statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Workspace Timestamp**: Set `last_updated` in workspace config

### Step 9: Generate Artifacts

1. **Save Migration Report**: Create `migration-check-{timestamp}.md` in reports directory
2. **Update Project Metadata**: Update `last_synced` if applicable
3. **Log Task Completion**: Record final activity entry with outcomes

---

## Smart Analysis Features:
- **Migration Pattern Recognition**: Identify common migration patterns and flag unusual approaches
- **Historical Context**: Compare with previous migrations for consistency
- **Cross-Reference Validation**: Ensure application code changes align with database changes
- **Environment-Aware**: Consider differences between staging and production environments

## Metadata Structure:
```json
{
  "fromCommit": "abc123def",
  "toCommit": "xyz789ghi",
  "slug": "migration-check-abc123-to-xyz789",
  "started": "2025-07-22T14:30:00Z",
  "lastUpdated": "2025-07-22T14:45:00Z",
  "phase": "setup|discovery|risk-assessment|impact-analysis|validation|summary|completed",
  "migrations": {
    "found": 3,
    "new": 2,
    "modified": 1,
    "deleted": 0,
    "riskLevels": {
      "critical": 0,
      "high": 0,
      "medium": 1,
      "low": 2
    }
  },
  "analysis": {
    "tablesAffected": ["users", "orders", "products"],
    "lockingOperations": 1,
    "estimatedMaxLockTime": "30 seconds",
    "idempotencyValidated": true,
    "rollbackComplexity": "not-applicable-forward-only",
    "productionReady": true
  },
  "files": {
    "analyzed": [
      "pkg/database/migrations/20250722_add_user_preferences.sql",
      "pkg/database/migrations/20250722_create_audit_log.sql"
    ],
    "codeReferences": [
      "pkg/models/user.go",
      "pkg/handlers/user_preferences.go"
    ]
  },
  "decisions": {
    "recommendation": "proceed-with-caution",
    "criticalFindings": [
      "migration-uses-table-lock-estimated-30-seconds",
      "one-migration-missing-if-not-exists-clause"
    ],
    "mitigationStrategies": [
      "deploy-during-low-traffic-window-for-locking-operations",
      "monitor-database-locks-during-migration",
      "ensure-idempotency-before-production-deployment"
    ]
  }
}
```

## Autonomous Operation Features:
- **Intelligent Migration Detection**: Automatically categorizes migration types and complexity
- **Risk-Based Prioritization**: Focuses analysis on highest-impact changes first
- **Context-Aware Analysis**: Considers application code changes alongside database changes
- **Historical Pattern Learning**: References previous migrations for consistency checking
- **Multi-Environment Awareness**: Considers staging vs production deployment differences

## Usage Examples

**Basic Migration Check:**
"Check migrations between main and HEAD commits on the cs project"

**Release Migration Check:**
"Check migrations from v2.1.0 to v2.2.0 on the api-service project"

**Production Deployment Check:**
"Check migrations from production/current to staging/latest on the database project"

## Expected Outcomes

After completing this workflow:

1. **Comprehensive Migration Analysis**: Detailed risk assessment and production readiness evaluation
2. **Complete Activity Trail**: Full audit log of migration check process and findings
3. **Task Coordination**: Other agents can see migration check status and results
4. **Actionable Recommendations**: Clear guidance for deployment safety and timing
5. **Workspace Integration**: Migration check integrated with overall development metrics
6. **Report Generation**: Structured report available for deployment teams

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark task as "failed" with error context
- **Continue Where Possible**: Complete remaining analysis steps
- **Provide Recovery Guidance**: Offer specific steps to resolve issues
- **Maintain State**: Ensure partial progress is not lost

## Integration Points

- **CI/CD Integration**: Can be run as pre-deployment gate
- **Notification Systems**: Results can trigger alerts for high-risk migrations
- **Documentation Systems**: Reports can be automatically archived for audit trails
- **Monitoring Integration**: Can generate monitoring queries for post-deployment validation

## Usage with Claude Code

To execute this workflow:

> "Check migrations from commit abc123 to def456 on the cs project"

> "Analyze migrations between v2.1.0 and v2.2.0 on the database project"

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the migration analysis process.