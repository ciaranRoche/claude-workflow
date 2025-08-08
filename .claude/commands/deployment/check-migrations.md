# Claude Code Pre-Production Migration Check Workflow (MCP-Enhanced)

This workflow guides Claude Code through comprehensive database migration analysis between commits, with mandatory activity logging integration and **Database MCP integration for live schema validation**.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
- Git is installed and configured with access to target repositories
- **Database MCP server is configured and accessible**
- Database migration files follow established naming conventions
- Target project must be accessible through workspace configuration

## MANDATORY FIRST STEPS: Activity Log Integration

### Step 0A: Bootstrap Initialization

**CRITICAL: These files MUST exist and be readable. If any file cannot be read, STOP and inform the user.**

1. **Read Bootstrap Instructions**:
    - **File Path**: `.claude/bootstrap.md` (relative to current working directory)
    - **Action**: Use Read tool to load this file
    - **Error Handling**: If file doesn't exist or cannot be read, STOP execution and display: "ERROR: Cannot read .claude/bootstrap.md - Bootstrap file is missing or inaccessible. Please ensure this file exists in the workspace."

2. **Load Global Configuration**:
    - **File Path**: `.claude/config.md` (relative to current working directory)
    - **Action**: Use Read tool to load this file
    - **Error Handling**: If file doesn't exist or cannot be read, STOP execution and display: "ERROR: Cannot read .claude/config.md - Global configuration file is missing or inaccessible. Please ensure this file exists in the workspace."

3. **Validate Workspace Structure**:
    - **File Path**: `workspace-activity.json` (relative to current working directory)
    - **Action**: Use Read tool to check if file exists and is valid JSON
    - **Error Handling**: If file doesn't exist, create it with empty structure. If file exists but is invalid JSON, STOP execution and display: "ERROR: workspace-activity.json exists but contains invalid JSON. Please fix or delete this file."

### Step 0B: Activity Log Initialization

**MANDATORY: Follow the exact activity logging protocol defined in the bootstrap and config files.**

1. **Initialize Activity Log**:
    - **Action**: Read `workspace-activity.json` (already validated in Step 0A)
    - **Purpose**: Load current workspace state and existing tasks
    - **Error Handling**: If JSON parsing fails after validation, STOP execution and display: "ERROR: workspace-activity.json format is corrupted. Please restore from backup or recreate."

2. **Register Agent Session**:
    - **Action**: Create unique agent ID using format: `claude-agent-{timestamp}`
    - **Purpose**: Identify this specific Claude Code session for coordination
    - **Record**: Log agent registration in workspace activity

3. **Check Active Tasks**:
    - **Action**: Review `active_tasks` array in workspace-activity.json
    - **Purpose**: Identify conflicts with other active agents and resumable tasks
    - **Conflict Check**: Ensure no conflicts with ongoing migration check operations

4. **Create Migration Check Task**:
    - **Action**: Generate new task entry with type "migration-check"
    - **Format**: Follow task structure defined in bootstrap.md
    - **Validation**: Ensure all required fields are populated

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
    "project_alias": "{project-alias}",
    "database_mcp_enabled": true,
    "gabi_mcp_tools": ["get_db_name", "get_query_result"]
  },
  "progress": {
    "completed_steps": [],
    "current_step": "project-setup",
    "remaining_steps": ["project-setup", "mcp-connection", "commit-validation", "migration-discovery", "risk-assessment", "impact-analysis", "validation", "summary-generation"]
  }
}
```

```claude-code
# Autonomous database migration detection and analysis for production deployments
# Usage: claude-code check-migrations FROM_COMMIT TO_COMMIT

# Context: @.claude/development/migration-check.md
# Begin comprehensive migration analysis with Database MCP integration: $ARGUMENTS

## Workflow Overview:
This command autonomously analyzes changes between two commits to identify database migrations and assess their production readiness, providing comprehensive deployment guidance with live database schema validation via MCP.
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

### Step 1.5: Gabi MCP Connection Setup

