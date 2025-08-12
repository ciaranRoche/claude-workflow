#\!/bin/bash

CONFIG_FILE="workspace-config.json"

while IFS= read -r project_data; do
    alias=$(echo "$project_data" | jq -r '.alias')
    branch=$(echo "$project_data" | jq -r '.branch')
    local_path=$(echo "$project_data" | jq -r '.local_path' | sed 's|^\./||')
    
    echo "=== Processing $alias ==="
    cd "/home/croche/Work/projects/$local_path"
    
    # Fetch all remotes
    echo "  Fetching all remotes..."
    git fetch --all --quiet 2>/dev/null || true
    
    # Check current branch
    current_branch=$(git branch --show-current)
    echo "  Current branch: $current_branch"
    echo "  Target branch: $branch"
    
    # Checkout target branch
    if [ "$current_branch" \!= "$branch" ]; then
        if git show-ref --verify --quiet refs/heads/$branch; then
            echo "  ✅ Checking out existing local branch: $branch"
            git checkout "$branch" --quiet
        elif git show-ref --verify --quiet refs/remotes/origin/$branch; then
            echo "  ✅ Creating and checking out branch from origin: $branch"
            git checkout -b "$branch" "origin/$branch" --quiet
        else
            echo "  ⚠️  Branch $branch not found, staying on $current_branch"
        fi
    else
        echo "  ✅ Already on target branch: $branch"
    fi
    
    cd - >/dev/null
    echo ""
done < <(jq -c '.projects[]' "$CONFIG_FILE")

echo "Branch checkout complete\!"
