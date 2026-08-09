#!/usr/bin/env python3
"""PostToolUse/Bash hook: after `git worktree add`, run `direnv allow` in the new worktree.

Avoids the "direnv: error .envrc is blocked" prompt when visiting a freshly created
worktree. Parses the worktree path out of the Bash command (handling `-b`/`-B`/`--reason`
value flags, a leading `cd <dir> &&`, and relative paths), then runs `direnv allow <path>`
only when that worktree actually contains an `.envrc`. Always exits 0 — never blocks the tool.
"""
import json
import os
import re
import shlex
import subprocess
import sys

VALUE_FLAGS = {"-b", "-B", "--reason"}


def log(msg: str) -> None:
    dbg = os.environ.get("CLAUDE_DIRENV_HOOK_DEBUG")
    if dbg:
        with open(dbg, "a") as fh:
            fh.write(msg + "\n")


def parse_worktree_path(tokens):
    """First positional arg after `worktree add`, skipping flags and their values."""
    for i in range(len(tokens) - 1):
        if tokens[i] == "worktree" and tokens[i + 1] == "add":
            j = i + 2
            while j < len(tokens):
                t = tokens[j]
                if t == "--":  # end of options; next token is the path
                    return tokens[j + 1] if j + 1 < len(tokens) else None
                if t in VALUE_FLAGS:  # flag that consumes the next token
                    j += 2
                    continue
                if t.startswith("-"):  # any other flag (incl. --foo=bar); no separate value
                    j += 1
                    continue
                return t  # first positional == worktree path
    return None


def resolve_base(cmd: str, payload: dict) -> str:
    """Honor `cd <dir> &&` prefixes so relative worktree paths resolve correctly."""
    base = payload.get("cwd") or os.getcwd()
    segments = re.split(r"&&", cmd)
    for seg in segments:
        if "git" in seg and "worktree" in seg and "add" in seg:
            break
        m = re.match(r"\s*cd\s+(\S+)", seg)
        if m:
            target = os.path.expanduser(m.group(1).strip("\"'"))
            base = target if os.path.isabs(target) else os.path.normpath(os.path.join(base, target))
    return base


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    cmd = (payload.get("tool_input") or {}).get("command") or ""
    if "git" not in cmd or "worktree" not in cmd or "add" not in cmd:
        return 0
    try:
        tokens = shlex.split(cmd)
    except ValueError:
        return 0
    wt = parse_worktree_path(tokens)
    if not wt:
        return 0
    wt = os.path.expanduser(wt)
    if not os.path.isabs(wt):
        wt = os.path.normpath(os.path.join(resolve_base(cmd, payload), wt))
    log(f"worktree={wt} .envrc={os.path.isfile(os.path.join(wt, '.envrc'))}")
    if os.path.isfile(os.path.join(wt, ".envrc")):
        try:
            subprocess.run(["direnv", "allow", wt], check=False,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except FileNotFoundError:
            pass  # direnv not installed; nothing to do
    return 0


if __name__ == "__main__":
    sys.exit(main())
