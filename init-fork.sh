#!/bin/bash

# Claude Workflow Fork Initialization Script
# Sets up a fork for personal use with proper remote configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
UPSTREAM_REPO="git@github.com:ciaranRoche/claude-workflow.git"
WORKSPACE_CONFIG_TEMPLATE="workspace-config.template.json"
WORKSPACE_CONFIG="workspace-config.json"

echo -e "${BLUE}🚀 Claude Workflow Fork Initialization${NC}"
echo "=================================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    echo "Please run this script from your forked repository root"
    exit 1
fi

# Step 1: Configure remotes
echo -e "\n${YELLOW}📡 Configuring remotes...${NC}"

# Check current remotes
if git remote get-url upstream >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Upstream remote already configured${NC}"
else
    echo -e "${YELLOW}➕ Adding upstream remote${NC}"
    git remote add upstream "$UPSTREAM_REPO"
fi

# Verify remote configuration
echo -e "${BLUE}📋 Current remote configuration:${NC}"
git remote -v

# Step 2: Set up workspace configuration
echo -e "\n${YELLOW}⚙️ Setting up workspace configuration...${NC}"

if [ -f "$WORKSPACE_CONFIG_TEMPLATE" ]; then
    if [ ! -f "$WORKSPACE_CONFIG" ]; then
        echo -e "${YELLOW}📝 Creating workspace-config.json from template${NC}"
        cp "$WORKSPACE_CONFIG_TEMPLATE" "$WORKSPACE_CONFIG"
        echo -e "${GREEN}✅ Please edit workspace-config.json with your personal settings${NC}"
    else
        echo -e "${GREEN}✅ workspace-config.json already exists${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ No workspace-config template found${NC}"
fi

# Step 3: Set up git hooks for contribution workflow
echo -e "\n${YELLOW}🪝 Setting up git hooks...${NC}"

# Create pre-push hook to prevent accidental upstream pushes
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

# Prevent pushing private content to upstream
remote="$1"
url="$2"

if [[ "$url" == *"claude-workflow"* && "$url" != *"home-lab-claude"* ]]; then
    echo "⚠️  WARNING: Pushing to upstream claude-workflow repository"
    echo "Only public files should be pushed to upstream."
    echo "Use 'scripts/sync-upstream.sh' instead for proper filtering."
    echo ""
    read -p "Are you sure you want to continue? (y/N): " confirm
    if [[ $confirm != [yY] ]]; then
        echo "❌ Push cancelled"
        exit 1
    fi
fi
EOF

chmod +x .git/hooks/pre-push

# Step 4: Ensure proper .gitignore for private content
echo -e "\n${YELLOW}📄 Checking .gitignore configuration...${NC}"

# Add private patterns to .gitignore if not present
PRIVATE_PATTERNS=(
    "# Personal workspace configuration"
    "workspace-config.json.personal"
    "# Private project data"
    "projects/*/secrets/"
    "projects/*/.env*"
    "# Personal task data with sensitive info"
    "tasks/*/sensitive/"
    "# Local development files"
    ".vscode/settings.json"
)

for pattern in "${PRIVATE_PATTERNS[@]}"; do
    if ! grep -Fxq "$pattern" .gitignore 2>/dev/null; then
        echo "$pattern" >> .gitignore
    fi
done

# Step 5: Fetch upstream changes
echo -e "\n${YELLOW}🔄 Fetching latest changes from upstream...${NC}"
git fetch upstream

# Step 6: Display next steps
echo -e "\n${GREEN}✅ Fork initialization complete!${NC}"
echo "=================================================="
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Edit workspace-config.json with your project details"
echo "2. Add your private projects to the projects/ directory"
echo "3. Use 'scripts/sync-upstream.sh' to contribute public changes"
echo "4. Use regular git commands for your private fork"
echo ""
echo -e "${BLUE}🔧 Available Commands:${NC}"
echo "• scripts/sync-upstream.sh    - Sync public changes to upstream"
echo "• scripts/update-from-upstream.sh - Pull upstream changes to fork"
echo ""
echo -e "${YELLOW}⚠️ Remember:${NC}"
echo "• Only .claude/, docs/, .gitignore, CLAUDE.md, README.md go to upstream"
echo "• Everything else stays in your private fork"
echo "• Use the sync script to contribute changes back to claude-workflow"