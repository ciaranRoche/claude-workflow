#\!/bin/bash

# Generate unique agent ID and current timestamp
AGENT_ID="claude-agent-$(date +%s)000"
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create the new task entry
NEW_TASK='{
  "id": "task-2025-07-31-1140-project-setup",
  "type": "project-setup",
  "project": "workspace", 
  "title": "Prime all workspace projects",
  "status": "completed",
  "completed": "'$CURRENT_TIME'",
  "assigned_agent": "'$AGENT_ID'",
  "created": "'$CURRENT_TIME'",
  "last_activity": "'$CURRENT_TIME'",
  "context": {
    "workspace_config": "workspace-config.json",
    "projects_count": 11
  },
  "progress": {
    "completed_steps": ["bootstrap-initialization", "workspace-config-read", "directory-structure", "project-cloning", "remote-configuration", "branch-checkout", "metadata-update", "verification"],
    "current_step": "completed", 
    "remaining_steps": []
  },
  "results": {
    "projects_configured": 11,
    "projects_cloned": 2,
    "projects_verified": 9,
    "remotes_configured": 22,
    "branches_verified": 10,
    "metadata_updated": true,
    "workspace_config_updated": true,
    "new_projects_cloned": ["app-interface", "ocm-service-common"],
    "verification_status": "10_of_11_projects_fully_operational",
    "outstanding_issue": "ocm-common branch handled by another agent"
  }
}'

# Add the task to active_tasks array and update metrics
jq --argjson task "$NEW_TASK" '
  .active_tasks += [$task] |
  .metrics.total_tasks += 1 |
  .metrics.completed_tasks += 1 |
  .metrics.tasks_by_type["project-setup"] += 1 |
  .metrics.tasks_by_project.workspace += 1 |
  .workspace.last_updated = "'$CURRENT_TIME'"
' workspace-activity.json > workspace-activity-updated.json

# Replace original with updated version
mv workspace-activity-updated.json workspace-activity.json

echo "✅ Added project setup task to workspace-activity.json"
echo "   Task ID: task-2025-07-31-1140-project-setup"
echo "   Agent ID: $AGENT_ID"
echo "   Status: completed"
