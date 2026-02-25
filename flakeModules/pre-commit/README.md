# Pre-commit Hooks Flake Module

This module provides a self-contained pre-commit setup for flake-parts projects.

## Usage

This module is designed for flake-parts projects. Here's a complete minimal example:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dotfiles = {
      url = "github:nalabelle/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.dotfiles.flakeModules.pre-commit
      ];

      perSystem = { config, pkgs, ... }: {
        # Customize hooks if needed
        pre-commit.settings.hooks = {
          # your customizations
        };

        # Compose the pre-commit devShell into your default shell
        devShells.default = pkgs.mkShell {
          inputsFrom = [ config.devShells.pre-commit ];
          buildInputs = [ pkgs.nodejs ];
        };
      };

      systems = [ "x86_64-linux" "aarch64-darwin" ];
    };
}
```

**Note:** The `dotfiles` input provides `git-hooks` and `jumanjihouse-hooks` transitively, so you don't need to declare them.

## What This Module Provides

- `config.devShells.pre-commit` - A dev shell with pre-commit installed and configured
- `config.formatter` - Set to run pre-commit on all files
- `config.pre-commit.*` - All git-hooks.nix options and settings

## Default Hooks

The module enables these hooks by default:

### File Integrity

- fix-byte-order-marker
- check-case-conflicts
- check-executables-have-shebangs
- check-json
- check-merge-conflicts
- check-shebang-scripts-are-executable
- check-symlinks
- check-toml
- check-xml
- check-yaml
- end-of-file-fixer
- mixed-line-endings
- trim-trailing-whitespace

### Language-Specific

- shellcheck
- nixfmt

### Custom Hooks

- forbid-binary - Prevents binary files from being committed
- script-must-have-extension - Non-executable shell scripts must end in .sh
- script-must-not-have-extension - Executable shell scripts must not have extensions

## Customization

### Override Hook Settings

```nix
pre-commit.settings.hooks = {
  # Disable a default hook
  shellcheck.enable = false;

  # Customize a hook
  forbid-binary.excludes = [ "test/fonts/.*\\.otf$" ];

  # Add your own hooks
  prettier.enable = true;
};
```

### Enable Formatter (runs pre-commit in `nix flake check`)

By default, the formatter is disabled. To enable it:

```nix
pre-commit-defaults.enableFormatter = true;
```

This will run `pre-commit run --all-files` as part of `nix flake check`.

### Disable the Module

```nix
pre-commit-defaults.enable = false;
```

This will disable all default hooks and the devShell, but you can still configure pre-commit manually.
