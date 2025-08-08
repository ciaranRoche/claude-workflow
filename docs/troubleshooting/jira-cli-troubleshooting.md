# JIRA CLI Troubleshooting Guide

Comprehensive troubleshooting guide for JIRA CLI (`jira`) issues in the Claude Code workspace environment.

## Common Installation Issues

### Command Not Found

**Problem**: `jira: command not found`

**Solutions**:

```bash
# Check if jira is installed
which jira

# Check PATH configuration
echo $PATH

# Add to PATH if needed (add to ~/.bashrc, ~/.zshrc)
export PATH="/usr/local/bin:$PATH"

# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc
```

**Platform-specific fixes**:

**macOS (Homebrew)**:
```bash
# Reinstall if needed
brew uninstall jira-cli
brew install jira-cli

# Fix permissions
brew doctor
brew prune
```

**Linux**:
```bash
# Verify binary installation
ls -la /usr/local/bin/jira

# Check permissions
chmod +x /usr/local/bin/jira

# Reinstall from GitHub releases if needed
wget https://github.com/ankitpokhrel/jira-cli/releases/latest/download/jira_*_linux_amd64.tar.gz
tar -xzf jira_*_linux_amd64.tar.gz
sudo mv bin/jira /usr/local/bin/
```

### Permission Denied

**Problem**: `permission denied` when running jira command

```bash
# Fix binary permissions
sudo chmod +x /usr/local/bin/jira

# Check ownership
ls -la /usr/local/bin/jira

# Fix ownership if needed
sudo chown $USER:$USER /usr/local/bin/jira
```

### Configuration Directory Issues

**Problem**: Cannot create or access config directory

```bash
# Create config directory manually
mkdir -p ~/.config/jira-cli

# Fix permissions
chmod 755 ~/.config/jira-cli

# Check ownership
ls -la ~/.config/ | grep jira-cli
```

## Authentication Issues

### Authentication Failed

**Problem**: `authentication failed` or `401 Unauthorized`

**Diagnosis**:
```bash
# Check current user information
jira me

# Verify configuration
jira config list

# Test with verbose output
jira --debug me
```

**Solutions**:

1. **Re-initialize configuration**:
```bash
# Backup existing config
cp ~/.config/jira-cli/config.yml ~/.config/jira-cli/config.yml.backup

# Re-run initialization
jira init
```

2. **API Token Issues** (Atlassian Cloud):
```bash
# Verify token in Atlassian Account Settings
# Generate new token if needed
# Re-run: jira init
```

3. **Check server URL**:
```bash
# Verify server URL format
# Correct: https://your-company.atlassian.net
# Incorrect: https://your-company.atlassian.net/

# Test server connectivity
curl -I https://your-company.atlassian.net
```

### Invalid API Token

**Problem**: Token rejected or expired

**Solutions**:

