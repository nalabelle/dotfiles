# Git Template Source

This directory contains copier template sources for creating new projects with standardized configuration files.

## Template: `template/`

A copier template for bootstrapping new projects with development best practices.

### Included Files

#### Development Quality Tools

- **`.pre-commit-config.yaml`** - Pre-commit hooks for code quality
  - File validation (JSON, YAML, TOML, XML)
  - Code formatting and linting
  - Shell script validation with shellcheck
  - Binary file prevention and script standards

- **`devbox.json`** - Development environment configuration
  - Includes essential tools: shellcheck, pre-commit
  - Provides consistent development environment across projects

#### Project Management

- **`renovate.json`** - Automated dependency updates
  - Configured to use shared renovate configuration
  - Ensures dependencies stay up-to-date automatically

#### Kilocode Integration

- **`.kilocode/rules/memory-bank-instructions.md`** - Memory bank setup
  - Instructions for AI assistant memory management
  - Enables consistent project context across sessions

#### Git Configuration

- **`hooks/pre-commit`** - Git pre-commit hook implementation
  - Integrates with pre-commit framework
  - Ensures code quality before commits

### Usage with Copier

Bootstrap new projects with this template:

```bash
copier copy path/to/dotfiles/git/template /path/to/new/project
```

### Template Benefits

- **Code Quality**: Automated linting and formatting enforcement
- **Consistency**: Standardized project structure and tooling
- **Automation**: Dependency updates and quality checks
- **AI Integration**: Memory bank system for enhanced development workflow

### Post-Template Customization

After copying, customize the template files for your specific project:

1. Update `devbox.json` with project-specific tools
2. Modify `.pre-commit-config.yaml` for language-specific hooks
3. Initialize memory bank files for project context
4. Configure additional development tools as needed
