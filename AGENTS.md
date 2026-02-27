# Agents Guide for Dotfiles Repository

Nix flake-based dotfiles managing macOS (nix-darwin) and Linux (home-manager)
configurations. Primary languages: **Nix** and **Bash**.

## Build/Test/Lint Commands

### Testing

Tests = successful Nix builds. No unit test framework.

```sh
make test                    # Build configs for current OS (mirrors CI)
make test-darwin             # macOS only: build Darwin + home-manager configs
make test-linux              # Linux only: build home-manager config
```

Build a single configuration directly:

```sh
# Darwin system config
nix build .#darwinConfigurations.tennyson.system

# Home-manager configs (pick one)
nix build .#homeConfigurations."nalabelle@darwin".activationPackage
nix build .#homeConfigurations."nalabelle@chandler".activationPackage
nix build .#homeConfigurations."nalabelle@doyle".activationPackage
nix build .#homeConfigurations."nalabelle@linux".activationPackage
```

### Linting and Formatting

```sh
pre-commit run --all-files   # Run all checks (nixfmt, shellcheck, etc.)
pre-commit run nixfmt --all-files      # Only Nix formatting
pre-commit run shellcheck --all-files  # Only shell linting
```

The `.pre-commit-config.yaml` is **auto-generated** by `flakeModules/pre-commit/`.
Do NOT edit it directly -- modify `flakeModules/pre-commit/pre-commit.nix` instead.

### Applying Configurations

```sh
make switch          # Apply system + home config (darwin-rebuild or home-manager)
make home-switch     # Apply home-manager config only
make update          # nix flake update
make gc              # Garbage collect old generations
make clean           # Remove result symlink
```

### Dev Shell

Enter with `nix develop` or `direnv allow`. Provides pre-commit hooks, nixd LSP,
and shellcheck.

## Project Structure

```
flake.nix                  # Entry point: inputs, outputs, flake-parts
lib/default.nix            # mkDarwinSystem, mkHomeConfig helpers
nix/common.nix             # Shared system config (Nix settings, users)
nix/darwin.nix             # Darwin-specific system config
home/default.nix           # Home-manager aggregator (imports all home/*.nix)
home/*.nix                 # One concern per file (git, zsh, vim, tmux, etc.)
hosts/<name>/*.nix         # Per-host overrides (darwin-configuration, home-configuration)
packages/*.nix             # Custom package derivations
flakeModules/pre-commit/   # Reusable pre-commit flake module
bin/                       # Shell scripts (wrapped via writeShellApplication)
config/                    # Raw config files (vim, vscode, kilocode)
```

## Code Style Guidelines

### Nix Files (*.nix)

- **Formatting**: Enforced by `nixfmt` via pre-commit. 2-space indent.
- **Module arguments**: Set pattern with one arg per line, always end with `...`:
  ```nix
  {
    config,
    lib,
    pkgs,
    ...
  }:
  ```
- **Only list arguments that are actually used** in the file.
- **Imports**: Use relative paths (`./git.nix`, `../config/vim/base.vim`).
  Each `default.nix` aggregates sibling modules via `imports = [ ... ];`.
- **`lib` usage**:
  - `lib.mkDefault` for overridable defaults
  - `lib.mkIf` for conditional config (e.g., `lib.mkIf pkgs.stdenv.isDarwin`)
  - `lib.mkBefore` / `lib.mkAfter` for ordering shell init fragments
  - `lib.mkOption` with `lib.types.*` for custom options
  - `lib.hm.dag.entryAfter` for home-manager activation ordering
- **`with pkgs;`**: Use in list contexts (packages) only, never for attribute sets.
- **`inherit`**: Prefer for destructuring in `let` blocks:
  ```nix
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;
  ```
- **`let ... in`**: Place after function header, indent one level.
- **Lists**: One item per line, closing `];` on its own line.
- **Conditional imports**: Use `builtins.pathExists` for optional host-specific files.
- **Naming**: camelCase for variables and functions (`mkDarwinSystem`, `profileSettings`).
- **Comments**: `#` only. Describe "why", not "what". Use sparingly.

