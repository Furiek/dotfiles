# Shared by PowerShell 7 and Windows PowerShell; loaded by profile.ps1.
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Windows -HistoryNoDuplicates -MaximumHistoryCount 10000
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    if ((Get-Command Set-PSReadLineOption).Parameters.ContainsKey('PredictionSource')) {
        Set-PSReadLineOption -PredictionSource History
    }
}

# Remove built-in aliases that would otherwise take precedence over functions.
'gc', 'gp', 'gl' | ForEach-Object {
    Remove-Item "Alias:$_" -Force -ErrorAction SilentlyContinue
}
function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force @args }
function l { Get-ChildItem @args }
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function gs { git status @args }
function ga { git add @args }
function gaa { git add --all @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git pull @args }
function gb { git branch @args }
function gco { git checkout @args }
function gsw { git switch @args }
function gd { git diff @args }
function dps { docker ps @args }
function dpa { docker ps -a @args }
function dc { docker compose @args }
function dcu { docker compose up -d @args }
function dcd { docker compose down @args }
function dcl { docker compose logs -f @args }
function update { winget upgrade --all @args }
function ports { Get-NetTCPConnection @args }
function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Force -Path $Path -ErrorAction Stop | Out-Null
    Set-Location -LiteralPath $Path
}

if (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
    $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    $env:FZF_ALT_C_COMMAND = 'fd --type d --hidden --follow --exclude .git'
}
# Fuzzy file selection without requiring an extra PowerShell Gallery module.
function ff {
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) { return }
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd --type f --hidden --follow --exclude .git | fzf @args
    } else {
        Get-ChildItem -File -Recurse | ForEach-Object FullName | fzf @args
    }
}
# Keep environment names in the theme instead of adding another prompt prefix.
$env:VIRTUAL_ENV_DISABLE_PROMPT = '1'
$env:CONDA_CHANGEPS1 = 'false'
$poshTheme = Join-Path $HOME '.config/oh-my-posh/montys.omp.json'
if ($env:TERM -eq 'linux' -or $env:DOTFILES_PROMPT_STYLE -eq 'console') {
    $poshTheme = Join-Path $HOME '.config/oh-my-posh/montys-console.omp.json'
}
if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path $poshTheme)) {
    oh-my-posh init pwsh --config $poshTheme | Invoke-Expression
}
Write-Host ''
Write-Host 'Furiek' -ForegroundColor Magenta
Write-Host '--------------------------------------'
