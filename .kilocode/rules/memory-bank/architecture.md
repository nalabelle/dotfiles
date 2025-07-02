# System Architecture

## Core Architecture Pattern

The dotfiles project implements a **modular, declarative configuration system** using Nix flakes as the foundation. The architecture follows a clear separation of concerns with automatic host detection and configuration generation.

## Directory Structure

```
dotfiles/
├── flake.nix                    # Entry point - defines inputs and generates outputs
├── lib/default.nix              # Configuration generator with host auto-discovery
├── nix/                         # Core system configurations
│   ├── darwin.nix              # macOS system-level settings
│   └── nixos.nix               # Linux system-level settings
├── home/                        # Home Manager modules
│   ├── default.nix             # Base home configuration
│   ├── git.nix                 # Git configuration with productivity aliases
│   ├── vim.nix                 # Vim with plugin ecosystem
│   ├── zsh.nix                 # Shell configuration with Starship prompt
│   ├── tmux.nix                # Terminal multiplexer configuration
│   ├── tools.nix               # Development tools and custom scripts
│   ├── darwin.nix              # macOS-specific home configuration
│   ├── shell.nix               # Shell utilities and integrations
│   ├── fonts.nix               # Font configuration
│   └── vscode.nix              # VS Code configuration
├── hosts/                       # Host-specific configurations
│   ├── tennyson/               # Personal development machine
│   │   ├── darwin-configuration.nix
│   │   └── home-configuration.nix
│   └── bst/                    # Work machine
│       ├── darwin-configuration.nix
│       └── home-configuration.nix
├── config/                      # Application configuration files
│   ├── vim/                    # Vim configuration files
│   ├── vscode/                 # VS Code settings
│   └── kilocode/               # Kilocode extension rule files
├── bin/                         # Custom scripts and utilities
├── shell/                       # Shell utility functions
├── zsh/                        # Zsh-specific configuration files
├── test/                        # Testing infrastructure
│   ├── Dockerfile              # Multi-stage Docker testing
│   └── verify.sh               # Verification scripts
└── .kilocode/                   # Kilocode extension configuration
    └── rules/                  # Memory bank and custom rules
        └── memory-bank/        # Project memory and context files
```

## Configuration Generation Pattern

### Auto-Discovery System

The [`lib/default.nix`](lib/default.nix:44) implements an intelligent configuration generator:

1. **Host Detection**: Automatically scans [`hosts/`](hosts/) directory for available configurations
2. **Configuration Type Detection**: Determines if a host supports:
   - Darwin configuration (if `darwin-configuration.nix` exists)
   - Home Manager configuration (if `home-configuration.nix` exists)
3. **System Architecture Assignment**: Assigns appropriate system architecture based on configuration type

### Configuration Functions

- **`mkDarwinSystem`**: Creates nix-darwin configurations for macOS hosts
- **`mkHomeConfig`**: Creates Home Manager configurations with system-specific paths
- **Fallback Logic**: Provides graceful degradation when host-specific configs are missing

## Module System Architecture

### Home Manager Modules

Each tool/service has its own dedicated module in [`home/`](home/):

- **[`git.nix`](home/git.nix:1)**: Comprehensive Git configuration with 25+ productivity aliases
- **[`vim.nix`](home/vim.nix:1)**: Vim with curated plugin ecosystem (35+ plugins)
- **[`zsh.nix`](home/zsh.nix:1)**: Shell configuration with Starship prompt integration
- **[`tmux.nix`](home/tmux.nix:1)**: Terminal multiplexer with custom key bindings
- **[`tools.nix`](home/tools.nix:1)**: Development tools and custom shell applications

### System Configurations

- **[`nix/darwin.nix`](nix/darwin.nix:1)**: macOS system settings, Homebrew integration, and launchd services
- **[`nix/nixos.nix`](nix/nixos.nix:1)**: Linux system configuration (minimal, primarily imports)

## Service Management Architecture

### macOS Service Integration

The system uses **launchd user agents** for service management:

- **Qdrant Vector Database**: Auto-starts on login with custom storage paths
- **Ollama LLM Service**: Background service for local AI model serving
- **Configuration**: Defined in [`nix/darwin.nix`](nix/darwin.nix:151) with proper logging and resource limits

### macOS Activation Scripts Architecture

**Critical Discovery**: nix-darwin only supports three customizable activation scripts:

- **`preActivation`**: Runs before system configuration
- **`extraActivation`**: Runs during system configuration
- **`postActivation`**: Runs after system configuration (used for Homebrew-dependent operations)

**Invalid Pattern**: Individual `activationScripts."custom-name"` entries are not supported and will be silently ignored.

**Current Implementation**: All custom activation logic consolidated into `postActivation.text` including:

- System settings activation
- Homebrew analytics disable (with proper user environment)
- Screenshot directory creation
- **GUI PATH Configuration**: `launchctl config user path` for Finder-launched applications

**Key Technical Pattern**:

```nix
system.activationScripts.postActivation.text = ''
  # Homebrew operations require user context
  sudo -u ${username} HOME="/Users/${username}" /opt/homebrew/bin/brew analytics off

  # GUI application PATH inheritance
  launchctl config user path /Users/${username}/.nix-profile/bin:...
'';
```

### Environment Integration

- **Direnv**: Automatic environment loading for project directories
- **FZF**: Fuzzy finding integration across shell and tmux

