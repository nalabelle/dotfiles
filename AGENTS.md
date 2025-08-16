# Agents Guide for Dotfiles Repository

## Build/Test/Lint Commands
- `make test` - Run all tests (includes JS tests + Nix builds for current OS)
- `make test-js` - Test JavaScript utilities only
- `cd packages/merge-vscode-settings && npm test` - Run single JS package tests
- `nix build .#darwinConfigurations.tennyson.system` - Test Darwin config
- `nix build .#homeConfigurations."nalabelle@darwin".activationPackage` - Test home config
- `pre-commit run --all-files` - Run linting/formatting checks

## Code Style Guidelines
- **Indentation**: 2 spaces for most files, 4 for Python, tabs for Go/Rust/Makefile
- **Line endings**: LF, UTF-8 encoding, final newline required
- **Nix**: Use explicit imports, prefer `lib.mkDefault`, follow existing module structure
- **JavaScript**: Use `const`/`let`, avoid `var`, prefer explicit error handling with try/catch
- **File organization**: Group imports at top, maintain consistent module structure
- **Naming**: Use kebab-case for files, camelCase for JS variables, descriptive names
- **Comments**: Preserve existing comments in JSON/JSONC files, minimal comments elsewhere
- **Error handling**: Always handle errors explicitly, use proper exit codes (0/1)
