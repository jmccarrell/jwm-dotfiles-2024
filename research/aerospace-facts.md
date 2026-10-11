# AeroSpace, JankyBorders and SketchyBar on Lyra

Research for jmccarrell/jwm-dotfiles-2024#72 (map: #70). Gathered 2026-10-11.

Every fact cites its source. Facts read from source code cite the file at the
release tag. Facts observed on Lyra are marked **[Lyra]** and came from read-only
commands. Conclusions drawn from sources, rather than stated by them, are marked
**(inference)**.

Lyra at the time of writing **[Lyra]**: macOS 27.0.1 (26A434), arm64, Homebrew
7.0.9 at `/opt/homebrew`, undocked (only "Built-in Retina Display" in
`NSScreen.screens`). None of the tools is installed, and neither
`nikitabobko/tap` nor `felixkratz/formulae` is tapped. Rectangle Pro 3.67 and Alfred
5.8.1 are running. Rectangle 2.0 is installed but not running.

## Sources

- [AG] AeroSpace Guide, https://nikitabobko.github.io/AeroSpace/guide (page stamped "Last updated 2026-07-16")
- [AC] AeroSpace Commands, https://nikitabobko.github.io/AeroSpace/commands
- [AGo] AeroSpace Goodies, https://nikitabobko.github.io/AeroSpace/goodies
- [AR] AeroSpace README, https://github.com/nikitabobko/AeroSpace/blob/main/README.md
- [ADC] AeroSpace default config at tag v0.21.3-Beta, https://github.com/nikitabobko/AeroSpace/blob/v0.21.3-Beta/docs/config-examples/default-config.toml (identical to `main`)
- [AS] AeroSpace source at tag v0.21.3-Beta, https://github.com/nikitabobko/AeroSpace/tree/v0.21.3-Beta/Sources/AppBundle
- [ACask] AeroSpace cask, https://github.com/nikitabobko/homebrew-tap/blob/main/Casks/aerospace.rb
- [JR] JankyBorders README, https://github.com/FelixKratz/JankyBorders/blob/main/README.md
- [JM] JankyBorders man page (wiki), https://github.com/FelixKratz/JankyBorders/wiki/Man-Page
- [JS] JankyBorders source at tag v1.9.0, https://github.com/FelixKratz/JankyBorders/tree/v1.9.0/src
- [SR] SketchyBar README, https://github.com/FelixKratz/SketchyBar/blob/master/README.md
- [SSetup] SketchyBar setup docs, https://felixkratz.github.io/SketchyBar/setup
- [SEv] SketchyBar events docs, https://felixkratz.github.io/SketchyBar/config/events
- [SS] SketchyBar source at tag v2.24.1, https://github.com/FelixKratz/SketchyBar/blob/v2.24.1/src/hotload.c
- [FF] FelixKratz Homebrew formulae, https://github.com/FelixKratz/homebrew-formulae (`borders.rb`, `sketchybar.rb`)
- [RR] Rectangle README, https://github.com/rxhanson/Rectangle/blob/main/README.md
- [RT] Rectangle TerminalCommands.md, https://github.com/rxhanson/Rectangle/blob/main/TerminalCommands.md
- [RPG] Rectangle Pro docs, General, https://rectangleapp.com/pro/docs/general/
- [RPS] Rectangle Pro docs, Snap Areas, https://rectangleapp.com/pro/docs/snap-areas/
- [AlfH] Alfred help, General, https://www.alfredapp.com/help/general/

## 1. Install method, and how each starts at login

### AeroSpace

- Install: `brew install --cask nikitabobko/tap/aerospace`. It is the preferred
  method, and it gives auto-updates [AR][AG §1.1]. It ships from the author's tap,
  not homebrew/cask: `brew info --cask aerospace` reports "No Cask with this name
  exists" **[Lyra]**. Pinned versions install as `nikitabobko/tap/aerospace@<ver>` [AG §1.1].
- The app is not notarized. The cask's postflight removes `com.apple.quarantine`
  from the app and the CLI so it opens without a Gatekeeper warning [AR][ACask].
- The cask also installs the `aerospace` CLI, man pages, and bash completion at
  `$HOMEBREW_PREFIX/etc/bash_completion.d/aerospace` [ACask].
