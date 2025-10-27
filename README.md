# captain-contraption

A set of useful tools for managing a Linux system.

# Overview

I could have named this project _admin-tools_, but that would have been too boring. Fortunately, an online thesaurus
helped me derive a better name. Of all the possible synonyms for _admin_ and _tools_, I thought _captain_ and
_contraption_ made the funniest project name. That's all there is to the name.

_captain_contraption_ is my attempt to formalize and share some of the scripts I have used over the years. This is
really an eclectic mix of scripts with no real overarching plan. I hope these will be useful when you are managing
the contraptions (computers) over which you are the captain (admin). Of course, please feel free to help me grow
this project.

# Contents

- [captain-contraption.conf](#captain-contraption.conf)
- [conf-which](#conf-which)
- [mutate](#mutate)
- [nft-edit](#nft-edit)
- [ports-by-process](#ports-by-process)

### captain-contraption.conf



### conf-which

This is ```which``` for configuration files. ```conf-which``` will search the usual places for config files and return 
the path to the config file or exit with an error. One way to use it is:
```shell
CONF_FILE="$(conf-which captain-contraption.conf)" && source "$CONF_FILE"
```
The paths ```conf-which``` searchs can be customized by setting ```CONF_WHICH_PATHS``` in your .bashrc, for example:
```shell
CONF_WHICH_PATHS="$CONF_WHICH_PATHS":/your/path
```

### mutate

To prevent accidental overwrites or deletions, immutable files are useful. However, running chattr twice is tedious.
This script takes the file to edit as a commandline argument and opens it in your preferred text editor. If the
immutable attribute is set, the script will clear it before editing and set it after editing. If the file is not
immutable, then the file is left immutable. In this way, this script can be an all-purpose synonym for your preferred
text editor.

### nft-edit

nft-edit is a simple wrapper to reduce the tedium of editing, checking, and reloading firewall rules. It loads the rules
in your preferred text editor. When you exit your editor, it checks the rules for errors. If no errors are found, it
loads the new rules, and prints them for visual inspection.



### aide-init, aide-update, aide-check

These scripts simplify rotating databases, etc. when running aide.

* aide-init creates a new database and rotates any existing database (e.g., aide.db.gz -> aide.db.old.gz).
* aide-update reports changed files, creates a new database, and rotates databases (e.g., aide.db.gz -> aide.db.old.gz
  and aide.db.new.gz -> aide.db.gz).
* aide-check only reports changed files. No changes to databases.

### iface-restart

Restarts an interface that is controlled by Network Manager (using nmcli) with a three-second pause between down and up
operations.

### find-removed-packages

The Apt package manager will not automatically remove generated data and altered config files. This is good; however,
sometimes you really want to remove everything. This simple tool will list the packages that have residual files. Those
packages may be then manually removed using the ```apt purge``` command.

### ports-by-process

Display listening TCP/UDP ports grouped by process name for easy visualization. By default, this script displays all
ports from `ss -ltup`, but you can prioritize specific processes to have them appear first, followed by a "remainder"
section with all other ports.

Each group includes the column header from `ss` so sections are self-contained and readable.

#### Usage

```shell
ports-by-process [pattern1] [pattern2] ...
ss -ltup | ports-by-process [pattern1] [pattern2] ...
ports-by-process --help
```

#### Configuration

Patterns can be specified as command-line arguments or configured in `captain-contraption.conf` using the `PRIORITY_PORTS`
variable. Patterns use standard regex syntax for flexible matching.

Example in `captain-contraption.conf`:
```
PRIORITY_PORTS="kdeconnectd
firefox.*
jetbrains.*"
```

#### Examples

Show specific processes first, others in remainder:
```shell
ports-by-process kdeconnectd firefox-bin
```

Use regex patterns to match multiple processes:
```shell
ports-by-process 'jetbrains.*' 'firefox.*'
```

Pipe from `ss`:
```shell
ss -ltup | ports-by-process kdeconnectd
```

#### Behavior

* Patterns are matched against process names and use standard regex syntax
* Patterns are case-sensitive
* Command-line arguments override configuration file patterns
* If a process matches multiple patterns, it appears only in the first matching group
* Invalid regex patterns simply won't match anything (fail silently)
* When no patterns are configured, all ports appear in the "remainder" section
