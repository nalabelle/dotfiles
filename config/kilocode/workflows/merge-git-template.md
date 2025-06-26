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

### Environment files (.envrc, devbox.json)

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
