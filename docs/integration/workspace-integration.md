# Workspace Integration Guide

Comprehensive guide to how CLI tools integrate with Claude Code workspace commands and workflows.

## Overview

The Claude Code workspace uses external CLI tools to interact with services like GitHub and JIRA. This integration enables automated workflows for code review, issue management, repository synchronization, and development task management.

## Integration Architecture

### Command Dependencies

Workspace commands are organized by functional areas, each with specific CLI tool requirements:

```
Workspace Commands
├── development/
│   ├── review.md           → GitHub CLI (gh)
│   └── implement-jira.md   → JIRA CLI (jira)
├── workspace/
│   ├── pull.md            → GitHub CLI (gh)
│   ├── prime.md           → GitHub CLI (gh)
│   └── status.md          → GitHub CLI (gh)
├── deployment/
│   └── check-migrations.md → GitHub CLI (gh)
└── design/
    ├── create-design-document.md → GitHub CLI (gh)
    └── review-design-document.md → GitHub CLI (gh), Web Search
```

### CLI Tool Usage Patterns

#### GitHub CLI Integration
- **Authentication**: Uses token-based authentication with repository and organization access
- **Data Flow**: Fetches repository data, pull requests, issues, and manages GitHub API interactions
- **Output Processing**: Commands parse JSON and plain text output from GitHub CLI
- **Error Handling**: Workspace commands handle authentication failures and API rate limits

#### JIRA CLI Integration
- **Authentication**: Uses API tokens or username/password authentication
- **Data Flow**: Fetches issue details, comments, and project metadata
- **Output Processing**: Commands parse plain text output for requirements analysis
- **Error Handling**: Workspace commands handle connection failures and permission issues

## Detailed Command Integration

### Development Commands

#### Code Review (`development/review.md`)

**GitHub CLI Usage**:
```bash
# Commands used by the workspace
gh pr list --limit 20
gh pr view PR_NUMBER
gh pr diff PR_NUMBER
gh pr comment PR_NUMBER --body "Review comment"
gh pr review PR_NUMBER --approve
gh pr review PR_NUMBER --request-changes
```

**Integration Flow**:
1. **Authentication Check**: Verifies GitHub CLI authentication status
2. **Repository Context**: Identifies target repository from workspace configuration
3. **PR Data Fetching**: Retrieves pull request details, files changed, and existing comments
4. **Code Analysis**: Analyzes code changes for security, performance, and style issues
5. **Review Submission**: Posts comments and review decisions back to GitHub

**Required Permissions**:
- `repo` scope for repository access
- `workflow` scope for Actions-related PRs
- Organization membership for organization repositories

#### JIRA Implementation (`development/implement-jira.md`)

**JIRA CLI Usage**:
```bash
# Commands used by the workspace
jira issue view ISSUE-KEY --plain
jira issue view ISSUE-KEY --comments --plain
jira project view PROJECT-KEY
```

**Integration Flow**:
1. **Issue Fetching**: Retrieves comprehensive issue data including description and comments
2. **Requirements Analysis**: Parses JIRA content to extract functional requirements
3. **Context Building**: Analyzes codebase to understand implementation context
4. **Question Generation**: Creates clarification questions based on issue analysis
5. **Implementation Planning**: Converts requirements into actionable development tasks

**Required Permissions**:
- Browse Projects permission
- View Issues permission
- Access to specific projects referenced in workspace

### Workspace Management Commands

#### Workspace Pull (`workspace/pull.md`)

**GitHub CLI Usage**:
```bash
# Repository synchronization commands
gh repo clone OWNER/REPO
gh repo sync
gh pr list --state open
gh pr status
```

**Integration Flow**:
1. **Repository Discovery**: Identifies all repositories from workspace configuration
2. **Branch Analysis**: Checks current branch status and pending changes
3. **Conflict Detection**: Identifies merge conflicts and uncommitted changes
4. **Synchronization**: Pulls latest changes from origin/main
5. **Status Reporting**: Updates workspace activity log with sync results

#### Workspace Prime (`workspace/prime.md`)

