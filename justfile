home_dir := env("HOME")
test_dir := home_dir / "tmp/test-dotfiles"

# flags shared by every stow call:
#   --no-folding : make target dirs real dirs with per-file symlinks, never fold a
#                  whole dir into one symlink (keeps app runtime junk out of the repo)
#   NOTE: --adopt is deliberately NOT used. Adoption is a one-off import tool; in a
#   routine install it silently pulls target files into the repo and diverges machines.
stow_flags := "--verbose --no-folding"

# the '.' package installs the whole repo tree ($HOME + .config/*), minus repo meta,
# the repo-local .claude/ (settings for THIS repo), and the claude/ package (which the
# install recipe stows into ~/.claude separately, NOT ~/claude).
root_ignores := "--ignore=justfile --ignore=README.md --ignore=LICENSE --ignore=claude"

@_:
    just --list

# stow one package tree onto a target, creating the target if needed
[private]
stow-pkg target pkg *flags:
    mkdir -p {{target}}
    stow {{stow_flags}} {{flags}} -t {{target}} -S {{pkg}}

# Install all dotfiles
install: (stow-pkg home_dir "." root_ignores) (stow-pkg (home_dir / ".claude") "claude")

# Preview the root package without writing anything
check:
    stow {{stow_flags}} --no {{root_ignores}} -t {{home_dir}} -S .

# Verify the seed is healthy: every seeded file is a symlink into this repo, and every
# shared parent dir under ~/.config is a REAL dir (never folded into a symlink). Exit
# non-zero on any failure. Seed list is derived from git, so it never drifts.
status:
    #!/usr/bin/env bash
    set -uo pipefail
    repo="$(pwd)"
    fail=0
    # ~/.config and the managed subdirs must stay real dirs (the folding tripwire)
    for d in .config .config/kitty .config/ghostty .config/direnv; do
      t="{{home_dir}}/$d"
      if [ -L "$t" ]; then echo "✗ $d is a SYMLINK (folded!) — must be a real dir"; fail=1
      elif [ -d "$t" ]; then echo "✓ $d is a real dir"
      else echo "✗ $d missing"; fail=1; fi
    done
    # every tracked .config file must be a symlink resolving into this repo
    while IFS= read -r f; do
      t="{{home_dir}}/$f"
      if [ ! -L "$t" ]; then echo "✗ $f not a symlink"; fail=1
      elif [ "$(cd "$(dirname "$t")" && realpath "$(readlink "$t")")" != "$repo/$f" ]; then
        echo "✗ $f -> $(readlink "$t") (not this repo)"; fail=1
      elif [ ! -e "$t" ]; then echo "✗ $f dangling"; fail=1
      else echo "✓ $f -> repo"; fi
    done < <(git ls-files .config)
    exit $fail

# Test install into a temp directory
test: (stow-pkg test_dir "." root_ignores) (stow-pkg (test_dir / ".claude") "claude")

# Clean test directory
clean:
    rm -rf {{test_dir}}
