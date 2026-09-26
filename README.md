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

## Terminal colors

The shell sets a warm paper background (`#E8DCC5`), dark text (`#292524`) and a
dark cursor in Windows Terminal and terminals supporting xterm color sequences,
such as Ubuntu's GNOME Terminal. Bash also sets paper/ink colors on the Linux
text console (`TERM=linux`), including Proxmox's VM console. Run `clear` once
there if old screen contents still have the previous background.

These are session colors, applied when the shell opens; terminal settings files
aren't replaced. Over SSH they affect the terminal you're connecting from.
Multiplexers, redirected output and unrecognized terminal types are skipped.
If your terminal blocks color changes, set those colors in its preferences.

Use any standard monospace font. Nerd Fonts are no longer downloaded or required;
previously installed fonts are left in place.

## Prompt

Bash and PowerShell use our version of
[stelbent-compact.minimal](https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/stelbent-compact.minimal.omp.json).
It keeps the compact layout and colors, with ASCII labels and separators for
Proxmox consoles as well as desktop terminals. No Nerd Font is needed for the
prompt. The shell sets the window colors separately from the prompt.

- Python: shows the active virtual environment name and Python version.
- Conda: shows the active environment, including `base`. If a virtualenv is
  activated inside Conda, the inner virtualenv is shown.
- Docker: shows a non-default context or Docker host when configured. The default
  local context is hidden. This identifies the selected target, not daemon health
  or running containers.

Activate environments as usual; this setup doesn't install Python, Conda or
Docker. Their extra prompt prefixes are disabled so the theme displays the name
only once. Restart the shell before activating an environment after an update.

Edit `dot_config/oh-my-posh/stelbent-compact.minimal.omp.json` to customize it.
The theme is stored in this repo, so upstream downloads won't overwrite changes.
The upstream license is in `LICENSE.oh-my-posh`.

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
