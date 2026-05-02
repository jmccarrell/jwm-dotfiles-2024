---
name: git-worktree-flow
description: Apply whenever working on a git project laid out as "bare-root with worktrees" — a directory containing a .bare/ subdirectory and one or more sibling worktree directories. Use for any task involving editing files, branching, committing, or syncing across machines in such a project. Detection — the project root contains both a .bare/ directory and a .git pointer file referring to it.
type: skill
---

# git-worktree-flow

## What this is for

A reusable flow for any git project laid out as **bare-root with
worktrees**:

```
<project>/
├── .bare/             ← the bare git repo
├── .git               ← pointer file: `gitdir: ./.bare`
├── main/              ← worktree on branch `main`
└── <feature>/         ← optional sibling worktrees on feature branches
```

All work happens inside a worktree. The bare root itself is not a working
directory; `git status` from `<project>/` is meaningless.

## When this skill applies

- The current working directory or any project under discussion has the
  layout above.
- The conversation mentions worktrees, feature branches, or syncing a
  project across machines.
- Claude is about to edit, commit, branch, or run a git operation in a
  project with this layout.

## Core rules

1. **Never edit files in `main/` for new task work.** Feature work happens
   in a feature worktree. The narrow exception is documentation-only edits
   — see "Meta-doc edits exception" below.

2. **Branches sync across machines; worktrees do not.** A worktree's
   `.git` pointer file contains absolute filesystem paths. Sync via
   `git push` / `git pull` and recreate worktrees per machine.

3. **Claude reads; Jeff acts on mutating git commands.** Claude runs
   read-only checks (`git fetch`, `git status -sb`, `git log`, etc.) and
   reports drift. Mutating commands (`git pull`, `git push`, `git merge`,
   `git rebase`, `git commit`) are proposed for Jeff to run on the host.

## Session-start sync

At the start of any planning or implementation session in a bare-root
project, Claude runs the read-only checks and reports drift:

```sh
# Bare repo: fetch only.
cd <project>/.bare && git fetch origin

# Each active worktree: report status against its remote.
cd <project>/<worktree> && git status -sb
```

If a worktree is behind, Claude proposes `git pull --ff-only`. If ahead,
`git push`. Jeff runs the actual command. Drift is surfaced, not gated —
Jeff decides whether to sync first or proceed against current state.

## Starting a feature

Before editing anything, Claude asks Jeff to create a feature worktree:

```sh
cd <project>/main
git worktree add ../<feature> -b <feature>
cd ../<feature>
# any project-specific post-creation steps (symlink repointing, etc.)
```

Then Claude writes `<project>/<feature>/TASK.md` and only then begins
editing source files inside `<project>/<feature>/`.

## Cross-machine continuation

To pick up a feature branch on a different machine after it was started
elsewhere and pushed:

```sh
# Sync the bare repo so origin/<feature> is known locally.
cd <project>/.bare && git fetch origin

# Create a fresh worktree tracking the existing remote branch.
cd <project>/main
git worktree add -B <feature> ../<feature> origin/<feature>
cd ../<feature>
# any project-specific post-creation steps (symlink repointing, etc.)
```

`-B <feature>` creates or resets a local branch to match
`origin/<feature>`, so the worktree is a normal tracking branch on this
machine. Any project-specific per-machine state (symlinks, hook installs,
caches) has to be re-established here.

## TASK.md convention

`TASK.md` lives in the worktree root. It captures, for the current
sub-goal: goal, approach, notes, verification checklist.

- **Tracked on the feature branch.** Committed alongside the work it
  describes; travels cross-machine via the branch.
- **Removed before merge.** A teardown step before squash deletes
  `TASK.md` so it never reaches `main`. Best bundled into a project's
  close recipe so it's hard to forget.
- **Read on entry.** If Claude enters a worktree and a `TASK.md` exists,
  Claude reads it before doing anything else.

## In-flight commits: fixup + autosquash

The pattern that keeps history clean while preserving in-flight
checkpoints is **fixup commits**: the first commit on the worktree is the
real change, every subsequent edit is a fixup of that commit, and
`git rebase --interactive --autosquash main` collapses the chain into a
single clean commit at sub-goal close.