**Log Progress**: Update task progress to "mcp-connection"

**NEW: Gabi MCP Integration**

1. **Initialize Gabi MCP Connection**:
   ```claude-code
   # Verify Gabi MCP server is connected and accessible
   # The Gabi MCP server provides database analysis capabilities
   # Available tools: get_db_name, get_query_result
   ```

2. **Validate Database Connectivity**:
    - Use `get_db_name` to identify the target database
    - Test connection and verify access permissions
    - Log connection status and database information
    - Save connection metadata to `mcp-connection-info.md`

3. **Capture Current Schema State**:
   ```claude-code
   # Use Gabi MCP to query current database schema
   gabi_get_db_name  # Get database name/identifier
   
   # Query current schema information using get_query_result
   gabi_get_query_result --query "SELECT table_name, table_schema FROM information_schema.tables WHERE table_schema NOT IN ('information_schema', 'pg_catalog')" --output current-tables.json
   
   gabi_get_query_result --query "SELECT table_name, column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_schema NOT IN ('information_schema', 'pg_catalog') ORDER BY table_name, ordinal_position" --output current-columns.json
   
   gabi_get_query_result --query "SELECT constraint_name, table_name, constraint_type FROM information_schema.table_constraints WHERE table_schema NOT IN ('information_schema', 'pg_catalog')" --output current-constraints.json
   
   gabi_get_query_result --query "SELECT indexname, tablename, indexdef FROM pg_indexes WHERE schemaname NOT IN ('information_schema', 'pg_catalog')" --output current-indexes.json
   ```

**Activity Logging**: Record Gabi MCP connection establishment and schema capture

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
    - **NEW**: Include MCP connection status in metadata

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

### Step 3: Migration Discovery with MCP Validation

**Log Progress**: Update task progress to "migration-discovery"

**Goal**: Identify all database migrations in the change set and validate against live schema

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

7. **Content analysis with Gabi MCP validation**:
    - Use `mcp__RepoPrompt__get_file_contents` to read each migration
    - Parse: SQL statements, migration types, table dependencies
    - Identify: destructive operations, data transformations, index changes
    - **NEW: Gabi MCP Schema Validation**:
      ```claude-code
      # For each migration, validate against current schema using Gabi MCP
      for migration in new_migrations:
          # Extract table names and operations from migration
          migration_tables = parse_migration_tables($migration)
          
          # Use Gabi MCP to check if referenced tables exist
          for table in migration_tables:
              gabi_get_query_result --query "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = '$table' AND table_schema NOT IN ('information_schema', 'pg_catalog'))"
          
          # Check for column existence conflicts for ALTER TABLE operations
          if migration_contains_alter_table($migration):
              gabi_get_query_result --query "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '$table' AND table_schema NOT IN ('information_schema', 'pg_catalog')"
          
          # Validate constraint names don't conflict
          if migration_contains_constraints($migration):
              gabi_get_query_result --query "SELECT constraint_name FROM information_schema.table_constraints WHERE table_name = '$table'"
      ```
    - Save to: `02-migration-content-analysis.md`

**Activity Logging**: Record migration discovery results, file inventory, and MCP validation results

---

### Step 4: Risk Assessment & Dependencies with Live Schema Analysis

**Log Progress**: Update task progress to "risk-assessment"

**Goal**: Evaluate migration safety and identify potential issues using live database state

