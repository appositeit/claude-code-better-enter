# Package Contents

This directory contains everything needed to patch Claude Code CLI for better Enter key behavior.

## Files

### Core Files
- `claude-better-enter.patch` - The actual patch file that modifies cli.js
- `apply-patch.sh` - Installation script for Linux/macOS
- `apply-patch.ps1` - Installation script for Windows PowerShell
- `uninstall.sh` - Uninstallation script for Linux/macOS

### Configuration
- `kitty-mappings.conf` - Kitty terminal key mappings for Shift/Ctrl/Alt+Enter

### Documentation
- `README.md` - Comprehensive documentation and usage guide
- `LICENSE` - MIT License
- `PACKAGE_CONTENTS.md` - This file

### Other
- `.gitignore` - Git ignore file for the repository

## Quick Start

1. Clone or download this repository
2. Run the appropriate installer:
   - Linux/macOS: `./apply-patch.sh`
   - Windows: `.\apply-patch.ps1`
3. If using Kitty terminal, add the mappings from `kitty-mappings.conf`
4. Enjoy multi-line input in Claude Code CLI!

## How to Upload to GitHub

1. Create a new repository on GitHub
2. Initialize git in this directory:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Claude Code Better Enter patch"
   git branch -M main
   git remote add origin https://github.com/yourusername/claude-code-better-enter.git
   git push -u origin main
   ```

## Testing Before Release

1. Test the patch on a fresh Claude Code installation
2. Verify both installation scripts work
3. Test all key combinations in Kitty
4. Verify \\+Enter works in other terminals
5. Test the uninstall script