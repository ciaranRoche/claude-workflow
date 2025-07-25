# Query Logging Command for Claude Code

This command allows users to submit general queries while maintaining comprehensive activity logging for tracking all questions and inquiries made in the workspace.

## Prerequisites

- Ensure `workspace-activity.json` exists in the workspace root
- Workspace is properly initialized with activity logging
- User has permissions to read and modify workspace files

## MANDATORY FIRST STEPS: Activity Log Integration

### Step 0A: Bootstrap Initialization
1. **Read Bootstrap Instructions**: Load `.claude/bootstrap.md` for mandatory setup
2. **Load Global Configuration**: Read `.claude/config.md` for workspace protocols
3. **Validate Workspace Structure**: Confirm all required files and directories exist

### Step 0B: Activity Log Initialization
1. **Initialize Activity Log**: Read or create `workspace-activity.json`
2. **Register Agent Session**: Create unique agent ID (`claude-agent-{timestamp}`)
3. **Check Active Tasks**: Review existing tasks to prevent conflicts
4. **Create Query Task**: Generate new task with type "user-query"

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-user-query",
  "type": "user-query",
  "project": "workspace",
  "title": "Process user query: {query-summary}",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-24T10:00:00Z",
  "last_activity": "2025-07-24T14:30:00Z",
  "context": {
    "query_text": "{full-user-query}",
    "query_type": "general|technical|project-specific|documentation",
    "estimated_complexity": "simple|moderate|complex",
    "related_projects": []
  },
  "progress": {
    "completed_steps": [],
    "current_step": "query-analysis",
    "remaining_steps": ["query-analysis", "context-gathering", "response-generation", "follow-up-logging"]
  }
}
```

## Core Workflow Steps

### Step 1: Query Analysis and Classification

**Log Progress**: Update task progress to "query-analysis"

Analyze the user's query to understand:
1. **Query Type Classification**:
   - **General**: Basic questions or information requests
   - **Technical**: Code-related, debugging, or implementation questions
   - **Project-Specific**: Questions about specific projects in the workspace
   - **Documentation**: Requests for documentation or explanations
   - **Troubleshooting**: Error resolution or problem-solving queries

2. **Complexity Assessment**:
   - **Simple**: Single-step answers, basic information
   - **Moderate**: Multi-step responses, some research required
   - **Complex**: Deep analysis, multiple components, extended research

3. **Context Requirements**:
   - Identify if query requires project-specific context
   - Determine if codebase analysis is needed
   - Check if external resources or documentation needed

**Activity Logging**: Record query classification and analysis results

### Step 2: Context Gathering

**Log Progress**: Update task progress to "context-gathering"

Based on query analysis, gather relevant context:

#### 2A: Project Context (if needed)
- Load relevant project configurations from `workspace-config.json`
- Read project-specific `claude.md` files
- Navigate to relevant project directories
- Load recent project activity history

#### 2B: Workspace Context
- Review recent workspace activities
- Check for related previous queries
- Load relevant configuration files
- Identify any dependencies or prerequisites

#### 2C: External Context (if needed)
- Search codebase for relevant files or patterns
- Load documentation or README files
- Check for related issues or tasks

**Activity Logging**: Record context gathering steps and sources accessed

### Step 3: Response Generation

**Log Progress**: Update task progress to "response-generation"

Generate comprehensive response to user query:

#### 3A: Direct Answer
Provide clear, actionable response to the user's specific question

#### 3B: Additional Context
Include relevant background information, examples, or related concepts

#### 3C: Follow-up Suggestions
Suggest related queries, next steps, or additional resources

#### 3D: Documentation Links
Reference relevant files, documentation, or resources in the workspace

**Activity Logging**: Record response generation process and key points covered

### Step 4: Query Logging and Follow-up

**Log Progress**: Update task progress to "follow-up-logging"

Complete the query tracking process:

#### 4A: Enhanced Query Record
Update the task context with:
- Final response summary
- Resources accessed during research
- Time spent on query resolution
- Difficulty level encountered vs. estimated

#### 4B: Query Pattern Tracking
Add query to workspace metrics for:
- Query frequency by type
- Common question patterns
- User learning progression
- Knowledge gap identification

#### 4C: Follow-up Recommendations
Log suggestions for:
- Related documentation to create
- Common patterns to document
- Training or learning resources
- Process improvements

**Activity Logging**: Record final query processing results and recommendations

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 5: Complete Query Task and Update Metrics

1. **Mark Query Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive query resolution summary
3. **Update Query Metrics**: Add to query tracking statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Last Activity**: Set current timestamp for workspace activity

### Step 6: Generate Query Summary

1. **Create Query Report**: Generate brief summary of query and resolution
2. **Log Command Completion**: Record final activity entry with outcomes
3. **Display Results**: Show user response and log query tracking confirmation

## Query Metrics and Tracking

### Query Categories Tracked:
- **Type Distribution**: General, technical, project-specific, documentation
- **Complexity Patterns**: Simple vs. complex query trends
- **Resolution Time**: Average time spent per query type
- **Follow-up Frequency**: How often queries lead to additional questions
- **Knowledge Gaps**: Areas where users frequently need help

### Query History Benefits:
- **Learning Pattern Recognition**: Identify user learning progression
- **Documentation Gaps**: Find areas needing better documentation
- **Common Issues**: Track frequently asked questions
- **Workspace Optimization**: Improve tools and processes based on queries
- **Training Opportunities**: Identify areas for user training or guidance

## Usage Examples

**Simple Query:**
"How do I check the git status of a project?"

**Technical Query:**
"Why is my React component not re-rendering when props change?"

**Project-Specific Query:**
"What's the current status of the user authentication feature in the mobile project?"

**Documentation Query:**
"Can you explain how the workspace activity logging system works?"

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark query task as "failed" with error context
- **Provide Guidance**: Offer specific steps to resolve issues
- **Maintain Query Record**: Ensure partial query data is preserved

### Common Issues and Resolutions

**Unclear Query:**
- Request clarification from user
- Log ambiguous query patterns for future improvement
- Provide multiple interpretation options

**Complex Query Requiring Extended Research:**
- Break into sub-queries if possible
- Log intermediate findings
- Provide progress updates for long-running research

**Query Outside Expertise Area:**
- Acknowledge limitations clearly
- Suggest alternative resources or approaches
- Log knowledge gap for future enhancement

## Integration with Other Commands

This query command integrates with:
- **Status Command**: Shows query history and patterns
- **Project Commands**: Provides project-specific context for queries
- **Activity Logging**: Core integration with all workspace operations
- **Documentation Generation**: Uses query patterns to improve documentation

## Expected Outcomes

After completing this workflow:

1. **Complete Query Resolution**: User receives comprehensive answer to their question
2. **Full Activity Trail**: Complete audit log of query processing and research
3. **Enhanced Metrics**: Updated workspace knowledge tracking and patterns
4. **Learning Insights**: Better understanding of user needs and knowledge gaps
5. **Process Improvement**: Data for optimizing workspace tools and documentation

## Usage with Claude Code

To execute this workflow:

> "I have a question about implementing user authentication in my React app"

> "Can you help me understand how to set up CI/CD for my project?"

> "/query How do I debug memory leaks in Node.js?" (if configured as slash command)

Claude Code will automatically integrate with the activity logging system and provide comprehensive query processing with complete tracking for workspace optimization.