# Claude Code JIRA Creation Workflow

This workflow guides Claude Code through creating new JIRA issues with comprehensive details, proper categorization, and mandatory activity logging integration.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
- JIRA CLI tool is installed and configured with authentication
- Git is installed and configured with access to target repositories
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
   - **Conflict Check**: Ensure no conflicts with ongoing JIRA creation operations

4. **Create JIRA Creation Task**: 
   - **Action**: Generate new task entry with type "jira-creation"
   - **Format**: Follow task structure defined in bootstrap.md
   - **Validation**: Ensure all required fields are populated

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-jira-creation",
  "type": "jira-creation",
  "project": "{project-alias}",
  "title": "Create JIRA issue: {issue-title}",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-23T10:00:00Z",
  "last_activity": "2025-07-23T14:30:00Z",
  "context": {
    "jira_project": "{jira-project}",
    "project_alias": "{project-alias}",
    "issue_type": "{issue-type}"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "project-setup",
    "remaining_steps": ["project-setup", "issue-definition", "confirmation", "jira-creation", "verification"]
  }
}
```

```claude-code
# Autonomous JIRA issue creation with comprehensive details
# Usage: claude-code create-jira "Issue Title" [PROJECT-KEY]

# Context: @.claude/context/jira-cli-usage.md
# Begin comprehensive JIRA creation: $ARGUMENTS

## Workflow Overview:
This command creates detailed JIRA issues with proper categorization and component assignment.
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

### Step 2: Issue Definition and Requirements Gathering

**Log Progress**: Update task progress to "issue-definition"

**Goal**: Gather comprehensive issue details with user confirmation

1. **Create timestamped workspace**:
   ```bash
   mkdir -p "tasks/$(date +%Y-%m-%d-%H%M)-jira-creation"
   cd "tasks/$(date +%Y-%m-%d-%H%M)-jira-creation"
   ```

2. **Initialize tracking**:
    - Create `metadata.json` with progress tracking
    - Set phase: "issue-definition"

3. **Gather issue requirements**:
   - **Title**: Present proposed title for confirmation
   - **Description**: Generate detailed description based on user input
   - **Issue Type**: Determine appropriate type (Story, Bug, Task, Epic)
   - **Priority**: Assess and suggest priority level
   - **Component**: Identify relevant project component
   - **Epic Link**: Ask if this should be linked to a parent Epic
   - **Labels**: Suggest relevant labels based on project context

4. **Interactive confirmation**:
   - Present all gathered details for user review
   - Request explicit confirmation for title and description
   - Allow modifications before proceeding
   - Save finalized details to: `00-issue-definition.md`

**Activity Logging**: Record issue definition and user confirmations

---

### Step 3: User Confirmation and Validation

**Log Progress**: Update task progress to "confirmation"

**Goal**: Ensure all details are accurate before creation

5. **Present complete issue summary**:
   ```markdown
   ## JIRA Issue Summary
   
   **Title**: [Confirmed Title]
   **Project**: [PROJECT-KEY]
   **Issue Type**: [Story/Bug/Task/Epic]
   **Priority**: [High/Medium/Low]
   **Component**: [Component Name]
   **Epic Link**: [EPIC-123 or None]
   
   **Description**:
   [Full description with acceptance criteria]
   
   **Labels**: [label1, label2, label3]
   ```

6. **Final confirmation prompt**:
   - Ask: "Please confirm these details are correct before creating the JIRA issue"
   - Wait for explicit user approval
   - Record confirmation in: `01-user-confirmation.md`

**Activity Logging**: Record user confirmation and final issue details

---

### Step 4: JIRA Issue Creation

**Log Progress**: Update task progress to "jira-creation"

**Goal**: Create the JIRA issue with all confirmed details

7. **Execute JIRA creation**:
   ```bash
   # Create the issue with all details
   jira issue create \
     --project="$PROJECT_KEY" \
     --type="$ISSUE_TYPE" \
     --summary="$TITLE" \
     --body="$DESCRIPTION" \
     --priority="$PRIORITY" \
     --component="$COMPONENT" \
     --labels="$LABELS"
   ```

8. **Handle Epic linking** (if specified):
   ```bash
   # Link to parent Epic if provided
   jira issue link $NEW_ISSUE_KEY $EPIC_KEY
   ```

