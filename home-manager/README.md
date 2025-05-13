# Home-Manager Config

This repository contains a modular Nix flake configuration for managing both NixOS (Linux) and
nix-darwin (macOS) systems, as well as standalone home-manager configurations.

## Directory Structure

```
flake.nix
├─ ./hosts
│   └─ default.nix    # Linux system configurations
├─ ./darwin
│   ├─ default.nix    # macOS system configurations
│   ├─ darwin-configuration.nix  # macOS system settings
│   └─ host-users.nix  # Host and user settings
├─ ./nix
│   └─ default.nix    # Home Manager configurations
└─ ./modules          # Reusable configuration modules
    ├─ base.nix       # Base configuration for all systems
    ├─ ./shell        # Shell configuration modules
    ├─ ./terminal     # Terminal configuration modules
    ├─ ./dev          # Development tools configuration modules
    └─ ./macos        # macOS-specific configuration modules
```

## Installation

```sh
# Install xcode
xcode-select --install
softwareupdate --install-rosetta --agree-to-license

# Install Nix (if not already installed)
sh <(curl -L https://nixos.org/nix/install) --no-daemon
# or
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# Follow instructions
```

## Usage

### For macOS systems

```sh
# Switch to the darwin configuration
darwin-rebuild switch --flake .#tennyson
```

### For Linux systems

```sh
# Switch to the NixOS configuration
nixos-rebuild switch --flake .#hostname
```

### For standalone Home Manager

```sh
# For macOS
nix run . -- switch --flake .#aarch64-darwin

# For Linux
nix run . -- switch --flake .#x86_64-linux
```

## Adding New Systems

To add a new system:

1. For Linux: Edit `hosts/default.nix` to add your new system configuration
2. For macOS: Edit `darwin/default.nix` to add your new system configuration
3. For Home Manager: Edit `nix/default.nix` to add your new home configuration

## Adding New Modules

To add a new module:

1. Create a new directory in `modules/` or add a file to an existing directory
2. Update the appropriate `default.nix` file to import your new module
3. Add your configuration to the new module file

## Updating

```sh
# Update flake inputs
nix flake update
```
