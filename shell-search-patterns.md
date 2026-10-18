# Shell search patterns

The few moves worth building into habit. **New** marks what this setup adds.
Run `keys` to show this page.

## Find a command I ran before

- **Ctrl-R**, type a few words, **Enter** runs it. **New:** Atuin, history from every host.
- **Tab** instead of Enter puts it on the line to edit first. **New**
- **Ctrl-R again** inside the search narrows it: all hosts, this host, this
  session, this directory. "What did I run here last time?" **New**
- **?** at an empty prompt asks Atuin AI for a command in plain English;
  **Enter** runs it, **Tab** inserts it. **New**

## Put a file or path into a command

- Type the command, then **Ctrl-T** to pick the file; **Tab** marks several.
  Skips git-ignored files and previews each one. **New:** fd and bat.
- `vim **<Tab>`, `cd **<Tab>`, `ssh **<Tab>`: fuzzy completion after any command.

## Go to a directory

- `z proj` jumps to the best match from where you have been.
- `zi proj` when there are several matches: pick from a list.
- **Alt-C** picks any directory below here and goes there. **New:** works now
  that left Option sends Alt.

## Narrow any fzf list

Words are fuzzy and order-free. Add `'word` for exact, `^start`, `end$`,
`!exclude`, and `a | b` for either.

## Save a short command to rerun on any host

- Run it, then `atuin scripts new <name> --last`: your editor opens with that
  command. Change a value to `{{ ns }}` to make it a variable, and save. It
  syncs with history. **New**
- `asr <name>` runs it and asks for each variable; `-v ns=flux-system` skips
  the question.
- `atuin scripts list` shows them; `atuin scripts edit <name>` changes one.
- Example: `kubectl get pods -n flux-system`, then `atuin scripts new pods --last`,
  change `flux-system` to `{{ ns }}`; later, `asr pods`.

Short, non-interactive commands only; real scripts stay as files in git.

## Keep a command out of history

Start it with a space.
