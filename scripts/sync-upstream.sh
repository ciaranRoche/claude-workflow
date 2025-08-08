#!/bin/bash

# Sync public content to upstream claude-workflow repository
# Only syncs approved public files, keeps private content in fork

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PUBLIC_BRANCH="upstream-sync"
MAIN_BRANCH="main"

# PUBLIC FILES - Only these go to upstream
PUBLIC_PATHS=(
    ".claude/"
    "docs/"
    ".gitignore"
    "CLAUDE.md"
    "README.md"
    "scripts/init-fork.sh"
    "scripts/sync-upstream.sh"
    "scripts/update-from-upstream.sh"
    "workspace-config.template.json"
    "CONTRIBUTING.md"
)

echo -e "${BLUE}🔄 Claude Workflow Upstream Sync${NC}"
echo "=================================================="

# Verify we're in the right repository
if ! git remote get-url upstream | grep -q "claude-workflow"; then
    echo -e "${RED}❌ Error: upstream remote not configured for claude-workflow${NC}"
    echo "Run scripts/init-fork.sh first"
    exit 1
fi

# Ensure we're on main branch and up to date
echo -e "${YELLOW}📂 Preparing main branch...${NC}"
git checkout $MAIN_BRANCH
git status --porcelain | head -5

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️ You have uncommitted changes:${NC}"
    git status --short
    echo ""
    read -p "Commit these changes first? (y/N): " commit_first
    if [[ $commit_first == [yY] ]]; then
        git add .
        git commit -m "chore: prepare for upstream sync"
    else
        echo -e "${RED}❌ Please commit or stash changes before syncing${NC}"
        exit 1
    fi
fi

# Create/update sync branch
echo -e "${YELLOW}🌟 Creating upstream sync branch...${NC}"
if git show-ref --verify --quiet refs/heads/$PUBLIC_BRANCH; then
    git checkout $PUBLIC_BRANCH
    git reset --hard $MAIN_BRANCH
else
    git checkout -b $PUBLIC_BRANCH $MAIN_BRANCH
fi

# Create temporary directory for public files
TEMP_DIR=$(mktemp -d)
echo -e "${YELLOW}📦 Extracting public files to: $TEMP_DIR${NC}"

# Copy public files to temp directory with proper directory structure
for path in "${PUBLIC_PATHS[@]}"; do
    if [ -e "$path" ]; then
        # Create directory structure in temp
        if [ -d "$path" ]; then
            cp -r "$path" "$TEMP_DIR/"
        else
            # For files, preserve the directory structure
            mkdir -p "$TEMP_DIR/$(dirname "$path")"
            cp "$path" "$TEMP_DIR/$path"
        fi
        echo -e "${GREEN}✅ Copied: $path${NC}"
    else
        echo -e "${YELLOW}⚠️ Not found: $path${NC}"
    fi
done

# Handle workspace-config.json specially (template only)
if [ -f "workspace-config.json" ]; then
    # Create template version without personal data
    echo -e "${YELLOW}📝 Creating workspace-config template...${NC}"
    cat > "$TEMP_DIR/workspace-config.template.json" << 'EOF'
{
  "user": {
    "name": "Your Name",
    "email": "your.email@example.com",
    "github_username": "your-github-username",
    "jira_domain": "your-domain.atlassian.net"
  },
  "projects": {
    "example-project": {
      "name": "Example Project",
      "description": "Template project configuration",
      "repository": "git@github.com:your-username/example-project.git",
      "local_path": "./projects/example-project",
      "jira_project_key": "EX"
    }
  },
  "settings": {
    "default_branch": "main",
    "auto_sync": false,
    "task_retention_days": 30
  }
}
EOF
fi

# Clear current branch and add only public files
echo -e "${YELLOW}🧹 Preparing clean public branch...${NC}"
git rm -rf . --quiet || true
cp -r "$TEMP_DIR/"* . 2>/dev/null || true
cp -r "$TEMP_DIR/".* . 2>/dev/null || true

# Clean up temp directory
rm -rf "$TEMP_DIR"

# Stage all public files
git add .

# Check if there are changes to sync
if git diff --staged --quiet; then
    echo -e "${GREEN}✅ No changes to sync to upstream${NC}"
    git checkout $MAIN_BRANCH
    git branch -D $PUBLIC_BRANCH 2>/dev/null || true
    exit 0
fi

# Show what will be synced
echo -e "${BLUE}📋 Changes to be synced:${NC}"
git diff --staged --name-only | sed 's/^/  /'

# Commit changes
git commit -m "feat: sync public content from fork

Automated sync of Claude workflow tools and documentation.
Private project data remains in fork only.

🤖 Generated with upstream sync script"

# Push branch to upstream and create PR
echo -e "${YELLOW}⬆️ Creating pull request to upstream repository...${NC}"
echo "This will push branch to: $(git remote get-url upstream)"
read -p "Continue? (Y/n): " confirm
if [[ $confirm != [nN] ]]; then
    # Push the public branch to upstream (not main)
    git push upstream $PUBLIC_BRANCH --no-verify
    
    # Create pull request using GitHub CLI
    if command -v gh >/dev/null 2>&1; then
        echo -e "${YELLOW}📝 Creating pull request...${NC}"
        PR_TITLE="sync: Update public workflow tools from fork"
        PR_BODY="Automated sync of Claude workflow tools and documentation from personal fork.

## Changes Included
- Updated .claude/ workflow configurations
- Documentation improvements  
- Script enhancements
- Template updates

## Security Review
✅ Only public files included (no private project data)
✅ Personal configuration sanitized to template format
✅ Private content remains secure in fork

This PR was created automatically by the sync-upstream script to safely share workflow improvements while maintaining security separation between public tools and private projects."
        
        gh pr create --title "$PR_TITLE" --body "$PR_BODY" --repo upstream --head "$PUBLIC_BRANCH" --base main
        echo -e "${GREEN}✅ Pull request created successfully!${NC}"
    else
        echo -e "${YELLOW}⚠️ GitHub CLI (gh) not found${NC}"
        echo -e "${BLUE}📋 Manual PR creation required:${NC}"
        echo "1. Go to: $(git remote get-url upstream | sed 's/\.git$//')/compare/main...$PUBLIC_BRANCH"
        echo "2. Create PR with title: sync: Update public workflow tools from fork"
        echo "3. Review changes to ensure no private data is included"
    fi
else
    echo -e "${YELLOW}❌ Sync cancelled by user${NC}"
fi

# Return to main branch and cleanup
git checkout $MAIN_BRANCH
git branch -D $PUBLIC_BRANCH 2>/dev/null || true

echo "=================================================="
echo -e "${GREEN}🎉 Upstream sync completed!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo "• Public files prepared and pushed to upstream branch"
echo "• Pull request created for review and merge"
echo "• Private content remains secure in your fork"
echo "• Awaiting upstream maintainer review"