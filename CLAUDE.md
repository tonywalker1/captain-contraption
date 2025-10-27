# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**captain-contraption** is a collection of shell scripts for Linux system administration and management. The project is deliberately eclectic—there is no overarching architectural pattern, just a set of useful utilities that solve common admin tasks. All scripts are MIT licensed.

## Project Structure

- `bin/` - Executable shell scripts (the main content of this project)
- `etc/` - Configuration files
- `README.md` - Main documentation describing each tool
- `.gitignore` - Only ignores `.idea/` (IDE files)

## Scripts Overview

The project contains the following utilities:

- **conf-which** - Configuration file locator (like `which` but for config files). Searches standard paths and supports custom search paths via `CONF_WHICH_PATHS`.
- **mutate** - Wrapper for editing immutable files. Temporarily removes the immutable attribute, opens in editor, then restores it.
- **nft-edit** - Editor wrapper for nftables firewall rules. Validates syntax and reloads rules after editing.
- **aide-check** - Runs AIDE file integrity checks using configuration discovery.
- **aide-init** - Initializes AIDE database and rotates existing databases.
- **aide-update** - Updates AIDE database, reports changes, and rotates databases.
- **iface-restart** - Restarts a network interface managed by NetworkManager with a 3-second pause.
- **find-removed-packages** - Lists packages with residual files after removal.
- **notify-send-all** - Sends notifications to all active user sessions.

## Key Architecture Patterns

### Configuration Discovery Pattern
Multiple scripts use `conf-which` to locate configuration files in standard locations (`.`, `$HOME`, `/etc`, `/usr/local/etc`, `/opt/etc`). The pattern is:
```bash
CONF_FILE="$(conf-which captain-contraption.conf)" && source "$CONF_FILE"
```
This allows flexible configuration without hardcoding paths. The search path can be customized via the `CONF_WHICH_PATHS` environment variable.

### Script Composition with mutate
The `mutate` script is used by `nft-edit` and other tools that need to edit protected or immutable files. The key design:
- `mutate` checks if file is writable
- If not writable, it removes immutable attribute, edits, then restores it
- If writable, it just edits normally
This prevents accidental overwrites while keeping scripts DRY.

### Database Rotation Pattern
AIDE-related scripts follow a consistent pattern for database management:
- Current database: `aide.db.gz`
- New/pending database: `aide.db.new.gz`
- Old/backup database: `aide.db.old.gz`

This pattern is configured in `captain-contraption.conf` via:
- `AIDE_NEW_DB`
- `AIDE_CUR_DB`
- `AIDE_OLD_DB`

## Development Commands

Since this is a collection of shell scripts without a build system:

### Running Scripts
```bash
# Run a specific script
./bin/conf-which some-config.conf

# Scripts expect to be in PATH for production use
# For testing, either use full paths or add bin/ to PATH
export PATH="./bin:$PATH"
conf-which some-config.conf
```

### Testing
There is no formal test suite. Manual testing is required:
```bash
# Test conf-which
./bin/conf-which captain-contraption.conf

# Test mutate (dry run - no actual editing)
./bin/mutate /tmp/test-file

# Test nft-edit syntax checking (without reload)
./bin/nft-edit /etc/nftables.conf
```

### Shell Script Linting
The scripts use both `/bin/sh` (POSIX sh) and `/bin/bash` (bash-specific). Use `shellcheck` for linting:
```bash
# Check all scripts
shellcheck bin/*

# Check a specific script
shellcheck bin/conf-which
```

Note: Some scripts use bash features (like `[[ ]]`), while others aim for POSIX compatibility. Check the shebang line to understand which shell is expected.

### Configuration
Review `etc/captain-contraption.conf` for available configuration options:
- `TEXT_EDITOR` - Override the default `$EDITOR` environment variable
- `AIDE_*_DB` - Configure AIDE database paths

## Important Notes for Development

### Environment Dependencies
Most scripts rely on external tools:
- `conf-which` requires standard POSIX utilities and bash
- `mutate` and `nft-edit` require: editor, `chattr`, `nft` (nftables)
- AIDE scripts require: `aide`, `conf-which`
- `iface-restart` requires: `nmcli`, `systemctl`
- `find-removed-packages` requires: `apt` package manager
- `notify-send-all` requires: `notify-send`, process utilities

### Script Patterns
- Scripts use command chaining (`&&`) for error handling
- Scripts validate required arguments
- Most scripts support `--help` or `-h` flags
- Configuration file sourcing uses `conf-which` for flexibility

### Shell Compatibility
- Prefer POSIX sh (`#!/usr/bin/env sh`) when possible
- Use bash (`#!/usr/bin/env bash`) only when necessary for features like `[[ ]]`
- Test both `/bin/sh` and `/bin/bash` when modifying scripts

### Immutable File Handling
The `mutate` script is designed to edit files that might have the immutable attribute set (`chattr +i`). Key behavior:
- If file is writable, just edit normally
- If file is not writable, remove immutable flag, edit, restore immutable flag
- This prevents accidental file overwrites while allowing intentional edits

### Configuration File Sourcing
When a script sources configuration (like `source "$CONF_FILE"`), ensure:
- The configuration file exists (use `conf-which` to locate it)
- The `&&` operator prevents further execution if config is missing
- Variables are properly exported if child processes need them