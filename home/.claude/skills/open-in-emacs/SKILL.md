---
name: open-in-emacs
description: Open a file or directory in Jeff's running Emacs with `emacsclient`, optionally at a line and column. Use when a message starts with "open in emacs" followed by a path or file name (e.g. "open in emacs init.el", "open in emacs foo.py:42"), when the message is just "open in emacs" (open the file the conversation is about), or when Jeff otherwise asks to see a file in Emacs or his editor. The desktop app's "Open in" menu and its open-in-editor tool have no Emacs entry, so this replaces them.
---

# Open in Emacs

Jeff runs an Emacs server; `emacsclient` (on PATH from Homebrew) hands it files.
Use this instead of the app's open-in-editor tool, which offers only VS Code,
Cursor, Windsurf and Zed.

```bash
emacsclient -n /abs/path/file.el                 # open a file
emacsclient -n +42 /abs/path/file.el             # at line 42
emacsclient -n +42:7 /abs/path/file.el           # at line 42, column 7
emacsclient -n /abs/path/a.py /abs/path/b.py     # several files
emacsclient -n /abs/path/dir/                    # a directory opens in dired
```

Then bring Emacs to the front, since `emacsclient -n` leaves focus where it was:

```bash
open -a Emacs
```

- The request usually reads `open in emacs <name>`, where `<name>` may be a bare file
  name, a relative path, or `name:LINE`. Resolve it against the working directory
  first, then search the session's folders; if several files match, ask which one.
- A bare `open in emacs` with no name means the file the conversation is about.
  Take, in order: a file you just edited or created, one Jeff just pointed at (a
  link, a screenshot, an error with a path), then the last file discussed. Open it
  at the line under discussion, if there is one. If no file clearly stands out,
  list the likely ones and ask rather than guess.
- Always pass `-n`: without it the command blocks until Jeff finishes the buffer.
- Pass absolute paths; `+LINE` applies only to the file right after it.
- If it fails with `can't find socket`, the server isn't running. Say so and stop.
  Don't start one with `-a ''` or `--daemon`: that creates Emacs state Jeff didn't ask for.
