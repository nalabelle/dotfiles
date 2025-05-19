# Home-Manager Config

This repository contains a modular Nix flake configuration for managing both NixOS (Linux) and
nix-darwin (macOS) systems, as well as standalone home-manager configurations.

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

## Updating

```sh
# Update flake inputs
nix flake update
```
