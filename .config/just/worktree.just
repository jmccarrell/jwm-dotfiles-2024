# git-worktree-flow recipes — operational counterpart to the
# git-worktree-flow skill (~/.claude/skills/git-worktree-flow/SKILL.md).
#
# Operates on a "bare-root with worktrees" git project layout:
#
#     <project>/.bare/        — bare git repo
#     <project>/main/         — worktree on `main`
#     <project>/<feature>/    — feature-branch worktrees
#
# WIRING (per project, one-time, in the project's own justfile):
#
#     mod wt env_var('HOME') / '.config/just/worktree.just'
#
# Then invoke the recipes with the `wt::` namespace prefix:
#
#     just wt::new <feature>
#     just wt::status
#     just wt::fixup
#     just wt::close
#     ...
#
# Requires just >= 1.19 (for `mod`).
#
# DECOUPLING: these recipes do not call back to project-level recipes.
# Run your project's verification (e.g. `just verify`) BEFORE invoking
# `wt::fixup` or `wt::close`. The shared module stays project-agnostic.
#
# All recipes are run from inside a worktree (typically main/, or the
# active feature worktree). Recipes that operate on a sibling worktree
# expect to be invoked from a worktree that is NOT the target.

# Default recipe: list everything in this module.
@_:
    @just --list --unsorted --justfile {{justfile()}}

# Create a new feature worktree on a new branch.
#
# Run from any existing worktree (typically main/). Creates the new
# worktree at ../{{feature}}/ on a fresh branch named {{feature}}.
new feature:
    git worktree add ../{{feature}} -b {{feature}}
    @echo ""
    @echo "Worktree created: ../{{feature}}"
    @echo "Run any project-specific post-creation steps (symlinks, hook"
    @echo "installs, etc.) before editing."

# Track an existing remote feature branch on this machine.
#
# Cross-machine continuation. Fetches origin, then creates ../{{feature}}/
# as a worktree tracking origin/{{feature}}.
track feature:
    git fetch origin
    git worktree add -B {{feature}} ../{{feature}} origin/{{feature}}
    @echo ""
    @echo "Worktree tracking origin/{{feature}}: ../{{feature}}"
    @echo "Run any project-specific post-creation steps before editing."

# Read-only drift report: fetch + per-worktree status against origin.
#
# Mutates nothing locally. Use as a session-start sync check or any time
# you want to know what would need to happen to align with origin.
status:
    #!/usr/bin/env bash
    set -euo pipefail
    git fetch origin >/dev/null 2>&1 || {
        echo "wt::status: git fetch origin failed" >&2
        exit 1
    }
    git worktree list --porcelain | awk '
        /^worktree /  { wt=$2 }
        /^bare/       { wt="" }
        /^branch /    { branch=$2; sub("refs/heads/", "", branch); print wt"\t"branch }
    ' | while IFS=$'\t' read -r wt branch; do
        [ -z "$wt" ] && continue
        printf "=== %s (%s) ===\n" "$wt" "$branch"
        (cd "$wt" && git status -sb 2>/dev/null | head -3) || true
        echo ""
    done

# List worktrees with their branches.
list:
    git worktree list

# Make a fixup commit against the first real commit on this branch.
#
# Stage your files first (`git add ...`); this recipe does not stage on
# your behalf. Run AFTER your project's verification step has passed.
fixup:
    #!/usr/bin/env bash
    set -euo pipefail
    first=$(git log --reverse --format='%h' main..HEAD | head -1)
    if [ -z "$first" ]; then
        echo "wt::fixup: no commits on this branch yet — make a real commit first" >&2
        exit 1
    fi
    if git diff --cached --quiet; then
        echo "wt::fixup: nothing staged. Run 'git add ...' first." >&2
        exit 1
    fi
    git commit --fixup="$first"

# Autosquash rebase against main.
#
# Collapses the fixup chain into the targeted real commit. Run after
# the sub-goal is verified and ready to merge.
squash:
    git rebase --interactive --autosquash main

# Close the sub-goal: remove TASK.md, fixup the deletion, autosquash.
#
# After this returns, push with: git push --force-with-lease
# Run AFTER your project's verification step has passed.
close:
    #!/usr/bin/env bash
    set -euo pipefail
    first=$(git log --reverse --format='%h' main..HEAD | head -1)
    if [ -z "$first" ]; then
        echo "wt::close: no commits on this branch yet" >&2
        exit 1
    fi
    if [ -e TASK.md ]; then
        git rm TASK.md
        git commit --fixup="$first"
    fi
    git rebase --interactive --autosquash main
    echo ""
    echo "Squashed. When ready: git push --force-with-lease"

# Remove a feature worktree and delete its local branch.
#
# Run from a worktree OTHER than the one being removed (typically main/).
# Use after the branch has been merged.
clean feature:
    git worktree remove ../{{feature}}
    git branch -d {{feature}}
