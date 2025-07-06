# Claude Code Better Enter

By default, Claude Code CLI submits your message when you press Enter, making it difficult to write multi-line messages. This is frustrating when you want to:
- Write code blocks
- Format lists or bullet points
- Compose longer, structured prompts
- Include multiple paragraphs

This patch modifies [Claude Code CLI](https://github.com/anthropics/claude-code) to:
- **Enter** → Insert a new line (instead of submitting)
- **Shift+Enter** / **Ctrl+Enter** / **Alt+Enter** → Submit message (in Kitty terminal)
- **\\+Enter** → Submit message (works in any terminal)

We do this by:
* Making sure \\+<enter> still submits, but so does the section symbol (§, unicode: U+00A7, html: &sect;)
* We can use terminal remapping to allow **Shift+Enter**, **Ctrl+Enter**, and **Alt+Enter** to also submit.

On Linux Gnome Terminal does not support this kind of keyboard remapping, but [Kitty](https://github.com/kovidgoyal/kitty) does. Example configuration for kitty is included, but to configure your terminal of choice ask your favourite AI:

```text
How do I configure my terminal (<insert name of your terminal here>) to remap <shift>+<enter>, <ctrl>+<enter>, and <alt>+<enter> to emit the section symbol (§, unicode: U+00A7, html: &sect;).
```

## NOTE: Patching is brittle!

This patch is likely to break randomly, since it is patching minified code and if cli.js is changed, the patch will likely break. The patch works as of 2025-7-06 on Claude 1.0.43. Raise a bug if a version breaks and I'll look at updating, but no promises on timing- life is busy!

## Installation

### Prerequisites
- [Claude Code CLI](https://github.com/anthropics/claude-code) installed globally
- Node.js and npm
- (Linux, Optional) [Kitty terminal](https://sw.kovidgoyal.net/kitty/) for full keyboard shortcut support

### Quick Install

#### Linux/macOS:
```bash
git clone https://github.com/yourusername/claude-code-better-enter.git
cd claude-code-better-enter
./apply-patch.sh
```

#### Windows (PowerShell as Administrator):
```powershell
git clone https://github.com/yourusername/claude-code-better-enter.git
cd claude-code-better-enter
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\apply-patch.ps1
```

### Terminal Configuration

#### Kitty Terminal

For Shift+Enter, Ctrl+Enter, and Alt+Enter support, add the mappings to your Kitty config:

```bash
# Linux/macOS
cat kitty-mappings.conf >> ~/.config/kitty/kitty.conf

# Or manually include it:
echo "include /path/to/claude-code-better-enter/kitty-mappings.conf" >> ~/.config/kitty/kitty.conf
```

#### GNOME Terminal

GNOME Terminal requires a system-level keyboard shortcut. Run the setup script:

```bash
./setup-gnome-terminal.sh
```

This will configure Alt+Enter to work via xdotool. See `gnome-terminal-setup.md` for manual setup options.

## Usage

After installation:

1. **Writing multi-line messages**: Just press Enter to create new lines
2. **Submitting messages**:
   - In Kitty: Press `Shift+Enter`, `Ctrl+Enter`, or `Alt+Enter`
   - In any terminal: Type `\` then press Enter

### Example
```
$ claude
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You: Can you write a function that:
- Takes a list of numbers
- Filters out negative values  
- Returns the sum

def sum_positive(numbers):
    return sum(n for n in numbers if n > 0)
[Press Shift+Enter to submit]
```

## How It Works

The patch modifies two key functions in Claude's CLI:

1. **DA Function (Input Handler)**: Intercepts the section sign character (§) and triggers immediate submission. Kitty maps Shift/Ctrl/Alt+Enter to send this character.

2. **b1 Function (Enter Key Handler)**: Changed to insert newlines by default, with special handling for backslash+Enter to maintain a universal submit method.

## Uninstalling

The installer creates timestamped backups. To uninstall:

```bash
# Find your Claude CLI installation
npm root -g
# Navigate to @anthropic-ai/claude-code/
# Restore from any .backup-* file
```

## Compatibility

- ✅ Linux
- ✅ macOS  
- ✅ Windows
- ✅ Works with any terminal (using \\+Enter)
- ✅ Enhanced support for Kitty terminal
- ✅ GNOME Terminal support (via xdotool)

## Known Limitations

- Shift+Enter, Ctrl+Enter, Alt+Enter require Kitty terminal or xdotool setup
- GNOME Terminal's Alt+Enter is a system-wide shortcut (affects all apps)
- Standard terminals can only use \\+Enter for submission
- Patch needs to be reapplied after Claude Code updates
- xdotool doesn't work on Wayland (use X11 or \\+Enter)

## Terminal Limitations Explained

Most terminal emulators cannot distinguish between:
- Enter vs Shift+Enter (both send CR/LF)
- Enter vs Ctrl+Enter (in many terminals)

This is a fundamental limitation of terminal protocols, not a bug. Kitty terminal works around this by allowing custom key mappings that send unique character sequences.

## Contributing

Issues and pull requests welcome! Please test thoroughly before submitting.

## License

MIT License - See LICENSE file

## Acknowledgments

Thanks to the Anthropic team for Claude Code CLI. This patch aims to enhance usability while maintaining compatibility.
