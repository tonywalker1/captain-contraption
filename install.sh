#!/bin/sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PREFIX="${PREFIX:-/usr/local}"
ACTION="${1:-install}"

# Verify this is being run from the correct location
if [ ! -d "${SCRIPT_DIR}/bin" ] || [ ! -f "${SCRIPT_DIR}/etc/captain-contraption.conf" ]; then
    echo "Error: This script must be run from the captain-contraption project root" >&2
    echo "Expected to find: ${SCRIPT_DIR}/bin and ${SCRIPT_DIR}/etc/captain-contraption.conf" >&2
    exit 1
fi

show_help() {
    cat <<EOF
Usage: $(basename "$0") [install|uninstall]

Install or uninstall captain-contraption utilities.

Environment variables:
  PREFIX          Installation prefix (default: /usr/local)

Examples:
  ./install.sh install                    # Install to /usr/local
  PREFIX=/opt/captain ./install.sh        # Install to /opt/captain
  ./install.sh uninstall                  # Uninstall from /usr/local
EOF
}

install_files() {
    echo "Installing to ${PREFIX}..."

    # Create directories
    mkdir -p "${PREFIX}/bin"
    mkdir -p "${PREFIX}/etc"

    # Install scripts from bin/
    for script in "${SCRIPT_DIR}/bin"/*; do
        if [ -f "$script" ]; then
            filename=$(basename "$script")
            echo "Installing ${filename} to ${PREFIX}/bin/"
            install -C -m 755 "$script" "${PREFIX}/bin/"
        fi
    done

    # Install config file with backup for modified versions
    CONF_DEST="${PREFIX}/etc/captain-contraption.conf"
    CONF_SRC="${SCRIPT_DIR}/etc/captain-contraption.conf"

    if [ -f "$CONF_DEST" ]; then
        # Config exists, check if it differs from source
        if ! cmp -s "$CONF_SRC" "$CONF_DEST"; then
            echo "Config file has local modifications, backing up to ${CONF_DEST}.bak"
            cp "$CONF_DEST" "${CONF_DEST}.bak"
        fi
    fi

    echo "Installing captain-contraption.conf to ${PREFIX}/etc/"
    install -C -m 644 "$CONF_SRC" "${PREFIX}/etc/"

    echo "Installation complete!"
}

uninstall_files() {
    echo "Uninstalling from ${PREFIX}..."

    # Remove scripts from bin/
    for script in "${SCRIPT_DIR}/bin"/*; do
        if [ -f "$script" ]; then
            filename=$(basename "$script")
            if [ -f "${PREFIX}/bin/${filename}" ]; then
                echo "Removing ${PREFIX}/bin/${filename}"
                rm "${PREFIX}/bin/${filename}"
            fi
        fi
    done

    # Remove config file
    if [ -f "${PREFIX}/etc/captain-contraption.conf" ]; then
        echo "Removing ${PREFIX}/etc/captain-contraption.conf"
        rm "${PREFIX}/etc/captain-contraption.conf"
    fi

    echo "Uninstall complete!"
}

case "$ACTION" in
    help|--help|-h)
        show_help
        exit 0
        ;;
    install)
        install_files
        ;;
    uninstall)
        uninstall_files
        ;;
    *)
        echo "Unknown action: $ACTION" >&2
        show_help
        exit 1
        ;;
esac
