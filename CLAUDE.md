# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working with this repository.

## Project Overview

**captain-contraption** is a collection of shell scripts for Linux system administration and management. The
project is deliberately eclectic—there is no overarching architectural pattern, just useful utilities that solve
common admin tasks. All scripts are MIT licensed.

## Project Structure

```
captain-contraption/
├── bin/                          # 10 executable shell scripts
├── etc/                          # Configuration files
├── install.sh                    # Installation/uninstallation script
├── README.md                     # User-facing documentation
├── CLAUDE.md                     # This file (general guidance)
├── CLAUDE.local.md               # Local development info (not in repo)
├── LICENSE                       # MIT License
└── CONTRIBUTING.md               # Contribution guidelines
```

## Complete Scripts Reference

All scripts are in `bin/` and executable. See `README.md` for detailed user documentation. Here's a technical
reference for each:

### Core Utilities

**conf-which** - Configuration file locator
- Shebang: `#!/usr/bin/bash` (Bash-specific)
- Searches: `.` → `$HOME` → `/etc` → `/usr/local/etc` → `/opt/etc`
- Customizable via `CONF_WHICH_PATHS` environment variable
- Falls back to recursive search in `/etc` if not found in standard paths
- Used by other scripts for flexible configuration discovery
- Supports `--help` and `--show` flags

**mutate** - Edit immutable/protected files safely
- Shebang: `#!/usr/bin/bash` (Bash-specific)
- Handles files with immutability attribute (`chattr +i`)
- If file writable: edits directly
- If file not writable: removes immutable flag, edits, restores flag
- Uses `captain-contraption.conf` for `TEXT_EDITOR` setting
- Supports `--help` flag

### System Administration Tools

**nft-edit** - Firewall rule editor for nftables
- Shebang: `#!/bin/sh` (POSIX compatible)
- Locates `nftables.conf` via `conf-which` or accepts path argument
- Uses `mutate` to handle immutable files
- Validates syntax with `nft --check --file`
- Reloads rules with `systemctl reload nftables.service`
- Displays ruleset after successful reload
- Supports `--help` flag

**aide-check** - Run AIDE file integrity checks
- Shebang: `#!/bin/sh` (POSIX compatible)
- Locates config files via `conf-which`
- Runs `aide --check --config`
- Supports `--help` flag

**aide-init** - Initialize AIDE database
- Shebang: `#!/bin/sh` (POSIX compatible)
- Creates new database from scratch
- Rotates existing: `aide.db.gz` → `aide.db.old.gz`
- Configured via `AIDE_CUR_DB`, `AIDE_OLD_DB`, `AIDE_NEW_DB`
- Supports `--help` flag

**aide-update** - Update AIDE database
- Shebang: `#!/bin/sh` (POSIX compatible)
- If current database exists: updates it, reports changes
- If current database missing: initializes it instead
- Rotates databases: `aide.db.gz` → `aide.db.old.gz`, `aide.db.new.gz` → `aide.db.gz`
- Configured via `AIDE_CUR_DB`, `AIDE_OLD_DB`, `AIDE_NEW_DB`
- Supports `--help` flag

**iface-restart** - NetworkManager interface control
- Shebang: `#!/bin/sh` (POSIX compatible)
- Uses `nmcli` to manage connections
- Takes connection name as argument
- Implements 3-second pause between down and up
- Supports `--help` and `-h` flags

**find-removed-packages** - Identify unremoved package files
- Shebang: `#!/bin/sh` (POSIX compatible)
- **Debian/Ubuntu only** - designed for apt/dpkg systems
- Uses `dpkg --list` to find packages marked for removal (rc state)
- Lists packages that still have config files
- Use with `apt purge` to completely remove packages
- Supports `--help` and `-h` flags
- See README.md for RPM-based system alternatives

**notify-send-all** - Send notifications to all user sessions
- Shebang: `#!/usr/bin/bash` (Bash-specific)
- Iterates through active user sessions in `/run/user/*/`
- Uses `getent passwd` to map UIDs to usernames
- Forwards arguments to `notify-send` for each user
- Properly sets `DBUS_SESSION_BUS_ADDRESS` for each session
- Supports `--help` flag

**ports-by-process** - Display ports grouped by process
- Shebang: `#!/usr/bin/bash` (Bash-specific)
- Reads from `ss -ltup` command or via pipe
- Groups listening TCP/UDP ports by process name
- Can prioritize specific processes to display first
- Remaining ports shown in "remainder" section
- Patterns: command-line args override `PRIORITY_PORTS` config
- Uses standard regex syntax (case-sensitive)
- Each group includes `ss` header for readability
- Supports `--help` flag

## Configuration File

**etc/captain-contraption.conf** - Central configuration for all scripts

