# Global Claude Context — Jeff McCarrell

## Working style

- **When uncertain, ask first.** If the task is ambiguous or there are meaningful choices to make, stop and ask before proceeding. Don't assume and barrel ahead.
- **Code-first.** Show the code or the change. Keep prose explanations brief unless I ask for more detail.
- **Be direct.** Skip unnecessary preamble and filler. Get to the substance.

## Languages and tools

Primary: Python, Emacs Lisp, Shell/Bash

- Python: prefer standard library where sufficient; use virtual environments for projects with dependencies
- Emacs Lisp: functions and variables use the `jwm/` prefix; package management via `use-package`
- Shell: prefer bash; POSIX-compatible where portability matters

## Git repos and worktrees

Jeff's repos are **plain clones** — `git clone` into a standard tree and work at the
repo root. The **bare-root + worktrees** layout (a `.bare/` dir plus a `.git` pointer
file) is **not used** — Jeff considers it a mistake; never create one.

Feature worktrees are still fine where a repo uses them (e.g. the `lab` repos): the
layout is a **standard repo with sibling `*.worktrees/` dirs** — keep the main checkout
on `main` and add each worktree alongside it, never off a bare root.
- Each worktree is an independent checkout of a branch.
- `TASK.md` in a worktree/repo root (if present) describes what that checkout is
  currently focused on — read it before starting work.

### Worktrunk (`wt`)

Worktree operations go through [worktrunk](https://worktrunk.dev), not raw
`git worktree`:

```sh
wt switch --create <slug>   # create branch + worktree, based on the default branch
wt switch <slug>            # move to an existing worktree
wt list                     # all worktrees, with dirty/ahead/behind status
wt remove <slug>            # remove the worktree; delete the branch if merged
```

The `<repo>.worktrees/<branch>` layout comes from the `worktree-path` template in
`~/.config/worktrunk/config.toml` (seeded from the dotfiles repo), so it is
configured once rather than spelled out per command. Shell integration is loaded
from `.bash_profile`, which is what lets `wt switch` change the shell's directory.

If `wt` is not on PATH, fall back to the raw equivalents — `git worktree add
../<repo>.worktrees/<slug> -b <slug>`, `git worktree remove <path>`, `git worktree
list`. The layout is identical either way; only the branch-deletion safety below
is lost.

## Git authority

Claude may do these without asking:

- create feature worktrees and branches (`wt switch --create <slug>`)
- commit on feature branches (amend only commits that haven't been pushed)
- push feature branches (never push main; never use `--force`)
- manage issues and PRs: `gh` for GitHub repos, `tea` for Forgejo-hosted repos
- after Jeff merges a PR: `wt remove <slug>` for the branch Claude created —
  and the remote branch too, if Claude created it and the host didn't already
  auto-delete it — provided nothing outside the repo depends on that checkout
  (each project's CLAUDE.md defines its own checks)

Plain `wt remove` stays on that list because it cannot violate the never-list
below: it deletes the branch only when merging it would add nothing to the
default branch, recognizing squash and rebase merges via patch-id and tree
comparison, and it reports the evidence (`tree matches main`). On an unmerged
branch it removes the worktree, keeps the branch, and prints the `-D` command
rather than running it — that command is Jeff's to run, not Claude's.

Claude must never do these itself — it hands Jeff the exact command instead:

- commit anything to main, or merge any branch into main — including `wt merge`,
  which squashes, rebases, and fast-forwards the target in a single step
- delete any branch that is unmerged, or that Claude did not create — including
  `wt remove -D`, which force-deletes unmerged branches
- rewrite pushed history — no rebase, amend, or reset of commits that are
  already on the remote
- force-push anything
- add, remove, or repoint git remotes, or change repo settings

Main checkouts are read-only for Claude, file edits included — all work, code
and docs, lands via feature worktree + PR.

If the next required step is on the never-list and Jeff is unavailable: stop
and ask. Never work around it.

## Project workspaces

### /Users/jeff/jwm/proj/emacs-config
Jeff's Emacs configuration workspace — itself a git repo — containing:
- `literate-emacs.d/` — a plain git repo; active config project
- `reference-emacs-configs/` — cloned reference configs, read-only inspiration

See `emacs-config/CLAUDE.md` for full workspace layout.
See `emacs-config/literate-emacs.d/CLAUDE.md` for project conventions.

### /Users/jeff/jwm/proj/jwm-dotfiles-2024
Dotfiles repo — a plain git repo (files at the repo root; this file is `claude/CLAUDE.md`).
See `jwm-dotfiles-2024/README.md` for layout.

### /Users/jeff/pdata/jeff-ci
Personal quantitative finance / CI project. Standard git repo (not worktree-enabled).
See `jeff-ci/CLAUDE.md` for project conventions and architecture.

## TASK.md convention

In any worktree or repo checkout, a `TASK.md` file at the root describes the current goal and approach. It is not tracked in git. Always read it before starting work if it exists.
