# Pre-commit Hooks Flake Module

This module provides a self-contained pre-commit setup for flake-parts projects.

## Usage

Add to your flake inputs:

```nix
inputs.dotfiles = {
  url = "github:nalabelle/dotfiles";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Import the module:

```nix
imports = [
  inputs.dotfiles.flakeModules.pre-commit
];
```

Configure in perSystem:

```nix
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
```

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
- nixfmt-rfc-style

### Custom Hooks
- forbid-binary - Prevents binary files from being committed
- script-must-have-extension - Non-executable shell scripts must end in .sh
- script-must-not-have-extension - Executable shell scripts must not have extensions

## Customization

Override any hook settings:

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

## Disabling the Module

```nix
pre-commit-defaults.enable = false;
```

This will disable all default hooks and the devShell, but you can still configure pre-commit manually.