1. **Regenerate API Token**:
   - Go to [Atlassian Account Settings](https://id.atlassian.com/manage-profile/security/api-tokens)
   - Revoke old token
   - Create new token with descriptive name
   - Update configuration: `jira init`

2. **Check token permissions**:
   - Ensure token has access to required projects
   - Verify account permissions in JIRA admin

3. **Validate token manually**:
```bash
# Test API token with curl
curl -u your-email@company.com:YOUR_API_TOKEN \
  -H "Accept: application/json" \
  https://your-company.atlassian.net/rest/api/3/myself
```

### Server Connection Issues

**Problem**: Cannot connect to JIRA server

**Diagnosis**:
```bash
# Test basic connectivity
ping your-company.atlassian.net
curl -I https://your-company.atlassian.net

# Test with debug mode
jira --debug me
```

**Solutions**:

1. **Network connectivity**:
```bash
# Check DNS resolution
nslookup your-company.atlassian.net

# Test HTTPS connection
openssl s_client -connect your-company.atlassian.net:443
```

2. **Proxy configuration**:
```bash
# Configure proxy if needed
export HTTPS_PROXY=http://proxy.company.com:8080
export HTTP_PROXY=http://proxy.company.com:8080

# Test with proxy
jira me
```

3. **Firewall issues**:
   - Ensure port 443 is open
   - Whitelist Atlassian domains
   - Check corporate firewall rules

## Configuration Issues

### Invalid Configuration File

**Problem**: `invalid configuration` or YAML parsing errors

**Diagnosis**:
```bash
# Check configuration file
cat ~/.config/jira-cli/config.yml

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('~/.config/jira-cli/config.yml'))"
```

**Solutions**:

1. **Fix YAML syntax**:
```bash
# Common issues:
# - Missing quotes around values with special characters
# - Incorrect indentation
# - Mixed tabs and spaces

# Example correct format:
installation: cloud
server: "https://company.atlassian.net"
login: "user@company.com"
project: "PROJECT_KEY"
```

2. **Reset configuration**:
```bash
# Remove corrupted config
rm ~/.config/jira-cli/config.yml

# Reinitialize
jira init
```

### Missing Required Fields

**Problem**: Configuration missing required fields

```bash
# Check required fields in config
jira config list

# Set missing fields
jira config set server "https://your-company.atlassian.net"
jira config set login "your-email@company.com"
jira config set project "YOUR_PROJECT_KEY"
```

### Project Access Issues

**Problem**: Cannot access specified project

**Diagnosis**:
```bash
# List available projects
jira project list

# Test specific project access
jira project view YOUR_PROJECT_KEY
```

**Solutions**:

1. **Verify project key**:
   - Check project key spelling
   - Projects keys are usually uppercase (e.g., "PROJ", not "proj")

2. **Check permissions**:
   - Ensure you have "Browse Projects" permission
   - Verify project isn't restricted to specific users/groups

3. **Update default project**:
```bash
# Set accessible project as default
jira config set project ACCESSIBLE_PROJECT_KEY
```

## API and Permission Issues

### Insufficient Permissions

**Problem**: `403 Forbidden` or permission denied errors

**Solutions**:

1. **Check user permissions**:
   - Contact JIRA administrator
   - Request necessary permissions:
     - Browse Projects
     - View Issues
     - Create Issues (if needed)
     - Add Comments (if needed)

2. **Verify project access**:
```bash
# Test basic project operations
jira project list
jira issue list --project YOUR_PROJECT --limit 1
```

3. **Check organization restrictions**:
   - Some organizations restrict API access
   - May require admin approval for API tokens

### Rate Limiting

**Problem**: `429 Too Many Requests` errors

**Solutions**:

1. **Implement delays**:
```bash
# Add delays between commands
jira issue list --limit 5
sleep 2
jira issue view ISSUE-123
```

2. **Reduce query frequency**:
   - Use smaller page sizes
   - Limit concurrent requests
   - Cache results when possible

3. **Check rate limits** (Atlassian Cloud):
   - Cloud instances have API rate limits
   - Limits reset every hour
   - Consider upgrading plan if limits are too restrictive

## Issue Query and Display Issues

### No Issues Found

**Problem**: `jira issue list` returns no results

**Diagnosis**:
```bash
# Test with different parameters
jira issue list --limit 10
jira issue list --project YOUR_PROJECT
jira issue list --assignee currentUser()

# Use JQL for debugging
jira issue list --jql "project = YOUR_PROJECT"
```

**Solutions**:

1. **Check project assignment**:
```bash
# Verify project has issues
jira project view YOUR_PROJECT

# Try different project
jira issue list --project DIFFERENT_PROJECT
```

2. **Verify user access**:
```bash
# Check your user info
jira me

# Test with broader search
jira issue list --jql "assignee = currentUser() OR reporter = currentUser()"
```

### JQL Query Errors

**Problem**: Invalid JQL syntax errors

**Solutions**:

1. **Validate JQL syntax**:
```bash
# Test simple queries first
jira issue list --jql "project = YOUR_PROJECT"
jira issue list --jql "assignee = currentUser()"

# Use quotes for complex values
jira issue list --jql "summary ~ \"search term\""
```

2. **Common JQL patterns**:
```bash
# Find your assigned issues
jira issue list --jql "assignee = currentUser() AND status != Done"

# Find recent issues
jira issue list --jql "created >= -7d"

# Find issues by type
jira issue list --jql "project = YOUR_PROJECT AND issuetype = Story"
```

### Display Formatting Issues

**Problem**: Output formatting is broken or unreadable

**Solutions**:

1. **Use plain output**:
```bash
# For workspace integration, always use --plain
jira issue view ISSUE-123 --plain
jira issue list --plain
```

2. **Check terminal compatibility**:
```bash
# Test with basic output
jira issue list --limit 1 --plain

# Check terminal encoding
echo $LANG
echo $LC_ALL
```

## Workspace Integration Issues

### JIRA Implementation Command Failures

**Problem**: `development/implement-jira.md` command fails

**Diagnosis**:
```bash
# Test the exact commands used by workspace
ISSUE_KEY="YOUR-PROJECT-123"

# Test issue fetching
jira issue view $ISSUE_KEY --plain
jira issue view $ISSUE_KEY --comments --plain

# Check file creation
jira issue view $ISSUE_KEY --plain > test-issue.txt
cat test-issue.txt
```

**Solutions**:

1. **Verify issue exists**:
```bash
# Check issue key format (usually PROJECT-123)
jira issue view PROJECT-123

# Search for issues if key is unknown
jira issue list --jql "summary ~ \"search term\""
```

2. **Check comment access**:
```bash
# Test comment retrieval
jira issue view ISSUE-123 --comments

# Verify you can see comments in JIRA web interface
```

3. **File output issues**:
```bash
# Test file creation in workspace directory
cd /path/to/workspace/tasks/
mkdir test-output
cd test-output

jira issue view ISSUE-123 --plain > raw-jira-issue.txt
jira issue view ISSUE-123 --comments --plain > raw-jira-comments.txt

# Check file contents
ls -la *.txt
head -10 raw-jira-issue.txt
```

### Data Parsing Issues

**Problem**: Workspace commands can't parse JIRA output

**Solutions**:

1. **Verify output format**:
```bash
# Check output format matches expectations
jira issue view ISSUE-123 --plain | head -20

# Compare with expected format in workspace commands
```

2. **Handle special characters**:
```bash
# Issues with special characters in titles/descriptions
jira issue view ISSUE-123 --plain | cat -v  # Show non-printing characters

# Use different encoding if needed
export LC_ALL=C.UTF-8
jira issue view ISSUE-123 --plain
```

## Advanced Debugging

### Enable Debug Mode

```bash
# Run commands with debug information
jira --debug issue list --limit 1

# Save debug output
jira --debug me 2> debug.log
cat debug.log
```

### Configuration Debugging

```bash
# View all configuration
jira config list

# Check specific settings
jira config get server
jira config get login
jira config get project

# View raw configuration file
cat ~/.config/jira-cli/config.yml
```

### Network Debugging

```bash
# Test API endpoints manually
curl -u your-email:your-token \
  -H "Accept: application/json" \
  https://your-company.atlassian.net/rest/api/3/myself

# Test issue endpoint
curl -u your-email:your-token \
  -H "Accept: application/json" \
  https://your-company.atlassian.net/rest/api/3/issue/PROJECT-123
```

## Emergency Recovery

### Complete Configuration Reset

If all else fails:

```bash
# Backup current configuration
cp -r ~/.config/jira-cli ~/.config/jira-cli.backup

# Remove all JIRA CLI configuration
rm -rf ~/.config/jira-cli

# Reinstall JIRA CLI if needed
# (use appropriate method for your platform)

# Reconfigure from scratch
jira init

# Test basic functionality
jira me
jira project list
jira issue list --limit 1
```

### Validate Recovery

```bash
# Test all basic operations
echo "Testing JIRA CLI recovery..."

# Check version
jira version

# Check authentication
jira me

# Check project access
jira project list | head -3

# Check issue access
jira issue list --limit 1

# Test workspace command pattern
ISSUE_KEY="PROJECT-123"  # Replace with actual issue
jira issue view $ISSUE_KEY --plain > test-recovery.txt
echo "Recovery test complete - check test-recovery.txt"
```

## Platform-Specific Issues

### macOS Issues

**Gatekeeper warnings**:
```bash
# If macOS blocks the binary
sudo spctl --master-disable  # Temporarily disable Gatekeeper
# Or right-click binary and select "Open" to allow
```

**Homebrew permissions**:
```bash
# Fix Homebrew permissions
brew doctor
sudo chown -R $(whoami) $(brew --prefix)/*
```

### Linux Distribution Issues

**Package manager conflicts**:
```bash
# Remove conflicting packages
sudo apt remove jira  # If different JIRA package exists

# Install from GitHub releases instead
wget https://github.com/ankitpokhrel/jira-cli/releases/latest/download/jira_*_linux_amd64.tar.gz
```

**Library dependencies**:
```bash
# Check for missing libraries
ldd /usr/local/bin/jira

# Install missing dependencies
sudo apt install libc6  # Example
```

### Windows/WSL Issues

**Path separators**:
```bash
# Use Unix-style paths in WSL
export PATH="/usr/local/bin:$PATH"
```

**Line ending issues**:
```bash
# Convert Windows line endings
dos2unix ~/.config/jira-cli/config.yml
```

## Getting Help

### Built-in Help

```bash
# General help
jira help

# Command-specific help
jira issue help
jira project help

# Get examples
jira issue list --help
```

### Community Resources

1. **GitHub Issues**: https://github.com/ankitpokhrel/jira-cli/issues
2. **GitHub Discussions**: https://github.com/ankitpokhrel/jira-cli/discussions
3. **Atlassian Community**: https://community.atlassian.com/
4. **Stack Overflow**: Tag `jira-cli`

### Reporting Issues

When reporting issues:

1. **Include version information**:
```bash
jira version
uname -a  # system information
```

2. **Provide debug output**:
```bash
jira --debug command-that-fails 2> error.log
```

3. **Include configuration** (sanitized):
```bash
jira config list
# Remove sensitive information like tokens and server URLs
```

4. **Describe expected vs actual behavior**

## Prevention Best Practices

### Regular Maintenance

```bash
# Monthly maintenance script
#!/bin/bash
echo "JIRA CLI maintenance..."

# Update JIRA CLI
# (use appropriate update method for your platform)

# Test authentication
jira me

# Test basic functionality
jira project list | head -3
jira issue list --limit 1

echo "Maintenance complete"
```

### Configuration Backup

```bash
# Regularly backup configuration
cp ~/.config/jira-cli/config.yml ~/.config/jira-cli/config.yml.backup

# Version control configuration (without sensitive data)
# Create sanitized version for backup
sed 's/login: .*/login: "REDACTED"/' ~/.config/jira-cli/config.yml > config-template.yml
```

### Token Management

1. **Set token expiration dates** (when supported)
2. **Rotate tokens regularly** (quarterly recommended)
3. **Use descriptive token names** ("JIRA CLI - Dev Machine")
4. **Monitor token usage** in Atlassian Account Settings
5. **Revoke unused tokens** immediately

---

**Related Documentation**:
- **[JIRA CLI Setup Guide](../setup/jira-cli-setup.md)**
- **[Workspace Integration Guide](../integration/workspace-integration.md)**
- **[GitHub CLI Troubleshooting](github-cli-troubleshooting.md)**