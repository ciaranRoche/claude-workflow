#\!/bin/bash

echo "======================================="
echo "    WORKSPACE PRIMING VERIFICATION"
echo "======================================="
echo

# 1. Project Count Verification
echo "📊 PROJECT COUNT VERIFICATION"
echo "   Expected: 11 projects"
echo "   Actual: $(ls -1 projects/ | wc -l) projects"
echo "   Status: $([ $(ls -1 projects/ | wc -l) -eq 11 ] && echo "✅ PASS" || echo "❌ FAIL")"
echo

# 2. Git Repository Verification
echo "🔧 GIT REPOSITORY VERIFICATION"
failed_repos=0
for dir in projects/*/; do
    project=$(basename "$dir")
    if [ -d "$dir/.git" ]; then
        echo "   ✅ $project: Git repository exists"
    else
        echo "   ❌ $project: Missing .git directory"
        ((failed_repos++))
    fi
done
echo "   Status: $([ $failed_repos -eq 0 ] && echo "✅ ALL PASS" || echo "❌ $failed_repos FAILED")"
echo

# 3. Remote Configuration Verification
echo "🌐 REMOTE CONFIGURATION VERIFICATION"
failed_remotes=0
while IFS= read -r project_data; do
    alias=$(echo "$project_data" | jq -r '.alias')
    platform=$(echo "$project_data" | jq -r '.platform')
    local_path=$(echo "$project_data" | jq -r '.local_path' | sed 's|^\./||')
    
    cd "/home/croche/Work/projects/$local_path"
    
    # Check origin remote
    origin_url=$(git remote get-url origin 2>/dev/null || echo "MISSING")
    if [ "$origin_url" \!= "MISSING" ]; then
        echo "   ✅ $alias: origin configured"
    else
        echo "   ❌ $alias: origin missing"
        ((failed_remotes++))
    fi
    
    # Check user fork remote
    if [ "$platform" = "github" ]; then
        fork_url=$(git remote get-url ciaranRoche 2>/dev/null || echo "MISSING")
        fork_name="ciaranRoche"
    else
        fork_url=$(git remote get-url croche 2>/dev/null || echo "MISSING")
        fork_name="croche"
    fi
    
    if [ "$fork_url" \!= "MISSING" ]; then
        echo "   ✅ $alias: $fork_name fork configured"
    else
        echo "   ❌ $alias: $fork_name fork missing"
        ((failed_remotes++))
    fi
    
    cd - >/dev/null
done < <(jq -c '.projects[]' workspace-config.json)
echo "   Status: $([ $failed_remotes -eq 0 ] && echo "✅ ALL PASS" || echo "❌ $failed_remotes FAILED")"
echo

# 4. Branch Verification
echo "🌿 BRANCH VERIFICATION"
failed_branches=0
while IFS= read -r project_data; do
    alias=$(echo "$project_data" | jq -r '.alias')
    expected_branch=$(echo "$project_data" | jq -r '.branch')
    local_path=$(echo "$project_data" | jq -r '.local_path' | sed 's|^\./||')
    
    cd "/home/croche/Work/projects/$local_path"
    current_branch=$(git branch --show-current)
    
    if [ "$current_branch" = "$expected_branch" ]; then
        echo "   ✅ $alias: on $current_branch (expected: $expected_branch)"
    else
        echo "   ❌ $alias: on $current_branch (expected: $expected_branch)"
        ((failed_branches++))
    fi
    
    cd - >/dev/null
done < <(jq -c '.projects[]' workspace-config.json)
echo "   Status: $([ $failed_branches -eq 0 ] && echo "✅ ALL PASS" || echo "❌ $failed_branches FAILED")"
echo

# 5. Metadata Verification
echo "📋 METADATA VERIFICATION"
total_projects=$(jq '.metadata.total_projects' workspace-config.json)
active_projects=$(jq '.metadata.active_projects' workspace-config.json)
last_updated=$(jq -r '.metadata.last_updated' workspace-config.json)

echo "   Total projects: $total_projects"
echo "   Active projects: $active_projects"
echo "   Last updated: $last_updated"
echo "   Status: ✅ METADATA UPDATED"
echo

# Final Summary
echo "======================================="
echo "           FINAL SUMMARY"
echo "======================================="
if [ $failed_repos -eq 0 ] && [ $failed_remotes -eq 0 ] && [ $failed_branches -eq 0 ]; then
    echo "   🎉 WORKSPACE PRIMING COMPLETED SUCCESSFULLY\!"
    echo "   All 11 projects are properly configured and ready for development."
else
    echo "   ⚠️  WORKSPACE PRIMING COMPLETED WITH ISSUES"
    echo "   Some projects may need manual attention."
fi
echo
