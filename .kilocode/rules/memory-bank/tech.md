# Technology Stack

## Core Technologies

### Nix Ecosystem

- **Nix Package Manager**: Functional package manager with reproducible builds
- **Nix Flakes**: Modern dependency management and configuration system
- **Home Manager**: Declarative user environment management
- **nix-darwin**: macOS system configuration through Nix
- **nixpkgs**: Comprehensive package collection (using nixos-unstable channel)

### System Integration

- **macOS Integration**: Native system preferences, launchd services, Homebrew bridge
- **GUI Application Environment**: launchctl PATH configuration for Finder-launched applications
- **Linux Support**: Home Manager configurations with systemd patterns
- **Cross-Platform**: Unified configuration with platform-specific adaptations

## Development Environment

### Shell & Terminal

- **Zsh**: Primary shell with extensive customization
- **Starship**: Cross-shell prompt with Git integration and status indicators
- **Tmux**: Terminal multiplexer with vi key bindings and custom status line
- **FZF**: Fuzzy finder with shell and tmux integration

#### Home Manager Zsh Configuration

**programs.zsh.initContent** supports ordered initialization with `lib.mkOrder`:

- **500 (mkBefore)**: Early initialization (replaces initExtraFirst)
- **550**: Before completion initialization (replaces initExtraBeforeCompInit)
- **1000 (default)**: General configuration (replaces initExtra)
- **1500 (mkAfter)**: Last to run configuration

**Pattern for multiple initialization phases:**

```nix
initContent = let
  zshConfigEarlyInit = lib.mkOrder 500 "early initialization";
  zshConfig = lib.mkOrder 1000 "general configuration";
in
  lib.mkMerge [ zshConfigEarlyInit zshConfig ];
```

**Critical for direnv integration**: Homebrew setup must use `lib.mkOrder 500` to ensure PATH is properly established before direnv hooks initialize.

### Editor & Development Tools

- **Vim**: Full-featured editor with 35+ plugins including:
  - Language support (Polyglot, ALE, Markdown Preview)
  - Git integration (Fugitive)
  - UI enhancements (Airline, NERDTree, Vista)
  - Nix-specific tooling (vim-addon-nix)
- **VS Code**: Configured through Home Manager with Kilo Code MCP settings
- **Git**: Comprehensive configuration with 25+ productivity aliases

### Languages & Runtimes

- **Python**: Poetry for dependency management, configured for in-project virtualenvs
- **JavaScript/TypeScript**: Node.js support with language-specific Vim plugins
- **Nix Language**: Full toolchain with nil LSP, nixfmt formatter
- **Shell Scripting**: Bash/Zsh with shellcheck validation

## Infrastructure & Services

### AI/ML Stack

- **Qdrant**: Vector database for embeddings and similarity search
- **Ollama**: Local LLM serving with automatic startup
- **Both services**: Configured as launchd user agents with logging and resource limits

### Database Tools

- **PostgreSQL**: Full client tools installation
- **SQLite**: Lightweight database for local development
- **MySQL**: Client configuration with custom prompt and auto-rehash

### Container & Orchestration

- **Docker**: Desktop application via Homebrew
- **DevBox**: Development environment isolation
- **Containers**: Policy configuration for insecure local development

## Development Workflow

### Version Control

- **Git Aliases**: Extensive productivity shortcuts including:
  - Branch management (`br`, `rm-merged`, `gone-rm`)
  - Rebase workflows (`ri`, `rb`, `rbc`, `rba`)
  - Stack management (`stack`, `fpstack`)
  - Commit utilities (`amend`, `wip`, `fix`)
- **GitHub CLI**: Integrated for repository management
- **Pre-commit Hooks**: Automated validation with shellcheck, format checking

### Package Management

- **Nix Packages**: Primary package management through Home Manager
- **Homebrew**: macOS GUI applications and tools not in nixpkgs
- **Host-specific Packages**: Per-machine customization through host configurations

### Environment Management

- **Direnv**: Automatic environment loading with nix-direnv integration
- **Project Isolation**: DevBox for project-specific dependencies
- **XDG Directories**: Proper configuration file organization

## Quality & Validation

### Code Quality

- **Shellcheck**: Shell script static analysis
- **shfmt**: Shell script formatting
- **nixfmt**: Nix code formatting
- **Pre-commit**: Git hooks for validation

### Configuration Management

- **Flake Lock**: Pinned dependency versions for reproducibility
- **Make Targets**: Testing and deployment automation
- **Validation**: `nix flake check` for configuration verification

### Home Manager File Management

- **File Creation Behavior**: Home Manager ALWAYS creates symlinks to the Nix store, regardless of `text` vs `source` attributes
- **`text` vs `source` distinction**:
  - `text`: Creates file in Nix store with specified content, then symlinks to it
  - `source`: Symlinks to existing file in Nix store
  - **Both result in symlinks** in the user's home directory
- **Actual File Copies**: Must use activation scripts with `home.activation.*` for real file copies
- **Activation Script Pattern**: Use `lib.hm.dag.entryAfter ["writeBoundary"]` with `${pkgs.tool}/bin/tool` for package references
- **Efficient Updates**: Use `rsync --update` to only copy when content changes, avoiding unnecessary file operations

## Custom Tooling

### Shell Applications

Custom scripts packaged as Nix shell applications:

- **nix-refresh**: Intelligent system update with fallback logic
- **dff**: Directory comparison utility
- **find-and-replace**: Text replacement tool
- **status-getcpu/getload**: System monitoring for tmux status

### Shell Utilities

Cross-platform compatibility functions in `shell/util/shell`:

- Shell detection and conditional execution
- Command existence verification
- Path and file management utilities
- Homebrew integration helpers

## Cloud & External Services

### Multi-Cloud Management

- **1Password CLI**: Secure credential management
- **Tailscale**: VPN and mesh networking (via Homebrew)

### Development Services

- **Act**: Local GitHub Actions testing
- **mkcert**: Local SSL certificate generation
- **Wake-on-LAN**: Network device management

## Build & Deployment

### Automation

- **Makefile**: Build targets for testing, switching, and maintenance
- **Remote Bootstrap**: Direct GitHub flake deployment without local checkout
- **Atomic Updates**: Nix generation-based rollback capability

### Dependencies

- **Flake Inputs**: Managed external dependencies
  - nixpkgs (nixos-unstable)
  - home-manager
  - nix-darwin
  - mkAlias utility
- **Lock File**: Reproducible builds across environments

This technology stack provides a modern, reproducible development environment with strong emphasis on automation, cross-platform compatibility, and developer productivity.