- Start at login: set `start-at-login = true` in the config. The default is
  `false` [ADC]. When it is true, AeroSpace registers itself through
  `SMAppService.mainApp`, which makes it a Login Item. When it is false,
  AeroSpace unregisters [AS `config/startAtLogin.swift`]. It also deletes a legacy
  `~/Library/LaunchAgents/bobko.aerospace.plist` that earlier versions wrote [same file].

### JankyBorders

- Install: `brew tap FelixKratz/formulae && brew install borders` [JR]. The formula
  builds from source and ad-hoc codesigns the binary [FF `borders.rb`].
- There are two documented ways to start it:
  - From AeroSpace: `after-startup-command = ['exec-and-forget borders <options>']`
    [JR][AGo §3]. The Goodies page says borders detects an already-running
    process, "so it won't be run twice on AeroSpace restart" [AGo §3].
  - As a service: `brew services start borders` [JR]. The formula's service block
    is a LaunchAgent with `keep_alive true` [FF `borders.rb`].

### SketchyBar

- Install: `brew tap FelixKratz/formulae && brew install sketchybar` [SSetup].
  The default font is Hack Nerd Font, installed with
  `brew install --cask font-hack-nerd-font` [SSetup].
- There are two documented ways to start it:
  - As a service: `brew services start sketchybar` [SSetup], which is a
    `keep_alive` LaunchAgent [FF `sketchybar.rb`].
  - From AeroSpace: `after-startup-command = ['exec-and-forget sketchybar']`
    [AGo §7]. Like borders, it detects a running instance [AGo §7].
- **(inference)** For each tool, pick one launcher. A `brew services` agent with
  `keep_alive` keeps running, and restarts after a crash, even while AeroSpace is
  quit. Starting the tool from `after-startup-command` ties it to AeroSpace's
  lifecycle instead. That matters for the map's "going back takes one step".
- AeroSpace's `exec-*` commands get `/opt/homebrew/bin:/opt/homebrew/sbin`
  prepended to `PATH` by default, so a bare `borders` or `sketchybar` resolves on
  Lyra [AG §2.10].

## 2. Config locations, and fit with this repo's `home/.config/` layout

How seeding works (repo `README.md` and `justfile`): the path of each file under
`home/` is the path of its symlink under `$HOME`. `just install` runs
`stow --no-folding -R`, so every directory stays a real directory that holds
per-file symlinks. `just status` checks a **hard-coded** list of directories that
must not be folded into symlinks (`justfile`, `status` recipe).

| Tool | Location it reads | Repo path | Fits? |
|---|---|---|---|
| AeroSpace | `~/.aerospace.toml` **or** `${XDG_CONFIG_HOME:-~/.config}/aerospace/aerospace.toml` [AG §2.1] | `home/.config/aerospace/aerospace.toml` | Yes |
| JankyBorders | `~/.config/borders/bordersrc`, then `~/.bordersrc` [JS `misc/helpers.h`][JR] | `home/.config/borders/bordersrc` | Yes |
| SketchyBar | `$XDG_CONFIG_HOME/sketchybar/sketchybarrc`, then `~/.config/sketchybar/sketchybarrc`, then `~/.sketchybarrc`, plus `plugins/` beside it [SS `get_config_file`][SSetup] | `home/.config/sketchybar/sketchybarrc`, `home/.config/sketchybar/plugins/*` | Yes |

Details that affect the fit:

- **AeroSpace config ambiguity.** If both config locations exist, AeroSpace
  reports the ambiguity [AG §2.1] and does not choose one [AS
  `config/ConfigFile.swift`: `ambiguousConfigError`]. `~/.aerospace.toml` must
  therefore never exist on Lyra. It does not exist today **[Lyra]**.
- **AeroSpace config semantics.** If a key is omitted, a scalar key falls back to
  the default config. Key bindings (`mode.*.binding`), `on-focused-monitor-changed`
  and `exec` fall back to *empty*. "Your config is the source of truth for
  keyboard bindings" [AG §2.3]. A minimal config is therefore minimal everywhere
  except its bindings, which must all be listed.
