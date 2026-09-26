# dotfiles

My Bash and PowerShell setup, managed with chezmoi.

Oh My Posh with Montys, fzf, fd, bat, and
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

## Git Bash on Windows

Use the Windows `chezmoi.exe` installed above, not the Linux executable in WSL.
The Windows installer supplies Git, Oh My Posh, fzf, fd and bat for both shells.
From Git Bash, after pushing these changes:

```bash
chezmoi update
exec bash --login
```

On a fresh machine, use the same `chezmoi init --apply` command as PowerShell.
Chezmoi now deploys `.bashrc` on Windows too. A setup script adds a guarded loader
to the first existing `.bash_profile`, `.bash_login`, or `.profile`, backing it up
before editing. If none exists, it creates `.bash_profile`. Run a full apply;
`--exclude scripts` skips this login setup.

Git Bash's `$HOME` must point to the same Windows user directory chezmoi manages
(normally `/c/Users/YourName`). WSL has a separate Linux home and setup. Compare
`echo "$HOME"` and `chezmoi execute-template '{{ .chezmoi.homeDir }}'` if files
seem to land in the wrong place. Reopen Git Bash after installing tools so it
picks up the Windows PATH. Linux-only tools (ble.sh, tmux and figlet) aren't
installed on Windows; the banner falls back to colored text.

## Prompt

The prompt is Montys, selected at shell startup:

- Graphical terminals and typical SSH sessions get full Montys with Nerd Font icons.
- Linux text consoles (`TERM=linux`), including Proxmox's VM console, get Montys
  with ASCII symbols and standard ANSI colors instead of custom RGB colors.
- Bash uses a basic prompt for `TERM=dumb` or an unset terminal type.

Neither variant changes the terminal palette or whole-window background. Montys
colors only its own prompt segments. The environment and Docker indicators remain:
active Python/Conda environment (including `base`), Python version, and non-default
Docker context or host. Python, Conda and Docker themselves are not installed.

FiraCode Nerd Font is installed by the setup scripts. Select it in your graphical
terminal's preferences. With SSH the font is needed on the computer running the
terminal, not just the remote VM. Existing setups missing the font can run
`oh-my-posh font install FiraCode` on that computer.

Terminal type cannot tell us whether a font is installed. To use the console
variant in a graphical terminal or SSH session without Nerd Fonts:

```bash
export DOTFILES_PROMPT_STYLE=console
exec bash
```

In PowerShell, set `$env:DOTFILES_PROMPT_STYLE = 'console'` and reload the profile.
Unset the variable to return to automatic selection.

Both themes are stored in `dot_config/oh-my-posh/`. The upstream license is in
`LICENSE.oh-my-posh`.

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
