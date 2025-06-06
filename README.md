# Dotfiles

This repository contains a modular Nix flake configuration for managing both NixOS (Linux) and
nix-darwin (macOS) systems, as well as standalone home-manager configurations.

## Prerequisites

### macOS Setup

```sh
# Install Xcode Command Line Tools
xcode-select --install
softwareupdate --install-rosetta --agree-to-license
```

### Install Nix

```sh
# Option 1: Official installer
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Option 2: Determinate Systems installer (recommended)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

After installation, restart your terminal or source the nix profile:

```sh
source ~/.nix-profile/etc/profile.d/nix.sh
```

## Quick Setup

### Bootstrap Without Local Checkout

You can bootstrap your system directly from GitHub without cloning the repository:

```sh
# For macOS with nix-darwin
sudo -E HOME=$HOME nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake 'github:nalabelle/dotfiles#'$(hostname)

# For Linux with NixOS
sudo nix --extra-experimental-features "nix-command flakes" run nixpkgs#nixos-rebuild -- switch --flake 'github:nalabelle/dotfiles#'$(hostname)

# For standalone Home Manager
nix --extra-experimental-features "nix-command flakes" run home-manager/master -- switch --flake 'github:nalabelle/dotfiles#'$(whoami)@$(hostname)
```

### Local Development Setup

```sh
# Clone the repository
git clone https://github.com/nalabelle/dotfiles.git
cd dotfiles

# Test the configuration
make test

# Apply the configuration
make switch

# Update flake inputs
make update
```
