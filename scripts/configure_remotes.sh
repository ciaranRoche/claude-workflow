#\!/bin/bash

# Load workspace config
CONFIG_FILE="workspace-config.json"

# Process each project from the config
while IFS= read -r project_data; do
    alias=$(echo "$project_data" | jq -r '.alias')
    platform=$(echo "$project_data" | jq -r '.platform')
    ssh_url=$(echo "$project_data" | jq -r '.ssh_url')
    local_path=$(echo "$project_data" | jq -r '.local_path' | sed 's|^\./||')
    
    echo "=== Configuring $alias ($platform) ==="
    
    cd "/home/croche/Work/projects/$local_path"
    
    # Set origin to upstream repository
    git remote set-url origin "$ssh_url" 2>/dev/null || git remote add origin "$ssh_url"
    
    # Add user fork remote based on platform
    if [ "$platform" = "github" ]; then
        fork_url=$(echo "$ssh_url" | sed 's|openshift-online|ciaranRoche|')
        git remote remove ciaranRoche 2>/dev/null || true
        git remote add ciaranRoche "$fork_url"
        echo "  ✅ Origin: $ssh_url"
        echo "  ✅ Fork (ciaranRoche): $fork_url"
    elif [ "$platform" = "gitlab" ]; then
        fork_url=$(echo "$ssh_url" | sed 's|service/|croche/|' | sed 's|ocm/|croche/|')
        git remote remove croche 2>/dev/null || true
        git remote add croche "$fork_url"
        echo "  ✅ Origin: $ssh_url"
        echo "  ✅ Fork (croche): $fork_url"
    fi
    
    cd - >/dev/null
    echo ""
done < <(jq -c '.projects[]' "$CONFIG_FILE")

echo "Remote configuration complete\!"