- **AeroSpace auto-reload through a symlink.** `auto-reload-config` (default
  `false`) watches the config with `open(path, O_EVTONLY)` and a dispatch source on
  write, delete, rename and revoke [AS `config/ConfigFileWatcher.swift`]. `open`
  follows the symlink, so the watcher sees the file in the repo.
  **(inference)** It should fire when the repo file is edited, but this is
  untested with Emacs's save-by-rename.
- **Executable bit.** `bordersrc` and `sketchybarrc` are executed as programs.
  Both tools `chmod +x` the file themselves before running it [JS
  `misc/helpers.h` `file_setx`][SS `ensure_executable_permission`]. Through a stow
  symlink, that chmod lands on the repo file. Committing those files and the
  plugins as mode 755 makes the chmod a no-op. SketchyBar plugins must be
  executable [SSetup].
- **`$CONFIG_DIR` stays in `$HOME`.** On the default path, SketchyBar sets
  `CONFIG_DIR` to `dirname` of the config path *without* `realpath`. Only a
  `--config <path>` argument is resolved with `realpath` [SS
  `set_config_file_path` vs `exec_config_file`]. So `$CONFIG_DIR` is
  `~/.config/sketchybar`, and `$CONFIG_DIR/plugins/x.sh` resolves through the
  per-file symlinks. Plugins must be referenced by absolute path [SSetup].
- **SketchyBar hotload.** Hotload is off unless enabled. It uses FSEvents on
  `dirname` of the config, which is `~/.config/sketchybar` [SS
  `begin_receiving_config_change_events`]. **(inference)** Edits to the repo file
  happen in the repo directory, not in the directory of symlinks, so hotload
  would likely miss them. Run `sketchybar --reload` instead (the `--reload`
  domain is defined in `src/misc/defines.h` at the same tag).
- **Repo housekeeping (inference).** To give the new directories the same
  folding protection as the existing ones, add `.config/aerospace`,
  `.config/borders`, `.config/sketchybar` and `.config/sketchybar/plugins` to the
  `just status` directory list. Add the files to the seed listing in `README.md`
  as well.
- Logs from `brew services` go to `/opt/homebrew/var/log/{borders,sketchybar}/`
  [FF], outside the repo.

## 3. macOS settings AeroSpace requires or recommends

| Setting | Source says | Lyra today |
|---|---|---|
| **Accessibility permission** (required) | AeroSpace loops until `AXIsProcessTrusted`, prompting with `AXIsProcessTrustedWithOptions`. While waiting with the prompt, it runs `tccutil reset Accessibility <appId>` "because macOS doesn't reset it for us when the app signature changes" [AS `util/accessibility.swift`]. **(inference)** Expect to grant it again after some upgrades. | Not installed |
| **Displays have separate Spaces** | AeroSpace: macOS "works better and more stable" with it **disabled**. Focus bugs, performance issues and focus jumps are reported when it is enabled. Disable it with `defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer`; logout is required. Trade-offs when it is disabled: a window can span monitors, the menu bar shows only on the main monitor, and if one monitor goes native-fullscreen the other monitor is black [AG §4.3]. Enabled is still supported [AG §4]. | **Enabled** (the macOS default; the `spans-displays` key is absent) **[Lyra]** |
| **Group windows by application** | This is the workaround for Mission Control showing windows too small: `defaults write com.apple.dock expose-group-apps -bool true && killall Dock` [AG §4.2]. | Off (key absent) **[Lyra]** |
| **Monitor arrangement** | Every monitor needs free space at its bottom-left or bottom-right corner, because hidden windows are parked there. Otherwise slivers of hidden windows appear on the neighbouring monitor (System Settings → Displays → Arrange) [AG §4.1]. | See §4 |
| **Dock** | Put the Dock at the bottom and turn on auto-hide to minimise the 1-px slivers of hidden windows [AG §4]. | `autohide = 1`; orientation is the default (bottom) **[Lyra]** |
| **Use one macOS Space** | The intended workflow is one macOS Space, or one per monitor when "Displays have separate Spaces" is on, and no further use of Spaces [AG §4]. | — |
| Optional | `defaults write -g NSWindowShouldDragOnGesture -bool true` (ctrl+cmd-drag moves any window) [AR]. `defaults write -g NSAutomaticWindowAnimationsEnabled -bool false` [AGo §5]. `automatically-unhide-macos-hidden-apps` or unbinding `cmd-h` [ADC][AGo §10]. | — |