8. **Enhanced risk classification with Gabi MCP**:
    - **Critical Risk**: Operations requiring table locks, schema locks, or long-running transactions
    - **High Risk**: DROP statements, large table alterations, data deletions, ADD COLUMN with NOT NULL
    - **Medium Risk**: ADD COLUMN with constraints, index modifications, foreign keys
    - **Low Risk**: ADD COLUMN nullable, new tables, new indexes (with CONCURRENTLY where applicable)
    - **NEW: Gabi MCP-Enhanced Risk Analysis**:
      ```claude-code
      # Use Gabi MCP to analyze table sizes and estimate impact
      for table in affected_tables:
          # Get table row count and size estimates
          gabi_get_query_result --query "SELECT COUNT(*) as row_count FROM $table"
          gabi_get_query_result --query "SELECT pg_size_pretty(pg_total_relation_size('$table')) as table_size, pg_size_pretty(pg_relation_size('$table')) as data_size"
          
          # Check for active connections and current load
          gabi_get_query_result --query "SELECT count(*) as active_connections FROM pg_stat_activity WHERE state = 'active'"
          
          # Analyze table usage patterns
          gabi_get_query_result --query "SELECT schemaname, tablename, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch FROM pg_stat_user_tables WHERE tablename = '$table'"
      ```
    - Document risk level per migration with specific lock and transaction concerns
    - **Include Gabi MCP-derived table size and performance impact estimates**
    - Save to: `03-risk-assessment.md`

9. **Dependency analysis with live schema**:
    - Map table relationships affected by migrations
    - **NEW: Use Gabi MCP to get live foreign key relationships**:
      ```claude-code
      # Query foreign key dependencies using Gabi MCP
      for table in affected_tables:
          # Get foreign keys where this table is referenced
          gabi_get_query_result --query "SELECT tc.constraint_name, tc.table_name, kcu.column_name, ccu.table_name AS foreign_table_name, ccu.column_name AS foreign_column_name FROM information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name WHERE tc.constraint_type = 'FOREIGN KEY' AND (tc.table_name = '$table' OR ccu.table_name = '$table')"
          
          # Get triggers on affected tables
          gabi_get_query_result --query "SELECT trigger_name, event_manipulation, action_statement FROM information_schema.triggers WHERE event_object_table = '$table'"
          
          # Get views that depend on these tables
          gabi_get_query_result --query "SELECT table_name as view_name FROM information_schema.views WHERE view_definition LIKE '%$table%'"
      ```
    - Identify cascade effects and constraint dependencies
    - Check for migration ordering requirements
    - Use `mcp__RepoPrompt__search` to find code references to affected tables
    - Save to: `04-dependency-analysis.md`

10. **Idempotency validation with Gabi MCP simulation**:
    - Verify each migration can be run multiple times safely
    - Check for proper IF NOT EXISTS / IF EXISTS conditions
    - **NEW: Gabi MCP Validation Queries**:
      ```claude-code
      # Use Gabi MCP to validate migration logic without applying changes
      for migration in migrations:
          migration_sql = parse_migration_sql($migration)
          
          # For CREATE TABLE statements, check if table already exists
          if migration_contains_create_table($migration):
              table_name = extract_table_name($migration)
              gabi_get_query_result --query "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = '$table_name')"
          
          # For ALTER TABLE statements, check if columns/constraints already exist
          if migration_contains_alter_table($migration):
              column_checks = extract_column_operations($migration)
              for check in column_checks:
                  gabi_get_query_result --query "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = '$check.table' AND column_name = '$check.column')"
          
          # For CREATE INDEX statements, check if index already exists
          if migration_contains_create_index($migration):
              index_name = extract_index_name($migration)
              gabi_get_query_result --query "SELECT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = '$index_name')"
      ```
    - Identify operations that could fail on re-execution
    - Ensure migrations handle existing state gracefully
    - Save to: `05-idempotency-assessment.md`

**Activity Logging**: Record risk assessment findings, dependency analysis, and MCP simulation results

---

### Step 5: Production Impact Analysis with Database Performance Data

**Log Progress**: Update task progress to "impact-analysis"

**Goal**: Evaluate deployment timing and performance implications using live database metrics

