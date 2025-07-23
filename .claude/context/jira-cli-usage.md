# JIRA CLI Usage Context

This file contains JIRA CLI usage instructions and context for Claude Code workflows.

## Overview

The JIRA CLI provides command-line access to JIRA issues and operations. Most commands will open an interactive mode or output formatted results by default.

**Key Flags:**
- `--no-input` - Disable interactive mode for commands like edit
- `--raw` - Output raw JSON instead of formatted results for commands like list and view
- `--plain` - Output plain text format (useful for saving to files)

## Issue Listing and Querying

### Basic Issue Listing
```bash
# List recent issues
jira issue list

# List issues in specific status
jira issue list -s "To Do"

# List issues in raw JSON format
jira issue list --raw

# Limit results with pagination
jira issue list --paginate 20          # Limit to 20 items
jira issue list --paginate 10:50       # Get 50 items starting from 10
```

### JQL Queries
```bash
# List issues with JQL query
jira issue list -q 'project=OCM'

# Complex vulnerability tracking query
jira issue list -q 'project=OCM AND (issuetype="Vulnerability" OR (issuetype="Bug" and labels="SecurityTracking")) AND (summary~"{CVE_ID}" OR summary~"{SOFTWARE_NAME}")'
```

## Issue Viewing and Details

### View Issue Information
```bash
# View issue in formatted output
jira issue view ISSUE-1

# View issue in raw JSON format
jira issue view ISSUE-1 --raw

# View issue in plain text (good for saving to files)
jira issue view ISSUE-1 --plain

# View issue with comments
jira issue view ISSUE-1 --comments --plain
```

## Issue Assignment

### Assign and Unassign Issues
```bash
# Assign issue to user
jira issue assign ISSUE-1 "Jon Doe"

# Unassign issue (use 'x' as placeholder)
jira issue assign ISSUE-1 x
```

## Issue Editing and Metadata

### Labels and Components
```bash
# Add labels and components
jira issue edit ISSUE-1 --label p1 --no-input
jira issue edit ISSUE-1 --label p2 --component example-component1 --component example-component2 --no-input

# Remove labels and components (prefix with '-')
jira issue edit ISSUE-1 --label -p1 --no-input
jira issue edit ISSUE-1 --label -p2 --component -example-component1 --component -example-component2 --no-input
```

## Comments

### Adding Comments
```bash
# Add simple comment (supports markdown)
jira issue comment add ISSUE-1 "My comment body"

# Add multi-line comment
jira issue comment add ISSUE-1 $'Supports\n\nNew line'
```

## Issue Creation and Linking

### Create Sub-tasks
```bash
# Create sub-task with parent issue
jira issue create -t "Sub-task" -P ISSUE-1 -s "My issue summary/title" -b $'My issue description\n\nSupports Newline only with single quotes' -C example-component1 -C example-component2 --no-input
```

### Link Issues
```bash
# Link two issues
jira issue link ISSUE-1 ISSUE-2 link_type
```

**Available Link Types:**
- `Account` - Account relationship
- `Blocks` - Blocking relationship
- `Causality` - Cause and effect
- `Cloners` - Cloning relationship
- `Depend` - Dependency relationship
- `Document` - Documentation relationship
- `Duplicate` - Duplicate issues
- `Incorporates` - Incorporation relationship
- `Informs` - Information relationship
- `Issue split` - Issue splitting
- `Related` - General relationship
- `Triggers` - Triggering relationship

## Issue State Management

### Move Issues Between States
```bash
# Move issue to "In Progress"
jira issue move ISSUE-1 "In Progress"

# Close issue with resolution and comment
jira issue move ISSUE-1 "Closed" -R "Not a Bug" --comment $"Multi-line string
summarizing the reason for closing.\n\nBe detailed."
```

**Available Resolution Values:**
- `Done` - Work completed successfully
- `Won't Do` - Work will not be completed
- `Cannot Reproduce` - Issue cannot be reproduced
- `Can't Do` - Work cannot be completed due to constraints
- `Duplicate` - Duplicate of another issue
- `Not a Bug` - Issue is not actually a bug
- `Done-Errata` - Completed with errata
- `MirrorOrphan` - Mirror orphan issue
- `Test Pending` - Waiting for testing
- `Obsolete` - Issue is no longer relevant

## Important Notes

⚠️ **State Transitions**: The possible states are specific to the issue type and project configuration. If you encounter an error because the provided state is not supported, ask the user for the correct state string rather than attempting to create one.

💡 **Interactive Mode**: Always use `--no-input` flag when automating commands to avoid interactive prompts that could hang the process.

📄 **Output Formats**: Use `--raw` for JSON output when you need to parse results programmatically, or `--plain` for human-readable text that can be saved to files.