**Conflict between AeroSpace and SketchyBar.** SketchyBar "will only work properly
with the system setting 'Displays have separate Spaces' turned on (the default
setting)" [SSetup]. AeroSpace recommends turning it off [AG §4.3]. With SketchyBar,
the setting stays on, and AeroSpace's documented focus and performance caveats
for that mode apply. Without SketchyBar, turning it off is open. Whichever way it
goes, the choice affects only the docked setup, which per the map is the one that
wins.

SketchyBar replacing the menu bar also means auto-hiding the macOS menu bar. On
macOS Sonoma that setting is under Control Center → "Automatically hide and show
the menu bar" [SSetup]. The docs do not give a path for macOS 27.

## 4. Workspaces and monitors; docking and undocking

Documented model [AG §7]:

- One pool of workspaces is shared by all monitors. Each monitor shows one
  workspace, and two monitors cannot show the same workspace.
- Every workspace, even an empty or invisible one, has an assigned monitor. By
  default that is the **main** monitor (System Settings → Displays → Use as).
- `workspace X` shows X on its assigned monitor, not on the focused one. This is
  the one difference from i3.
- `move-workspace-to-monitor` reassigns a workspace. It fails for force-assigned
  workspaces [AG §7.1][AC `move-workspace-to-monitor`].
- `workspace-to-monitor-force-assignment` pins workspaces. Its patterns are `main`,
  `secondary` (the non-main monitor, when there are exactly two), a 1-based number
  counted left to right, or a case-insensitive regex substring of the monitor
  name. The value can be an array, and the first matching pattern wins [AG §7.1].
  Gaps can also be set per monitor with the same patterns [ADC].

What happens when monitors appear or disappear is **not described in the guide**.
The release source shows the following [AS `tree/Workspace.swift`,
`tree/WorkspaceEx.swift`, `util/appBundleUtil.swift`]:

- When the monitor count changes (`gcMonitors`), AeroSpace runs
  `rearrangeWorkspacesOnMonitors`. Each workspace that was visible stays visible
  on whichever new monitor is nearest to its old monitor's top-left corner. Each
  monitor left without a workspace gets a "stub". The stub is the workspace
  previously visible at that position, or else any invisible workspace assigned
  there, or else the first unused numbered workspace.
- A workspace's monitor is resolved in this order: its force-assignment, then
  where it is visible, then the monitor nearest its last assigned position
  (`monitorApproximation`), then the main monitor.
- A force-assignment whose patterns match no connected monitor resolves to `nil`.
  The workspace then falls back as above and does not disappear.
- **(inference)** On undock, workspaces from the external monitor fold onto the
  built-in display. On re-dock, workspaces that were not reassigned return to the
  monitor nearest their stored position. Number patterns (`1`, `2`) count monitors
  left to right, so their meaning shifts between laptop-only and docked setups.
  Name patterns such as `'dell'` or `'built-in'`, or arrays of fallbacks, are
  stable. This is worth testing on Lyra before relying on it.

Lyra's displays as Rectangle Pro last recorded them (`displayCache` in
`com.knollsoft.Hookshot`) **[Lyra]**: "DELL U3223QE" 3840×2160 at origin
(-943, 1329), and "Built-in Retina Display" 2056×1329 at (0, 0). **(inference)** If
these are AppKit coordinates (y up), the Dell sits above the laptop, and both
monitors have a free bottom corner, which satisfies [AG §4.1]. Check this in
System Settings → Displays the next time Lyra is docked.

Mouse follows focus: the default config sets
`on-focused-monitor-changed = ['move-mouse monitor-lazy-center']` [ADC]. Because
that key falls back to empty when omitted, a minimal config drops this behaviour
unless it copies the line [AG §2.3].

## 5. How JankyBorders and SketchyBar integrate with AeroSpace

### JankyBorders

- AeroSpace provides no callback for it and needs none. borders tracks focus
  itself from the window server, "without relying on the accessibility API" [JR].
  The integration is only the launch line in `after-startup-command` [JR][AGo §3].
