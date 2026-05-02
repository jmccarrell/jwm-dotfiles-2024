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

## Git worktree pattern

Several of Jeff's projects use a **bare repo + worktrees** layout:

```
project-name/
├── .bare/       ← bare git repo
├── .git         ← pointer file: contains "gitdir: ./.bare"
└── main/        ← main worktree (feature worktrees are siblings)
    ├── CLAUDE.md
    └── ...
```

When working in one of these repos:
- All git commands and file work happen inside a worktree directory (e.g., `main/`), never at the top level
- Each worktree is an independent checkout of a branch
- `TASK.md` in a worktree root (if present) describes what that worktree is currently focused on — read it before starting work

## Project workspaces

### /Users/jeff/jwm/proj/emacs-config
Jeff's Emacs configuration workspace. Not itself a git repo — contains:
- `literate-emacs.d/` — worktree-enabled repo (bare + worktrees); active config project
- `reference-emacs-configs/` — 14 cloned reference configs, read-only inspiration

See `emacs-config/CLAUDE.md` for full workspace layout.
See `emacs-config/literate-emacs.d/main/CLAUDE.md` for project conventions.

### /Users/jeff/jwm/proj/jwm-dotfiles-2024
Dotfiles repo. Worktree-enabled (bare + worktrees, same pattern as above).
See `jwm-dotfiles-2024/main/CLAUDE.md` if present for project conventions.

### /Users/jeff/pdata/jeff-ci
Personal quantitative finance / CI project. Standard git repo (not worktree-enabled).
See `jeff-ci/CLAUDE.md` for project conventions and architecture.

## TASK.md convention

In any worktree, a `TASK.md` file at the worktree root describes the current goal and approach. It is not tracked in git. Always read it before starting work if it exists.
