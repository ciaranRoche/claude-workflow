# Code Review Workflow for Claude Code

This workflow guides Claude Code through conducting a comprehensive code review of commits from a fork, with mandatory activity logging integration.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
- SSH keys are configured for the target platform (GitHub/GitLab)
- Git is installed and configured
- Target project must be set up through the project priming workflow

## MANDATORY FIRST STEPS: Activity Log Integration

### Step 0A: Bootstrap Initialization
1. **Read Bootstrap Instructions**: Load `.claude/bootstrap.md` for mandatory setup
2. **Load Global Configuration**: Read `.claude/config.md` for workspace protocols
3. **Validate Workspace Structure**: Confirm all required files and directories exist

### Step 0B: Activity Log Initialization
1. **Initialize Activity Log**: Read or create `workspace-activity.json`
2. **Register Agent Session**: Create unique agent ID (`claude-agent-{timestamp}`)
3. **Check Active Tasks**: Review existing tasks to prevent conflicts
4. **Create Code Review Task**: Generate new task with type "code-review"

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-code-review",
  "type": "code-review",
  "project": "{project-alias}",
  "title": "Review {fork-owner}/{branch} - {commit-count} commits",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-23T10:00:00Z",
  "last_activity": "2025-07-23T14:30:00Z",
  "context": {
    "fork_owner": "{fork-owner}",
    "branch": "{branch-name}",
    "commits": "{commit-count}",
    "project_alias": "{project-alias}"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "project-validation",
    "remaining_steps": ["project-validation", "directory-navigation", "branch-update", "fork-configuration", "branch-checkout", "commit-analysis", "code-review", "integration-analysis", "summary-generation"]
  }
}
```

## Core Workflow Steps

### Step 1: Read Workspace Configuration and Validate Project

**Log Progress**: Update task progress to "project-validation"

Claude, please read the `workspace-config.json` file and:

1. Locate the project by its alias (e.g., "cs" for uhc-clusters-service)
2. Verify the project exists in the workspace configuration
3. Extract the project's platform (github/gitlab), SSH URLs, and local path
4. Confirm the project directory exists locally
5. **Load Project Context**: Read the project's `claude.md` file for specific guidelines

**Activity Logging**: Record project validation results and any issues found

### Step 2: Navigate to Project Directory

**Log Progress**: Update task progress to "directory-navigation"

Change to the specified project's local directory using the `local_path` from the workspace configuration.

**Activity Logging**: Record directory change and current working directory

### Step 3: Update Main Branch

**Log Progress**: Update task progress to "branch-update"

Update the local main branch with the latest changes:

1. Check out the main branch (use `branch` field from project config, typically "main" or "master")
2. Pull the latest changes from origin
3. Verify the branch is up to date

**Activity Logging**: Record branch update results and any merge conflicts

### Step 4: Configure Fork Remote  

**Log Progress**: Update task progress to "fork-configuration"

Set up the fork remote for review:

1. Check if the fork remote already exists using `git remote -v`
2. If the remote doesn't exist, add it using the appropriate SSH URL format:
   - For GitHub projects: `git@github.com:<fork-owner>/<repo-name>.git`
   - For GitLab projects: `git@gitlab.cee.redhat.com:<fork-owner>/<repo-name>.git`
3. Use the project's platform and repository name from the workspace config
4. Name the remote after the fork owner for clarity

**Activity Logging**: Record remote configuration changes and any SSH key issues

### Step 5: Fetch Fork and Checkout Branch

**Log Progress**: Update task progress to "branch-checkout"

Fetch the fork and prepare for review:

1. Fetch all branches from the fork remote: `git fetch <fork-owner>`
2. List available branches from the fork to confirm the target branch exists
3. Checkout the specified branch: `git checkout <fork-owner>/<branch-name>`
4. Verify you're on the correct branch and commit

**Activity Logging**: Record branch checkout results and current commit hash

### Step 6: Analyze Commit Range

**Log Progress**: Update task progress to "commit-analysis"

Determine and display the commits to review:

1. Show the commit log for the specified number of commits (default: 1)
2. Display one-line summaries: `git log --oneline -<commit-count>`
3. Show the diff statistics: `git diff --stat HEAD~<commit-count>..HEAD`
4. Identify the files that will be analyzed

**Activity Logging**: Record commit range, file list, and diff statistics

### Step 7: Comprehensive Code Review

**Log Progress**: Update task progress to "code-review"

For each commit in the specified range, perform detailed analysis:

#### Code Quality Analysis
- **Style Consistency**: Check adherence to project coding standards and patterns
- **Readability**: Assess code clarity, naming conventions, and structure
- **Maintainability**: Evaluate code organization, complexity, and technical debt
- **Architecture**: Review design patterns and integration with existing codebase

#### Security Review
- **Vulnerability Assessment**: Scan for common security issues (SQL injection, XSS, etc.)
- **Credential Safety**: Check for hardcoded secrets, API keys, or sensitive data
- **Input Validation**: Review data sanitization and validation practices
- **Authentication/Authorization**: Verify proper access controls

#### Performance Analysis
- **Efficiency**: Identify potential bottlenecks and optimization opportunities
- **Resource Usage**: Review memory, CPU, and I/O considerations
- **Scalability**: Assess impact on system performance under load
- **Database Queries**: Analyze query efficiency and N+1 problems

#### Testing Evaluation
- **Test Coverage**: Identify gaps in unit, integration, and end-to-end tests
- **Test Quality**: Review test structure, assertions, and edge case coverage
- **Mocking Strategy**: Evaluate proper use of mocks and test isolation
- **Test Maintainability**: Assess test code quality and documentation

#### Documentation Review
- **Code Comments**: Check for clear, necessary, and up-to-date comments
- **API Documentation**: Verify proper documentation of public interfaces
- **README Updates**: Ensure documentation reflects code changes
- **Change Documentation**: Review commit messages and PR descriptions

**Activity Logging**: Record findings for each analysis category with severity levels

### Step 8: Integration Analysis

**Log Progress**: Update task progress to "integration-analysis"

Assess how the changes integrate with the existing codebase:

1. **Dependency Impact**: Review changes to dependencies and their implications
2. **API Compatibility**: Check for breaking changes to public interfaces
3. **Database Changes**: Analyze schema changes and migration strategies
4. **Configuration Changes**: Review environment and configuration updates

**Activity Logging**: Record integration concerns and compatibility issues

### Step 9: Generate Review Summary

**Log Progress**: Update task progress to "summary-generation"

Create a comprehensive review report including:

1. **Executive Summary**: High-level assessment and recommendation
2. **Critical Issues**: Security vulnerabilities and breaking changes
3. **Major Concerns**: Performance issues and architectural problems
4. **Minor Issues**: Style violations and improvement suggestions
5. **Positive Aspects**: Well-implemented features and good practices
6. **Action Items**: Specific recommendations for improvement

**Activity Logging**: Record summary generation and save report location

### Step 10: Cleanup

After completing the review:

1. Return to the main branch: `git checkout <main-branch>`
2. Clean up any temporary files or state
3. Optionally remove the fork remote if it was temporarily added

**Activity Logging**: Record cleanup actions and final repository state

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 11: Complete Task and Update Metrics

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive review summary and recommendations
3. **Update Workspace Metrics**: Refresh counters and statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Workspace Timestamp**: Set `last_updated` in workspace config

### Step 12: Generate Artifacts

1. **Save Review Report**: Create `code-review-{timestamp}.md` in reports directory
2. **Update Project Metadata**: Update `last_synced` if applicable
3. **Log Task Completion**: Record final activity entry with outcomes

## Usage Examples

**Basic Review:**
"Review the latest commit from user123's feature-branch fork on the cs project"

**Multi-commit Review:**
"Review the last 3 commits from john-doe's refactor-api branch on the web-service project"

**Specific Project Review:**
"Review 5 commits from alice's performance-improvements branch on the mobile project"

## Project-Specific Considerations

### For GitLab Projects (like uhc-clusters-service)
- Use GitLab SSH URL format: `git@gitlab.cee.redhat.com:<fork-owner>/<repo-name>.git`
- Consider GitLab-specific CI/CD pipeline impacts
- Review GitLab merge request templates and compliance
- Apply project-specific guidelines from project's `claude.md`

### For GitHub Projects
- Use GitHub SSH URL format: `git@github.com:<fork-owner>/<repo-name>.git`
- Consider GitHub Actions workflow impacts
- Review pull request templates and checks
- Apply project-specific guidelines from project's `claude.md`

## Expected Outcomes

After completing this workflow:

1. **Comprehensive Code Analysis**: Detailed security, performance, and quality review
2. **Complete Activity Trail**: Full audit log of review process and findings
3. **Task Coordination**: Other agents can see review status and results
4. **Actionable Feedback**: Clear recommendations for the developer
5. **Workspace Integration**: Review integrated with overall development metrics
6. **Report Generation**: Structured report available for stakeholders

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark task as "failed" with error context
- **Continue Where Possible**: Complete remaining analysis steps
- **Provide Recovery Guidance**: Offer specific steps to resolve issues
- **Maintain State**: Ensure partial progress is not lost

## Usage with Claude Code

To execute this workflow:

> "Review 3 commits from alice's new-feature branch on the cs project"

> "Review the latest commit from bob's bugfix-auth branch on the api-service project"

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the review process.