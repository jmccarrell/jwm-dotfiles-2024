---
name: open-in-emacs
description: Open a file or directory in Jeff's running Emacs with `emacsclient`, optionally at a line and column. Use when Jeff says "open X in emacs", "show me that in emacs", "jump to line N in emacs", or asks to see a file in his editor. The desktop app's "Open in" menu and its open-in-editor tool have no Emacs entry, so this replaces them.
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

- Always pass `-n`: without it the command blocks until Jeff finishes the buffer.
- Pass absolute paths; `+LINE` applies only to the file right after it.
- If it fails with `can't find socket`, the server isn't running. Say so and stop.
  Don't start one with `-a ''` or `--daemon`: that creates Emacs state Jeff didn't ask for.
