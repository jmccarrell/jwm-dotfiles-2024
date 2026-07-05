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
on `main` and add each worktree alongside it (`git worktree add ../<repo>.worktrees/<slug>`),
never off a bare root.
- Each worktree is an independent checkout of a branch.
- `TASK.md` in a worktree/repo root (if present) describes what that checkout is
  currently focused on — read it before starting work.

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
