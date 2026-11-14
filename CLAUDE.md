# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal Linux dotfiles managed by [chezmoi](https://www.chezmoi.io/). This directory is the chezmoi **source state**; `chezmoi apply` renders it into `$HOME`. Packages come from Homebrew (Linuxbrew), secrets are age-encrypted. `bootstrap.sh` sets up a fresh machine (distro deps, brew, age, chezmoi, `chezmoi init Useekaw --apply --ssh`, `brew bundle`).

## Commands

```sh
chezmoi diff                          # preview what apply would change in $HOME
chezmoi apply [-v] [--dry-run]        # render source state into $HOME
chezmoi apply ~/.config/zsh           # apply a single target
chezmoi cat ~/.gitconfig              # print rendered target of one file
chezmoi execute-template < file.tmpl  # render an arbitrary template
chezmoi data                          # show template data (is_work, is_desktop, is_wsl, ...)
chezmoi managed / chezmoi ignored     # what is (not) deployed on this machine
chezmoi add|re-add <target>           # pull edits made in $HOME back into the source
shellcheck <script>                   # lint shell scripts (installed via Brewfile)
```

There is no build or test suite. Verify changes with `chezmoi diff` / `chezmoi cat` / `chezmoi execute-template`, and check other machine profiles with overridden data, e.g. `chezmoi --override-data '{"is_work":true,"is_desktop":false}' execute-template < file.tmpl` (same flag works with `ignored`, `managed`, `diff`).

Decrypting templates needs the age identity at `~/.secrets/age_chezmoi.key`.

## Architecture

### chezmoi naming

Source names encode target attributes: `dot_` → `.`, `private_` → mode 0700/0600, `executable_` → +x, `encrypted_` → age-decrypted on apply, `.tmpl` → Go template. Example: `dot_local/bin/executable_foo` → `~/.local/bin/foo`. New files at the repo root are deployed to `~/` unless listed in `.chezmoiignore.tmpl`.

### Machine profiles

`.chezmoi.toml.tmpl` defines three booleans used everywhere in templates:

- `is_work` – prompted once; selects work vs. personal git identity, SSH keys/hosts, Brewfile extras, age recipient.
- `is_desktop` – prompted once, forced `false` inside WSL; gates GUI configs (alacritty, gtk, matugen, VS Code, freerdp, `.desktop` files).
- `is_wsl` – detected from kernel release; enables `wslview` shim and WSL-only env.

Per-profile file exclusion lives in `.chezmoiignore.tmpl` (paths there are **target** paths, e.g. `.config/foo`, not `dot_config/foo`). Any new file that should not land on every machine needs an entry there.

### Secrets

- Whole-file secrets: `.secrets/*.age` and `.git_*.age` at the root (ignored as targets because they start with `.`), pulled into templates via `{{ (include ".secrets/x.age") | decrypt }}` (see `dot_ssh/`, `dot_gitconfig.tmpl`).
- Inline secrets: an armored age block piped to `decrypt` inside a template (see `dot_zshenv.tmpl`).
- Encrypted target files: `encrypted_` prefix (e.g. `dot_config/private_mcp-gateway/encrypted_private_token.age`).

Never write plaintext secrets into the source; encrypt with `chezmoi encrypt` / `age`.

### run_onchange scripts

`run_onchange_after_*.sh.tmpl` run after apply only when their rendered content changes. Each embeds a `sha256sum` of the file it reacts to (Brewfile → `brew bundle`, bat themes → `bat cache --build`, yazi `package.toml` → `ya pkg install`, systemd units → enable timers). When adding such a script, include the hash of its input in a comment so edits retrigger it. Scripts must skip gracefully (exit 0) when the tool is missing.

### Packages

`dot_brewfile.tmpl` → `~/.brewfile`, with work/personal sections. Third-party tap formulae need `trusted: true` in the Brewfile itself.

### Shell

`dot_zshrc.tmpl` sources `~/.config/zsh/*.zsh` in lexical order; numeric prefixes (`000-init` zinit … `099-omp` oh-my-posh) define load order. `dot_zshenv.tmpl` holds env/PATH/ssh-agent.

### Update notices

systemd user timers (`dot_config/systemd/user/*-update-check.*`) run `~/.local/bin/{chezmoi,brew}-update-check`, which write a status file to `$XDG_CACHE_HOME`; `090`/`091-*-notice.zsh` show it at shell start, and `085-update-check-hooks.zsh` wraps `brew`/`chezmoi` to refresh it after updates. `chezmoi-update-check` does `git pull --ff-only` in the source dir.

### Theming

On personal desktops, matugen (driven by DankMaterialShell) generates themes from the wallpaper: templates in `dot_config/matugen/templates/` → yazi/zellij/bat theme files, with post-hooks `bat-theme-hue-sync.py` and `zellij-ansi-sync.py`. Generated files are not managed (see `.chezmoiignore.tmpl`). Configs that reference the matugen theme fall back to `gruvbox-dark` where it is not generated (`dot_config/bat/config.tmpl`, `dot_config/zellij/config.kdl.tmpl` via `lookPath "matugen"`).

### Externals

`.chezmoiexternal.toml` clones `~/.config/nvim` from `github.com/Useekaw/nvim` (branch `personal`); Neovim config is not in this repo.

### Claude Code

`private_dot_claude/` deploys only custom agents and skills to `~/.claude/` (homelab/Obsidian-related, excluded on work machines). Other Claude Code config is not managed here.

## Conventions

- Conventional Commits with a scope naming the tool, e.g. `fix(brew): ...`, `feat(zellij): ...`.
- Comments explain *why* a setting exists (often the bug it works around); keep that style.
