# Contributing to captain-contraption

Thank you for your interest in contributing to captain-contraption!

We're building a useful collection of shell scripts for Linux system administration, and we'd love your help. Whether you're fixing a typo, reporting a bug, suggesting a feature, or writing code, **all contributions are welcome and appreciated**.

## First Time Contributing?

**No worries!** Everyone starts somewhere. Here are some easy ways to get started:

- **Fix typos or improve documentation** - Found confusing wording in README or a script? Improvements are welcome!
- **Report bugs** - Even if you can't fix it yourself, telling us about problems helps everyone
- **Test on different systems** - Try scripts on your system and share your experience (especially BSD!)
- **Suggest new utilities** - Have a useful admin script? Share it!
- **Ask questions** - Not sure how something works? Open an issue and ask!

We're friendly and patient with new contributors. Don't be shy!

## How to Contribute

### Reporting Bugs

Found a bug? Please open an issue and include:

- **What you expected to happen**
- **What actually happened**
- **Steps to reproduce** (if possible)
- **Your environment** (OS, shell version, relevant tool versions)
- **Error messages or logs** (if any)

**Example:**

```
Expected: aide-check should validate the integrity database
Actual: Script fails with "aide.conf not found" error
Steps: Run aide-check without a configuration file
Environment: Fedora 40, bash 5.2.26
Error: ERROR: aide.conf not found
```

### Suggesting Features or Improvements

Have an idea? We'd love to hear it! Open an issue with:

- **The problem you're trying to solve** or the use case you have in mind
- **Your proposed solution** (if you have one)
- **Why this would be useful** to you or others

### Contributing Code

#### Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/captain-contraption.git
   cd captain-contraption
   ```

3. **Create a branch** for your work:
   ```bash
   git checkout -b add-new-utility
   ```

#### Making Changes

- **Write clear commit messages** - Explain *why* you made the change, not just *what* changed
- **Keep changes focused** - One feature or fix per pull request makes review easier
- **Follow the code style** - See guidelines below
- **Test on your system** - Verify changes work before submitting
- **Check with ShellCheck** - Use `shellcheck` for linting

**Test your scripts:**

```bash
# Check a specific script for issues
shellcheck bin/your-script