### Shell Scripts (bin/*)

- **Strict mode**: `set -euo pipefail` at the top of non-trivial scripts.
- **No file extension** on executable scripts (enforced by pre-commit).
  Non-executable scripts must end in `.sh`.
- **Shebang**: `#!/usr/bin/env bash` preferred. Use `#!/bin/sh` for POSIX-only scripts.
- **Quoting**: Always double-quote variable expansions (`"$1"`, `"$var"`).
- **Functions**: `name() {` syntax (no `function` keyword). Use `local` for scoped vars.
- **Naming**: `snake_case` for functions and local variables, `UPPER_CASE` for constants.
- **Error output**: Print errors/status to stderr (`>&2`).
- **Script structure**: shebang, set flags, constants, helper functions, `main()`, `main "$@"`.
- **Input validation**: Check argument counts early, print usage to stderr, exit 1.
- **writeShellApplication**: Scripts are wrapped in `home/tools.nix` with explicit `runtimeInputs`.

### File Formatting (all files)

Enforced via `.editorconfig`:

| File type       | Indent  | Size |
|-----------------|---------|------|
| Default (`*`)   | spaces  | 2    |
| `*.{py,pyi}`    | spaces  | 4    |
| `*.{go,rs}`     | tabs    | -    |
| `Makefile`      | tabs    | -    |
| `*.{yml,yaml}`  | spaces  | 2    |
| `*.json`        | spaces  | 2    |

Global: UTF-8, LF line endings, final newline, trim trailing whitespace (except `*.md`).

### JSON/JSONC

- 2-space indent. Include `$schema` field where applicable.
- camelCase for property names.
- Preserve existing comments in JSONC files -- they explain non-obvious settings.

### YAML

- 2-space indent. Pin GitHub Actions versions with SHA + version comment:
  ```yaml
  uses: actions/checkout@<sha> # v6
  ```

### Makefile

- Tab indent. `.PHONY` before every target.
- `## comment` suffix on targets for auto-help via `make help`.
- Strict shell: `SHELL := bash`, `.SHELLFLAGS := -eu -o pipefail -c`.

## Naming Conventions

- **Files**: kebab-case (`darwin-configuration.nix`, `template-diff`).
  Simple module names use plain lowercase (`shell.nix`, `git.nix`).
- **Directories**: lowercase (`home/`, `hosts/`, `nix/`).
  Exception: `flakeModules` follows flake-parts convention.
- **Nix variables/functions**: camelCase (`mkHomeConfig`, `configDir`).
- **Shell variables**: snake_case locals, UPPER_CASE constants.

## Error Handling

- **Nix**: Use `lib.mkIf` for platform conditionals. Use `builtins.pathExists`
  for optional file inclusion. Never use `builtins.abort` in module code.
- **Shell**: Always `set -euo pipefail`. Validate inputs early. Exit 1 on failure.
  Print errors to stderr. Use `|| true` only when failure is expected.

## Pre-commit Hooks (enforced in CI)

- `nixfmt` -- Nix formatting
- `shellcheck` -- Shell linting
- `end-of-file-fixer`, `trim-trailing-whitespace`, `mixed-line-endings`
- `check-json`, `check-toml`, `check-xml`, `check-yaml`
- `check-executables-have-shebangs`, `check-merge-conflicts`, `check-case-conflicts`
- `forbid-binary` -- No binary files
- `script-must-not-have-extension` -- Executable shell scripts have no extension
- `script-must-have-extension` -- Non-executable shell scripts end in `.sh`

## CI Pipeline

GitHub Actions on push/PR to `main`:
1. **pre-commit** -- Lint/format checks (ubuntu)
2. **build-home-manager** -- Build `nalabelle@chandler` (ubuntu)
3. **build-darwin** -- Build `tennyson` system + `nalabelle@darwin` home (macos-15)
4. **build-home-manager-darwin** -- Package home-manager artifact (macos-15)

All jobs depend on pre-commit passing first.
