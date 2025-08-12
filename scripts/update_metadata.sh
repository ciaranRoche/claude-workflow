#\!/bin/bash

# Get current timestamp in ISO format
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Update workspace config with current timestamp for all projects
jq --arg time "$CURRENT_TIME" '
  .projects[] |= (.last_synced = $time) |
  .metadata.last_updated = $time |
  .metadata.total_projects = (.projects | length) |
  .metadata.active_projects = ([.projects[] | select(.active == true)] | length)
' workspace-config.json > workspace-config-updated.json

# Replace original with updated version
mv workspace-config-updated.json workspace-config.json

echo "✅ Updated workspace configuration with:"
echo "  - Last synced: $CURRENT_TIME"
echo "  - Total projects: $(jq '.metadata.total_projects' workspace-config.json)"
echo "  - Active projects: $(jq '.metadata.active_projects' workspace-config.json)"
