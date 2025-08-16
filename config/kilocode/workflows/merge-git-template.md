# Git Template Merge Workflow

This workflow guides you through comparing a project with the git-template baseline and applying beneficial changes.

## Step 1: Run template comparison

Execute the template-diff tool to see differences:

```bash
template-diff
```

## Step 2: Analyze diff output

The template-diff tool compares only files that exist in the template (left join) and shows how your project differs from the template baseline:

### Project additions (lines with `+`)

- These show what your project has added beyond the template
- **Action:** Evaluate if these are still needed and beneficial
- Could be valuable improvements OR outdated additions that should be removed
- Examples: additional pre-commit hooks, extra development tools, project-specific configurations

### Template baseline content (lines with `-`)

- These show template content that's not in your project
- **Action:** Evaluate if these should be added to your project
- Consider if the template approach might be better than your current implementation

### Missing template files

- Files that exist in template but not in your project
- **Action:** Evaluate if they would benefit your project
- Use `write_to_file` to add beneficial template files

### Files that match perfectly

- No diff output means the file matches the template exactly
- **Action:** No changes needed

## Step 3: Apply selected changes

For each template improvement you want to adopt:

1. **For missing template files:**
   - Copy the full template content shown in the output
   - Use `write_to_file` to create the file in your project

2. **For template content to adopt (- lines):**
   - Use `read_file` to see your current project version
   - Decide what template content (- lines) to adopt
   - Use `apply_diff` or `write_to_file` to merge the beneficial template content

3. **For project additions to keep or remove (+ lines):**
   - Evaluate if these additions are still useful
   - Remove outdated additions or keep beneficial ones
   - Consider if the template's simpler approach might be better

## Step 4: Common file handling strategies

### Configuration files (.editorconfig, .pre-commit-config.yaml, renovate.json)

- Generally safe to adopt template version
- Template versions usually have better/newer standards

#### Renovate configuration migration

**Important:** Projects may still reference the deprecated external Renovate configuration repository.

- **What to look for:** Check if `renovate.json` extends `github>nalabelle/renovate-config`
- **Required action:** Update to use the new dotfiles-based configuration:

  ```json
  {
    "$schema": "https://docs.renovatebot.com/renovate-schema.json",
    "extends": ["github>nalabelle/dotfiles//git/renovate/default.json5"]
  }
  ```

- **Context:** The external `renovate-config` repository has been migrated and consolidated into the dotfiles repository at `git/renovate/default.json5`
- **Template reference:** The git template already uses the new configuration path

#### Pre-commit workflow duplication check

Before adding or updating pre-commit workflows from the template:

- **Check for existing pre-commit workflows** in the project. Some repositories may already have pre-commit integrated into other workflows (such as `ci.yml` or consolidated CI/CD files).
- **How to identify existing pre-commit setups:**
  - Inspect `.github/workflows/` for any workflow files that include pre-commit steps.
  - Look for jobs or steps named `pre-commit` or referencing `pre-commit run` in consolidated workflows.
  - Avoid creating duplicate standalone pre-commit workflows if pre-commit is already covered by another workflow.
- Only add or update pre-commit workflows if they are missing or not already handled by existing CI/CD configuration.

### Environment files (.envrc, shell.nix, flake.nix)

- Merge carefully - preserve project-specific dependencies
- Add template tools that benefit the project
- Keep project-specific environment variables and tools

### Documentation (README.md)

- Usually keep project version
- Only adopt structural improvements from template

### Ignore files (.gitignore)

- Merge both sets of patterns
- Add template patterns that apply to project type
- Keep project-specific ignore patterns

## Step 5: Test changes

After applying template changes:

1. Verify the project still builds/runs correctly
2. Test any new tools or configurations added from template
3. Commit changes with descriptive message about template updates applied

This workflow ensures you get template improvements while preserving project-specific functionality.
