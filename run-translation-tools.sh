#!/bin/bash
# Translation Tools Runner
# This script loads the .env file and provides easy access to translation tools

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Loading environment variables from .env..."
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
    echo "Environment loaded successfully!"
else
    echo "Warning: .env file not found in $SCRIPT_DIR"
    echo "Using default paths..."
    PROJECT_ROOT="$SCRIPT_DIR"
    TRANSLATIONS_DIR="$SCRIPT_DIR/translations"
    SOURCE_DIR="$SCRIPT_DIR"
    TOOLS_DIR="$SCRIPT_DIR/translations/tools"
fi

# Show help
show_help() {
    echo "Translation Tools Runner"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  status       Show translation status"
    echo "  extract      Extract translatable texts"
    echo "  update       Update translation files"
    echo "  clean        Clean unused translation keys"
    echo "  sync         Sync keys across all language files"
    echo "  help         Show this help message"
    echo ""
    echo "Options for 'update' command:"
    echo "  -l LANG      Specify language (e.g.: zh_CN, pt_BR)"
    echo "  -y           Auto-confirm all prompts"
    echo ""
    echo "Examples:"
    echo "  $0 status                    # Show current status"
    echo "  $0 update                    # Update all languages"
    echo "  $0 update -l zh_CN          # Update only Chinese"
    echo "  $0 clean -y                  # Clean unused keys without prompts"
    echo "  $0 sync                      # Sync all language files"
}

# Check if tools directory exists
if [ ! -d "$TOOLS_DIR" ]; then
    echo "Error: Tools directory not found: $TOOLS_DIR"
    exit 1
fi

# Check if manage-translations.sh exists
MANAGE_SCRIPT="$TOOLS_DIR/manage-translations.sh"
if [ ! -f "$MANAGE_SCRIPT" ]; then
    echo "Error: manage-translations.sh not found: $MANAGE_SCRIPT"
    exit 1
fi

# Make sure the script is executable
chmod +x "$MANAGE_SCRIPT"

# Parse command
COMMAND="$1"
shift || true

case "$COMMAND" in
    status)
        echo "Showing translation status..."
        "$MANAGE_SCRIPT" --trans-dir "$TRANSLATIONS_DIR" --source-dir "$SOURCE_DIR" status
        ;;
    extract)
        echo "Extracting translatable texts..."
        "$MANAGE_SCRIPT" --trans-dir "$TRANSLATIONS_DIR" --source-dir "$SOURCE_DIR" extract
        ;;
    update)
        echo "Updating translation files..."
        "$MANAGE_SCRIPT" --trans-dir "$TRANSLATIONS_DIR" --source-dir "$SOURCE_DIR" update "$@"
        ;;
    clean)
        echo "Cleaning unused translation keys..."
        "$MANAGE_SCRIPT" --trans-dir "$TRANSLATIONS_DIR" --source-dir "$SOURCE_DIR" clean "$@"
        ;;
    sync)
        echo "Syncing translation keys..."
        "$MANAGE_SCRIPT" --trans-dir "$TRANSLATIONS_DIR" --source-dir "$SOURCE_DIR" sync "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        echo "Error: No command specified"
        echo ""
        show_help
        exit 1
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        echo ""
        show_help
        exit 1
        ;;
esac
