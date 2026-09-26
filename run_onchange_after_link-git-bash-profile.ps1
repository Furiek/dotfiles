param([string]$Destination = $HOME)
$ErrorActionPreference = 'Stop'
# Bash reads only the first existing login file; preserve that choice and content.
$profilePath = Join-Path $Destination '.bash_profile'
foreach ($name in @('.bash_profile', '.bash_login', '.profile')) {
    $candidate = Join-Path $Destination $name
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        $profilePath = $candidate
        break
    }
}
$marker = '# chezmoi-dotfiles: load interactive Bash configuration'
$existing = if (Test-Path -LiteralPath $profilePath) { [IO.File]::ReadAllText($profilePath) } else { '' }
if (-not $existing.Contains($marker)) {
    if (Test-Path -LiteralPath $profilePath) {
        Copy-Item -LiteralPath $profilePath -Destination ($profilePath + '.chezmoi-backup') -Force
    }
    $loader = @'
# chezmoi-dotfiles: load interactive Bash configuration
if [ -n "${BASH_VERSION-}" ] && [ -z "${_DOTFILES_BASHRC_LOADED-}" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
'@
    $text = $existing.TrimEnd("`r", "`n") + "`n" + $loader.Replace("`r`n", "`n") + "`n"
    [IO.File]::WriteAllText($profilePath, $text, (New-Object System.Text.UTF8Encoding($false)))
}
