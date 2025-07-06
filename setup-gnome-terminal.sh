#!/bin/bash

# Setup script for GNOME Terminal users
# This creates a system-wide keyboard shortcut for Alt+Enter

set -e

echo "Claude Better Enter - GNOME Terminal Setup"
echo "=========================================="
echo ""

# Check if running GNOME
if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ] && [ "$XDG_CURRENT_DESKTOP" != "ubuntu:GNOME" ]; then
    echo "Warning: This script is designed for GNOME desktop environment."
    echo "Current desktop: $XDG_CURRENT_DESKTOP"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Check for xdotool
if ! command -v xdotool &> /dev/null; then
    echo "xdotool is required for this setup."
    echo "Would you like to install it?"
    read -p "Install xdotool? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y xdotool
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y xdotool
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm xdotool
        else
            echo "Please install xdotool manually and run this script again."
            exit 1
        fi
    else
        echo "Cannot proceed without xdotool."
        exit 1
    fi
fi

# Function to add custom keybinding
add_keybinding() {
    local name="$1"
    local command="$2"
    local binding="$3"
    
    # Get current custom keybindings
    local current=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    
    # Find next available slot
    local i=0
    while [[ $current == *"custom$i"* ]]; do
        ((i++))
    done
    
    local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$i/"
    
    # Add to list if not empty
    if [ "$current" == "@as []" ]; then
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$path']"
    else
        # Remove the closing bracket, add new path, add closing bracket
        current=${current%]}
        current="${current}, '$path']"
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$current"
    fi
    
    # Set the keybinding properties
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path name "$name"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path command "$command"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path binding "$binding"
    
    echo "Created keybinding: $binding → $name"
}

echo "Setting up keyboard shortcuts..."
echo ""

# Check if Alt+Return is already bound
if gsettings list-recursively | grep -q "<Alt>Return"; then
    echo "Warning: Alt+Enter appears to be already bound."
    echo "This might conflict with existing shortcuts."
fi

# Add the keybinding
add_keybinding "Claude Submit (§)" "xdotool type '§'" "<Alt>Return"

echo ""
echo "✅ Setup complete!"
echo ""
echo "You can now use:"
echo "  • Enter: Create new lines"
echo "  • Alt+Enter: Submit message (inserts §)"
echo "  • \\+Enter: Submit message (alternative)"
echo ""
echo "Note: This creates a system-wide shortcut that works in all applications."
echo "To remove it, go to Settings → Keyboard → Keyboard Shortcuts"
echo ""
echo "Troubleshooting:"
echo "  - If Alt+Enter doesn't work, check Settings → Keyboard → Keyboard Shortcuts"
echo "  - On Wayland, xdotool may not work. Use \\+Enter instead"
echo "  - Some applications may intercept Alt+Enter before the system"