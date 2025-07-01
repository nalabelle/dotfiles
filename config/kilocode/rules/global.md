# global.md

Common guidelines for all projects.

## Guidelines

- Follow the project's coding style and conventions.
- Run `pre-commit run --all-files` to check for linting and formatting issues before considering a task done. Fix any issues that arise. This will also run build and tests.
- If there's no pre-commit config, prompt the user about whether one needs to be added.
- Add dependencies via command-line instead of editing project config files to ensure dependencies are up to date

## Code Simplicity Principles

### Prioritize Code Locality

- **Keep related logic together**: Place code near where it's used rather than creating distant abstractions
- **Minimize indirection**: Avoid unnecessary layers, wrappers, or abstractions that obscure the actual logic
- **Favor explicit over implicit**: Prefer clear, direct code over clever abstractions that require mental mapping

### Eliminate Compatibility Layers

- **Never create compatibility functions/layers unless explicitly requested** by the user
- **Remove existing compatibility code** when it's no longer needed or can be simplified
- **Choose one approach**: When multiple solutions exist, pick the best one and eliminate alternatives

### Simplification Mindset

- **Always look for ways to eliminate code and logic branches**
- **Question every abstraction**: Does this layer actually provide value or just add complexity?
- **Prefer deletion over addition**: Removing code is often more valuable than adding features
- **Consolidate similar logic**: Merge duplicate or near-duplicate code paths when possible
- **Remove dead code**: Eliminate unused functions, variables, and imports immediately

### Decision Framework

When faced with multiple implementation options:

1. **Direct solution**: Can this be solved without abstraction?
2. **Existing patterns**: Does the codebase already handle this case?
3. **Simplest approach**: Which option requires the least code and mental overhead?
4. **Future maintenance**: Which approach will be easiest to understand and modify later?

### Logging Guidelines

- **Use DEBUG/TRACE by default**: Most logging should be at debug or trace level
- **Reserve INFO/WARN for very important things**: Only use higher levels for critical events
- **Developers can increase logging levels** when troubleshooting specific issues
- **Avoid chatty logs**: Don't log every function entry/exit or routine operations
- **Log meaningful events**: Focus on state changes, errors, and important business logic

### Examples of What to Avoid

- Creating utility functions for single-use cases
- Building configuration layers when direct configuration suffices
- Adding feature flags or compatibility modes without clear necessity
- Keeping "just in case" code that isn't actively used
- Creating abstractions to handle hypothetical future requirements
- Verbose logging that clutters output during normal operation
