# Agents

## Version Control

Use `jj` (Jujutsu) instead of `git` for all VCS operations (commit, status, diff, etc.).

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. Each commit message must be structured as:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature (correlates with a MINOR version bump in SemVer)
- **fix**: A bug fix (correlates with a PATCH version bump)
- **docs**: Documentation-only changes
- **style**: Changes that do not affect the meaning of code (whitespace, formatting)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding or correcting tests
- **build**: Changes that affect the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files

### Rules

- Use lowercase for the type and description.
- Do not end the description with a period.
- Use the imperative mood in the description (e.g., "add" not "added" or "adds").
- Append `!` after the type/scope for breaking changes (e.g., `feat!: remove deprecated API`).
- A `BREAKING CHANGE:` footer may also be used to describe breaking changes.

## Formatting

Run `nix fmt` after making changes.
