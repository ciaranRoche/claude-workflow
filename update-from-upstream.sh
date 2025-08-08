#!/bin/bash

# Update fork with latest changes from upstream claude-workflow
# Merges public changes while preserving private fork content

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Updating Fork from Upstream${NC}"
echo "=================================================="

# Verify upstream remote exists
if ! git remote get-url upstream >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: upstream remote not configured${NC}"
    echo "Run scripts/init-fork.sh first"
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️ You have uncommitted changes:${NC}"
    git status --short
    echo ""
    read -p "Stash changes and continue? (Y/n): " stash_changes
    if [[ $stash_changes != [nN] ]]; then
        git stash push -m "Auto-stash before upstream update"
        STASHED_CHANGES=true
    else
        echo -e "${RED}❌ Please commit or stash changes first${NC}"
        exit 1
    fi
fi

# Fetch latest from upstream
echo -e "${YELLOW}📡 Fetching from upstream...${NC}"
git fetch upstream

# Show what will be updated
echo -e "${BLUE}📋 Changes from upstream:${NC}"
git log --oneline HEAD..upstream/main | head -10

# Merge upstream changes
echo -e "${YELLOW}🔀 Merging upstream changes...${NC}"
if git merge upstream/main --no-edit; then
    echo -e "${GREEN}✅ Successfully merged upstream changes${NC}"
else
    echo -e "${RED}❌ Merge conflicts detected${NC}"
    echo -e "${YELLOW}📝 Resolve conflicts and run: git commit${NC}"
    exit 1
fi

# Restore stashed changes if any
if [ "$STASHED_CHANGES" = true ]; then
    echo -e "${YELLOW}📦 Restoring stashed changes...${NC}"
    if git stash pop; then
        echo -e "${GREEN}✅ Stashed changes restored${NC}"
    else
        echo -e "${YELLOW}⚠️ Conflicts in stashed changes, resolve manually${NC}"
    fi
fi

# Update workspace config if template changed
if git diff --name-only HEAD~1 HEAD | grep -q "workspace-config.template.json"; then
    echo -e "${YELLOW}📝 Workspace config template updated${NC}"
    echo "Consider reviewing workspace-config.json for new options"
fi

echo "=================================================="
echo -e "${GREEN}🎉 Fork update completed!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo "• Latest upstream changes merged into your fork"
echo "• Private content preserved"
echo "• Ready to continue development"

# Show current status
echo -e "\n${BLUE}📊 Current Status:${NC}"
git log --oneline -5