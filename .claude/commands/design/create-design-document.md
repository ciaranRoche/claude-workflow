# Claude Code Design Document Creation Workflow

This workflow guides Claude Code through comprehensive design document creation and requirements gathering, with mandatory activity logging integration.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
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
4. **Create Design Document Task**: Generate new task with type "design-document"

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-design-document",
  "type": "design-document",
  "project": "{project-alias}",
  "title": "Create design document: {feature-description}",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-23T10:00:00Z",
  "last_activity": "2025-07-23T14:30:00Z",
  "context": {
    "feature_slug": "{feature-slug}",
    "arguments": "{original-arguments}",
    "project_alias": "{project-alias}"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "initial-setup",
    "remaining_steps": ["initial-setup", "codebase-analysis", "context-discovery", "targeted-context", "expert-questions", "requirements-spec", "design-document"]
  }
}
```

```claude-code
# Autonomous design document creation and requirements gathering
# Usage: claude-code create-design-document FEATURE_DESCRIPTION
# Context: Begin gathering requirements for design document : $ARGUMENTS
```

---

## Core Workflow Steps

### Step 1: Initial Setup & Codebase Analysis

**Log Progress**: Update task progress to "initial-setup"

**Goal**: Establish workspace and understand project architecture

1. **Create timestamped workspace**:
   ```bash
   mkdir -p "tasks/$(date +%Y-%m-%d-%H%M)-design-document-${FEATURE_SLUG}"
   cd "tasks/$(date +%Y-%m-%d-%H%M)-design-document-${FEATURE_SLUG}"
   ```

2. **Extract feature slug** from $ARGUMENTS (e.g., "add user profile" → "user-profile")

3. **Create initial files**:
   - `00-initial-request.md` with the user's request
   - `metadata.json` with status tracking and feature information

4. **Update tracking**: Read and update `design/requirements/.current-requirement` with folder name

5. **High-level architecture analysis**:
   - Use Glob tool to explore project structure and file organization
   - Use mcp__RepoPrompt__get_file_tree (if available) to understand overall structure
   - Get high-level architecture overview
   - Identify main components and services
   - Understand technology stack
   - Note patterns and conventions

**Activity Logging**: Record workspace setup, feature analysis, and architecture overview

**Log Progress**: Update task progress to "codebase-analysis"

### Step 2: Context Discovery Questions

**Log Progress**: Update task progress to "context-discovery"

**Goal**: Understand the problem space through targeted questioning

6. **Generate discovery questions**:
   - Create 5 critical business logic questions to understand the problem space
   - Questions should be concise and help gather context needed for the design document
   - Base questions on initial architecture analysis and feature requirements
   - Include smart defaults derived from existing project patterns
   - Write all questions to `01-discovery-questions.md` with smart defaults

7. **Interactive clarification**:
   - Present questions ONE at a time
   - Show: question + smart default + reasoning for default
   - Wait for user confirmation/override before proceeding to next question
   - Only after all questions are asked, record answers in `02-discovery-answers.md`
   - Update `metadata.json` with question completion status

**Activity Logging**: Record discovery questions generated, user responses, and context gathered

### Step 3: Targeted Context Gathering

**Log Progress**: Update task progress to "targeted-context"

**Goal**: Build deep understanding of relevant code and patterns

8. **Autonomous code analysis** (after all discovery questions answered):
   - Use mcp__RepoPrompt__search (if available) to find specific files based on discovery answers
   - Use Grep tool to search for similar features and existing implementations
   - Use mcp__RepoPrompt__set_selection and read_selected_files (if available) to batch read relevant code
   - Use Read tool to analyze specific files identified from searches
   - Deep dive into similar features and patterns
   - Analyze specific implementation details

9. **External research** (when needed):
   - Use WebSearch for best practices or library documentation
   - Research patterns and approaches relevant to the feature
   - Gather context on third-party integrations or frameworks

10. **Document findings**:
    - Record all analysis in `03-context-findings.md` including:
    - Specific files that need modification
    - Exact patterns to follow
    - Similar features analyzed in detail
    - Technical constraints and considerations
    - Integration points identified
    - Architecture patterns to leverage

**Activity Logging**: Record context gathering results, files analyzed, and technical insights discovered

### Step 4: Expert Requirements Questions

**Log Progress**: Update task progress to "expert-questions"

**Goal**: Ask expert-level questions with deep codebase understanding

11. **Generate expert-level questions**:
    - Write the top 5 most pressing detailed questions to `04-detail-questions.md`
    - Ask questions like a senior developer who knows the codebase intimately
    - Questions should be as if speaking to the product manager who knows nothing of the code
    - Focus on clarifying expected system behavior now that you have deep code understanding
    - Include smart defaults based on discovered codebase patterns
    - Format as clear yes/no or specific choice questions

12. **Interactive expert clarification**:
    - Present questions ONE at a time with technical context
    - Show: question + smart default + reasoning based on codebase analysis
    - Wait for user confirmation/override before proceeding
    - Only after ALL questions are asked, record answers in `05-detail-answers.md`
    - Update `metadata.json` with expert question completion status

**Activity Logging**: Record expert questions generated, user decisions, and final clarifications

### Step 5: Requirements Documentation

**Log Progress**: Update task progress to "requirements-spec"

**Goal**: Create comprehensive, actionable requirements specification

13. **Generate requirements specification**:
    - Create comprehensive spec in `06-requirements-spec.md` including:
    - Problem statement and solution overview
    - Functional requirements based on all discovery and expert answers
    - Technical requirements with specific file paths and components
    - Implementation hints and patterns to follow from codebase analysis
    - Acceptance criteria with measurable outcomes
    - Assumptions for any unanswered questions
    - Integration requirements and constraints
    - Performance and scalability considerations

**Activity Logging**: Record requirements specification generation and completeness validation

### Step 6: Design Document Creation

**Log Progress**: Update task progress to "design-document"

**Goal**: Generate comprehensive design document based on gathered requirements

14. **Generate design document**:
    - Create detailed design document in `07-design-document.md`
    - Base design on requirements from `06-requirements-spec.md`
    - Include:
      - System architecture and component design
      - Data flow and interaction patterns
      - API specifications and interfaces
      - Database schema changes (if applicable)
      - UI/UX considerations and mockups
      - Error handling and edge cases
      - Testing strategy and approach
      - Implementation timeline and milestones
      - Risk assessment and mitigation strategies

**Activity Logging**: Record design document creation and final deliverable completion

---

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 7: Complete Task and Update Metrics

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive design document summary and deliverables
3. **Update Workspace Metrics**: Refresh counters and statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Workspace Timestamp**: Set `last_updated` in workspace config

### Step 8: Generate Artifacts

1. **Save Design Report**: Create `design-document-{timestamp}.md` in reports directory
2. **Update Project Metadata**: Update `last_synced` if applicable
3. **Log Task Completion**: Record final activity entry with outcomes and deliverables

---

## Important Rules:
- ONE question at a time
- Write ALL questions to file BEFORE asking any
- Stay focused on requirements (no implementation)
- Use actual file paths and component names in detail phase
- Document WHY each default makes sense
- Use tools available if recommended ones aren't installed or available

## Metadata Structure:
```json
{
  "id": "feature-slug",
  "started": "ISO-8601-timestamp",
  "lastUpdated": "ISO-8601-timestamp",
  "status": "active",
  "phase": "discovery|context|detail|complete",
  "progress": {
    "discovery": { "answered": 0, "total": 5 },
    "detail": { "answered": 0, "total": 0 }
  },
  "contextFiles": ["paths/of/files/analyzed"],
  "relatedFeatures": ["similar features found"]
}
```

## Smart Defaults Strategy:
- **Business Logic**: Mirror patterns from similar features in codebase
- **Technical Approach**: Follow established architectural patterns and conventions
- **UI/UX**: Use existing design system components and interaction patterns
- **Data Handling**: Apply current data modeling and API design approaches
- **Integration**: Leverage existing service communication patterns
- **Performance**: Follow current optimization and caching strategies

## Phase Transitions:
- After each phase, announce: "Phase complete. Starting [next phase]..."
- Save all work before moving to next phase
- Log phase completion in activity log with progress summary

## Usage Examples

**Basic Design Document:**
"Create design document for add user profile functionality"

**Feature Enhancement:**
"Create design document for implementing advanced search filters on the products page"

**API Design:**
"Create design document for new REST API endpoints for order management"

**UI Component Design:**
"Create design document for reusable notification system component"

## Expected Outcomes

After completing this workflow:

1. **Comprehensive Design Document**: Detailed technical design with architecture, APIs, and implementation guidance
2. **Complete Requirements Analysis**: Thorough understanding of business and technical requirements
3. **Complete Activity Trail**: Full audit log of design process, decisions, and user interactions
4. **Task Coordination**: Other agents can see design document status and outcomes
5. **Actionable Specifications**: Clear requirements and design ready for implementation
6. **Workspace Integration**: Design document integrated with overall development metrics
7. **Report Generation**: Structured report available for stakeholders and development teams

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark task as "failed" with error context
- **Continue Where Possible**: Complete remaining analysis and documentation steps
- **Provide Recovery Guidance**: Offer specific steps to resolve issues
- **Maintain State**: Ensure partial progress and decisions are not lost

## Usage with Claude Code

To execute this workflow:

> "Create design document for user authentication improvements"

> "Create design document for implementing real-time notifications"

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the design document creation process.
