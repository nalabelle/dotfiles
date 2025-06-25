# Git Template System

This directory contains a universal template foundation that can be used by this dotfiles repository and other projects via git subtree.

## Template Structure

- `git/template/` - Universal foundation files for any project
- Root directory - Template foundation + dotfiles-specific overlays

## Applying Template to Dotfiles Root

To apply the template foundation to this dotfiles repository root:

```bash
# Apply template foundation to root using git subtree
git subtree pull --prefix=. --strategy=subtree main --squash --allow-unrelated-histories

# Alternative: merge template directory to root
git read-tree --prefix=/ -u main:git/template/
```

Git will naturally handle any conflicts between template and existing files.

## Using Template in Other Projects

Other projects can pull template files via git subtree:

### Initial Setup

```bash
# Add template as subtree in your project
git subtree add --prefix=standards \
    https://github.com/nalabelle/dotfiles.git main:git/template --squash
```

### Pull Updates

```bash
# Update template files from dotfiles repo
git subtree pull --prefix=standards \
    https://github.com/nalabelle/dotfiles.git main:git/template --squash
```

### Selective File Copy

If you only want specific files:

```bash
# Show available template files
git show main:git/template/

# Copy specific files
git show main:git/template/.pre-commit-config.yaml > .pre-commit-config.yaml
git show main:git/template/devbox.json > devbox.json
```

## Template Files

Current template provides:

- `.editorconfig` - Universal editor configuration
- `.envrc` - Devbox integration for direnv
- `.pre-commit-config.yaml` - Standard pre-commit hooks
- `devbox.json` - Development environment setup
- `renovate.json` - Dependency update automation

## Workflow

1. **Template Maintenance**: Keep `git/template/` clean and universal
2. **Dotfiles Usage**: Root files = template + dotfiles-specific extensions
3. **Other Projects**: Use git subtree to pull template selectively
4. **Updates**: Template changes propagate via git subtree pull

This approach leverages git's native merge capabilities instead of custom tooling.