## Kilocode Extension Architecture

### MCP Server Integration

The system integrates with Kilocode's Model Context Protocol (MCP) servers:

- **Context7**: Library documentation and code examples via Nix shell
- **Fetch**: Internet access for up-to-date information via UV
- **GitHub**: Repository management and operations via Docker

### Configuration Management

- **Base Settings**: [`config/vscode/kilocode-mcp-settings.json`](config/vscode/kilocode-mcp-settings.json:1) defines MCP server configurations
- **Host Override**: [`home/vscode.nix`](home/vscode.nix:20) allows host-specific MCP server additions
- **Cross-Platform**: Supports both macOS and Linux VS Code installations

### Rule File Workaround

Due to Kilocode extension bug excluding symlinks:

- **Activation Scripts**: Use [`home.activation.kilocodeRules`](home/vscode.nix:48) for file copying
- **Efficient Updates**: [`rsync --update`](home/vscode.nix:64) only copies when content changes
- **Symlink Detection**: Replaces existing symlinks with actual files
- **File Management**: Global, Python, and TypeScript rule files managed automatically

## Build and Deployment Architecture

### Flake-Based Build System

1. **Input Management**: [`flake.nix`](flake.nix:4) defines all external dependencies
2. **Lock File**: [`flake.lock`](flake.lock) ensures reproducible builds
3. **Output Generation**: Automatic generation of darwin/home configurations

### Update Mechanisms

- **[`nix-refresh`](bin/nix-refresh:1)**: Intelligent update script with fallback logic
- **Configuration Validation**: [`make test`](Makefile:3) provides pre-deployment validation
- **Atomic Updates**: Nix ensures atomic configuration switches

## Custom Script Architecture

### Shell Application Pattern

Custom scripts are packaged as Nix shell applications in [`home/tools.nix`](home/tools.nix:31):

- **[`nix-refresh`](bin/nix-refresh:1)**: System update orchestration
- **[`dff`](bin/dff:1)**: Directory diff utility
- **[`find-and-replace`](bin/find-and-replace:1)**: Text replacement tool
- **[`status-getcpu`](bin/status-getcpu:1)**: CPU count utility for tmux
- **[`status-getload`](bin/status-getload:1)**: Load average utility for tmux

### Shell Utility Functions

[`shell/util/shell`](shell/util/shell:1) provides cross-shell compatibility functions:

- Shell detection (`+shell.zsh`, `+shell.bash`)
- Command existence checking (`+cmd.exists`)
- Path management utilities (`+any.exists`, `+any.executable`)

## Platform-Specific Adaptations

### macOS Integration

- **System Preferences**: Comprehensive macOS defaults configuration
- **Homebrew Integration**: Managed Homebrew packages for GUI applications
- **TouchID sudo**: Enhanced authentication for administrative tasks
- **Screenshot Management**: Custom screenshot directory and settings

### Cross-Platform Considerations

- **Home Directory Paths**: Dynamic path resolution based on system type
- **Package Availability**: Platform-specific package selections
- **Service Management**: launchd on macOS, systemd patterns for Linux

## Configuration Patterns

### Host-Specific Overrides

Hosts can override base configurations through:

- **Additional Homebrew packages**: Host-specific casks and brews
- **Custom system settings**: Per-machine tweaks and preferences
- **Tool-specific configurations**: Host-specific tool versions or settings

### Modular Extension Points

- **Git Aliases**: Extensive productivity-focused Git workflow optimization
- **Vim Plugins**: Curated plugin ecosystem with language-specific support
- **Zsh Configuration**: Custom prompt, completion, and history management
- **Tmux Customization**: Productivity-focused key bindings and status line

### Legacy Shell Script Migration Pattern

The system follows a systematic approach for migrating legacy shell scripts to declarative Nix configuration:

#### Migration Strategy

1. **Analysis Phase**: Examine legacy shell scripts to identify:
   - Tool completions that need preservation
   - Unique shell options not covered by Home Manager defaults
   - Redundant functionality already handled by nix-darwin/Home Manager
   - Unused or commented-out functions

2. **Classification**: Categorize script components as:
   - **MIGRATE**: Functional components requiring declarative equivalents
   - **REDUNDANT**: Functionality superseded by Nix ecosystem tools
   - **CLEANUP**: Unused code that can be safely removed

3. **Implementation Patterns**:
   - **Completions**: `legacy shell completion` → `programs.zsh.completions`
   - **Shell Options**: `sourced option files` → `programs.zsh.initExtra`
   - **Environment Setup**: `manual environment sourcing` → `nix-darwin integration`
   - **Custom Functions**: `shell functions` → `Nix shell applications` or removal if unused

#### Current Migration: ZSH Directory

**Target**: [`zsh/`](zsh/) directory with 4 legacy files
**Pattern Application**:

- `zsh/completions`: MIGRATE tool completions (gt, devbox) to `programs.zsh.completions`
- `zsh/imports`: REDUNDANT Homebrew/Homeshick setup handled by nix-darwin
- `zsh/options`: PARTIALLY REDUNDANT unique globbing/vi-mode settings need migration
- `zsh/prompt`: CLEANUP custom prompt functions (unused, Starship active)

**Success Criteria**: Preserve all functional capabilities while eliminating maintenance burden through declarative configuration management.

This architecture provides a robust foundation for declarative system management while maintaining flexibility for host-specific customization and easy extensibility.
