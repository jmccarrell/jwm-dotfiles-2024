# jwm-dotfiles-2024
Jeffs dotfiles; back to bash

## Git identity

Shared Git config now uses three layers:

- `.gitconfig` is the tracked base config.
- `.gitconfig.personal` is the tracked override for repos under `~/jwm`.
- `.gitconfig.machine` is an untracked per-machine file that sets the default email.

Create `.gitconfig.machine` in the repo checkout before installing the dotfiles.

Work machine:

```gitconfig
[user]
	email = work-address@example.com
```

Personal machine:

```gitconfig
[user]
	email = personal-address@example.com
```

With that in place:

- work-machine repos under `~/code` use the work address
- work-machine repos under `~/jwm` use the personal address
- personal-machine repos use the personal address everywhere