9. **Capture creation results**:
   - Record new issue key
   - Save JIRA URL
   - Document creation timestamp
   - Save to: `02-creation-results.md`

**Activity Logging**: Record JIRA creation results and issue key

---

### Step 5: Verification and Documentation

**Log Progress**: Update task progress to "verification"

**Goal**: Verify successful creation and document results

10. **Verify issue creation**:
    ```bash
    # Fetch the created issue to verify
    jira issue view $NEW_ISSUE_KEY --plain > created-issue-verification.txt
    ```

11. **Generate summary report**:
    - Create comprehensive creation summary
    - Include issue key, URL, and all details
    - Format for easy sharing and reference
    - Save to: `03-creation-summary.md`

12. **Update project tracking** (if applicable):
    - Log new issue in project documentation
    - Update relevant tracking files
    - Maintain project issue registry

**Activity Logging**: Record verification results and final documentation

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 6: Complete Task and Update Metrics

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive JIRA creation summary and results
3. **Update Workspace Metrics**: Refresh counters and statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Workspace Timestamp**: Set `last_updated` in workspace config

### Step 7: Generate Artifacts

1. **Save Creation Report**: Create `jira-creation-{timestamp}.md` in reports directory
2. **Update Project Metadata**: Update issue tracking if applicable
3. **Log Task Completion**: Record final activity entry with outcomes

---

## Issue Type Guidelines

### Story
- New features or enhancements
- User-facing functionality
- Business value delivery

### Bug
- Defects or issues in existing functionality
- Incorrect behavior that needs fixing
- Regression issues

### Task
- Technical work items
- Maintenance activities
- Process improvements

### Epic
- Large features spanning multiple stories
- Major initiatives or projects
- Cross-functional work coordination

## Component Identification

**Automatic component suggestion based on**:
- Repository analysis
- File structure patterns
- Existing JIRA components
- Project documentation

**Common component patterns**:
- Frontend/UI components
- Backend/API services
- Database/Storage
- Infrastructure/DevOps
- Documentation
- Testing/QA

## Metadata Structure:
```json
{
  "title": "Issue Title",
  "projectKey": "PROJ",
  "issueType": "Story|Bug|Task|Epic",
  "priority": "High|Medium|Low",
  "component": "Component Name",
  "epicLink": "EPIC-123 or null",
  "labels": ["label1", "label2"],
  "created": "2025-07-23T14:30:00Z",
  "issueKey": "PROJ-456",
  "url": "https://jira.company.com/browse/PROJ-456",
  "confirmed": true,
  "verification": "success"
}
```

## Usage Examples

**Basic Issue Creation:**
"Create JIRA issue 'Add user authentication to dashboard' for the web-app project"

**Bug Report Creation:**
"Create JIRA bug report 'Login form validation errors' for the api-service project"

**Epic Creation:**
"Create JIRA epic 'Implement user management system' for the platform project"

## Expected Outcomes

After completing this workflow:

1. **New JIRA Issue**: Successfully created with all confirmed details
2. **Complete Activity Trail**: Full audit log of creation process and user confirmations
3. **Task Coordination**: Other agents can see JIRA creation status and results
4. **Verification Documentation**: Proof of successful creation with issue key and URL
5. **Workspace Integration**: JIRA creation integrated with overall development metrics
6. **Creation Report**: Structured report available for stakeholders and team members

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark task as "failed" with error context
- **Provide Recovery Guidance**: Offer specific steps to resolve issues
- **Maintain State**: Ensure partial progress is not lost
- **Rollback if Needed**: Clean up any partial JIRA data

## Interactive Prompts

The workflow includes these confirmation points:

1. **Title Confirmation**: "Is this title accurate: [proposed title]?"
2. **Description Review**: "Please review and confirm this description..."
3. **Component Selection**: "Should this be assigned to component: [suggested component]?"
4. **Epic Linking**: "Should this issue be linked to Epic [EPIC-KEY]?"
5. **Final Approval**: "Please confirm all details before creating the JIRA issue"

## Usage with Claude Code

To execute this workflow:

> "Create JIRA issue 'Add user profile management' for the cs project"

> "Create a new JIRA bug report for login issues on the web-app project"

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the JIRA creation process with all required confirmations.