# Claude Code Better Enter Patch Installer for Windows
# This script applies the patch to enable multi-line input in Claude Code CLI

Write-Host "Claude Code Better Enter Patch Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to find Claude Code installation
function Find-ClaudeCLI {
    # Try npm global first
    try {
        $npmRoot = npm root -g 2>$null
        $cliPath = Join-Path $npmRoot "@anthropic-ai\claude-code\cli.js"
        if (Test-Path $cliPath) {
            return $cliPath
        }
    } catch {}
    
    # Try where command
    try {
        $claudePath = (Get-Command claude -ErrorAction SilentlyContinue).Source
        if ($claudePath) {
            # Check if it's a .cmd file
            if ($claudePath -match '\.cmd$') {
                # Read the cmd file to find the actual node script
                $cmdContent = Get-Content $claudePath
                foreach ($line in $cmdContent) {
                    if ($line -match 'node.*cli\.js') {
                        # Extract the path
                        $matches = [regex]::Matches($line, '"([^"]+cli\.js)"')
                        if ($matches.Count -gt 0) {
                            $extractedPath = $matches[0].Groups[1].Value
                            if (Test-Path $extractedPath) {
                                return $extractedPath
                            }
                        }
                    }
                }
            }
            
            # Check common locations relative to the command
            $dir = Split-Path $claudePath -Parent
            $possiblePaths = @(
                (Join-Path $dir "cli.js"),
                (Join-Path $dir "..\lib\node_modules\@anthropic-ai\claude-code\cli.js")
            )
            
            foreach ($path in $possiblePaths) {
                if (Test-Path $path) {
                    return (Resolve-Path $path).Path
                }
            }
        }
    } catch {}
    
    return $null
}

# Find Claude CLI
Write-Host "Looking for Claude Code CLI installation..."
$cliPath = Find-ClaudeCLI

if (-not $cliPath) {
    Write-Host "Error: Could not find Claude Code CLI installation." -ForegroundColor Red
    Write-Host "Please make sure Claude Code is installed globally with:"
    Write-Host "  npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    exit 1
}

Write-Host "Found Claude CLI at: $cliPath" -ForegroundColor Green

# Check if already patched
$content = Get-Content $cliPath -Raw
if ($content -match "Direct submission when § is typed") {
    Write-Host ""
    Write-Host "Warning: Claude CLI appears to already be patched." -ForegroundColor Yellow
    $response = Read-Host "Do you want to continue anyway? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        exit 0
    }
}

# Create backup
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$cliPath.backup-$timestamp"
Write-Host "Creating backup at: $backupPath"
Copy-Item $cliPath $backupPath

# Read patch file
if (-not (Test-Path "claude-better-enter.patch")) {
    Write-Host "Error: claude-better-enter.patch not found in current directory." -ForegroundColor Red
    exit 1
}

# Apply patch manually (Windows doesn't have patch command by default)
Write-Host "Applying patch..."

try {
    # Read the current file
    $currentContent = Get-Content $cliPath -Raw
    
    # Apply the two main modifications
    
    # 1. Modify the DA function to detect § and submit
    $daPattern = 'function DA\(T1, I1\) \{[\s\S]*?let P1 = R \? R\(T1, I1\) : T1;'
    $daReplacement = @'
function DA(T1, I1) {
    if (T1) {
      // Direct submission when § is typed
      if (T1 === "§") {
        Q?.(A); // Submit directly
        return; // Don't process the character further
      }
    }
    let P1 = R ? R(T1, I1) : T1;
'@
    
    if ($currentContent -match $daPattern) {
        $currentContent = $currentContent -replace $daPattern, $daReplacement
    } else {
        throw "Could not find DA function pattern"
    }
    
    # 2. Modify the b1 function to make Enter insert newline
    $b1Pattern = 'function b1\(T1\) \{[\s\S]*?Q\?\.\(A\);\s*\}'
    $b1Replacement = @'
function b1(T1) {
    // Semicolon+Enter submits (our Alt+Enter mapping)
    if (T1.return && L.offset > 0 && L.text[L.offset - 1] === ";") {
      L.backspace(); // Remove the semicolon
      Q?.(A); // Submit
      return;
    }
    
    // MODIFIED: Backslash+Enter now SUBMITS instead of inserting newline
    if (T1.return && L.offset > 0 && L.text[L.offset - 1] === "\\") {
      L.backspace(); // Remove the backslash
      Q?.(A); // Submit
      return;
    }
    // Ctrl+Enter or Cmd+Enter submits
    if (T1.return && (T1.ctrl || T1.meta)) {
      Q?.(A);
      return;
    }
    
    // Default: Enter always inserts newline
    if (T1.return) {
      return L.insert(`
`);
    }
    
    Q?.(A);
  }
'@
    
    if ($currentContent -match $b1Pattern) {
        $currentContent = $currentContent -replace $b1Pattern, $b1Replacement
    } else {
        throw "Could not find b1 function pattern"
    }
    
    # Write the patched content
    Set-Content $cliPath $currentContent -NoNewline
    
    Write-Host ""
    Write-Host "✅ Patch applied successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now use:"
    Write-Host "  • Enter: Create new lines" -ForegroundColor Cyan
    Write-Host "  • \+Enter: Submit (works in any terminal)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Note: Shift+Enter, Ctrl+Enter, Alt+Enter require Kitty terminal with provided config" -ForegroundColor Yellow
}
catch {
    Write-Host ""
    Write-Host "❌ Error: Failed to apply patch - $_" -ForegroundColor Red
    Write-Host "Restoring from backup..."
    Copy-Item $backupPath $cliPath -Force
    Write-Host "Original file restored."
    exit 1
}