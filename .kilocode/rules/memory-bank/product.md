# Product Vision

## Why This Project Exists

This dotfiles repository solves the fundamental problem of environment inconsistency across development machines. Traditional dotfiles approaches suffer from:

- **Manual synchronization**: Copying configuration files between machines leads to drift and inconsistencies
- **Platform differences**: Different setup procedures for macOS vs Linux systems  
- **Dependency management**: Applications and tools become out of sync between environments
- **Setup complexity**: New machine setup requires extensive manual configuration
- **Version control gaps**: Many dotfile managers don't handle binary dependencies well

## Problems It Solves

### 1. **Reproducible Development Environments**

- Eliminates "works on my machine" problems by ensuring identical tool versions and configurations
- Provides deterministic builds through Nix's functional package management
- Enables atomic rollbacks to previous working configurations

### 2. **Cross-Platform Consistency**  

- Unified configuration syntax for both macOS (via nix-darwin) and Linux (via home-manager)
- Platform-specific adaptations handled declaratively
- Consistent shell environment, editor setup, and development tools across platforms

### 3. **Automated System Management**

- Declarative system configuration eliminates manual setup steps
- Automatic service management (Qdrant, Ollama) through launchd integration
- Homebrew integration for macOS-specific applications while maintaining Nix benefits

### 4. **Developer Productivity**

- Comprehensive Git aliases and workflow optimizations
- Advanced Vim configuration with curated plugin ecosystem  
- Zsh with intelligent completions, history management, and visual feedback
- Tmux session management with productivity-focused key bindings

## How It Should Work

### **Bootstrapping Experience**

Users should be able to bootstrap a complete development environment with a single command:

```bash
# Remote bootstrap without local checkout
sudo -E nix run nix-darwin -- switch --flake 'github:nalabelle/dotfiles#'$(hostname)
```

### **Configuration Management**

- **Host Discovery**: Automatically detects available host configurations from `hosts/` directory
- **Modular Architecture**: Each tool/service gets its own module for maintainability
- **Fallback Handling**: Graceful fallback to default configurations when host-specific config unavailable

### **Development Workflow**

- **Local Testing**: `make test` validates configurations before applying
- **Safe Updates**: `nix-refresh` script handles both system and home manager updates
- **Version Control**: All configuration changes tracked in Git with pre-commit validation

### **Service Integration**

- **AI/ML Services**: Qdrant vector database and Ollama LLM services auto-start on login
- **Development Tools**: DevBox, direnv, and project-specific environments work seamlessly
- **Cloud Integration**: MCPM (Multi-Cloud Package Manager) provides unified cloud resource access

## User Experience Goals

### **Immediate Productivity**

New machines should be fully productive within minutes of bootstrap completion, with all development tools, aliases, and integrations working immediately.

### **Invisible Complexity**

The underlying Nix complexity should be hidden behind simple commands (`make switch`, `nix-refresh`) while still providing the benefits of reproducibility.

### **Extensibility**

Adding new hosts, tools, or configurations should follow clear patterns established in the existing architecture without requiring deep Nix knowledge.

### **Reliability**

System updates should be atomic and reversible, with clear error messages and recovery procedures when things go wrong.