- Configure it either with arguments on the launch line or with `bordersrc`. The
  rc file runs only when the first `borders` process starts **with no arguments**
  [JM][JS `main.c`: `if (!update_mask) execute_config_file(...)`]. Use
  `exec-and-forget borders` with no arguments to make `bordersrc` the config.
- Running `borders <opts>` again while it is running updates the live instance
  [JR][JM].
- Accessibility is needed only with `ax_focus=on`, which uses the slower AX API
  for compatibility with tools such as yabai [JM]. At startup borders checks
  whether it is already trusted, without prompting [JS `main.c`, `misc/ax.h`].
- Options include `style`, `active_color`, `inactive_color`, `width`, `hidpi`,
  `blacklist` and `whitelist` [JM].

### SketchyBar

- AeroSpace pushes workspace changes through the `exec-on-workspace-change`
  callback, which runs `sketchybar --trigger aerospace_workspace_change ...`. The
  child process gets `AEROSPACE_FOCUSED_WORKSPACE` and `AEROSPACE_PREV_WORKSPACE`
  [AG §5.3].
- In `sketchybarrc`, `sketchybar --add event aerospace_workspace_change` declares
  the custom event. One item per workspace from `aerospace list-workspaces --all`
  subscribes to it, and its plugin script highlights the item when `$1` equals the
  focused workspace. `click_script="aerospace workspace $sid"` makes the items
  clickable [AGo §7]. Custom events and `--trigger` with `VAR=value` pairs are
  standard SketchyBar features [SEv].
- **Mismatch in the docs:** the Guide's snippet passes `FOCUSED=...` [AG §5.3], but
  the Goodies plugin reads `$FOCUSED_WORKSPACE` [AGo §7]. The variable name passed
  by the trigger must match the one the plugin reads.
- SketchyBar's built-in `space_change` and `space_windows_change` events follow
  **Mission Control Spaces** [SEv], not AeroSpace workspaces. **(inference)** Those
  events are not useful under AeroSpace's emulated workspaces.
- AeroSpace offers other hooks: `on-focus-changed`, `on-focused-monitor-changed`
  [AG §5.2] and `on-mode-changed` [ADC]. It also has `aerospace subscribe`, a
  persistent JSON-lines event stream (`focus-changed`, `focused-monitor-changed`,
  `focused-workspace-changed`, `mode-changed`, `window-detected`,
  `binding-triggered`) [AC `subscribe`], and a documented Unix socket at
  `/tmp/bobko.aerospace-$USER.sock` [AG §10].
- For per-monitor bars, `aerospace list-monitors --format
  '%{monitor-appkit-nsscreen-screens-id}'` gives the `NSScreen.screens` index
  "useful for integration with ... sketchybar" [AC `list-monitors`].
- AeroSpace's stated stance: "only a very minimal support for ricing - gaps and a
  few callbacks for integrations with bars". Ricing issues "are mostly ignored"
  [AR].

## 6. Turning Rectangle's shortcuts off without uninstalling

Neither Rectangle nor Rectangle Pro documents a single "disable all shortcuts"
switch. The documented building blocks are below.

- **Back up first.** Rectangle has Import/Export JSON in Settings (v0.44+) [RR].
  Rectangle Pro has General → Export Config / Import Config [RPG]. Preferences
  live in `~/Library/Preferences/com.knollsoft.Rectangle.plist` [RR]. Rectangle
  Pro uses the `com.knollsoft.Hookshot` domain [RT].
- **Stop it running.** Rectangle Pro documents a "Launch on login" setting [RPG].
  Both apps store it as `launchOnLogin`, which is `1` in both
  `com.knollsoft.Rectangle` and `com.knollsoft.Hookshot` on Lyra **[Lyra]**. Turning that off and quitting removes every
  shortcut and snap area with no other edits, and re-launching restores them.
  **(inference)** This is the most reversible route.
- **Keep it running, without its shortcuts.** Clear each shortcut in the Shortcuts
  UI. "Restore Default Shortcuts" brings them back [RT][RPG].
  `defaults delete com.knollsoft.Hookshot` resets everything, not only the
  shortcuts [RPG]. Use it only with an export in hand.