**GitHub CLI Usage**:
```bash
# Repository setup commands
gh auth status
gh repo list OWNER --limit 100
gh repo clone OWNER/REPO LOCAL_PATH
gh repo set-default OWNER/REPO
```

**Integration Flow**:
1. **Authentication Verification**: Ensures GitHub CLI is properly authenticated
2. **Repository Cloning**: Clones repositories defined in workspace configuration
3. **Remote Configuration**: Sets up appropriate remote URLs and default repositories
4. **Permission Verification**: Tests access to all configured repositories
5. **Metadata Update**: Updates workspace configuration with setup results

#### Workspace Status (`workspace/status.md`)

**GitHub CLI Usage**:
```bash
# Status checking commands
gh repo list --limit 50
gh pr list --author @me
gh pr status
gh api rate_limit
```

**Integration Flow**:
1. **Repository Status**: Checks synchronization status of all workspace repositories
2. **PR Monitoring**: Identifies pending pull requests and review requests
3. **Activity Summary**: Compiles recent development activity across repositories
4. **Rate Limit Monitoring**: Checks GitHub API rate limit status
5. **Interactive Management**: Provides options to resume or manage active tasks

### Deployment Commands

#### Migration Check (`deployment/check-migrations.md`)

**GitHub CLI Usage**:
```bash
# Migration analysis commands
gh pr list --search "migration" --state all
gh pr diff PR_NUMBER
gh search repos "migration schema" --owner OWNER
gh api repos/OWNER/REPO/compare/v1.2.0...v1.3.0
```

**Integration Flow**:
1. **Migration Detection**: Searches for migration-related pull requests and changes
2. **Version Comparison**: Compares database schema changes between versions
3. **Dependency Analysis**: Identifies migration dependencies and ordering requirements
4. **Risk Assessment**: Evaluates potential deployment risks from schema changes
5. **Approval Workflow**: Generates deployment readiness report

### Design Commands

#### Design Document Creation (`design/create-design-document.md`)

**GitHub CLI Usage**:
```bash
# Design document management
gh issue create --title "Design: Feature Name" --body "Design document"
gh issue list --label "design"
gh issue comment ISSUE_NUMBER --body "Design feedback"
gh pr create --title "Implement: Feature" --body "Implementation PR"
```

**Integration Flow**:
1. **Design Issue Creation**: Creates GitHub issues for design documentation
2. **Template Application**: Uses design document templates from repository
3. **Review Coordination**: Manages design review workflow through GitHub
4. **Implementation Linking**: Links design documents to implementation pull requests
5. **Documentation Updates**: Maintains design documentation throughout development

#### Design Document Review (`design/review-design-document.md`)

**GitHub CLI Usage**:
```bash
# Design review operations
gh search repos "architecture design" --owner OWNER
gh issue list --label "design" --state all
gh pr list --search "design document" --state all
gh api repos/OWNER/REPO/contents/path/to/design-doc.md
```

**Integration Flow**:
1. **Document Discovery**: Locates target design documents from GitHub repositories or local workspace
2. **Alternative Research**: Uses web search and GitHub to research industry best practices and alternative approaches
3. **Expert Consultation**: Creates interactive review questions for stakeholder input
4. **Review Documentation**: Generates comprehensive review reports in the `/reviews` directory
5. **Improvement Recommendations**: Provides prioritized improvement roadmap with implementation guidance

**Output Structure**:
```
reviews/YYYY-MM-DD-HHMM-design-review-{feature}/
├── 00-review-request.md        # Original review request
├── 01-original-design.md       # Copy of design document being reviewed
├── 02-analysis-findings.md     # Structural and technical analysis
├── 03-alternative-research.md  # Industry best practices and alternatives
├── 04-improvement-analysis.md  # Gap analysis and improvements
├── 05-expert-questions.md      # Review questions for stakeholders
├── 06-expert-answers.md        # Stakeholder responses
├── 07-recommendations.md       # Prioritized improvement recommendations
├── 08-review-report.md         # Comprehensive final report
└── metadata.json               # Review tracking and progress
```

## Configuration Management

### Workspace Configuration (`workspace-config.json`)