11. **Lock and transaction analysis with Gabi MCP performance data**:
    - Identify operations that acquire table-level or schema locks
    - **NEW: Use Gabi MCP to get current database performance metrics**:
      ```claude-code
      # Get current lock information and database activity
      gabi_get_query_result --query "SELECT locktype, database, relation::regclass, page, tuple, virtualxid, transactionid, classid, objid, objsubid, virtualtransaction, pid, mode, granted, fastpath FROM pg_locks WHERE NOT granted"
      
      # Get current database activity and connections
      gabi_get_query_result --query "SELECT datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit, tup_returned, tup_fetched, tup_inserted, tup_updated, tup_deleted FROM pg_stat_database WHERE datname = current_database()"
      
      # Analyze table access patterns for affected tables
      for table in affected_tables:
          gabi_get_query_result --query "SELECT schemaname, tablename, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd, n_live_tup, n_dead_tup FROM pg_stat_user_tables WHERE tablename = '$table'"
      
      # Get index usage statistics
      gabi_get_query_result --query "SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch FROM pg_stat_user_indexes WHERE tablename IN (affected_tables)"
      ```
    - Estimate lock duration based on table size and operation type
    - Check for operations that block concurrent reads/writes
    - Analyze transaction boundaries and potential for long-running transactions
    - Flag migrations that could cause service disruption due to locking
    - **Include recommendations for optimal deployment windows based on database activity patterns**
    - Save to: `06-lock-analysis.md`

12. **Application compatibility check with live data validation**:
    - Use `mcp__RepoPrompt__search` to find code that uses affected database objects
    - **NEW: Gabi MCP Data Validation**:
      ```claude-code
      # Check current data characteristics that might be affected by migrations
      for table in affected_tables:
          # Sample data to understand current state
          gabi_get_query_result --query "SELECT * FROM $table ORDER BY RANDOM() LIMIT 10"
          
          # Check data types and constraints that might be affected
          gabi_get_query_result --query "SELECT column_name, data_type, is_nullable, column_default, character_maximum_length FROM information_schema.columns WHERE table_name = '$table'"
          
          # For migrations adding NOT NULL constraints, check for null values
          if migration_adds_not_null_constraint($migration, table):
              affected_columns = extract_not_null_columns($migration, table)
              for column in affected_columns:
                  gabi_get_query_result --query "SELECT COUNT(*) as null_count FROM $table WHERE $column IS NULL"
          
          # For migrations changing column types, validate existing data compatibility
          if migration_changes_column_type($migration, table):
              type_changes = extract_type_changes($migration, table)
              for change in type_changes:
                  gabi_get_query_result --query "SELECT COUNT(*) as total_rows, COUNT(CASE WHEN $change.column::text ~ '^[0-9]+

13. **Environment considerations with Gabi MCP database analysis**:
    - Check for environment-specific migration requirements
    - **NEW: Gabi MCP Database Environment Analysis**:
      ```claude-code
      # Get database version and configuration that might affect migrations
      gabi_get_query_result --query "SELECT version()"
      gabi_get_query_result --query "SHOW ALL" # Get current database configuration
      
      # Check for environment-specific data or extensions
      gabi_get_query_result --query "SELECT extname, extversion FROM pg_extension"
      
      # Analyze database size and resource usage
      gabi_get_query_result --query "SELECT pg_size_pretty(pg_database_size(current_database())) as database_size"
      gabi_get_query_result --query "SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size FROM pg_tables WHERE schemaname NOT IN ('information_schema', 'pg_catalog') ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC LIMIT 20"
      
      # Check for timing-sensitive data that might affect migration windows
      gabi_get_query_result --query "SELECT COUNT(*) as active_sessions, MAX(now() - query_start) as longest_query FROM pg_stat_activity WHERE state = 'active'"
      ```
    - THEN 1 END) as valid_conversions FROM $table WHERE $change.column IS NOT NULL LIMIT 100"
      ```
    - Identify potential breaking changes to application code
    - Check for missing migrations that code changes might require
    - Save to: `07-application-compatibility.md`

13. **Environment considerations with MCP environment comparison**:
    - Check for environment-specific migration requirements
    - **NEW: Multi-Environment MCP Analysis**:
      ```claude-code
      # Compare schemas across environments if multiple MCP connections available
      mcp_database_compare_environments --env1 staging --env2 production --output env-comparison.json
      # Identify environment-specific data or configuration
      mcp_database_get_environment_specific_data --output env-specific.json
      ```

