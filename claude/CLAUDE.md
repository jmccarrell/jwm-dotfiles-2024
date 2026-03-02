# Global Claude Code Instructions

## GitHub

- Use `gh` (GitHub CLI) for all GitHub operations: creating repos, PRs, issues, etc.
- Create private repos with: `gh repo create <name> --private --source=. --remote=origin --push`

## File Writing

- Always use Unix line endings (LF, `\n`) when writing files — never CRLF (`\r\n`)

## Git Repositories

- When creating any new git repository, immediately add a `.gitattributes` file with:
  ```
  * text=auto eol=lf
  ```

## Python

- Always use `uv` for all Python command interactions (e.g., `uv run python`, `uv add`, `uv pip install`, etc.)
- Never invoke `python`, `python3`, or `pip` directly — always go through `uv`
- Always use `uv run python` — never bare `python`, `python3`, or `uv run python3`
- For every new Python-based project, use the starter template at `/Users/jeff/jwm/proj/python-uv-template` (includes Python, uv, and just setup)
- When a `.env` file exists in the project directory, always pass it to uv: `uv run --env-file .env ...`
