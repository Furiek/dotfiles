# dotfiles

My Bash and PowerShell setup, managed with chezmoi.

Oh My Posh with a customized stelbent-compact.minimal theme, fzf, fd, bat, and
Git/Docker shortcuts. Linux gets ble.sh, tmux and figlet. PowerShell uses
PSReadLine and has an `ff` command for fuzzy file search. Docker isn't installed
by these scripts.

## Linux

The installer supports Debian/Ubuntu, Fedora and Arch. WSL uses the Linux setup.

On Debian/Ubuntu, install the prerequisites:

```bash
sudo apt-get update && sudo apt-get install -y git curl
```

On Fedora or Arch, install `git` and `curl` with your package manager. Then:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
"$HOME/.local/bin/chezmoi" init --apply https://github.com/Furiek/dotfiles.git
exec bash
```

You'll need sudo for the system packages. On other distros, install the tools
manually and use `chezmoi apply --exclude scripts` after initializing the repo.

## Windows

Run in PowerShell. If `winget` is missing, install App Installer from the
Microsoft Store first.

```powershell
winget install --id Git.Git --exact --source winget
winget install --id twpayne.chezmoi --exact --source winget
```

Close and reopen PowerShell, then:

```powershell
chezmoi init --apply https://github.com/Furiek/dotfiles.git
```

This installs the tools and PowerShell 7. Open PowerShell 7 when it's done.
Windows PowerShell 5.1 also has a profile configured.

If PowerShell blocks the profile, allow local scripts for your user:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

The shared profile lives at `~/.config/powershell/profile.ps1`. Setup adds a
line to load it from both PowerShell editions' profiles, using the actual
Documents folder even if it's in OneDrive. Existing profiles are kept, with a
`.chezmoi-backup` copy made before editing.

## Prompt

Both shells use `stelbent-compact.minimal.omp.json`, with ASCII separators and
terminal-default text colors. Prompt backgrounds are transparent. The shell
does not change the terminal palette or window background. Nerd Fonts aren't
required or installed.

Python/Conda names appear when an environment is active, including Conda `base`.
A virtualenv inside Conda takes precedence. Docker shows a configured non-default
context or host, not daemon health or running containers. These tools are not
installed by the dotfiles. Their extra environment prompt prefixes are disabled
to avoid showing the environment name twice.

The customized theme lives in `dot_config/oh-my-posh/`; its upstream license is
in `LICENSE.oh-my-posh`.

If an earlier setup changed your Proxmox Linux console colors, reset them once
in that console after updating:

```bash
printf '\033]R\033[0;37;40m\033[8]\033[2J\033[H'
exec bash
```

This recovery command is for the Linux text console (`TERM=linux`), not an SSH
terminal window.

## Private repo

Authenticate with GitHub before running `chezmoi init`. With an SSH key set up,
use this instead of the HTTPS command:

```bash
chezmoi init --apply git@github.com:Furiek/dotfiles.git
```

## Updates

After pushing changes, run this on your other machines:

```bash
chezmoi update
```

The installers run once per machine. Shell configs update on every apply.

## Working on the repo

Edit files in `~/Code/dotfiles`. From that checkout:

```bash
chezmoi --source . diff
chezmoi --source . apply
```

These commands also work in PowerShell. To apply just the config files without
running installers or registering the Windows profile loader:

```bash
chezmoi --source . apply --exclude scripts
```

No need to copy files into chezmoi's source directory or change `sourceDir`.
Fresh machines use chezmoi's default location, normally
`~/.local/share/chezmoi` on Linux.
