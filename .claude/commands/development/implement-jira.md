# Claude Code JIRA Analysis & Requirements Workflow

This workflow guides Claude Code through comprehensive JIRA issue analysis and requirements gathering, with mandatory activity logging integration.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
- JIRA CLI tool is installed and configured with authentication
- Git is installed and configured with access to target repositories
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
4. **Create JIRA Implementation Task**: Generate new task with type "feature-development"

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-feature-development",
  "type": "feature-development",
  "project": "{project-alias}",
  "title": "Implement JIRA {issue-key}: {issue-title}",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-23T10:00:00Z",
  "last_activity": "2025-07-23T14:30:00Z",
  "context": {
    "issue_key": "{issue-key}",
    "jira_project": "{jira-project}",
    "project_alias": "{project-alias}"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "project-setup",
    "remaining_steps": ["project-setup", "jira-fetch", "codebase-discovery", "context-gathering", "requirements-clarification", "requirements-specification", "implementation-planning", "implementation-kickoff"]
  }
}
```

```claude-code
# Autonomous JIRA issue analysis and requirements gathering
# Usage: claude-code analyze-jira ISSUE-KEY

# Context: @.claude/context/jira-cli-usage.md
# Begin comprehensive JIRA analysis: $ARGUMENTS

## Workflow Overview:
This command autonomously transforms a JIRA issue into actionable requirements by understanding both the request and your codebase context.
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

### Step 2: Project Setup & JIRA Fetch

**Log Progress**: Update task progress to "jira-fetch"

**Goal**: Establish workspace and gather initial requirements

1. **Create timestamped workspace**:
   ```bash
   mkdir -p ".claude/changes/$(date +%Y-%m-%d-%H%M)-${ISSUE_KEY}"
   cd ".claude/changes/$(date +%Y-%m-%d-%H%M)-${ISSUE_KEY}"
   ```

2. **Initialize tracking**:
    - Create `metadata.json` with progress tracking
    - Set phase: "jira-fetch"

3. **Fetch comprehensive JIRA data**:
   ```bash
   # Get full issue details
   jira issue view $ISSUE_KEY --plain > raw-jira-issue.txt
   jira issue view $ISSUE_KEY --comments --plain > raw-jira-comments.txt
   ```

4. **Parse and document initial requirements**:
    - Extract: title, description, acceptance criteria, labels, priority
    - Identify: stakeholders, timeline, business context
    - Save to: `00-jira-analysis.md`

**Activity Logging**: Record JIRA data fetch results and initial requirements parsing

---

### Step 3: Codebase Discovery

**Log Progress**: Update task progress to "codebase-discovery"

**Goal**: Understand architecture and identify relevant code patterns

5. **High-level architecture scan**:
    - Use `mcp__RepoPrompt__get_file_tree` to map project structure
    - Identify: main services, data models, UI components, APIs
    - Document: tech stack, conventions, folder organization
    - Save to: `01-architecture-overview.md`

6. **Pattern recognition**:
    - Search for similar features using `mcp__RepoPrompt__search`
    - Analyze existing implementations that match JIRA requirements
    - Document: reusable patterns, common approaches, integration points
    - Save to: `02-existing-patterns.md`

**Activity Logging**: Record architecture analysis and pattern discovery results

---

### Step 4: Intelligent Context Gathering

**Log Progress**: Update task progress to "context-gathering"

**Goal**: Build deep understanding of relevant code

7. **Targeted file analysis**:
    - Use `mcp__RepoPrompt__set_selection` for batch file reading
    - Focus on: components mentioned in JIRA, similar features, shared utilities
    - Analyze: data flow, state management, API contracts, UI patterns

8. **External research** (when needed):
    - Use WebSearch for library documentation
    - Research best practices for identified technologies
    - Gather context on third-party integrations

9. **Document findings**:
    - File paths requiring changes
    - Integration touchpoints
    - Technical constraints
    - Save to: `03-technical-context.md`

**Activity Logging**: Record context gathering results and technical analysis

---

### Step 5: Smart Requirements Clarification

**Log Progress**: Update task progress to "requirements-clarification"

**Goal**: Ask targeted questions with intelligent defaults

10. **Generate discovery questions**:
    - Create 5 critical business logic questions
    - Base on: JIRA details + codebase patterns + similar features
    - Include smart defaults derived from existing code behavior
    - Format: Yes/No with clear reasoning for defaults
    - Save to: `04-discovery-questions.md`

11. **Interactive clarification**:
    - Present questions ONE at a time
    - Show: question + smart default + reasoning
    - Wait for user confirmation/override before proceeding
    - Record answers in: `05-discovery-answers.md`

12. **Expert-level detail questions**:
    - Generate 5 implementation-specific questions
    - Focus on: edge cases, error handling, performance, user experience
    - Include defaults based on codebase conventions
    - Save to: `06-detail-questions.md`
    - Ask and record answers in: `07-detail-answers.md`

**Activity Logging**: Record requirements clarification results and user decisions

