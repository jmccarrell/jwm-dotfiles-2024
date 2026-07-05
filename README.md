# jwm-dotfiles-2024
Jeffs dotfiles; back to bash

## Layout & install (GNU Stow)

This repo **seeds** a specific, enumerated set of config files into `$HOME` and
`~/.config` — and nothing more. It does **not** own or mirror those directories.
`~/.config` in particular is a *shared* directory: many programs (`gcloud`, `gh`,
`git`, `zed`, `op`, `sops`, …) write into it freely, and the dotfiles just drop a few
symlinks in alongside them. A file's path in the repo is where its symlink lands:

```
# the seed set — everything this repo installs
.config/starship.toml          -> ~/.config/starship.toml
.config/direnv/direnvrc        -> ~/.config/direnv/direnvrc
.config/kitty/*                -> ~/.config/kitty/*
.config/ghostty/config.ghostty -> ~/.config/ghostty/config.ghostty
.bash_profile, .aliases, …     -> ~/…            (top-level $HOME dotfiles)
claude/CLAUDE.md, …            -> ~/.claude/…    (separate `claude` package)
```

Install with [`just`](https://github.com/casey/just):

```sh
just check     # dry run — show what would be linked, write nothing
just install   # link the seed set into place
just status    # verify the seed is healthy (symlinks resolve, nothing folded)
```

**Always install via `just`, never a bare `stow`.** The safety of seeding into a
shared `~/.config` depends on flags the recipes bake in; a hand-run `stow` without
them can quietly fold a lightly-populated managed dir (e.g. `ghostty/`) into a
directory symlink and capture another program's writes.

Guarantees, and the flags that provide them (see `justfile`):

- **`--no-folding`** → managed subdirs (`kitty/`, `ghostty/`, `direnv/`) and `~/.config`
  itself stay **real directories** with per-file symlinks inside. Stow never collapses
  one into a single directory symlink. This is what lets other programs — and kitty's
  own runtime files (`session-*.bash`, `*.bak`, gitignored) — keep writing into
  `~/.config/*` without touching the repo.
- **no `--adopt`** → an existing target file is never sucked into the repo (adoption is
  a one-off import tool; run it by hand deliberately if you ever need it, never in a
  routine install).
- **conflicts error out** → a real file owned by another tool is never clobbered; stow
  stops and reports instead.
- `~/.claude/` (global Claude config) is a separate `claude/` package because the repo
  already has its own repo-local `.claude/`; the root package ignores `claude`.

## Git identity

Shared Git config now uses three layers:

- `.gitconfig` is the tracked base config.
- `.gitconfig.personal` is the tracked override for repos under `~/jwm`.
- `.gitconfig.machine` is an untracked per-machine file that sets the default email.

Create `.gitconfig.machine` in the repo checkout before installing the dotfiles.

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
