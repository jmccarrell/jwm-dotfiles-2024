# Shell search patterns

The few moves worth building into habit. **New** marks what this setup adds.
Run `keys` to show this page.

## Find a command I ran before

- **Ctrl-R**, type a few words, **Enter** runs it. **New:** Atuin, history from every host.
- **Tab** instead of Enter puts it on the line to edit first. **New**
- **Ctrl-R again** inside the search narrows it: all hosts, this host, this
  session, this directory. "What did I run here last time?" **New**

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

## Keep a command out of history

Start it with a space.