| Variable | Default | Purpose |
|----------|---------|---------|
| `TEXT_EDITOR` | `/usr/bin/nano -wl` | Text editor for `mutate`, `nft-edit` |
| `AIDE_NEW_DB` | `/var/lib/aide/aide.db.new.gz` | New AIDE database path |
| `AIDE_CUR_DB` | `/var/lib/aide/aide.db.gz` | Current AIDE database path |
| `AIDE_OLD_DB` | `/var/lib/aide/aide.db.old.gz` | Backup AIDE database path |
| `PRIORITY_PORTS` | `kdeconnectd`, `firefox.*`, `jetbrains.*` | Regex patterns for `ports-by-process` |

## Installation

**install.sh** - Install/uninstall all scripts and config
- Usage: `./install.sh [install|uninstall]`
- Default PREFIX: `/usr/local` (customizable via `PREFIX` env var)
- Creates `PREFIX/bin/` and `PREFIX/etc/` directories
- Installs all scripts with 755 permissions
- Smart config backup (only if locally modified)
- Validates it's run from project root
- Supports `help`, `--help`, `-h` flags

## Key Architecture Patterns

### Configuration Discovery
Most scripts use `conf-which` to locate configuration files:
```bash
CONF_FILE="$(conf-which captain-contraption.conf)" && source "$CONF_FILE"
```
This pattern enables:
- Flexible configuration without hardcoded paths
- Customizable search via `CONF_WHICH_PATHS`
- Standard location convention (`.`, `$HOME`, `/etc`, `/usr/local/etc`, `/opt/etc`)

### File Immutability Handling
The `mutate` script provides reusable abstraction for editing protected files:
- Detects if file is writable
- Removes immutable flag if needed, edits, then restores it
- Prevents accidental overwrites via `chattr +i`
- Used by `nft-edit` to manage firewall rules safely

### Database Rotation Pattern
AIDE scripts use consistent naming for database versions:
- **Current**: `aide.db.gz` (in use by AIDE)
- **New**: `aide.db.new.gz` (freshly created by `aide --init/update`)
- **Old**: `aide.db.old.gz` (previous version for comparison)

This pattern is configured in `captain-contraption.conf`.

### Error Handling
All scripts use `&&` command chaining for error handling:
```bash
command1 && command2 && command3
```
This ensures operations stop on failure without nested conditionals.

### Help Flags
All scripts support `--help` or `-h` flags for usage information.

## Development and Testing

### Shell Compatibility
The project uses both POSIX shell (`#!/bin/sh`) and Bash:
- **POSIX scripts** (8 scripts): `nft-edit`, `aide-*`, `iface-restart`,
  `find-removed-packages` - broader compatibility
- **Bash scripts** (2 scripts): `conf-which`, `mutate`, `notify-send-all`,
  `ports-by-process` - use bash-specific features

When modifying scripts, check the shebang line and test accordingly.

### Linting Shell Scripts
Use `shellcheck` to validate scripts:
```bash
# Check all scripts
shellcheck bin/*

# Check a specific script
shellcheck bin/conf-which
```

Some warnings about POSIX vs Bash compatibility are expected. Review CONTRIBUTING.md for guidelines.

### External Dependencies
Each script requires specific tools:
- `conf-which`: bash, standard POSIX utilities
- `mutate`, `nft-edit`: text editor, `chattr`, `nft` (nftables)
- AIDE scripts: `aide`, `conf-which`
- `iface-restart`: `nmcli`, `systemctl`
- `find-removed-packages`: `dpkg`, `apt` (**Debian/Ubuntu systems only**)
- `notify-send-all`: `notify-send`, process utilities
- `ports-by-process`: `ss`, bash, associative arrays

See CLAUDE.local.md for setting up a local development environment.

### Testing Strategy
There is no formal test suite. Manual testing is required:
1. Run script with `--help` to verify usage is clear
2. Test basic functionality with test files/inputs
3. For system scripts (AIDE, firewall), test in safe environments
4. Use `shellcheck` to catch syntax errors before testing

## Code Style and Patterns

### Variable Naming
- Configuration variables: UPPERCASE (e.g., `AIDE_CUR_DB`)
- Local/temporary variables: lowercase (e.g., `conf_file`)
- Environment variables: UPPERCASE (e.g., `EDITOR`, `CONF_WHICH_PATHS`)

### Function Definition
All scripts define a `display_help()` function for usage information.

### Argument Validation
Scripts validate required arguments before proceeding:
```bash
if [ $# -eq 0 ]; then
    display_help
    exit 1
fi
```

### Configuration Sourcing
When sourcing config with `&&`:
```bash
CONF_FILE="$(conf-which captain-contraption.conf)" && source "$CONF_FILE"
```
The `&&` operator prevents further execution if config is missing.

## Markdown Documentation Standards

- Wrap lines at 120 columns for consistency
- Use clear section headers for navigation
- Include code examples in bash blocks
- Document configuration variables in tables
- Link to README.md for user-facing documentation
- Use CLAUDE.local.md for development-specific information