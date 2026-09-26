$ErrorActionPreference = 'Stop'
# Resolve the real Documents directory, including OneDrive/folder redirection.
$documents = [Environment]::GetFolderPath('MyDocuments')
if (-not $documents) { throw 'Cannot locate the Windows Documents directory.' }
$loader = '. (Join-Path $HOME ''.config/powershell/profile.ps1'') # chezmoi-dotfiles'
foreach ($edition in @('PowerShell', 'WindowsPowerShell')) {
    $directory = Join-Path $documents $edition
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $profilePath = Join-Path $directory 'profile.ps1'
    $existing = if (Test-Path $profilePath) { Get-Content -LiteralPath $profilePath -Raw } else { '' }
    if ($existing -notmatch [regex]::Escape($loader)) {
        if (Test-Path $profilePath) {
            Copy-Item -LiteralPath $profilePath -Destination ($profilePath + '.chezmoi-backup') -Force
        }
        Set-Content -LiteralPath $profilePath -Value ($existing + "`r`n" + $loader) -Encoding UTF8
    }
}