CLI tools integrate with workspace configuration for:

```json
{
  "projects": {
    "project-alias": {
      "github": {
        "owner": "organization",
        "repository": "repo-name",
        "default_branch": "main"
      },
      "jira": {
        "project_key": "PROJ",
        "server_url": "https://company.atlassian.net"
      }
    }
  }
}
```

**GitHub CLI Configuration**:
- Repository cloning uses `github.owner` and `github.repository`
- Default branch operations use `github.default_branch`
- Organization-specific authentication uses `github.owner`

**JIRA CLI Configuration**:
- Issue operations use `jira.project_key`
- Server connections use `jira.server_url`
- Project-specific queries filter by project key

### Activity Logging Integration

Both CLI tools integrate with the workspace activity logging system:

```json
{
  "active_tasks": [
    {
      "id": "task-2025-07-25-1400-code-review",
      "type": "code-review",
      "github_context": {
        "repository": "owner/repo",
        "pr_number": 123,
        "branch": "feature/new-functionality"
      },
      "cli_operations": [
        "gh pr view 123",
        "gh pr comment 123 --body 'LGTM'"
      ]
    }
  ]
}
```

## Error Handling and Recovery

### Authentication Failures

**GitHub CLI**:
```bash
# Workspace commands handle authentication failures
if ! gh auth status >/dev/null 2>&1; then
    echo "ERROR: GitHub CLI not authenticated"
    echo "Run: gh auth login"
    exit 1
fi
```

**JIRA CLI**:
```bash
# Workspace commands verify JIRA connectivity
if ! jira me >/dev/null 2>&1; then
    echo "ERROR: JIRA CLI not configured or authenticated"
    echo "Run: jira init"
    exit 1
fi
```

### Network and API Issues

**Rate Limit Handling**:
```bash
# GitHub API rate limit checking
rate_limit=$(gh api rate_limit --jq '.rate.remaining')
if [ "$rate_limit" -lt 10 ]; then
    echo "WARNING: GitHub API rate limit low ($rate_limit remaining)"
    sleep 60  # Wait before continuing
fi
```

**Connection Retry Logic**:
```bash
# Retry failed operations with exponential backoff
retry_count=0
max_retries=3

while [ $retry_count -lt $max_retries ]; do
    if gh pr list >/dev/null 2>&1; then
        break
    fi
    retry_count=$((retry_count + 1))
    sleep $((retry_count * 2))
done
```

### Permission and Access Issues

**Repository Access Validation**:
```bash
# Verify repository access before operations
if ! gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
    echo "ERROR: Cannot access repository $OWNER/$REPO"
    echo "Check permissions and repository name"
    exit 1
fi
```

**JIRA Project Access Validation**:
```bash
# Verify project access before issue operations
if ! jira project view "$PROJECT_KEY" >/dev/null 2>&1; then
    echo "ERROR: Cannot access JIRA project $PROJECT_KEY"
    echo "Check permissions and project key"
    exit 1
fi
```

## Performance Optimization

### Efficient API Usage

**GitHub CLI Optimization**:
```bash
# Use pagination and limits to reduce API calls
gh pr list --limit 20 --state open
gh issue list --limit 10 --assignee @me

# Cache frequently accessed data
gh repo list --limit 100 > ~/.cache/gh-repos.txt
```

**JIRA CLI Optimization**:
```bash
# Use specific queries to limit data transfer
jira issue list --jql "project = $PROJECT AND updated >= -7d" --limit 20

# Cache issue data for workspace analysis
jira issue view "$ISSUE_KEY" --plain > "cache/issue-$ISSUE_KEY.txt"
```

### Parallel Operations

```bash
# Process multiple repositories in parallel
for repo in $(cat workspace-repos.txt); do
    (
        echo "Processing $repo..."
        gh repo clone "$repo" "projects/$(basename $repo)"
    ) &
done
wait  # Wait for all background jobs to complete
```

## Security Considerations

### Token Management

**GitHub CLI Tokens**:
- Use tokens with minimal required scopes
- Rotate tokens regularly (quarterly recommended)
- Store tokens securely using system credential managers
- Monitor token usage in GitHub settings

