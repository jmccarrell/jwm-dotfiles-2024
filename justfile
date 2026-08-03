home_dir := env("HOME")
test_dir := home_dir / "tmp/test-dotfiles"

# --no-folding keeps every target dir a real dir with per-file symlinks. Folded to
# a directory symlink, everything the owning app writes there later -- caches,
# session state, downloaded packages -- lands in this repo instead of $HOME.
#
# --adopt is never used. It pulls existing target files into the repo, which
# diverges the two macs silently; run it by hand if an import is ever wanted.
#
# --verbose is not shared. `install` runs unattended from bin/daily (jwm-bin), so it
# stays silent unless there is a conflict to report. `check` and `test` opt back in,
# because for them the narration is the output.
stow_flags := "--no-folding"

@_:
    just --list

# stow one package tree onto a target, creating the target if needed.
#
# -R (restow), never -S. -S only adds, so a file dropped from the repo keeps its
# dangling symlink in $HOME forever. -R's unstow pass reaps any link that resolves
# into this repo and whose source is gone -- which is also what migrates a file from
# one path in the repo to another.
#
# A conflict aborts the whole plan before anything is written, so a failed run leaves
# $HOME exactly as it was. What -R costs is churn: every run relinks the whole seed,
# so the symlinks are briefly absent.
[private]
stow-pkg target pkg *flags:
    mkdir -p {{target}}
    stow {{stow_flags}} {{flags}} -t {{target}} -R {{pkg}}

# There are no --ignore flags, and that is the point. `home/` holds exactly the seed
# set, so anything else in this repo -- justfile, README, LICENSE, the repo-local
# .claude/, an untracked TASK.md -- is outside the package and cannot reach $HOME.
# The old '.' package needed a hand-maintained ignore list, and any file added at the
# repo root was seeded into $HOME until someone remembered to extend it.

# Install all dotfiles
install: (stow-pkg home_dir "home")

# -S and verbose where `install` is -R and quiet: a preview only has to read as
# "nothing to do" or "something to do" at a glance. The cost is that it cannot show a
# pending deletion cleanup, because only -R performs one.

# Preview the install without writing anything
check:
    stow {{stow_flags}} --verbose --no -t {{home_dir}} -S home

# This exists because the answer rots silently. On macOS every terminal tab is a
# login shell, so anything ~/.bash_profile does is billed per tab.
#
# Prints the end-to-end cost, then a per-line breakdown from an xtrace carrying
# $EPOCHREALTIME in PS4. The "site" column is file:line, so a regression points
# straight at the offending line.

# Time a login shell, and show where the time goes
profile-shell-startup runs="7":
    #!/usr/bin/env bash
    set -uo pipefail
    [ -n "${EPOCHREALTIME:-}" ] || { echo "needs bash 5+ (got ${BASH_VERSION})" >&2; exit 1; }

    # warm the page cache first; a cold first run would dominate a small sample
    "$BASH" --login -c exit > /dev/null 2>&1
    t0=$EPOCHREALTIME
    for (( i = 0; i < {{runs}}; i++ )); do "$BASH" --login -c exit > /dev/null 2>&1; done
    t1=$EPOCHREALTIME
    printf '\n  %.1f ms per login shell (mean of {{runs}})\n\n' \
        "$(echo "($t1 - $t0) * 1000 / {{runs}}" | bc -l)"

    # Trace `source ~/.bash_profile` rather than a real login shell: the tracer needs
    # PS4 set before the first traced command, and a login shell gives no hook for
    # that. /etc/profile is skipped, hence the small shortfall against the figure
    # above.
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
    # A traced line costs the gap until the next timestamp. Lines with no leading
    # timestamp are a traced command's own stderr; skipping them keeps that time
    # attributed to the command that emitted it.
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
# managed parent dir is a REAL dir, never folded into a symlink. Exit non-zero on any
# failure. The seed list comes from git, so it never drifts.
status:
    #!/usr/bin/env bash
    set -uo pipefail
    repo="$(pwd)"
    fail=0
    # The folding tripwire. Three of these hold state that must never reach the repo:
    # .claude every Claude session, project and plugin; .config/mise the conf.d/*.toml
    # carrying machine-local tool versions, which is the whole point of it being
    # machine-local; .config/yazi whatever `ya pkg add` downloads.
    for d in .claude .config .config/direnv .config/ghostty .config/git \
             .config/mise .config/worktrunk .config/yazi; do
      t="{{home_dir}}/$d"
      if [ -L "$t" ]; then echo "✗ $d is a SYMLINK (folded!) — must be a real dir"; fail=1
      elif [ -d "$t" ]; then echo "✓ $d is a real dir"
      else echo "✗ $d missing"; fail=1; fi
    done
    # Every tracked file under home/ must be a symlink resolving back to it. A file's
    # path below home/ is where its symlink lands, hence the ${f#home/} strip.
    while IFS= read -r f; do
      t="{{home_dir}}/${f#home/}"
      if [ ! -L "$t" ]; then echo "✗ ${f#home/} not a symlink"; fail=1
      elif [ "$(cd "$(dirname "$t")" && realpath "$(readlink "$t")")" != "$repo/$f" ]; then
        echo "✗ ${f#home/} -> $(readlink "$t") (not this repo)"; fail=1
      elif [ ! -e "$t" ]; then echo "✗ ${f#home/} dangling"; fail=1
      else echo "✓ ${f#home/} -> repo"; fi
    done < <(git ls-files home)
    exit $fail

# Verbose on purpose: seeing what got linked is the entire point of a test install,
# and unlike `install` nothing here runs unattended.

# Test install into a temp directory
test: (stow-pkg test_dir "home" "--verbose")

# Clean test directory
clean:
    rm -rf {{test_dir}}
