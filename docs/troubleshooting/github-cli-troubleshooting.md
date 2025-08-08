# GitHub CLI Troubleshooting Guide

Comprehensive troubleshooting guide for GitHub CLI (`gh`) issues in the Claude Code workspace environment.

## Common Installation Issues

### Command Not Found

**Problem**: `gh: command not found`

**Solutions**:

```bash
# Check if gh is installed
which gh

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
brew uninstall gh
brew install gh

# Fix permissions
brew doctor
brew prune
```

**Linux**:
```bash
# Verify package installation
dpkg -l | grep gh          # Debian/Ubuntu
rpm -qa | grep gh          # RHEL/CentOS

# Reinstall if needed
sudo apt reinstall gh      # Debian/Ubuntu
sudo yum reinstall gh      # RHEL/CentOS
```

### Version Conflicts

**Problem**: Old version installed or multiple versions

```bash
# Check current version
gh --version

# Check all installed versions
which -a gh
ls -la /usr/local/bin/gh*

# Remove old versions
sudo rm /usr/local/bin/gh-old
brew cleanup gh  # macOS
```

## Authentication Issues

### Authentication Failed

**Problem**: `authentication failed` or `401 Unauthorized`

**Diagnosis**:
```bash
# Check authentication status
gh auth status

# View detailed auth info
gh auth status --show-token
```

**Solutions**:

1. **Re-authenticate**:
```bash
# Logout and re-login
gh auth logout
gh auth login
```

2. **Token Issues**:
```bash
# Check token scopes
gh api user

# Refresh token with required scopes
gh auth refresh --scopes repo,workflow,read:org,user:email
```

3. **Environment Variable Conflicts**:
```bash
# Check for conflicting environment variables
echo $GITHUB_TOKEN
echo $GH_TOKEN

# Unset if conflicting
unset GITHUB_TOKEN
unset GH_TOKEN
```

### Token Expired or Invalid

**Problem**: Previously working token stops working

**Solutions**:

1. **Check token status on GitHub**:
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Verify token exists and hasn't expired
   - Check if token was revoked

2. **Generate new token**:
```bash
# Create new token with required scopes:
# - repo (full repository access)
# - workflow (GitHub Actions)
# - read:org (organization access)
# - user:email (email access)

# Update CLI with new token
gh auth login --with-token < new-token.txt
```

### Two-Factor Authentication Issues

**Problem**: 2FA blocking authentication

**Solutions**:

1. **Use Personal Access Token**:
   - Create PAT instead of using password
   - Use PAT as password during login

2. **Browser Authentication**:
```bash
# Use browser-based auth (bypasses 2FA issues)
gh auth login --web
```

## Network and Connectivity Issues

### Connection Timeouts

**Problem**: `connection timeout` or `network unreachable`

**Diagnosis**:
```bash
# Test basic connectivity
ping github.com
curl -I https://api.github.com

# Test with verbose output
gh repo list --limit 1 --debug
```

**Solutions**:

1. **Proxy Configuration**:
```bash
# Configure proxy
export HTTPS_PROXY=http://proxy.company.com:8080
export HTTP_PROXY=http://proxy.company.com:8080
export NO_PROXY=localhost,127.0.0.1

# Test with proxy
gh repo list --limit 1
```

2. **Firewall Issues**:
   - Ensure ports 80 and 443 are open
   - Whitelist GitHub domains:
     - `github.com`
     - `api.github.com`
     - `uploads.github.com`

3. **DNS Issues**:
```bash
# Test DNS resolution
nslookup github.com
dig github.com

# Try alternative DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf.backup
```

### SSL/TLS Certificate Issues

**Problem**: `certificate verification failed`

**Solutions**:

1. **Update certificates**:
```bash
# macOS
brew upgrade ca-certificates

# Linux
sudo apt update && sudo apt upgrade ca-certificates  # Debian/Ubuntu
sudo yum update ca-certificates                       # RHEL/CentOS
```

2. **Corporate certificates**:
```bash
# Add corporate certificate to system store
sudo cp corporate-cert.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

3. **Temporary bypass (not recommended for production)**:
```bash
# Only for testing
export GIT_SSL_NO_VERIFY=true
```

## Repository Access Issues

### Repository Not Found

**Problem**: `repository not found` for existing repositories

**Diagnosis**:
```bash
# Check repository access
gh repo view owner/repository

# Check organization membership
gh api user/orgs

# List accessible repositories
gh repo list owner --limit 10
```

**Solutions**:

1. **Verify repository exists**:
   - Check repository name spelling
   - Verify repository isn't private (if using public token)
   - Confirm you have access permissions

2. **Organization access**:
```bash
# Check if organization grants access to members
gh api orgs/organization-name/members/your-username

# Request access if needed
# (Contact organization administrators)
```

3. **Token scope issues**:
```bash
# Refresh token with repository scopes
gh auth refresh --scopes repo,read:org
```

### Permission Denied

**Problem**: `permission denied` for repository operations

**Solutions**:

1. **Check repository permissions**:
   - Verify you have appropriate role (read, write, admin)
   - Check if repository requires specific permissions

2. **Organization policies**:
   - Some organizations restrict external app access
   - May need to authorize GitHub CLI in organization settings

3. **Branch protection**:
   - Protected branches may prevent direct pushes
   - Use pull requests for protected branches

## Workspace Command Integration Issues

### Code Review Command Failures

**Problem**: `development/review.md` command fails

**Diagnosis**:
```bash
# Test PR operations
gh pr list
gh pr view 123
gh pr comment 123 --body "test comment"
```

**Solutions**:

1. **Check PR access**:
```bash
# Verify PR exists and you have access
gh pr view PR_NUMBER

