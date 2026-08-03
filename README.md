# jwm-dotfiles-2024
Jeffs dotfiles; back to bash

## Layout & install (GNU Stow)

Everything this repo installs lives under `home/`, which mirrors `$HOME`. A file's
path below `home/` is where its symlink lands, and that is the whole rule:

```
home/.bash_profile               -> ~/.bash_profile
home/.aliases  .functions  .path -> ~/…                (top-level $HOME dotfiles)
home/.claude/CLAUDE.md           -> ~/.claude/CLAUDE.md
home/.config/starship.toml       -> ~/.config/starship.toml
home/.config/direnv/direnvrc     -> ~/.config/direnv/direnvrc
home/.config/ghostty/config.ghostty
home/.config/git/ignore          -> ~/.config/git/ignore
home/.config/git/attributes      -> ~/.config/git/attributes
home/.config/mise/config.toml    home/.config/uv/uv.toml
home/.config/worktrunk/config.toml
home/.config/yazi/yazi.toml      home/.config/yazi/keymap.toml
```

`home/` is the only stow package, so the repo root is free: `justfile`, `README.md`,
the repo-local `.claude/`, an untracked `TASK.md` — none of it can reach `$HOME`.
That used to require a hand-maintained `--ignore` list, and a file added at the repo
root was seeded into `$HOME` until someone remembered to extend it.

This repo seeds an enumerated set of files and **does not own or mirror** the
directories it seeds into. `~/.config` in particular is *shared*: `gcloud`, `gh`,
`git`, `zed`, `op`, `sops` and others write into it freely, and these are just a few
symlinks alongside them. `~/.claude` is shared the same way, with far more at stake —
every session, project and plugin Claude Code writes lives there.

Install with [`just`](https://github.com/casey/just):

```sh
just check     # dry run — show what would be linked, write nothing
just install   # link the seed set into place
just status    # verify the seed is healthy (symlinks resolve, nothing folded)
```

**Always install via `just`, never a bare `stow`.** The safety of seeding into shared
directories depends on flags the recipes bake in; a hand-run `stow` without them can
quietly fold a lightly-populated managed dir into a directory symlink and capture
another program's writes.

Guarantees, and the flags that provide them (see `justfile`):

- **`--no-folding`** → every managed dir (`~/.claude`, `~/.config`, and the subdirs
  under it) stays a **real directory** with per-file symlinks inside. Fold one into a
  directory symlink and every file the owning app later writes there — caches,
  session state, downloaded packages — lands in this repo instead. `just status`
  enforces it as a tripwire.
- **no `--adopt`** → an existing target file is never sucked into the repo (adoption is
  a one-off import tool; run it by hand deliberately if you ever need it, never in a
  routine install).
- **conflicts error out** → a real file owned by another tool is never clobbered; stow
  stops and reports instead, leaving `$HOME` untouched.

## Git identity

Shared Git config uses three layers:

- `home/.gitconfig` is the tracked base config.
- `home/.gitconfig.personal` is the tracked override for repos under `~/jwm`.
- `home/.gitconfig.machine` is an untracked per-machine file that sets the default
  email.

Create `home/.gitconfig.machine` before installing the dotfiles.

Work machine:

```gitconfig
[user]
	email = work-address@example.com
```

Personal machine:

```gitconfig
[user]
	email = personal-address@example.com
```

With that in place:

- work-machine repos under `~/code` use the work address
- work-machine repos under `~/jwm` use the personal address
- personal-machine repos use the personal address everywhere

## Global git ignore and attributes

`home/.config/git/{ignore,attributes}` are git's own default locations when
`core.excludesfile` and `core.attributesfile` are unset — which is why `.gitconfig`
sets neither. The previous `~/.gitignore` could not be a symlink at all: a file
basenamed `.gitignore` is in stow's built-in ignore list, so it sat in `$HOME`
unmanaged while a byte-identical copy at `~/.config/git/ignore` went unread.

The repo's own root `.gitignore` is a different file with a different job, and is not
seeded anywhere.
