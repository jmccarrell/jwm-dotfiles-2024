home_dir := env("HOME")
test_dir := home_dir / "tmp/test-dotfiles"

# flags shared by every stow call:
#   --no-folding : make target dirs real dirs with per-file symlinks, never fold a
#                  whole dir into one symlink (keeps app runtime junk out of the repo)
#   NOTE: --adopt is deliberately NOT used. Adoption is a one-off import tool; in a
#   routine install it silently pulls target files into the repo and diverges machines.
#
# --verbose is deliberately NOT shared any more. `install` now runs unattended from
# bin/daily (jwm-bin) every morning, and under -R stow narrates all ~21 links on
# every run whether or not anything changed: a healthy no-op is 36 lines. Quiet
# here means silence when there is nothing to say, and a conflict report when there
# is. `check` and `test` opt back in explicitly, because for them the narration IS
# the output.
stow_flags := "--no-folding"

# the '.' package installs the whole repo tree ($HOME + .config/*), minus repo meta,
# the repo-local .claude/ (settings for THIS repo), and the claude/ package (which the
# install recipe stows into ~/.claude separately, NOT ~/claude).
root_ignores := "--ignore=justfile --ignore=README.md --ignore=LICENSE --ignore=claude"

@_:
    just --list

# stow one package tree onto a target, creating the target if needed.
#
# -R (restow = unstow, then stow) rather than -S (stow). -S is add-only: it links
# whatever is new and never looks at what left, so a file deleted from the repo
# keeps its now-dangling symlink in $HOME forever. Retiring kitty needed manual
# cleanup for exactly this reason, and `just status` would not have caught it --
# it iterates `git ls-files`, so it only ever validates files that ARE in the repo,
# never orphans from files that are not.
#
# -R costs the same (23ms vs 24ms on this tree) and is no less safe: stow 2.4
# resolves the whole plan and reports conflicts BEFORE touching the filesystem, so
# a conflict aborts with everything still in place, exit 1, under either flag.
# What it does cost is churn -- every run unlinks and relinks all ~21 links, which
# leaves a ~24ms window per run where the symlinks are absent.
[private]
stow-pkg target pkg *flags:
    mkdir -p {{target}}
    stow {{stow_flags}} {{flags}} -t {{target}} -R {{pkg}}

# Install all dotfiles
install: (stow-pkg home_dir "." root_ignores) (stow-pkg (home_dir / ".claude") "claude")

# Deliberately -S where `install` is -R, and verbose where `install` is quiet.
# This is a preview, so what matters is telling "nothing to do" from "something to
# do" at a glance: -S --no is 1 line on a healthy tree and grows only for a new
# link or a conflict, where -R --no is 37 lines either way.
#
# The cost of that choice: this will not show a pending deletion cleanup, since
# only -R performs one. `just install` is what reconciles them.

# Preview the root package without writing anything
check:
    stow {{stow_flags}} --verbose --no {{root_ignores}} -t {{home_dir}} -S .

# This exists because the answer rots silently. On macOS every terminal tab is a
# login shell, so anything ~/.bash_profile does is billed per tab -- and by Aug
# 2026 a `pyenv init -` plus a homebrew-python symlink pass had grown to 0.86s of
# a 1.40s startup with nothing to surface it.
#
# Prints the end-to-end cost first, then a per-line breakdown from an xtrace with
# $EPOCHREALTIME timestamps in PS4. The "site" column is file:line, so a
# regression points straight at the offending line.
#
# Time a login shell, and show where the time goes
profile-shell-startup runs="7":
    #!/usr/bin/env bash
    set -uo pipefail
    [ -n "${EPOCHREALTIME:-}" ] || { echo "needs bash 5+ (got ${BASH_VERSION})" >&2; exit 1; }

    # warm the page cache first -- a cold first run reads ~2x slower and would
    # dominate a small sample
    "$BASH" --login -c exit > /dev/null 2>&1
    t0=$EPOCHREALTIME
    for (( i = 0; i < {{runs}}; i++ )); do "$BASH" --login -c exit > /dev/null 2>&1; done
    t1=$EPOCHREALTIME
    printf '\n  %.1f ms per login shell (mean of {{runs}})\n\n' \
        "$(echo "($t1 - $t0) * 1000 / {{runs}}" | bc -l)"

    # Trace a plain `source ~/.bash_profile` rather than a real login shell: the
    # tracer needs PS4 set before the first traced command, which a login shell
    # gives no hook for. /etc/profile is skipped, hence the small shortfall
    # against the figure above.
    prof=$(mktemp -t shell-startup-prof) || exit 1
    trace=$(mktemp -t shell-startup-trace) || exit 1
    trap 'rm -f "$prof" "$trace"' EXIT
    cat > "$prof" <<PROF
    PS4='+ \$EPOCHREALTIME \${BASH_SOURCE##*/}:\${LINENO}: '
    exec 2> "$trace"
    set -x
    source ~/.bash_profile
    PROF
    "$BASH" --noprofile --norc "$prof" > /dev/null 2>&1

    printf '  %8s  %5s  %s\n' seconds calls site
    # Cost of a traced line = the gap until the next timestamp. Lines with no
    # leading timestamp are a traced command's own stderr; skipping them keeps
    # their elapsed time attributed to the command that emitted them.
    awk '
      $2 ~ /^[0-9]+\.[0-9]+$/ {
        ts = $2 + 0
        if (seen) { tot[site] += ts - prev; n[site]++; total += ts - prev }
        prev = ts; site = $3; seen = 1
      }
      END {
        for (s in tot) printf "  %8.3f  %5d  %s\n", tot[s], n[s], s
        printf "  %8.3f  %5s  %s\n", total, "", "TOTAL TRACED"
      }
    ' "$trace" | sort -rn | head -n 20

# Verify the seed is healthy: every seeded file is a symlink into this repo, and every
# shared parent dir under ~/.config is a REAL dir (never folded into a symlink). Exit
# non-zero on any failure. Seed list is derived from git, so it never drifts.
status:
    #!/usr/bin/env bash
    set -uo pipefail
    repo="$(pwd)"
    fail=0
    # ~/.config and the managed subdirs must stay real dirs (the folding tripwire).
    #
    # .config/mise matters more than the others: mise reads conf.d/*.toml out of it
    # and that is the seam carrying machine-local tool versions -- terraform on the
    # Mark43 mac, nothing on the other. Folded to a symlink, conf.d would have to
    # live in the repo, which defeats the point of it being machine-local.
    for d in .config .config/ghostty .config/direnv .config/worktrunk .config/mise; do
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

# Verbose on purpose: seeing what got linked is the entire point of a test
# install, and unlike `install` nothing here runs unattended.

# Test install into a temp directory
test: (stow-pkg test_dir "." root_ignores "--verbose") (stow-pkg (test_dir / ".claude") "claude" "--verbose")

# Clean test directory
clean:
    rm -rf {{test_dir}}