# Check repository permissions
gh repo view owner/repo
```

2. **Comment permissions**:
   - Ensure token has `repo` scope
   - Verify you can comment on repository

### Workspace Pull Command Issues

**Problem**: `workspace/pull.md` command fails

**Solutions**:

1. **Git configuration**:
```bash
# Ensure git is configured properly
gh auth setup-git

# Verify git credentials
git config --list | grep credential
```

2. **Remote configuration**:
```bash
# Check remote URLs
git remote -v

# Fix HTTPS/SSH mismatch
gh repo set-default owner/repo
```

### Migration Check Command Issues

**Problem**: `deployment/check-migrations.md` command fails

**Solutions**:

1. **API rate limits**:
```bash
# Check rate limit status
gh api rate_limit

# Wait for reset or use authenticated requests
```

2. **Search permissions**:
```bash
# Test search functionality
gh search repos "migration" --limit 1
gh search prs "migration" --limit 1
```

## Performance Issues

### Slow API Responses

**Problem**: Commands take too long to execute

**Solutions**:

1. **Check API rate limits**:
```bash
# Monitor rate limit usage
gh api rate_limit
```

2. **Optimize queries**:
```bash
# Use specific limits
gh repo list --limit 10  # instead of fetching all
gh pr list --limit 5     # limit results
```

3. **Cache issues**:
```bash
# Clear CLI cache if needed
rm -rf ~/.config/gh/
gh auth login  # re-authenticate
```

### Memory Usage Issues

**Problem**: High memory usage with large repositories

**Solutions**:

1. **Pagination**:
```bash
# Use pagination for large datasets
gh pr list --limit 50 --state all
```

2. **Specific queries**:
```bash
# Be specific in searches
gh search prs "is:open author:username" --limit 10
```

## Advanced Debugging

### Enable Debug Mode

```bash
# Run commands with debug information
gh --debug repo list

# Save debug output
gh --debug repo list 2> debug.log
```

### HTTP Request Tracing

```bash
# Trace HTTP requests
export GH_DEBUG=api
gh repo list --limit 1
```

### Configuration Debugging

```bash
# View all configuration
gh config list

# Check specific configuration
gh config get editor
gh config get git_protocol

# Reset configuration
gh config set editor ""
gh config set git_protocol https
```

## Emergency Recovery

### Complete Reset

If all else fails, complete reset:

```bash
# Backup current configuration
cp -r ~/.config/gh ~/.config/gh.backup

# Remove all GitHub CLI configuration
rm -rf ~/.config/gh

# Logout and clear credentials
gh auth logout --hostname github.com

# Reinstall GitHub CLI
# (use appropriate method for your platform)

# Reconfigure from scratch
gh auth login
gh auth setup-git
```

### Validate Recovery

```bash
# Test basic functionality
gh --version
gh auth status
gh repo list --limit 3
gh pr list --limit 1

echo "GitHub CLI recovery complete"
```

## Getting Help

### Built-in Help

```bash
# General help
gh help

# Command-specific help
gh repo help
gh pr help create

# Get examples
gh pr create --help
```

### Community Resources

1. **GitHub CLI Discussions**: https://github.com/cli/cli/discussions
2. **GitHub CLI Issues**: https://github.com/cli/cli/issues
3. **GitHub Community**: https://github.community/
4. **Stack Overflow**: Tag `github-cli`

### Reporting Issues

When reporting issues:

1. **Include version information**:
```bash
gh --version
uname -a  # system information
```

2. **Provide debug output**:
```bash
gh --debug command-that-fails 2> error.log
```

3. **Include configuration**:
```bash
gh config list
gh auth status
```

4. **Sanitize sensitive information**:
   - Remove tokens, passwords, private repository names
   - Replace with placeholders like `REDACTED`

## Prevention Best Practices

### Regular Maintenance

```bash
# Monthly maintenance script
#!/bin/bash
echo "GitHub CLI maintenance..."

# Update GitHub CLI
brew upgrade gh  # or appropriate update method

# Check authentication
gh auth status

# Test basic functionality
gh repo list --limit 1

echo "Maintenance complete"
```

### Configuration Backup

```bash
# Regularly backup configuration
cp ~/.config/gh/config.yml ~/.config/gh/config.yml.backup
cp ~/.config/gh/hosts.yml ~/.config/gh/hosts.yml.backup
```

### Token Management

1. **Set token expiration dates**
2. **Rotate tokens regularly**
3. **Use minimal required scopes**
4. **Monitor token usage in GitHub settings**

---

**Related Documentation**:
- **[GitHub CLI Setup Guide](../setup/github-cli-setup.md)**
- **[Workspace Integration Guide](../integration/workspace-integration.md)**
- **[JIRA CLI Troubleshooting](jira-cli-troubleshooting.md)**