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

## Bootstrapping Without Local Checkout

You can bootstrap your system directly from GitHub without a local checkout:

```sh
# For macOS
sudo -E HOME=$HOME nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake 'github:nalabelle/dotfiles?dir=home-manager#'$(hostname)

# For Linux
sudo nix --extra-experimental-features "nix-command flakes" run nixpkgs#nixos-rebuild -- switch --flake 'github:nalabelle/dotfiles?dir=home-manager#'$(hostname)

# For standalone Home Manager
nix --extra-experimental-features "nix-command flakes" run home-manager/master -- switch --flake 'github:nalabelle/dotfiles?dir=home-manager#'$(whoami)@$(hostname)
```

## Updating

```sh
# Update flake inputs
nix flake update
```
