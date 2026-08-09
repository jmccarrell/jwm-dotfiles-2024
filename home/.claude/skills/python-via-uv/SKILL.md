---
name: python-via-uv
description: Run all Python through `uv run` (and `uv run --with <pkg>` for third-party deps) instead of bare python3/pip, so dependencies are hermetic and never "module not found". Use whenever executing, testing, or scripting Python in a session — inline `-c` snippets, heredocs, or `.py` files — especially when a non-stdlib package (pyyaml, requests, pandas, etc.) is needed.
---

# Python via uv

**Rule: never invoke bare `python3`/`python`/`pip` to run code.** Always go through
`uv run`. It resolves an interpreter and any requested packages into an ephemeral
env, so code runs the same way regardless of what the system Python has installed.
`uv` is at `/opt/homebrew/bin/uv`.

## Quick reference

| Instead of | Use |
|---|---|
| `python3 script.py` | `uv run script.py` |
| `python3 -c "..."` | `uv run python3 -c "..."` |
| `python3 -c` needing pyyaml | `uv run --with pyyaml python3 -c "..."` |
| `pip install X && python3 ...` | `uv run --with X python3 ...` |
| heredoc `python3 - <<'PY'` | `uv run --with X python3 - <<'PY'` |

Stdlib-only code still goes through uv (`uv run python3 -c "..."`) — no `--with` needed,
it just works. Reach for `--with` the moment any third-party import appears.

## Patterns

Inline snippet with a dependency:
```bash
uv run --with pyyaml python3 -c "import yaml; print(yaml.safe_load(open('f.yaml')))"
```

Multiple packages — repeat `--with`:
```bash
uv run --with requests --with rich python3 -c "import requests, rich; ..."
```

Heredoc for multi-line code (quote the delimiter to stop shell expansion):
```bash
uv run --with pyyaml python3 - <<'PY'
import yaml
d = yaml.safe_load(open('talos/patches/controlplane.yaml'))
print(d['machine'].get('certSANs'))
PY
```

Pin a version when it matters: `--with 'pandas==2.2.*'`.
Pick the interpreter when it matters: `uv run --python 3.12 python3 ...`.

## Saved scripts → PEP 723 inline metadata

For a `.py` file that will be rerun, declare deps in the file so `uv run script.py`
is self-contained (no remembering the `--with` flags):
```python
# /// script
# requires-python = ">=3.12"
# dependencies = ["pyyaml", "requests"]
# ///
import yaml, requests
...
```
Then just `uv run script.py`. Add/edit deps with `uv add --script script.py <pkg>`.

## Notes

- First run with a new package downloads it (cached after); a one-line
  `Installed N packages` is normal, not an error.
- No project/venv setup is required — `uv run` works from any directory.
- If `uv` is somehow absent, install via `brew install uv`; only then fall back to
  `python3` and say so explicitly.
