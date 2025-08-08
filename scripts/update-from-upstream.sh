#!/bin/bash

# Update fork with latest changes from upstream claude-workflow
# Safely merges public changes while preserving ALL private fork content

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Updating Fork from Upstream${NC}"
echo "=================================================="

# Private files that must be preserved
PRIVATE_FILES=(
    "workspace-config.json"
    "workspace-activity.json"
    "tasks/"
    "reviews/"
    "reports/"
    "projects/"
)

# Verify upstream remote exists
if ! git remote get-url upstream >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: upstream remote not configured${NC}"
    echo "Run scripts/init-fork.sh first"
    exit 1
fi

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}⚠️ Not on main branch (currently on: $CURRENT_BRANCH)${NC}"
    read -p "Switch to main and continue? (Y/n): " switch_branch
    if [[ $switch_branch != [nN] ]]; then
        git checkout main
    else
        echo -e "${RED}❌ Must be on main branch to update from upstream${NC}"
        exit 1
    fi
fi

# Create temporary backup of private data
BACKUP_DIR=$(mktemp -d)
echo -e "${YELLOW}🛡️ Backing up private data to: $BACKUP_DIR${NC}"

for file in "${PRIVATE_FILES[@]}"; do
    if [ -e "$file" ]; then
        # Create parent directory structure in backup
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        cp -r "$file" "$BACKUP_DIR/$file" 2>/dev/null || true
        echo -e "${GREEN}✅ Backed up: $file${NC}"
    fi
done

# Handle uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️ You have uncommitted changes:${NC}"
    git status --short
    echo ""
    read -p "Commit changes before update? (Y/n): " commit_changes
    if [[ $commit_changes != [nN] ]]; then
        git add .
        git commit -m "chore: save work before upstream update

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    else
        echo -e "${RED}❌ Please commit changes first${NC}"
        rm -rf "$BACKUP_DIR"
        exit 1
    fi
fi

# Fetch latest from upstream
echo -e "${YELLOW}📡 Fetching from upstream...${NC}"
git fetch upstream

# Show what will be updated
echo -e "${BLUE}📋 Changes from upstream:${NC}"
git log --oneline HEAD..upstream/main | head -10
echo ""

# Confirm before proceeding
read -p "Continue with upstream merge? (Y/n): " confirm_merge
if [[ $confirm_merge == [nN] ]]; then
    echo -e "${YELLOW}❌ Update cancelled${NC}"
    rm -rf "$BACKUP_DIR"
    exit 0
fi

# Merge upstream changes
echo -e "${YELLOW}🔀 Merging upstream changes...${NC}"
if git merge upstream/main --no-edit; then
    echo -e "${GREEN}✅ Successfully merged upstream changes${NC}"
else
    echo -e "${RED}❌ Merge conflicts detected${NC}"
    echo -e "${YELLOW}📝 Resolve conflicts manually, then run this script again${NC}"
    rm -rf "$BACKUP_DIR"
    exit 1
fi

# Restore private data from backup
echo -e "${YELLOW}📦 Restoring private data...${NC}"
for file in "${PRIVATE_FILES[@]}"; do
    if [ -e "$BACKUP_DIR/$file" ]; then
        cp -r "$BACKUP_DIR/$file" "$file" 2>/dev/null || true
        echo -e "${GREEN}✅ Restored: $file${NC}"
    fi
done

# Clean up backup
rm -rf "$BACKUP_DIR"

# Check if we need to commit restored private data
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}💾 Committing restored private data...${NC}"
    git add .
    git commit -m "restore: preserve private data after upstream merge

- Restored workspace configuration and activity logs
- Maintained private project data and task history
- Ensured fork workflow data integrity

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
fi

# Update workspace config if template changed
if git diff --name-only HEAD~2 HEAD | grep -q "workspace-config.template.json"; then
    echo -e "${YELLOW}📝 Workspace config template updated${NC}"
    echo "Consider reviewing workspace-config.json for new options"
fi

echo "=================================================="
echo -e "${GREEN}🎉 Fork update completed!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo "• Latest upstream changes safely merged"
echo "• ALL private data preserved and restored"
echo "• Workspace integrity maintained"
echo "• Ready to continue development"

# Show current status
echo -e "\n${BLUE}📊 Current Status:${NC}"
git log --oneline -3