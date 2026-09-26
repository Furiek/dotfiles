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
# Newly installed tools are not on the invoking shell's PATH yet.
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    throw 'Open a new terminal and run chezmoi apply again to finish font installation.'
}
& oh-my-posh font install FiraCode
if ($LASTEXITCODE -ne 0) { throw 'FiraCode Nerd Font installation failed.' }
Write-Host 'Select FiraCode Nerd Font in your terminal settings, then open PowerShell 7.'
