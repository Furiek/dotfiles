param(
    [string]$UserHome = $HOME,
    [string]$LocalAppData = $env:LOCALAPPDATA
)
$ErrorActionPreference = 'Stop'
$imagePath = Join-Path $UserHome 'background_images/fkwindows.jpg'
if (-not (Test-Path -LiteralPath $imagePath -PathType Leaf)) {
    throw "Background image not found: $imagePath"
}
$terminalPaths = @(
    'Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json'
    'Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json'
    'Microsoft/Windows Terminal/settings.json'
)
$settingsPaths = @($terminalPaths | ForEach-Object {
    if ($LocalAppData) {
        $candidate = Join-Path $LocalAppData $_
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { $candidate }
    }
})
# PowerShell 7 parses Windows Terminal's JSON with comments and trailing commas.
if ($settingsPaths.Count -gt 0 -and $PSVersionTable.PSVersion.Major -lt 7) {
    $pwsh = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    $pwshPath = if ($pwsh) { $pwsh.Source } else { Join-Path $env:ProgramFiles 'PowerShell/7/pwsh.exe' }
    if (-not (Test-Path -LiteralPath $pwshPath)) {
        throw 'Open PowerShell 7 and run chezmoi apply again to configure terminal backgrounds.'
    }
    & $pwshPath -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -UserHome $UserHome -LocalAppData $LocalAppData
    if ($LASTEXITCODE -ne 0) { throw 'Terminal background configuration failed.' }
    return
}
function Save-Settings([string]$Path, [string]$Text) {
    # Keep the first backup so repeated applies do not overwrite the original.
    if ((Test-Path -LiteralPath $Path) -and -not (Test-Path -LiteralPath ($Path + '.chezmoi-backup'))) {
        Copy-Item -LiteralPath $Path -Destination ($Path + '.chezmoi-backup')
    }
    [IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}
foreach ($path in $settingsPaths) {
    $settings = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -AsHashtable
    if ($settings -isnot [System.Collections.IDictionary]) { throw "Expected a JSON object in $path" }
    if (-not $settings.Contains('profiles')) { $settings['profiles'] = @{} }
    if ($settings['profiles'] -isnot [System.Collections.IDictionary]) { throw "Unexpected profiles format in $path" }
    if (-not $settings['profiles'].Contains('defaults')) { $settings['profiles']['defaults'] = @{} }
    $defaults = $settings['profiles']['defaults']
    if ($defaults -isnot [System.Collections.IDictionary]) { throw "Unexpected profile defaults in $path" }
    $desired = @{
        backgroundImage = $imagePath.Replace('\', '/')
        backgroundImageOpacity = 0.15
        backgroundImageStretchMode = 'uniformToFill'
        backgroundImageAlignment = 'center'
    }
    $changed = $false
    foreach ($key in $desired.Keys) {
        if ($defaults[$key] -ne $desired[$key]) {
            $defaults[$key] = $desired[$key]
            $changed = $true
        }
    }
    if ($changed) {
        Save-Settings $path (($settings | ConvertTo-Json -Depth 100) + "`n")
        Write-Host "Configured Windows Terminal background: $path"
    }
}
# Mintty's standard user config, used by standalone Git Bash. Other keys survive.
$minttyPath = Join-Path $UserHome '.minttyrc'
$existing = if (Test-Path -LiteralPath $minttyPath) { [IO.File]::ReadAllText($minttyPath) } else { '' }
$background = 'Background=~/background_images/fkwindows.jpg,38'
if ($existing -notmatch ('(?m)^' + [regex]::Escape($background) + '\r?$')) {
    $updated = [regex]::Replace($existing, '(?m)^Background=.*(?:\r?\n|$)', '')
    Save-Settings $minttyPath ($updated.TrimEnd("`r", "`n") + "`n" + $background + "`n")
    Write-Host 'Configured Mintty background. Reopen Git Bash to see it.'
}
