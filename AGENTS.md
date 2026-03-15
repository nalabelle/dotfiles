# Agents Guide for Dotfiles Repository

Nix flake-based dotfiles managing macOS (nix-darwin) and Linux (home-manager)
configurations. Primary languages: **Nix** and **Bash**.

## Build/Test/Lint Commands

### IMPORTANT: Dev Shell Required

Most commands (`make`, `nix fmt`, `shellcheck`, etc.) require tools provided
by the Nix dev shell. If a command fails with "command not found", you are not
in the dev shell. Fix this by prefixing commands with `nix develop --command`:

```sh
nix develop --command make test
nix develop --command nix fmt
```

Alternatively, enter the shell first with `nix develop` or `direnv allow`, then
run commands normally. The only commands that work without the dev shell are
`nix build` and `nix flake` (they only need Nix itself).

### Testing

Tests = successful Nix builds. No unit test framework.

```sh
make test                    # Build configs for current OS (mirrors CI)
make test-darwin             # macOS only: build Darwin + home-manager configs
make test-linux              # Linux only: build home-manager config
```

Build a single configuration directly (works without dev shell):

```sh
nix build .#darwinConfigurations.tennyson.system
nix build .#homeConfigurations."nalabelle@chandler".activationPackage
nix build .#homeConfigurations."nalabelle@doyle".activationPackage
nix build .#homeConfigurations."nalabelle@darwin".activationPackage
nix build .#homeConfigurations."nalabelle@linux".activationPackage
```

### Linting and Formatting

```sh
nix fmt                                    # Format all files (treefmt)
nix flake check                            # Run all checks (formatting + linting)
lefthook run                               # Run git hooks manually
```

Configuration is managed via the `git-hooks` flake module from `github:nalabelle/git-hooks`.

### Other Make Targets

```sh
make switch          # Apply system + home config (darwin-rebuild or home-manager)
make home-switch     # Apply home-manager config only
make update          # nix flake update
make gc              # Garbage collect old generations
make clean           # Remove result symlink
```

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
bin/                       # Shell scripts (wrapped via writeShellApplication)
config/                    # Raw config files (vim, vscode, etc.)
```

## Code Style Guidelines

### Nix Files (*.nix)

- **Formatting**: Enforced by `nixfmt` via treefmt. 2-space indent.
- **Module arguments**: Set pattern, one arg per line, always end with `...`:
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
- **`lib` usage**: `lib.mkDefault` for overridable defaults, `lib.mkIf` for
  conditionals, `lib.mkBefore`/`lib.mkAfter` for ordering, `lib.mkOption`
  with `lib.types.*` for custom options, `lib.hm.dag.entryAfter` for
  activation ordering.
- **`with pkgs;`**: Use in list contexts (packages) only, never for attribute sets.
- **`inherit`**: Prefer for destructuring in `let` blocks:
  ```nix
  inherit (lib) mkOption types;
  ```
- **`let ... in`**: Place after function header, indent one level.
- **Lists**: One item per line, closing `];` on its own line.
- **Conditional imports**: Use `builtins.pathExists` for optional host-specific files.
- **Naming**: camelCase for variables and functions (`mkDarwinSystem`, `configDir`).
- **Comments**: `#` only. Describe "why", not "what". Use sparingly.

### Shell Scripts (bin/*)

- **Strict mode**: `set -euo pipefail` at the top of non-trivial scripts.
- **No file extension** on executable scripts (enforced by git-hooks).
  Non-executable scripts must end in `.sh`.
- **Shebang**: `#!/usr/bin/env bash` preferred. `#!/bin/sh` for POSIX-only.
- **Quoting**: Always double-quote variable expansions (`"$1"`, `"$var"`).
- **Functions**: `name() {` syntax (no `function` keyword). Use `local` for scoped vars.
- **Naming**: `snake_case` for functions/locals, `UPPER_CASE` for constants.
- **Error output**: Print errors/status to stderr (`>&2`).
- **Structure**: shebang, set flags, constants, helper functions, `main()`, `main "$@"`.
- **writeShellApplication**: Scripts are wrapped in `home/tools.nix` with explicit `runtimeInputs`.

### File Formatting

Enforced via `.editorconfig`:

| File type       | Indent  | Size |
|-----------------|---------|------|
| Default (`*`)   | spaces  | 2    |
| `*.{py,pyi}`    | spaces  | 4    |
| `*.{go,rs}`     | tabs    | -    |
| `Makefile`      | tabs    | -    |

Global: UTF-8, LF line endings, final newline, trim trailing whitespace (except `*.md`).

### JSON/JSONC

- 2-space indent. Include `$schema` field where applicable. camelCase properties.
- Preserve existing comments in JSONC files.

### YAML

- 2-space indent. Pin GitHub Actions versions with SHA + version comment:
  ```yaml
  uses: actions/checkout@<sha> # v6
  ```

### Makefile

- Tab indent. `.PHONY` before every target. `## comment` suffix for auto-help.
- Strict shell: `SHELL := bash`, `.SHELLFLAGS := -eu -o pipefail -c`.

## Naming Conventions

- **Files**: kebab-case (`darwin-configuration.nix`). Simple modules: lowercase (`git.nix`).
- **Directories**: lowercase. Exception: `flakeModules` (flake-parts convention).
- **Nix variables/functions**: camelCase (`mkHomeConfig`, `configDir`).
- **Shell variables**: snake_case locals, UPPER_CASE constants.

## Error Handling

- **Nix**: `lib.mkIf` for platform conditionals. `builtins.pathExists` for optional
  file inclusion. Never use `builtins.abort` in module code.
- **Shell**: Always `set -euo pipefail`. Validate inputs early. Exit 1 on failure.
  Errors to stderr. `|| true` only when failure is expected.

## Git Hooks (enforced in CI)

Formatting: `nixfmt`, `end-of-file-fixer`, `trim-trailing-whitespace-fixer`,
`mixed-line-endings`, `fix-byte-order-marker`.

Linting: `shellcheck`, `check-json`, `check-toml`, `check-xml`, `check-yaml`,
`check-executables-have-shebangs`, `check-shebang-scripts-are-executable`,
`check-merge-conflicts`, `check-symlinks`, `check-case-conflicts`,
`forbid-binary`, `script-must-not-have-extension`, `script-must-have-extension`.

## CI Pipeline

GitHub Actions on push/PR to `main` (`ci.yml`):
1. **checks** -- Lint/format checks (ubuntu)
2. **build-linux** -- Build `nalabelle@chandler` and `nalabelle@doyle` (ubuntu)
3. **build-darwin** -- Build `tennyson` system config (macos-15)

All build jobs depend on checks passing first.

Separate workflow (`ci-darwin.yml`, push to `main` only): packages home-manager
config as a distributable artifact via `make package-home`.
