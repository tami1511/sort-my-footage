<#
  Sort My Footage - installer for Windows 10/11.
  Run it by double-clicking Install.bat. Safe to run again: it only adds what is missing.

  What it does:
    1. Checks Python 3 (installs it with winget if missing, after asking).
    2. Checks ffmpeg (installs it with winget if missing, after asking).
    3. Checks Claude Code (offers the official installer if missing) and the Claude sign-in.
    4. Copies the skill to  %USERPROFILE%\.claude\skills\sort-my-footage
    5. Puts a "Sort My Footage" folder with a launcher on your Desktop.
  It changes nothing else on the computer.
#>
param(
    [switch]$DryRun,          # check and copy only; never install programs (for testing)
    [switch]$Yes              # answer yes to every question
)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Say($text, $color = 'Gray') { Write-Host $text -ForegroundColor $color }
function Ask($question) {
    if ($Yes) { return $true }
    $a = Read-Host "$question [Y/n]"
    return ($a -eq '' -or $a -match '^[yY]')
}
function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user;$env:LOCALAPPDATA\Microsoft\WinGet\Links;$env:USERPROFILE\.local\bin"
}
function Find-Python {
    # A tiny check file avoids PowerShell's quoting of arguments to other programs.
    $check = Join-Path $env:TEMP 'sortfootage-check.py'
    Set-Content -LiteralPath $check -Value 'import sys, tkinter; assert sys.version_info >= (3, 9); print(sys.executable)' -Encoding ASCII
    $ErrorActionPreference = 'Continue'
    foreach ($cmd in @('py', 'python')) {
        $exe = Get-Command $cmd -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $exe -or $exe.Source -match 'WindowsApps') { continue }   # skip the Microsoft Store stub
        $p = Start-Process -FilePath $exe.Source -ArgumentList $(if ($cmd -eq 'py') { "-3 `"$check`"" } else { "`"$check`"" }) `
            -NoNewWindow -Wait -PassThru -RedirectStandardOutput "$check.out" -RedirectStandardError "$check.err"
        $path = (Get-Content "$check.out" -ErrorAction SilentlyContinue | Select-Object -First 1)
        if ($p.ExitCode -eq 0 -and $path) { return $path.Trim() }
    }
    return $null
}
function Install-WithWinget($id, $what) {
    if ($DryRun) { Say "  (test run: would install $what with winget)" 'Yellow'; return $false }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Say "  winget isn't available. Install $what yourself, then run Install.bat again." 'Red'; return $false
    }
    if (-not (Ask "  Install $what now?")) { return $false }
    winget install --id $id --exact --scope user --accept-package-agreements --accept-source-agreements --silent
    Refresh-Path
    return $true
}

Say ""
Say "Sort My Footage - setup" 'White'
Say "------------------------"
if (-not $Yes -and -not $DryRun) {
    Say "This adds only what's missing on this computer:"
    Say "  Python, ffmpeg, Claude Code, and a 'Sort My Footage' folder on your Desktop."
    Say "Nothing else changes, and you never need to uninstall anything."
    Say ""
    Read-Host "Press Enter to install (or close this window to cancel)" | Out-Null
    $Yes = $true   # one question only: everything after this goes ahead by itself
}

# 1. Python
Say "1. Python"
$python = Find-Python
if (-not $python) {
    Say "  Python 3 is missing." 'Yellow'
    if (Install-WithWinget 'Python.Python.3.12' 'Python 3.12') { $python = Find-Python }
}
if (-not $python) { Say "  Python is needed. Get it from python.org, then run Install.bat again." 'Red'; if (-not $DryRun) { exit 1 } }
else { Say "  OK  $python" 'Green' }

# 2. ffmpeg
Say "2. ffmpeg (makes the small stills of each clip)"
Refresh-Path
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Say "  ffmpeg is missing." 'Yellow'
    Install-WithWinget 'Gyan.FFmpeg' 'ffmpeg' | Out-Null
}
if (Get-Command ffmpeg -ErrorAction SilentlyContinue) { Say "  OK" 'Green' }
else { Say "  ffmpeg still missing. Sorting won't work until it's installed." 'Red' }

# 3. Claude Code and sign-in
Say "3. Claude Code (needs a paid Claude plan: Pro or higher)"
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Say "  Claude Code is missing." 'Yellow'
    if ($DryRun) { Say "  (test run: would offer the official installer from claude.ai)" 'Yellow' }
    elseif (Ask "  Install Claude Code with the official installer from claude.ai?") {
        Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
        Refresh-Path
    }
}
$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) {
    $status = (& claude auth status 2>$null) -join ''
    if ($status -match '"loggedIn":\s*true') { Say "  OK  signed in" 'Green' }
    else {
        Say "  Claude Code isn't signed in yet." 'Yellow'
        if (-not $DryRun -and (Ask "  Sign in now? (your browser opens)")) { & claude auth login }
        elseif ($DryRun) { Say "  (test run: would run 'claude auth login')" 'Yellow' }
    }
} else { Say "  Claude Code is needed. Get it at https://claude.com/claude-code" 'Red' }

# 4. The skill
Say "4. Copying the skill"
$skillDir = Join-Path $env:USERPROFILE '.claude\skills\sort-my-footage'
New-Item -ItemType Directory -Force -Path (Join-Path $skillDir 'scripts') | Out-Null
Copy-Item (Join-Path $here 'skill\SKILL.md') $skillDir -Force
Copy-Item (Join-Path $here 'skill\scripts\*') (Join-Path $skillDir 'scripts') -Force
Say "  OK  $skillDir" 'Green'

# 5. Desktop folder and launcher
Say "5. Desktop launcher"
$desktop = [Environment]::GetFolderPath('Desktop')
$home2 = if ($env:SORT_FOOTAGE_HOME) { $env:SORT_FOOTAGE_HOME } else { Join-Path $desktop 'Sort My Footage' }
New-Item -ItemType Directory -Force -Path $home2 | Out-Null
$pythonw = if ($python) { Join-Path (Split-Path $python) 'pythonw.exe' } else { 'pythonw' }
$script = Join-Path $skillDir 'scripts\sort_footage.py'
$bat = "@echo off`r`nrem Double-click to open Sort My Footage.`r`nstart `"`" `"$pythonw`" `"$script`"`r`n"
Set-Content -LiteralPath (Join-Path $home2 'Sort My Footage.bat') -Value $bat -Encoding ASCII
Copy-Item (Join-Path $here 'README.md') (Join-Path $home2 'HOW TO USE.md') -Force
Say "  OK  $home2" 'Green'

Say ""
Say "Done. Open 'Sort My Footage' on your Desktop and double-click 'Sort My Footage.bat'." 'White'
