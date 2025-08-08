# Claude Code Agents Guide

This guide explains how to use the specialized Claude Code agents available in your workspace. These agents are designed to handle specific types of tasks with focused expertise and dedicated system prompts.

## What are Claude Code Agents?

Claude Code agents are specialized AI assistants that operate with specific expertise and focused responsibilities. Each agent:

- **Operates independently** with its own context window separate from the main conversation
- **Has specialized knowledge** for specific types of tasks (documentation, note-taking, code review, etc.)
- **Uses focused system prompts** that define their role and capabilities
- **Can access specific tools** relevant to their specialization
- **Integrates seamlessly** with your existing Claude Code workflow

## Available Agents

### 1. Documentation Sync Specialist (`docs-sync-specialist`)

**Purpose**: Ensures documentation stays synchronized with recent code changes

**When to use**:
- After implementing new features or APIs
- When modifying configuration files or system architecture
- Before releases to ensure docs are current
- When you notice documentation gaps or outdated information

**Examples**:
```
"I just finished implementing JWT authentication in the auth service"
"I updated the user table schema to include new fields for profile data"
"Can you review the recent API changes and update the documentation?"
```

**What it does**:
- Analyzes recent commits and code changes (last 7-14 days)
- Identifies documentation that needs updates
- Updates existing docs rather than creating new ones
- Ensures examples and code snippets reflect current implementation
- Maintains consistency in terminology and formatting
- Updates version numbers and changelog entries

### 2. Conversation Note Taker (`conversation-note-taker`)

**Purpose**: Captures and organizes key information from conversations into structured notes

**When to use**:
- After meaningful technical discussions
- Following architectural decision sessions
- When you want to preserve problem-solving insights
- To document decisions and trade-offs for future reference

**Examples**:
```
"That was a helpful discussion about database optimization. Can you summarize the key points?"
"We covered a lot of ground on the microservices approach. I want to preserve the trade-offs we discussed."
"Can you document the architectural decisions we made?"
```

**What it does**:
- Extracts key insights, decisions, and action items from conversations
- Creates structured notes with clear hierarchy and organization
- Highlights actionable items that require follow-up
- Includes sufficient context for future reference
- Saves notes with descriptive filenames including date and topic

## How to Use Agents

### Automatic Delegation

Claude Code can automatically delegate tasks to the appropriate agent based on:
- Your task description
- The agent's specialized description
- Available context and tools

Simply describe what you need, and Claude Code will invoke the appropriate agent:

```
"I need to update documentation after adding the new payment API"
→ Automatically uses docs-sync-specialist

"Can you summarize our discussion about the database schema changes?"
→ Automatically uses conversation-note-taker
```

### Explicit Invocation

You can explicitly request a specific agent:

```
"Use the docs-sync-specialist to review recent changes"
"Have the conversation-note-taker document this discussion"
```

## Agent File Structure

Agents are defined using Markdown files with YAML frontmatter located in `.claude/agents/`:

```markdown
---
name: agent-name
description: When this agent should be invoked
color: visual-identifier-color
---

System prompt defining the agent's role and capabilities
```

### Key Configuration Fields

- **`name`**: Unique identifier (lowercase, hyphen-separated)
- **`description`**: Detailed explanation of when to use this agent
- **`color`**: Visual identifier for the agent in Claude Code interface
- **System prompt**: Detailed instructions defining the agent's expertise and behavior

## Best Practices

### When to Use Agents

✅ **Use agents when**:
- You have a specific, focused task that matches an agent's expertise
- You need specialized knowledge or approach for the task
- The task benefits from dedicated context and tools
- You want to preserve main conversation context for other work

❌ **Don't use agents when**:
- The task is simple and general
- You need broad, multi-domain assistance
- The overhead of agent delegation isn't justified
- You're in an exploratory conversation phase

### Choosing the Right Agent

1. **docs-sync-specialist**: For any documentation-related work, especially after code changes
2. **conversation-note-taker**: For capturing and organizing discussion outcomes
3. **Main Claude Code**: For general development, exploratory work, and multi-domain tasks

### Working with Agent Output

- **Review agent recommendations**: Agents provide specialized insights, but you decide what to implement
- **Maintain context**: Important decisions made by agents are preserved in your main conversation
- **Follow up appropriately**: Agent work may require additional actions in your main workflow

## Integration with Workspace Workflow

Agents integrate seamlessly with your existing workspace system:

### Activity Logging
- Agent work is logged in `workspace-activity.json`
- Task tracking includes agent involvement
- Reports include agent contributions

### Project Context
- Agents access project-specific configuration from `claude.md` files
- Project coding standards and conventions are respected
- Integration with existing documentation structure

### Multi-Agent Coordination
- Multiple agents can work together on complex tasks
- Clean handoffs between agents and main Claude Code
- Conflict prevention and resolution

## Creating Custom Agents

To create a new agent for your specific needs:

1. **Identify the specialization**: What specific expertise or task type needs a dedicated agent?

2. **Create the agent file** in `.claude/agents/your-agent-name.md`:
   ```markdown
   ---
   name: your-agent-name
   description: Detailed description of when to use this agent
   color: blue
   ---
   
   Your specialized system prompt defining the agent's role and capabilities
   ```

3. **Follow best practices**:
   - Create focused agents with single responsibilities
   - Write detailed, specific system prompts
   - Include clear usage examples in the description
   - Test the agent with representative tasks

4. **Document the agent**: Update this guide to include your new agent

## Troubleshooting

### Common Issues

**Agent not being invoked automatically**:
- Check that your task description matches the agent's description
- Try explicit invocation using the agent name
- Verify the agent file syntax is correct

**Agent producing unexpected results**:
- Review the agent's system prompt for clarity
- Check if the task truly matches the agent's specialization
- Consider if the main Claude Code would be more appropriate

**Context issues**:
- Agents operate with separate context windows
- Important information may need to be restated for the agent
- Consider summarizing relevant context when invoking agents

### Getting Help

1. **Check agent descriptions**: Review `.claude/agents/` files for detailed usage guidance
2. **Test with simple tasks**: Start with straightforward tasks to understand agent behavior
3. **Use explicit invocation**: If automatic delegation isn't working, try explicit agent requests
4. **Fall back to main Claude Code**: For complex or multi-domain tasks, use the main assistant

## Summary

Claude Code agents provide specialized expertise for specific task types, helping you:

- **Maintain documentation** that stays current with code changes
- **Capture important insights** from technical discussions
- **Work more efficiently** with focused, expert assistance
- **Preserve context** for complex, multi-step workflows

Choose agents based on your specific needs, and don't hesitate to use the main Claude Code for general development and exploration work.

---

**Related Documentation**:
- [Claude Code Workspace Documentation](README.md)
- [Workspace Integration Guide](integration/workspace-integration.md)
- [CLAUDE.md Workspace Configuration](../CLAUDE.md)

**Agent Files Location**: `.claude/agents/`