**JIRA CLI Tokens**:
- Create project-specific tokens when possible
- Use descriptive token names for audit trails
- Set expiration dates when supported
- Revoke unused tokens immediately

### Data Handling

**Sensitive Information**:
```bash
# Sanitize output before logging
gh pr view 123 | sed 's/token=[^&]*/token=REDACTED/g'
jira issue view PROJ-123 --plain | sed 's/email@company.com/REDACTED@company.com/g'
```

**Secure Storage**:
```bash
# Ensure secure permissions on workspace files
chmod 600 ~/.config/gh/config.yml
chmod 600 ~/.config/jira-cli/config.yml
chmod 700 ~/.config/workspace/
```

## Testing and Validation

### Integration Testing

**GitHub CLI Test Suite**:
```bash
#!/bin/bash
# Test GitHub CLI integration
echo "Testing GitHub CLI integration..."

# Test authentication
gh auth status || exit 1

# Test repository access
gh repo list --limit 1 || exit 1

# Test PR operations
gh pr list --limit 1 || exit 1

echo "GitHub CLI integration tests passed"
```

**JIRA CLI Test Suite**:
```bash
#!/bin/bash
# Test JIRA CLI integration
echo "Testing JIRA CLI integration..."

# Test authentication
jira me || exit 1

# Test project access
jira project list | head -1 || exit 1

# Test issue operations
jira issue list --limit 1 || exit 1

echo "JIRA CLI integration tests passed"
```

### Continuous Validation

**Daily Health Checks**:
```bash
# Automated health check script
#!/bin/bash
HEALTH_LOG="/tmp/cli-health-$(date +%Y%m%d).log"

echo "$(date): CLI Health Check" >> "$HEALTH_LOG"

# GitHub CLI health
if gh auth status >/dev/null 2>&1; then
    echo "$(date): GitHub CLI - OK" >> "$HEALTH_LOG"
else
    echo "$(date): GitHub CLI - FAILED" >> "$HEALTH_LOG"
fi

# JIRA CLI health
if jira me >/dev/null 2>&1; then
    echo "$(date): JIRA CLI - OK" >> "$HEALTH_LOG"
else
    echo "$(date): JIRA CLI - FAILED" >> "$HEALTH_LOG"
fi
```

## Troubleshooting Integration Issues

### Common Integration Problems

1. **CLI Tool Not Found**:
   - Verify installation using setup guides
   - Check PATH configuration
   - Confirm binary permissions

2. **Authentication Failures**:
   - Re-run authentication setup
   - Verify token permissions and expiration
   - Check organization access settings

3. **Network Connectivity**:
   - Test direct connectivity to services
   - Configure proxy settings if needed
   - Verify firewall rules

4. **Permission Denied**:
   - Verify user permissions in GitHub/JIRA
   - Check repository/project access
   - Confirm token scopes

### Debug Mode

**Enable Debug Output**:
```bash
# GitHub CLI debug mode
export GH_DEBUG=api
gh pr list --limit 1

# JIRA CLI debug mode
jira --debug issue list --limit 1
```

**Workspace Command Debug**:
```bash
# Enable verbose output in workspace commands
export WORKSPACE_DEBUG=1
# Run workspace command with debug information
```

## Further Reading

- **[GitHub CLI Setup Guide](/home/croche/Work/projects/docs/setup/github-cli-setup.md)**
- **[JIRA CLI Setup Guide](/home/croche/Work/projects/docs/setup/jira-cli-setup.md)**
- **[GitHub CLI Troubleshooting](/home/croche/Work/projects/docs/troubleshooting/github-cli-troubleshooting.md)**
- **[JIRA CLI Troubleshooting](/home/croche/Work/projects/docs/troubleshooting/jira-cli-troubleshooting.md)**
- **[Prerequisites Guide](/home/croche/Work/projects/docs/setup/prerequisites.md)**

---

**Note**: This integration guide is maintained to reflect the current state of workspace commands. When adding new commands that require CLI tools, update this documentation to include the new integration patterns and requirements.