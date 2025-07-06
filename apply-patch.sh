#!/bin/bash

# Claude Code Better Enter Patch Installer
# This script applies the patch to enable multi-line input in Claude Code CLI

set -e

echo "Claude Code Better Enter Patch Installer"
echo "========================================"
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
    echo "Please make sure Claude Code is installed globally with:"
    echo "  npm install -g @anthropic-ai/claude-code"
    exit 1
fi

echo "Found Claude CLI at: $CLI_PATH"

# Check if already patched
if grep -q "Direct submission when § is typed" "$CLI_PATH" 2>/dev/null; then
    echo ""
    echo "Warning: Claude CLI appears to already be patched."
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Create backup
BACKUP_PATH="$CLI_PATH.backup-$(date +%Y%m%d-%H%M%S)"
echo "Creating backup at: $BACKUP_PATH"
cp "$CLI_PATH" "$BACKUP_PATH"

# Apply patch
echo "Applying patch..."
if patch -p0 "$CLI_PATH" < claude-better-enter.patch; then
    echo ""
    echo "✅ Patch applied successfully!"
    echo ""
    echo "You can now use:"
    echo "  • Enter: Create new lines"
    echo "  • Shift+Enter, Ctrl+Enter, or Alt+Enter: Submit (requires Kitty terminal with provided config)"
    echo "  • \\+Enter: Submit (works in any terminal)"
    echo ""
    echo "If using Kitty terminal, copy the provided kitty-mappings.conf to your Kitty config."
else
    echo ""
    echo "❌ Error: Failed to apply patch."
    echo "Restoring from backup..."
    cp "$BACKUP_PATH" "$CLI_PATH"
    echo "Original file restored."
    exit 1
fi