---

### Step 6: Comprehensive Requirements

**Log Progress**: Update task progress to "requirements-specification"

**Goal**: Create complete, actionable specification

13. **Generate requirements specification**:
    - Combine: JIRA details + user answers + technical analysis
    - Include: functional requirements, technical constraints, acceptance criteria
    - Reference: specific files, components, and patterns to follow
    - Format: Developer-ready specification
    - Save to: `08-final-requirements.md`

**Activity Logging**: Record requirements specification generation and final requirements

---

### Step 7: Implementation Planning

**Log Progress**: Update task progress to "implementation-planning"

**Goal**: Create step-by-step implementation roadmap

14. **Generate implementation plan**:
    - Break down into logical, sequential tasks
    - Include: file modifications, new components, testing strategy
    - Reference: specific code patterns and integration points
    - Estimate: complexity and dependencies
    - Save draft to: `09-implementation-plan.md`

15. **User approval**:
    - Present plan summary with key decisions
    - Request confirmation before finalizing
    - Update metadata.json with "ready-for-implementation"

**Activity Logging**: Record implementation planning results and user approval

---

### Step 8: Implementation Kickoff

**Log Progress**: Update task progress to "implementation-kickoff"

**Goal**: Begin development with clear next steps

16. **Create development todo**:
    - Generate prioritized task list from implementation plan
    - Include: specific commands, file paths, code snippets
    - Save to: `10-development-todo.md`

17. **Begin implementation**:
    - Start with first task from todo
    - Update progress in metadata.json
    - Maintain context throughout development

**Activity Logging**: Record implementation kickoff and initial development tasks

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 9: Complete Task and Update Metrics

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive JIRA implementation summary and results
3. **Update Workspace Metrics**: Refresh counters and statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Workspace Timestamp**: Set `last_updated` in workspace config

### Step 10: Generate Artifacts

1. **Save Implementation Report**: Create `jira-implementation-{timestamp}.md` in reports directory
2. **Update Project Metadata**: Update `last_synced` if applicable
3. **Log Task Completion**: Record final activity entry with outcomes

---

## Smart Defaults Strategy:
- **Business Logic**: Mirror patterns from similar features
- **UI Behavior**: Follow established component conventions
- **Data Handling**: Use existing API patterns and validation rules
- **Error Cases**: Apply standard error handling approaches
- **Performance**: Follow current optimization patterns

## Metadata Structure:
```json
{
  "issueKey": "PROJ-123",
  "slug": "feature-description",
  "started": "2025-07-18T10:30:00Z",
  "lastUpdated": "2025-07-18T10:30:00Z",
  "phase": "jira-fetch|discovery|context|detail|requirements|planning|implementation",
  "progress": {
    "discovery": { "answered": 0, "total": 5 },
    "detail": { "answered": 0, "total": 5 }
  },
  "files": {
    "analyzed": ["src/components/UserProfile.tsx"],
    "toModify": ["src/api/users.ts", "src/components/UserList.tsx"],
    "patterns": ["pagination", "user-management", "form-validation"]
  },
  "decisions": {
    "confirmed": ["use-existing-modal-pattern", "follow-api-conventions"],
    "assumptions": ["preserve-current-permissions", "maintain-mobile-compatibility"]
  }
}
```

## Usage Examples

**Basic JIRA Implementation:**
"Implement JIRA issue OCM-456 on the cs project"

**Specific Project JIRA:**
"Analyze and implement JIRA ticket PROJ-123 on the web-app project"

**Bug Fix Implementation:**
"Implement bug fix for JIRA issue BUG-789 on the api-service project"

## Expected Outcomes

After completing this workflow:

1. **Complete JIRA Analysis**: Comprehensive requirements gathering and technical analysis
2. **Complete Activity Trail**: Full audit log of JIRA implementation process and decisions
3. **Task Coordination**: Other agents can see JIRA implementation status and results
4. **Actionable Requirements**: Clear, developer-ready specification with implementation plan
5. **Workspace Integration**: JIRA implementation integrated with overall development metrics
6. **Report Generation**: Structured report available for stakeholders and team members

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark task as "failed" with error context
- **Continue Where Possible**: Complete remaining analysis steps
- **Provide Recovery Guidance**: Offer specific steps to resolve issues
- **Maintain State**: Ensure partial progress is not lost

## Autonomous Operation Features

This workflow minimizes interruptions by:
- **Intelligent Assumptions**: Based on codebase analysis and existing patterns
- **Essential Questions Only**: Focused on critical business logic decisions
- **Well-Reasoned Defaults**: Provided for all clarification questions
- **Batched Interactions**: Grouped into focused decision points
- **Comprehensive Documentation**: Maintained throughout the entire process

## Usage with Claude Code

To execute this workflow:

> "Implement JIRA issue OCM-456 on the cs project"

> "Analyze and implement JIRA ticket PROJ-123 with full requirements gathering"

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the JIRA implementation process.