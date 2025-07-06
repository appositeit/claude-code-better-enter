#!/bin/bash

# Claude Code Better Enter Patch Uninstaller

set -e

echo "Claude Code Better Enter Patch Uninstaller"
echo "=========================================="
echo ""

# Function to find Claude Code installation
find_claude_cli() {
    # Try npm global first
    local npm_global=$(npm root -g 2>/dev/null)
    if [ -n "$npm_global" ] && [ -f "$npm_global/@anthropic-ai/claude-code/cli.js" ]; then
        echo "$npm_global/@anthropic-ai/claude-code/cli.js"
        return 0
    fi
    
    # Try which command
    local claude_path=$(which claude 2>/dev/null)
    if [ -n "$claude_path" ]; then
        # Follow symlinks
        local real_path=$(readlink -f "$claude_path" 2>/dev/null || realpath "$claude_path" 2>/dev/null)
        if [ -n "$real_path" ]; then
            # Get the directory and look for cli.js
            local dir=$(dirname "$real_path")
            if [ -f "$dir/cli.js" ]; then
                echo "$dir/cli.js"
                return 0
            fi
            # Check parent directories
            if [ -f "$dir/../lib/node_modules/@anthropic-ai/claude-code/cli.js" ]; then
                echo "$dir/../lib/node_modules/@anthropic-ai/claude-code/cli.js"
                return 0
            fi
        fi
    fi
    
    return 1
}

# Find Claude CLI
echo "Looking for Claude Code CLI installation..."
CLI_PATH=$(find_claude_cli)

if [ -z "$CLI_PATH" ]; then
    echo "Error: Could not find Claude Code CLI installation."
    exit 1
fi

echo "Found Claude CLI at: $CLI_PATH"

# Check if patched
if ! grep -q "Direct submission when § is typed" "$CLI_PATH" 2>/dev/null; then
    echo ""
    echo "Claude CLI does not appear to be patched."
    exit 0
fi

# Find backups
CLI_DIR=$(dirname "$CLI_PATH")
echo ""
echo "Looking for backups..."
BACKUPS=($(ls -t "$CLI_PATH".backup-* 2>/dev/null || true))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "No backup files found."
    echo "Cannot uninstall without a backup."
    exit 1
fi

echo "Found ${#BACKUPS[@]} backup(s):"
for i in "${!BACKUPS[@]}"; do
    echo "  $((i+1)). $(basename "${BACKUPS[$i]}")"
done

# Select backup
if [ ${#BACKUPS[@]} -eq 1 ]; then
    SELECTED_BACKUP="${BACKUPS[0]}"
    echo ""
    echo "Using backup: $(basename "$SELECTED_BACKUP")"
else
    echo ""
    read -p "Select backup to restore (1-${#BACKUPS[@]}): " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#BACKUPS[@]} ]; then
        echo "Invalid selection."
        exit 1
    fi
    SELECTED_BACKUP="${BACKUPS[$((selection-1))]}"
fi

# Restore
echo "Restoring from backup..."
cp "$SELECTED_BACKUP" "$CLI_PATH"

echo ""
echo "✅ Patch uninstalled successfully!"
echo "Claude Code CLI has been restored to its original state."