# Check all scripts
shellcheck bin/*

# Run a script to verify it works
./bin/your-script --help
```

#### Code Style Guidelines

**Shell Choice:**

- **Prefer POSIX sh** (`#!/bin/sh`) when possible - better portability
- **Use bash** (`#!/bin/bash`) only when necessary (e.g., arrays, `[[ ]]` patterns)
- **Test both** - If you use bash features, verify compatibility with the script's shebang

**Scripting Style:**

- **Simple > clever** - Write code that's easy to understand
- **Error handling** - Use `&&` for error chains; fail loudly with clear messages
- **Quoting** - Always quote variables: `"$VAR"` not `$VAR`
- **Spacing** - 4 spaces for indentation (no tabs)
- **Help text** - Add `-h|--help` support to all scripts
- **Configuration** - Use `conf-which` for configuration file discovery (see CLAUDE.md)
- **Comments** - Explain the *why*, not just the *what*

**Example of good style:**

```bash
#!/bin/sh
# Clear shebang
display_help() {
    echo "Do something useful."
    echo "Usage: my-script [options]"
    echo "       my-script -h|--help    show this message and exit"
}

# Handle help flag early
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    display_help
    exit 0
fi

# Validate arguments
if [ "$#" -ne 1 ]; then
    echo "ERROR: Expected 1 argument" >&2
    exit 1
fi

# Do the work with proper error handling
CONFIG="$(conf-which my-config.conf)" && source "$CONFIG" || {
    echo "ERROR: my-config.conf not found" >&2
    exit 1
}

# Simple, clear logic
if [ -w "$1" ]; then
    echo "File is writable"
else
    echo "File is not writable"
fi
```

**What to avoid:**

```bash
# Bad: Unquoted variables
rm -f $FILE  # Breaks with spaces in filenames

# Bad: Unclear error handling
command1 | command2  # What if command1 fails?

# Bad: No help text
my-script filename  # How does a user know what to do?

# Bad: Overly complex logic
[ -f "$1" ] && [ -x "$1" ] && [ -r "$1" ] && [ -w "$1" ] && do_something  # Hard to read
```

#### Documentation

- **Add help text** to new scripts
- **Update README.md** to describe new utilities
- **Document configuration** if your script uses `captain-contraption.conf`
- **Include examples** showing how to use the script

#### Testing Your Changes

Before submitting:

1. **Run ShellCheck**: `shellcheck bin/your-script`
2. **Test the script**: `./bin/your-script --help` and actual use
3. **Test on different shells** (at least `/bin/sh` and `/bin/bash`)
4. **Verify no regressions** - Run existing scripts to ensure nothing broke

#### Submitting a Pull Request

1. **Push your branch** to your fork:
   ```bash
   git push origin add-new-utility
   ```

2. **Open a pull request** on GitHub with:
   - **Clear title** - "Add utility to check system load"
   - **Description of changes** - What you changed and why
   - **Related issues** - Reference any issues this addresses
   - **Testing notes** - How you tested this, what systems you tested on

3. **Respond to feedback** - Maintainers may suggest changes. This is normal!

**Example PR description:**

```markdown
## Summary

Adds a new utility to monitor system load and alert admins.

## Changes

- Added `bin/check-load` script with configurable thresholds
- Updated README.md with new utility documentation
- Configuration via PRIORITY_PORTS in captain-contraption.conf

## Testing

- Tested on Fedora 40 (bash) and Alpine (sh)
- Verified help text and error messages
- Checked with ShellCheck (no warnings)

Fixes #42
```

## Architecture and Design

See [CLAUDE.md](CLAUDE.md) for:

- Project structure and organization
- Key architecture patterns (configuration discovery, database rotation, etc.)
- How scripts compose with tools like `mutate` and `conf-which`
- Shell compatibility expectations

## Portable Shell Scripting Tips

captain-contraption aims to work across Linux and BSD systems. Here are some tips:

**Use POSIX equivalents:**

- `command -v` instead of `which`
- `[ -z "$var" ]` instead of `[[ -z "$var" ]]`
- `printf` instead of `echo -e` (more portable)
- Standard tools: `grep`, `sed`, `awk` (not GNU-only variants)

**Test portability:**

- Use `shellcheck --shell=sh` for POSIX compliance
- Test on both Linux and if possible a BSD system
- Check man pages for command portability

**Common gotchas:**

- `local` keyword is bash-only (use in bash scripts only)
- `[[ ]]` is bash-only (use `[ ]` for POSIX)
- Associative arrays are bash-only
- `>&` redirection syntax varies (stick to `> file` and `2>&1`)

## Code Review Process

When you submit a PR:

1. **Automated checks** run (ShellCheck, basic validation)
2. **Maintainers review** your code
3. **Discussion happens** if changes are needed
4. **Approval and merge** once everything looks good

Be patient - reviews take time, and that's okay. We appreciate your contribution!

## Community Guidelines

Please be respectful and kind to everyone:

- **Welcome newcomers** warmly
- **Assume good intentions** in discussions
- **Focus on ideas, not people** when disagreeing
- **Help each other learn**

We're building something useful together, and that's more fun when everyone feels welcome.

## License

By contributing, you agree that your contributions will be licensed under the MIT License (see [LICENSE](LICENSE)).

## Questions?

- **Not sure if your idea fits?** Open an issue and ask!
- **Stuck on something?** Open an issue or discussion!
- **Want to improve something?** We'd love to hear it!

There are no stupid questions. We were all beginners once.

**Thank you for contributing to captain-contraption!** Your time and effort make this project better for everyone.
