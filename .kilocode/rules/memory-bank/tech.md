# Technology Stack

## Core Technologies

### Nix Ecosystem

- **Nix Package Manager**: Functional package manager with reproducible builds
- **Nix Flakes**: Modern dependency management and configuration system
- **Home Manager**: Declarative user environment management
- **nix-darwin**: macOS system configuration through Nix
- **nixpkgs**: Comprehensive package collection (using nixos-unstable channel)

## Development Environment

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


## Development Workflow

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

- **Pre-commit**: Git hooks for validation

### Configuration Management

- **Flake Lock**: Pinned dependency versions for reproducibility
- **Make Targets**: Testing and deployment automation

### Home Manager File Management

- **File Creation Behavior**: Home Manager ALWAYS creates symlinks to the Nix store, regardless of `text` vs `source` attributes
- **`text` vs `source` distinction**:
  - `text`: Creates file in Nix store with specified content, then symlinks to it
  - `source`: Symlinks to existing file in Nix store
  - **Both result in symlinks** in the user's home directory
- **Actual File Copies**: Must use activation scripts with `home.activation.*` for real file copies
- **Activation Script Pattern**: Use `lib.hm.dag.entryAfter ["writeBoundary"]` with `${pkgs.tool}/bin/tool` for package references
- **Efficient Updates**: Use `rsync --update` to only copy when content changes, avoiding unnecessary file operations

## Build & Deployment

### Dependencies

- **Flake Inputs**: Managed external dependencies
  - nixpkgs (nixos-unstable)
  - home-manager
  - nix-darwin
  - mkAlias utility
- **Lock File**: Reproducible builds across environments

This technology stack provides a modern, reproducible development environment with strong emphasis on automation, cross-platform compatibility, and developer productivity.