A trial-and-error variant ("Pattern B": empty base, many small commits,
one squash at the end) exists for sub-goals where Claude is expected to
iterate heavily. Projects that want it should call it out explicitly;
otherwise default to fixup-on-first-real-commit.

### The fixup loop

1. Make the change.
2. Run any project-specific verification. Don't fixup until it passes.
3. `git add` only the files that should land in the same commit. Avoid
   staging unrelated drift.
4. `git commit --fixup=<first-commit-on-branch>`. Projects often expose
   this as a recipe (e.g. `just fixup`) with an interactive picker; the
   underlying command is the same.

A useful per-project invariant: if a generated artifact is paired with
its source, refuse to commit one without the other. Staged drift between
source and generated output is the main hazard with literate or
code-generated workflows.

### When to checkpoint

Natural checkpoints during sub-goal execution:

- After a project-specific verify step passes for a logical change.
- After a verification step in `TASK.md` passes.
- Before starting a follow-up edit that might need to be reverted.

Claude proposes a fixup at these moments rather than letting in-flight
refinements pile up uncheckpointed.

## Closing a sub-goal

When the sub-goal is verified and ready to merge:

```sh
# 1. Remove TASK.md from the branch.
git rm TASK.md
git commit --fixup=<first-commit-on-branch>

# 2. Sanity check the chain.
git log --oneline main..HEAD

# 3. Autosquash collapses the fixup chain into the target commit.
git rebase --interactive --autosquash main

# 4. Push the rewritten history safely.
git push --force-with-lease
```

`--force-with-lease` refuses to overwrite if origin has commits you
haven't seen locally.

Projects should bundle steps 1–3 into a single close recipe (e.g.
`just close`) so the TASK.md teardown is impossible to forget.

## Pre-push warning hook (per project, per machine)

A pre-push hook in `<project>/.bare/hooks/pre-push` that **warns without
blocking** when pushing a branch with unsquashed fixups is a useful
guardrail. Because `.bare/hooks/` is local to each clone, the hook is
per-machine setup. The canonical hook source lives tracked in the project
repo and an install recipe copies it into `.bare/hooks/` on each machine.

If WIP fixups need to travel cross-machine before squashing (paused on
machine A, resumed on machine B), bypass the warning with
`git push --no-verify`.

## Cleanup at sub-goal close

Once the squashed branch is merged and any project-specific generated
artifacts on `main` are regenerated, the feature worktree can be removed:

```sh
cd <project>/main
# project-specific: repoint any symlinks at main's files
git worktree remove ../<feature>
git branch -d <feature>
```

Repoint any project-specific symlinks back at `main` *before* removing the
worktree, or those symlinks dangle on next use.

## Meta-doc edits exception

Documentation-only files in `main/` that don't get processed into a
runtime artifact (no tangling, no generation, no symlink target) may be
edited directly in `main/`. Examples: `README.md`, project `CLAUDE.md`,
planning docs.

**Hard rule: every direct edit Claude makes to a tracked file in `main/`
must be accompanied in the same response by an explicit commit command
Jeff can paste:**

```sh
cd <project>/main && \
  git add <file> && git commit -m "<short summary>"
```

Without the commit, the edit accumulates as silent uncommitted state and
causes merge conflicts later when sub-goal worktrees touch the same file.

## Sandbox path-translation note

When Claude runs in a sandboxed agent context (e.g. Cowork's
local-agent-mode), the user's project folder may be mounted at a
different absolute path than the host sees. Worktrees record absolute
paths in their metadata, so a worktree created on the host has a `.git`
pointer that cannot be resolved from inside the sandbox.

- File tools (Read/Write/Edit) translate paths automatically — they work
  from either form.
- Git commands inside a worktree often fail in the sandbox if the
  worktree was created on the host. For read-only checks, use the bare
  repo directly: `git --git-dir=<project>/.bare ...`.
- Mutating git commands should be proposed for Jeff to run on the host,
  not executed in the sandbox.

This reinforces the "Claude reads, Jeff acts" rule.

## Project-specific layering

Projects layer their own concerns on top of this flow: symlinks,
generators, caches, sync helpers, spec conventions. Each project
describes its additions in its own CLAUDE.md. The first section of a
project CLAUDE.md should reference this skill so Claude knows the
worktree flow applies; the rest is project deviation.
