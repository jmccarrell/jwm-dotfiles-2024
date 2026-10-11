# AeroSpace source videos: tools, workflows, reusable config

Research for [#71](https://github.com/jmccarrell/jwm-dotfiles-2024/issues/71),
under the map [#70](https://github.com/jmccarrell/jwm-dotfiles-2024/issues/70).
Gathered 2026-10-11.

## Sources and how they were read

| Video | Channel | Published | Length |
|---|---|---|---|
| [My "Linux-Like" macOS Setup](https://youtu.be/upRpw0m-eyI) | Sam Natale | 2026-08-20 | 15:45 |
| [Aerospace Is Probably The Best MacOS Tiling Manager I've Ever Used](https://youtu.be/5nwnJjr5eOo) | DevOps Toolbox (Omer Hamerman, `omerxx`) | 2024-11-22 | 14:40 |

Both videos were read from their YouTube description, chapter list, and the
English caption track, fetched with `curl` from YouTube's caption endpoint
without installing anything. Every claim below about what a
video *shows* comes from its transcript; timestamps are given as `[m:ss]`.
Claims about *config files* come from the linked repos at the pinned commits.
Nothing was seen on screen, so key names that the speaker says aloud but that
the captions garble are cross-checked against the repo and flagged where they
disagree.

Repos, pinned:

- DevOps Toolbox: [`omerxx/dotfiles`](https://github.com/omerxx/dotfiles),
  linked from the video description.
  - video-era commit `908fc04` "pushing sketchybar and aerospace", 2024-11-22, the
    video's publish day
  - SketchyBar cleanup `34cfca3`, same day, and SketchyBar is untouched since
  - HEAD `97b2213`, 2026-04-13
- Sam Natale: [`smnatale/dotfiles`](https://github.com/smnatale/dotfiles),
  linked from the video description. HEAD `2014b03`, 2026-10-09. Its AeroSpace
  history in this layout starts 2026-09-21 ("migrate back to gnu-stow"), after
  the video, so the repo is the current config, not a frozen video-era copy.

## Tools named

| Tool | Video | Used for | Source |
|---|---|---|---|
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | both | i3-like tiling window manager; its own virtual workspaces; app launching via `exec-and-forget` | descriptions, transcripts |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) (`borders`) | both | coloured border on the focused window, started from AeroSpace | Natale [7:47], Toolbox [13:52] |
| [SketchyBar](https://github.com/FelixKratz/SketchyBar) | both | menu-bar replacement showing AeroSpace workspaces, clickable to switch; Natale adds battery and date | Natale [10:57], Toolbox [12:17] |
| [Vicinae](https://github.com/vicinaehq/vicinae) | Natale | open-source Spotlight/Raycast replacement for launching anything not bound to a key | Natale [9:22] |
| fzf | Toolbox | `ff`: fuzzy-pick any AeroSpace window and focus it | Toolbox [7:06] |
| skhd | Toolbox | the hotkey daemon he retired; AeroSpace bindings replace it | Toolbox [9:38], [12:11] |
| yabai | Toolbox | named as the alternative AeroSpace beat for him | Toolbox [1:55] |
| tmux | Toolbox | in-terminal splitting; "spiritual father" of the AeroSpace habit | Toolbox [14:24] |
| Nix home-manager | Toolbox | how he syncs config before a reload | Toolbox [11:09] |
| Raycast | Natale | named only to reject it as paid | Natale [9:17] |
| Ghostty, Kitty, WezTerm | both | terminals launched from AeroSpace bindings | transcripts, repos |
| Brave / Helium, Safari, Zen, Arc | both | browsers bound to app-launch keys | transcripts, repos |
| macOS `screencapture` | Natale | `alt-s` region screenshot to clipboard | Natale [6:22], repo |
| macOS `defaults` `NSWindowShouldDragOnGesture` | Toolbox | ctrl+cmd drag any part of a window to re-tile it | Toolbox [3:46]; the line is on the [AeroSpace Goodies](https://nikitabobko.github.io/AeroSpace/goodies) page, not in his repo |

## Workflows shown

### Workspace scheme

- **Natale:** numbered workspaces 1 to 5 only. He deletes the default letter
  workspaces from the bindings and sets `persistent-workspaces = ["1".."5"]` so
  the AeroSpace menu and SketchyBar show exactly those [3:19]. He turns on
  "i3 style ordered" under the AeroSpace menu's experimental settings so the
  menu-bar icon lists all workspaces [1:51]. Apps go to workspaces by hand,
  not by rule.
- **Toolbox:** numbered 1 to 4 in the bindings, with the SketchyBar showing every
  workspace AeroSpace knows [3:03]. A single 4K monitor is his main display,
  after trying two, three, and a 49-inch ultrawide [1:27]. Music (Brain.fm in
  Safari) is parked on its own workspace, then he jumps back [3:08]. `alt-tab`
  flips to the previous workspace (`workspace-back-and-forth`).

Neither video uses `on-window-detected` to send an app to a workspace. Both use
it only to make apps float:

- Natale floats Finder, Preview and a LÖVE game window; in the video, an iOS
  Simulator is his example of when to float [7:28].
- Toolbox floats Telegram and Finder in the video [8:31]; HEAD adds Safari,
  Mail, Trello, QuickTime and Discord, plus a misspelled `dicord` duplicate.

### Keybindings

Both use **Option (`alt`) as the only AeroSpace modifier**, close to the
AeroSpace defaults:

| Action | Natale | Toolbox |
|---|---|---|
| focus | `alt-h/j/k/l` | `alt-h/j/k/l` |
| move window | `alt-shift-h/j/k/l` | `alt-shift-h/j/k/l` |
| go to workspace | `alt-1..5` | `alt-1..4`, `alt-tab` back-and-forth |
| send window to workspace | `alt-shift-1..5` (focus stays) | `alt-shift-1..4 --focus-follows-window` |
| resize | `alt-minus` / `alt-equal` | `alt-shift-minus` / `alt-shift-equal` |
| layout toggle | default | `alt-slash` tiles h/v, `alt-comma` accordion h/v |
| join two windows into a nested container | none | `alt-shift-<arrow>` (`join-with`) |
| fullscreen (AeroSpace, not native) | `alt-f` | `alt-ctrl-shift-f` |
| float toggle | via service mode `f` | `alt-ctrl-f`, and service mode `f` |
| close one window | `alt-c` = `close --quit-if-last-window` | default cmd-w |
| service mode | `alt-comma` (repo); `alt-shift-semicolon` in the video [7:07] | `alt-shift-semicolon` |
| service-mode keys | `esc` reload, `r` flatten tree, `f` float toggle | same, plus `backspace` close all but current |
| app launch | `alt-enter` terminal, `alt-b` browser, `alt-e` Finder on `.`, `alt-s` screenshot | `alt-<letter>` per app; a second `apps` mode on `alt-shift-enter` as a "keyboard layer" [11:33] |

Two habits stand out:

- **AeroSpace as app launcher.** Toolbox moved every skhd `open -a` line into
  AeroSpace `exec-and-forget` and stopped skhd [9:38]-[12:11]. Natale does the
  same for his terminal and browser, and uses Vicinae for everything else [10:43].
- **Accordion as a reading stack.** Toolbox uses `alt-comma` accordion to page
  through articles and notes like a newspaper [4:01]-[4:47]; `accordion-padding =
  300` in his config.

Toolbox also uses `ff` in his shell, bound to Ghostty on `alt-g` in the video [8:02], to search
all windows by title, which shows the running command in Ghostty or the page in Safari:

```nu
def ff [] {
    aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'
}
```

([nushell/config.nu L911-L913 @ 97b2213](https://github.com/omerxx/dotfiles/blob/97b2213ad0e61c7a036290752e23497920978d55/nushell/config.nu#L911-L913))

### Monitor handling

- **Natale** shows a laptop only. His one per-monitor line gives the built-in
  display a smaller top gap for the notch:
  `gaps.outer.top = [{ monitor."built-in" = 8 }, 16]`. He also sets
  `on-focused-monitor-changed = ['move-mouse monitor-lazy-center']`.
- **Toolbox** works on one external 4K monitor [1:32]. At HEAD he pins workspaces
  to monitors by name (`1 = '^Built-in.*$'`, `2 = '^DELL U.*$'`, `3 = '^DELL S.*$'`),
  uses `alt-shift-tab` = `move-workspace-to-monitor --wrap-around next`, and gives
  the main monitor large outer gaps (350 left and right, 100 top and bottom) with
  small gaps elsewhere. That centres windows on a wide external screen and keeps
  the laptop tight. None of this is in the video-era commit; it arrived later
  (`9ed00c4` "updating aerospace with gaps per monitor", 2026-02-22).

Neither video mentions the AeroSpace guide's advice, which bears directly on
docked use ([guide §4](https://nikitabobko.github.io/AeroSpace/guide)):

- disable Mission Control's *Displays have separate Spaces*; the guide lists
  focus and performance bugs it causes across monitors
- arrange monitors so every one has a free bottom-left or bottom-right corner,
  because AeroSpace hides windows there

Monitor patterns for assignment and per-monitor gaps are `main`, `secondary`
(only when there are exactly two), a 1-based left-to-right number, or a
case-insensitive regex; an array of patterns takes the first match.

### Visual layer

- **Natale:** JankyBorders round, width 8, Catppuccin colours, in its own
  `bordersrc`. SketchyBar replaces the menu bar: he sets macOS menu bar
  auto-hide to "Always" [11:27] and adds a top gap so tiles clear the bar
  [11:51]; his bar has workspaces, battery and date. Plain black wallpaper.
  His repo has no SketchyBar config and his Brewfile does not install it, so
  SketchyBar and Vicinae are shown in the video only.
- **Toolbox:** a white border, a floating SketchyBar on the **right** edge
  (`position=right`), which is why his right outer gap was doubled in the video
  [8:46] (`outer.right = 80`, others 40). The bar shows an Apple menu item,
  AeroSpace workspaces (click to switch), and a calendar. He credits the AeroSpace
  Goodies page for the SketchyBar integration [13:37]. His later commit
  `de6f211` (2025-11-09) says "updating aerospace padding after removing the
  bar", so he appears to have dropped SketchyBar; the `sketchybar` startup line
  remains in the config.

## Config patterns worth reusing

### AeroSpace

From [`smnatale/dotfiles` `aerospace/.aerospace.toml` @ 2014b03](https://github.com/smnatale/dotfiles/blob/2014b0363a10f03ccd710a058003264840b3f22e/aerospace/.aerospace.toml):

- `persistent-workspaces = ["1", "2", "3", "4", "5"]` plus only the matching
  `alt-N` / `alt-shift-N` bindings: a small fixed set, nothing else in the bar
- `auto-reload-config = true` while tuning
- `alt-c = 'close --quit-if-last-window'`: close one window, quit only the last
- `after-startup-command = ['exec-and-forget borders']`, with borders options
  kept in `bordersrc` rather than inline
- per-monitor top gap: `gaps.outer.top = [{ monitor."built-in" = 8 }, 16]`
- service mode with `esc` reload, `r` flatten, `f` float toggle
- floating rules by bundle ID (`if.app-id = 'com.apple.finder'`); the current
  guide soft-deprecates `if.app-id` in favour of
  `if = 'test %{app-bundle-id} = com.apple.finder'`, though it says the old form
  will likely stay supported

From [`omerxx/dotfiles` `aerospace/aerospace.toml` @ 97b2213](https://github.com/omerxx/dotfiles/blob/97b2213ad0e61c7a036290752e23497920978d55/aerospace/aerospace.toml)
(video-era version: [@ 908fc04](https://github.com/omerxx/dotfiles/blob/908fc04952149c12a17b780f12253205469b4d05/aerospace/aerospace.toml)):

- `[workspace-to-monitor-force-assignment]` by monitor-name regex, so a
  workspace lands on the external display when docked
- per-monitor gaps keyed on `monitor.main` with a fallback value, which suits a
  docked-wins setup: generous on the external, tight on the laptop
- `alt-tab = 'workspace-back-and-forth'` and
  `alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'`
- `move-node-to-workspace N --focus-follows-window`
- `join-with` on `alt-shift-<arrow>`, `layout accordion` on `alt-comma`
- `backspace = ['close-all-windows-but-current', 'mode main']` in service mode
- a second binding mode (`mode apps`) as a launcher layer

Things not to copy from omerxx:

- `exec-on-workspace-change` passes `'exec-and-forget borders ...'` as a third
  argv element after `bash -c '<sketchybar trigger>'`. Bash treats it as `$0`, so
  it never runs; it looks like a mis-paste of the Goodies `after-startup-command`
  line. Borders width is also `0` at HEAD.
- `if.app-name-regex-substring = 'mail'` floats any app whose name contains
  "mail"; prefer exact bundle IDs.

### JankyBorders

- [`smnatale/dotfiles` `borders/.config/borders/bordersrc` @ 2014b03](https://github.com/smnatale/dotfiles/blob/2014b0363a10f03ccd710a058003264840b3f22e/borders/.config/borders/bordersrc):
  a `bordersrc` script with an options array (`style=round width=8.0 hidpi=off
  active_color=... inactive_color=...`), started by AeroSpace with plain
  `exec-and-forget borders`. Keeping options in `~/.config/borders/bordersrc`
  means colour changes do not touch the AeroSpace config.
- Toolbox's video-era line, identical to the Goodies page:
  `exec-and-forget borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0`.
  The Goodies page notes that borders detects an already running instance, so
  restarting AeroSpace does not start a second one.

### SketchyBar

All from `omerxx/dotfiles` @ 34cfca3, since Natale has no SketchyBar config in his repo:

- [`sketchybar/items/spaces.sh`](https://github.com/omerxx/dotfiles/blob/34cfca34efde76818721f55e28ef8210a69c885a/sketchybar/items/spaces.sh):
  registers the `aerospace_workspace_change` event, loops over
  `aerospace list-workspaces --all`, and adds one item per workspace with
  `click_script="aerospace workspace $sid"` and a highlight script
- [`sketchybar/plugins/aerospacer.sh`](https://github.com/omerxx/dotfiles/blob/34cfca34efde76818721f55e28ef8210a69c885a/sketchybar/plugins/aerospacer.sh):
  turns the item background on when `$1 = $FOCUSED_WORKSPACE`; this is the
  Goodies plugin verbatim plus debug `echo`s
- [`sketchybar/sketchybarrc`](https://github.com/omerxx/dotfiles/blob/34cfca34efde76818721f55e28ef8210a69c885a/sketchybar/sketchybarrc):
  bar layout: right-hand floating bar, `sticky=on`, blur, rounded corners. It
  still sets a yabai `SPACE_CLICK_SCRIPT` that is now unused
- the AeroSpace side:
  `exec-on-workspace-change = ['/bin/bash', '-c', 'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE']`
  plus `after-startup-command = ['exec-and-forget sketchybar']`
- [`sketchybar/items/aerospace.sh`](https://github.com/omerxx/dotfiles/blob/34cfca34efde76818721f55e28ef8210a69c885a/sketchybar/items/aerospace.sh)
  duplicates `spaces.sh` with a hard-coded `/Users/omerxx/...` path and is not
  sourced; skip it

## Relevance to Lyra

These are observations for the later tickets under #70, not decisions.

- **Option is the modifier in both videos, and that collides with Emacs Super.**
  Lyra's Emacs uses left Option as Super. AeroSpace cannot tell left Option from
  right Option; [AeroSpace#28](https://github.com/nikitabobko/AeroSpace/issues/28),
  the request to distinguish them, is still open. So any `alt-*` AeroSpace binding
  takes that chord from Emacs everywhere. In Ghostty, which does not set
  `macos-option-as-alt`, the same chords type special characters (`alt-1` is ¡),
  and AeroSpace would take those too. The keybinding ticket needs a different
  modifier or an explicit list of Super chords to give up.
- **Neither video assigns apps to workspaces.** Rules that send Ghostty, Emacs,
  Edge, Mail, Slack and Stocks to fixed workspaces would be Lyra's own design.
  Use `on-window-detected` with `move-node-to-workspace`, matched on bundle ID.
- **Docked-wins monitor handling** maps onto omerxx's later pattern: assign
  workspaces to `main` or by display name, and use per-monitor gaps with a
  laptop fallback. The guide's advice on *Displays have separate Spaces* and
  bottom-corner arrangement applies on day one.
- **SketchyBar is optional.** One author shows it only in the video and the other
  later removed his bar. Natale's minimal path (AeroSpace + borders, menu-bar
  workspace list in i3-ordered mode) is the smaller first step.
- **Vicinae overlaps Alfred** and is not needed while Alfred stays.
