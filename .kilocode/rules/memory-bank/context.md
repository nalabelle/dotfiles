# Current Context

## Current Work Focus

**GitHub Actions CI Fix**: ✅ **CI/CD COMPATIBILITY ISSUE RESOLVED**

- **Problem**: GitHub Actions failing on JavaScript tests due to legacy `nix-shell` command not being available in modern Nix flakes installer environment
- **Solution**: Two-part fix for complete CI compatibility:
  1. Updated [`Makefile`](Makefile:26) `test-js` target to use modern `nix shell nixpkgs#nodejs nixpkgs#nodePackages.npm --command` instead of deprecated `nix-shell -p nodejs --run`
  2. Updated [`.github/workflows/ci.yml`](.github/workflows/ci.yml:34) pre-commit job to install Nix before running pre-commit hooks
- **Root Cause Discovery**: The actual CI failure was caused by duplicate MCP settings logic in [`hosts/twain/home-configuration.nix`](hosts/twain/home-configuration.nix:5) trying to import a non-existent file
- **Architecture Enhancement**:
  - Added configurable `vscode.configPath` option to [`home/vscode.nix`](home/vscode.nix:125) for VS Code Server support
  - Eliminated duplicate MCP settings logic from twain host configuration
  - Twain now uses `vscode.configPath = ".vscode-server/data/User"` to automatically handle VS Code Server paths
- **Implementation Details**:
  - Replaced legacy Nix command with flakes-compatible syntax
  - Added `npm install &&` to ensure dependencies are installed in clean CI environment
  - Added Nix installation step to pre-commit CI job to support `make-test` hook
  - Maintains backward compatibility with local development environments
- **Validation**: All tests passing locally and pre-commit hooks successful
- **Benefits**: Complete CI pipeline now compatible with modern Nix installer used in GitHub Actions

**Previous Achievement**: VS Code Settings Declarative Management completed - Successfully moved VS Code settings from standalone JSON file to declarative Nix configuration with smart merge capabilities.

**Previous Achievement**: macOS GUI Application PATH Inheritance Fix completed - Major system integration issue resolved enabling GUI applications to access complete development environment.

**Previous Achievement**: Renovate Configuration Migration & CI/CD Infrastructure Consolidation completed - Migrated from external renovate-config repository to local configuration with consolidated GitHub Actions workflows.

**Previous Achievement**: Homebrew Cask Name Fix completed - Fixed cask naming mismatches causing unnecessary application removals during nix-refresh.

**Previous Achievement**: GitHub Workflows Enhancement completed - Added comprehensive GitHub Actions CI/CD pipeline with automated code quality validation.

**Previous Achievement**: MCPM Cleanup completed - Complete removal of Multi-Cloud Package Manager from dotfiles configuration.

**Previous Achievement**: ZSH Directory Cleanup and Migration completed - All 4 steps successfully implemented with legacy shell scripts migrated to declarative Nix configuration.

**Previous Achievement**: Kilocode extension integration stabilized with workaround for symlink handling bug implemented via activation scripts.

## Project Status

### Active Configurations

- **tennyson**: Personal development machine with full macOS configuration
  - Additional tools: Android development (NDK, Studio), Obsidian, Calibre, Zed editor
  - Cloud tools: Mountain Duck, ProtonVPN, KopiaUI backup
- **bst**: Work machine with streamlined configuration
  - Development tools: DBeaver, Linear, Graphite CLI
  - Custom Nix build group configuration (gid: 30000)

### Current System State

- **Architecture**: Nix flakes-based with automatic host discovery working reliably
- **Services**: Qdrant and Ollama configured as launchd user agents with proper logging
- **Development Environment**: Full stack with Vim (35+ plugins), Zsh, Git (25+ aliases), and Tmux
- **Quality Assurance**: Pre-commit hooks with shellcheck and formatting validation. **Testing Pattern**: Use `pre-commit run --all-files` for comprehensive validation - it includes `make test` for Nix configuration testing, so never run `make test` separately.
- **Editor Integration**: VS Code with Kilocode MCP servers (context7, fetch, github) configured

## Recent Changes

- **Renovate configuration migration and CI/CD workflow consolidation completed. See Current Work Focus for details.**

### Kilocode Integration Stabilized

- Workaround implemented for Kilocode extension symlink exclusion bug
- Activation script pattern using `rsync --update` for efficient file copying
- MCP server configuration with host-specific override capability

### Configuration Management

- Auto-discovery system proven reliable across both host configurations
- Fallback mechanisms working for both darwin and home-manager configurations
- Cross-platform compatibility maintained and tested via Docker deployment

## Next Steps

### Immediate Priorities

- Monitor infrastructure stability and validate consolidated Renovate and CI/CD workflows in practical usage.
- Continue Memory Bank validation and configuration stability checks.
- Review activation script efficiency and resource usage.

### Potential Areas for Enhancement

- **Additional Hosts**: Framework ready for adding new host configurations
- **Service Expansion**: Pattern established for adding new launchd services
- **Tool Integration**: Module system supports easy addition of new development tools
- **Testing Enhancement**: Expand Docker-based Linux testing for broader compatibility

## Important Notes

- **System Architecture**: Host-specific configurations override base settings through dedicated directories
- **Update Pattern**: `nix-refresh` script handles both darwin and home-manager updates with intelligent fallbacks
- **Quality Controls**: Pre-commit hooks ensure code quality before configuration changes are committed. Running `pre-commit run --all-files` is **required** after any configuration changes to validate:
  - Shell script syntax and style via shellcheck
  - File format validation (JSON, YAML, TOML, XML)
  - Basic file hygiene (trailing whitespace, line endings, etc.)
  - **Note**: `pre-commit run --all-files` includes `make test` for Nix configuration testing - never run `make test` separately
- **Service Management**: AI/ML services (Qdrant, Ollama) auto-start and maintain persistent storage

## Configuration Patterns

- **Git Workflow**: 25+ productivity aliases optimized for branch management and rebasing workflows
- **Vim Setup**: 35+ plugins with language-specific support and productivity enhancements
- **Shell Environment**: Zsh with Starship prompt, intelligent completion, and cross-platform compatibility
- **Development Tools**: DevBox, direnv, and project-specific environment isolation