- **Drag-to-snap** is separate from shortcuts. Rectangle says snapping "can be
  disabled" [RR], and its `windowSnapping` key is `1` on Lyra **[Lyra]**. Rectangle
  Pro has a "Snap windows by dragging" toggle [RPS]. **(inference)** Turn it off if
  Rectangle stays running alongside AeroSpace, because snapping moves windows that
  AeroSpace is tiling.
- **Ignore app** applies per app and un-registers shortcuts only while that app is
  frontmost [RR]. It cannot turn shortcuts off everywhere.
- **Current bindings [Lyra].** Rectangle's `move*` actions use ctrl+opt+cmd+arrow
  (`modifierFlags = 1441792`), and its Todo actions use ctrl+opt. **(inference)**
  Neither collides with AeroSpace's default `alt-*` bindings [ADC]. The conflict
  is behavioural: two tools moving the same windows.

## 7. Conflicts with Rectangle, Rectangle Pro and Alfred

- **Key grabbing in general.** If AeroSpace cannot handle a key, check for "keys
  conflict with other software that might listen to global keys" [AG §9].
- **Alfred.** Its default hotkey is ⌥Space [AlfH]. AeroSpace's default config
  binds many `alt-<key>` combinations but not `alt-space` [ADC]. Lyra's actual
  Alfred hotkey could not be read: its preferences are in the Dropbox sync
  folder, which the read-only check was not permitted to open **[Lyra]**.
  **(inference)** Every `alt-<letter>` that AeroSpace binds stops typing its
  Option-character in all apps, Alfred included.
- **Left vs right Option.** AeroSpace cannot yet tell left from right modifiers.
  Fixing that is a pre-1.0 item that might be possible via `CGEvent.tapCreate`
  (issue #28, open) [AR]. **(inference)** This matters because Emacs uses left
  Option as Super (map #70). Any AeroSpace `alt-*` binding also takes the key away
  from Emacs Super, so the modifier choice belongs to the grilling tickets.
- **Rectangle and Rectangle Pro** are covered in §6. While running, they have
  their own shortcuts, drag-to-snap, and (Pro) Stash, Quick Throw and cursor
  actions [RPG][RPS], and all of these move windows. AeroSpace states it does not
  aim to "play nicely with existing macOS features" [AR].

## 8. Version-specific notes

- **AeroSpace** is in Public Beta: "expect breaking changes until 1.0" [AR]. The
  current release is **0.21.3-Beta** (2026-07-16), published as a GitHub
  pre-release and the version the cask installs [ACask]. The binary runs on
  macOS 13+ [AR]. The cask declares `depends_on macos: :ventura` [ACask].
  - Use `config-version = 2` [AG §2.8]. It is the current maximum. A lower version
    makes `reload-config` warn. It also changes the `persistent-workspaces`
    fallback to empty, where version 1 inferred it from the bindings.
  - `subscribe` and the socket protocol are documented for this release [AC][AG §10].
  - The `if.app-id` form of `on-window-detected` is soft-deprecated in favour of
    `if = 'test %{app-bundle-id} = ...'` [AG §11].
  - macOS 27: the guide makes no specific statement. An open PR covers Xcode 27's
    Device Hub, whose windows AeroSpace ignores because macOS reports them with
    pid -1 (nikitabobko/AeroSpace#2316).
- **JankyBorders** is at **v1.9.0** (2026-05-14), the version the formula builds
  [FF]. It needs macOS 14.0+ [JR]. v1.8.4 added macOS 26 compatibility (release
  notes). Open macOS 27 issues: a border is sometimes missing after leaving
  fullscreen (FelixKratz/JankyBorders#201), and borders persist in Mission
  Control (#209).
- **SketchyBar** is at **v2.24.1** (2026-10-09) [FF]. v2.24.0 reworked the
  rendering system (release notes). macOS 27 support is being tracked in open
  FelixKratz/SketchyBar#850. Reports there and in #849, #852 and #830 cover items
  vanishing with an opaque bar colour, menu-bar alias problems, and notch
  click-through. One report in #850 matches Lyra's build exactly (27.0.1, 26A434).
  `media_change` is deprecated on macOS 26.0, and `wifi_change` has not worked
  since Sonoma [SEv].
- **Homebrew:** neither tap is present on Lyra yet **[Lyra]**. The AeroSpace cask
  is not in homebrew/cask.
