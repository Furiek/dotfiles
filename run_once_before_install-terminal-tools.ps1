$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'Windows only' }
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'Install App Installer (winget) from the Microsoft Store, then run chezmoi apply again.'
}
$packages = @{
    'git' = 'Git.Git'
    'pwsh' = 'Microsoft.PowerShell'
    'oh-my-posh' = 'JanDeDobbeleer.OhMyPosh'
    'fzf' = 'junegunn.fzf'
    'fd' = 'sharkdp.fd'
    'bat' = 'sharkdp.bat'
}
foreach ($command in $packages.Keys) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        & winget install --id $packages[$command] --exact --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
        # winget also returns this code when the installed package has no upgrade.
        if ($LASTEXITCODE -notin @(0, -1978335189)) {
            throw "winget failed for $($packages[$command]) (exit $LASTEXITCODE)"
        }
    }
}
Write-Host 'Open a new PowerShell 7 window to use the terminal setup.'
