# rust.md

Coding changes for Rust (*.rs) projects.

## Guidelines

- Use `cargo add` instead of manually editing Cargo.toml to ensure up-to-date dependencies
- Use restrictive visibility by default: prefer `super` > `crate` > `pub` - only expose what is intentionally part of the API
- Never put logic in mod.rs files - use them only for module declarations and re-exports
- Follow Rust naming conventions: snake_case for functions/variables, PascalCase for types
- Prefer explicit error handling with Result<T, E> over panicking
- Write documentation comments (///) for public APIs
- Prefer inline tests (#[cfg(test)] mod tests) over integration tests in a tests/ folder for unit testing
