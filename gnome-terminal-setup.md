# GNOME Terminal Setup for Claude Better Enter

## The Challenge

GNOME Terminal doesn't support custom key mappings like Kitty does. It cannot:
- Remap Shift+Enter, Ctrl+Enter, or Alt+Enter to send custom sequences
- Distinguish between Enter and Shift+Enter (terminal protocol limitation)
- Send arbitrary character sequences on key combinations

## Available Solutions

### 1. Use Backslash+Enter (Works by Default)
The patch already supports `\+Enter` for submission in any terminal, including GNOME Terminal.

### 2. Custom Keyboard Shortcut (System-Wide)
You can create a system-wide shortcut that types the § character:

#### Ubuntu/GNOME Setup:
1. Go to Settings → Keyboard → Keyboard Shortcuts
2. Click "+" to add a custom shortcut
3. Name: "Insert Section Sign"
4. Command: `xdotool type '§'`
5. Set shortcut: Alt+Enter (or your preference)

First install xdotool:
```bash
sudo apt install xdotool
```

#### Alternative with xte:
```bash
sudo apt install xautomation
# Command: xte 'str §'
```

### 3. Use Compose Key
Enable the compose key to type special characters:

1. Settings → Keyboard → Compose Key → Choose a key (e.g., Right Alt)
2. Type: Compose, s, o → § (section sign)
3. Then press Enter to submit

### 4. Input Method
Use the Ctrl+Shift+U method (works in most GTK applications):
1. Press Ctrl+Shift+U
2. Type: a7 (Unicode for §)
3. Press Space or Enter
4. Press Enter again to submit

### 5. AutoKey (Advanced)
Install AutoKey for more sophisticated remapping:

```bash
sudo apt install autokey-gtk
```

Create a script that sends § when Alt+Enter is pressed:
```python
# AutoKey script
keyboard.send_keys("§")
```

## Recommendation

For GNOME Terminal users, we recommend:
1. **Primary method**: Use `\+Enter` for submission (no setup required)
2. **Alternative**: Set up xdotool with a system keyboard shortcut
3. **Fallback**: Use the compose key method

## Why These Limitations Exist

GNOME Terminal follows the VTE (Virtual Terminal Emulator) library standards strictly, which means:
- It sends standard ANSI escape sequences only
- It cannot intercept and modify key combinations at the terminal level
- All remapping must happen at the system (X11/Wayland) level

## Script for xdotool Setup

```bash
#!/bin/bash
# setup-gnome-terminal.sh

echo "Setting up Alt+Enter for GNOME Terminal..."

# Install xdotool
if ! command -v xdotool &> /dev/null; then
    echo "Installing xdotool..."
    sudo apt update
    sudo apt install -y xdotool
fi

# Create the shortcut
echo "Creating keyboard shortcut..."
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Claude Submit'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "xdotool type '§'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Alt>Return'

echo "Done! Alt+Enter will now insert § for Claude submission."
echo "Note: This is a system-wide shortcut and will work in all applications."
```