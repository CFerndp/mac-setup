# Mac setup

My Mac development setup: AeroSpace tiling with Omarchy's shortcuts, Caps Lock as
SUPER, a SketchyBar status bar and a custom theme called Neon Noir.

## Usage

On a new Mac:

```bash
git clone git@github.com:CFerndp/mac-setup.git
cd mac-setup
./setup.sh
```

`setup.sh` installs everything with Homebrew, applies the macOS settings and runs `link.sh`.

`Brewfile` is an exact snapshot of everything installed with Homebrew (without VS Code
extensions). To reinstall it all at once: `brew bundle --file Brewfile`. To refresh it
after installing something: `brew bundle dump --file Brewfile --force --no-vscode`.

`link.sh` symlinks every file in `dotfiles/` to the same path under `~` (an existing
file is kept as `.bak-<date>`) and compiles the SketchyBar helpers. Because they are
symlinks, editing a config in `~` edits the repo: just commit.

If something stops working (for example after a macOS update), run `./doctor.sh`: it
checks apps and services, symlinks, compiled helpers and settings, and tells you how to
fix each problem. It only reads, never changes anything.

Files that are not in the repo because they hold other personal settings (`~/.zshrc`,
Zed and VS Code settings) are applied by hand from `snippets/`.

## Layout

```
dotfiles/            → symlinked into ~ (same path)
  .aerospace.toml
  .wezterm.lua
  .config/sketchybar/   bar: sketchybarrc, colors.sh, plugins/, helpers/
  .config/aerospace/    AeroSpace scripts (minimize / restore)
  .config/borders/      window borders
  .config/karabiner/    Caps Lock = SUPER
  .config/fastfetch/
  .config/neon-noir/     shell theme (Powerlevel10k and fzf colors)
  .config/btop/themes/   btop theme
  Library/Application Support/lazygit/config.yml   lazygit theme
  .config/neon-wallpaper/  animated wallpaper (index.html + wallpaper.swift helper)
  .config/zed/themes/neon-noir.json
snippets/            → snippets to paste into ~/.zshrc, Zed and VS Code
setup.sh             → full install
link.sh              → symlinks and helpers only
doctor.sh            → checks that everything is running
Brewfile             → everything installed with Homebrew
```

## Installed with Homebrew (`setup.sh`)

- **Apps:** Maccy, Shottr, AeroSpace, DBeaver, Ice, BetterDisplay, AppCleaner,
  Keka, Karabiner-Elements
- **CLI:** btop, duti, fastfetch, SwitchAudioSource (`switchaudio-osx`, for the bar's audio menu)
- **Look:** SketchyBar and JankyBorders (`borders`), from the `felixkratz/formulae` tap
  (only those two formulae are trusted, with `brew trust`). They are built on the Mac,
  so they need up-to-date Command Line Tools.
- **Fonts:** JetBrains Mono Nerd Font, sketchybar-app-font
- Dropped: Rectangle (clashes with AeroSpace), Starship (Powerlevel10k stays), Stats (the
  bar already shows CPU, battery and network) and MonitorControl (BetterDisplay does the same)

## Config files

| File | What it does |
|---|---|
| `~/.aerospace.toml` | AeroSpace with Omarchy's shortcuts |
| `~/.config/aerospace/minimize.sh` | Minimize and restore windows (SUPER+M / SUPER+Shift+M); remembers the order they were minimized in |
| `~/.config/karabiner/karabiner.json` | Caps Lock = SUPER (ctrl+opt+cmd); a quick tap = Caps Lock |
| `~/.wezterm.lua` | WezTerm: JetBrainsMono Nerd Font 14 pt, Neon Noir palette, 85 % opacity with blur, no title bar |
| `~/.config/sketchybar/` | Floating, rounded top bar (see below). Colors in `colors.sh`, scripts in `plugins/`, app icons in `plugins/icon_map.sh` (from sketchybar-app-font v3.0.21) |
| `~/.config/borders/bordersrc` | Magenta→cyan gradient border on the active window |
| `~/.config/zed/themes/neon-noir.json` | Neon Noir theme for Zed (enabled with `snippets/zed-settings.jsonc`) |
| `~/.config/fastfetch/config.jsonc` | fastfetch with the Apple logo in a neon gradient |
| `~/.config/neon-noir/theme.zsh` | Neon Noir colors for the Powerlevel10k prompt (colors only, the style is unchanged) and for fzf |
| `~/.config/btop/themes/neon-noir.theme` | btop theme (`link.sh` sets `color_theme = "neon-noir"` in `btop.conf`) |
| `~/Library/Application Support/lazygit/config.yml` | lazygit with rounded borders and Neon Noir colors |
| `~/.zshrc` (not in the repo) | Oh My Zsh + Powerlevel10k. First line: fastfetch, in WezTerm only; after `~/.p10k.zsh`: the Neon Noir theme (`snippets/zshrc.sh`) |
| VS Code `settings.json` (not in the repo) | External terminal = WezTerm and Neon Noir colors on top of "Default Dark Modern" (`snippets/vscode-neon-noir.jsonc`) |

## System settings

- WezTerm opens scripts (`.sh`, `.command`, `.tool`, `.zsh`, `.bash`) and `ssh://`, `telnet://` and `man` links (with `duti`)
- Fast key repeat, no accent popup when holding a key
- Finder shows hidden files and extensions
- Screenshots go to `~/Screenshots`
- macOS menu bar auto-hidden (it shows when the mouse reaches the top); SketchyBar takes its place

## Look: Neon Noir theme (custom palette, dark cyberpunk)

| Color | Hex | Used for |
|---|---|---|
| Background | `#0b0b12` | Backgrounds |
| Magenta | `#ff2a6d` | Active items, cursor, keywords |
| Cyan | `#05d9e8` | Accents, functions |
| Violet | `#b967ff` | Types, bar border |
| Green | `#00ff9f` | Strings |
| Yellow | `#f3e600` | Numbers, warnings |
| Text | `#d7d7e8` | Text |

No third-party extensions: in Zed it is a custom theme and in VS Code it is color settings.

### Bar (SketchyBar)

**Philosophy:** icons only. The data shows on hover (via `plugins/hover.sh`) and a
click leads to more. Colors warn you without hovering. Popups close by themselves when
the mouse leaves the bar.

The bar is transparent and the icons sit in **islands** (brackets with their own
background), as in FelixKratz's config: workspaces (one per display) · active app |
music · tools · input/output · system · date.

- **Left:**
  - Each display's workspaces with the icons of their apps, animated on change. A
    single script paints them all (`plugins/spaces.sh`, run by the hidden
    `spaces.observer` item) instead of one script per workspace.
  - Active app: its icon (name on hover). **Click: the workspaces are swapped for the
    app's menus** (File, Edit…), and another click brings them back. This replaces the
    macOS menu bar.
- **Right:**

  | Icon | On hover | Click | Other |
  |---|---|---|---|
  | Browser music (magenta = playing, grey = paused) | Title | Source, state, previous / play-pause / next, "Go to tab" | |
  | Slack, Teams, Outlook (only when there are unread items) | Unread count | Opens the app | |
  | Screenshots | — | Shottr: area, full screen, window, scrolling; macOS screen recording | |
  | Clipboard | "Portapapeles" | Opens Maccy (presses its shortcut, Shift+Cmd+C, with `helpers/hotkey`) | |
  | Docker (green = containers running, hidden if Docker is not running) | Running count | List; clicking one opens its logs in WezTerm; "Abrir lazydocker" | |
  | Speaker and mic | Names | Pick a device | Right click: Sound settings |
  | Keyboard | Layout (US / ES / ABC) | Switch | |
  | Volume (the icon shows the level) | % | Slider, mute and playback controls | Scroll wheel: up/down. Right click: Sound settings |
  | External display brightness (BetterDisplay; hidden without an external display) | % | Slider | Scroll wheel: up/down |
  | Network (Wi-Fi, cable, or red when offline) | Type and IP | macOS Wi-Fi / Network settings | |
  | CPU (cyan / yellow ≥ 50 % / red ≥ 80 %) | % | Activity Monitor | Right click: btop in WezTerm |
  | Battery (green / yellow / red when low) | %, charging or time left | — | |
  | Date, Spanish short format "L 09/11 10:37" (weekday initial, day/month, time) | Full date | — | |

  The music item may show only "YouTube Music" when that site does not put the song in
  the tab title (for example, while paused).
- `topmost=on`: the bar stays above the macOS menu bar when the latter shows.
- The brightness control uses BetterDisplay's CLI (`betterdisplaycli`), so **BetterDisplay
  must be running**: enable "Launch at login" in its settings. It controls the first
  display that isn't the laptop's.
- The clipboard button uses `helpers/hotkey` (`hotkey.swift`): it presses a shortcut at
  keyboard level (`hotkey 8 cmd,shift` = Shift+Cmd+C). Maccy has no other way to be
  opened from outside. If you change its shortcut, change `MACCY_KEY` in `sketchybarrc`.
- App menus use `helpers/menus` (`menus.swift`): `menus list` and `menus select <n>`.
  FelixKratz's idea, rewritten in Swift with public APIs. Needs Accessibility
  permission for SketchyBar.
- **Notch (laptop camera):** `helpers/notch.py` finds the display with a notch
  (`detect`) and, when something grows towards the camera, trims it (`fit`):
  - app menus that don't fit → a **»** button with a dropdown holding the rest;
  - workspaces → lose their app icons (inactive ones first), leaving the number;
  - music title → shortened.

  It runs after every workspace, app, music or notification change, and when displays
  are plugged in or out. On displays without a notch it does nothing.
- `updates=when_shown` by default: scripts don't run while their item is hidden. Items
  that start hidden and show themselves (notifications, Docker, music) use `updates=on`.
- The keyboard switcher uses `helpers/inputsource`, a small Swift tool
  (`inputsource.swift`, built with `swiftc -O inputsource.swift -o inputsource`).
  Commands: `list`, `current`, `select <id>`.
- Playback controls use `helpers/mediakey` (`mediakey.swift`), which presses the system
  media keys: `mediakey play|next|previous`. macOS may ask for Accessibility permission
  for SketchyBar the first time.
- "Now playing" reads tab titles with `helpers/music_tabs.scpt` and switches tabs with
  `helpers/focus_tab.scpt` (AppleScript; the `.applescript` files are the source,
  compiled with `osacompile`). It knows whether music is playing from the
  "Playing audio" assertion the browser sets in `pmset -g assertions`. It only queries
  browsers that are already open. YouTube Music does not put the artist in the title,
  so only the song shows there.

### Services

- SketchyBar and JankyBorders start by themselves with `brew services`. To restart them:

  ```bash
  brew services restart sketchybar
  brew services restart borders
  ```

- AeroSpace notifies SketchyBar on every workspace change (`exec-on-workspace-change`)
  and leaves 46 px at the top of the external display for the bar (it floats 6 px down
  and is 32 px tall). On the laptop macOS already reserves the notch strip, so there
  it's only 10 px.
- To go back to the macOS menu bar: System Settings → Control Center →
  "Automatically hide and show the menu bar" → Never, and `brew services stop sketchybar`.

## Animated wallpaper

`dotfiles/.config/neon-wallpaper/`:

- `index.html`: Neon Noir canvas animation. Modes via `?mode=`:
  - `window` (**external display, default**): the rooftop figure, sitting on the floor of
    a dark flat in front of a window as wide as the screen; outside, the city blurred
    by the rain and, on the glass, drops that slide down in jerks;
  - `edge` (**laptop, default**): a figure sitting with their back to you on the edge of
    a rooftop above a huge city, with light rain, a broken "NO EXIT" neon sign and the
    odd violet lightning flash;
  - `freefall`: a figure falling with open arms between rising skyscraper walls;
  - `city`: night city with a synthwave sun and a moving neon floor;
  - `minimal`: almost black with a faint grid, a slow scan line and a terminal cursor.

  To use other modes, change the helper's arguments in the plist
  (`--external city --builtin minimal`) and run `wallpaper.sh on` again.
- `wallpaper.swift`: a small helper that shows that page in a window at desktop level on
  each display (below the icons and everything else). It does what Plash does, which is
  no longer open source. It rebuilds itself when displays are plugged in or out.
  AeroSpace does not manage it. Options: `--external <mode>` and `--builtin <mode>`.
- `wallpaper.sh on` builds it and makes it start at login (LaunchAgent
  `com.cferndp.neon-wallpaper`); `wallpaper.sh off` removes it. **Run it by hand**
  (`setup.sh` doesn't):

  ```bash
  ~/.config/neon-wallpaper/wallpaper.sh on
  ```

- **Matching static wallpaper:** `~/.config/neon-wallpaper/wallpaper set-static` renders a
  frame of each scene at each display's resolution (into `static/`, not in git) and sets
  it as the regular macOS wallpaper. That's what shows on the lock screen, in Mission
  Control and while the animation is paused. Run it again after changing scene or display.
- **Battery:** on battery or in Low Power Mode the animation pauses and hides (the static
  one shows); it resumes when plugged in. To keep it animated on battery, add
  `--keep-on-battery` to the plist arguments.
- Power use: normal resolution (not Retina), 12–24 fps depending on the scene, no
  per-frame blur and only what changes is redrawn. About 20 % of one core in total with
  both displays.

## AeroSpace

- **SUPER = Caps Lock.**
- **Displays:** workspaces 1–5 on the external display (any display that isn't the
  laptop's) and 6–10 on the laptop. With only the laptop, they all go there. Assumes at
  most two displays.
- **Shortcuts** (some keys refer to a Spanish ISO keyboard):

  | Shortcut | Action |
  |---|---|
  | SUPER + Enter | WezTerm |
  | SUPER + Shift + B / Enter | Brave |
  | SUPER + Shift + N / F / T | Zed / Finder / btop |
  | SUPER + Shift + G | lazygit in WezTerm |
  | SUPER + Space | App launcher |
  | SUPER + Shift + Space | Bar: toggle workspaces / app menus |
  | SUPER + Escape | Lock the screen (presses macOS's Ctrl+Cmd+Q) |
  | SUPER + C | Area screenshot (Shottr) |
  | SUPER + W / Q | Close window |
  | SUPER + arrows | Move focus |
  | SUPER + Shift + arrows | Move window |
  | SUPER + J | Toggle horizontal/vertical split |
  | SUPER + L | Tiles / accordion (if windows aren't side by side, this is why) |
  | SUPER + T | Floating / tiling |
  | SUPER + F | Full screen |
  | SUPER + M | Minimize to the Dock |
  | SUPER + Shift + M | Restore the last minimized window (otherwise, the active app's) |
  | SUPER + `'` / `¡` (+ Shift) | Width (height) − / + (the two keys right of 0) |
  | SUPER + 1…0 | Go to workspace |
  | SUPER + Shift + 1…0 | Move window to workspace |
  | SUPER + Tab / Shift + Tab | Next / previous workspace |
  | SUPER + `º` | Last workspace (key left of 1) |
  | SUPER + Shift + `º` | Move workspace to the other display |
  | SUPER + Shift + `Ñ` | Service mode: `r` resets the layout, `Esc` reloads the config |

- **Troubleshooting:**

  ```bash
  aerospace list-monitors
  aerospace list-workspaces --all --format '%{workspace} → %{monitor-name}'
  aerospace list-windows --all --format '%{workspace} | %{app-name} | %{window-layout}'
  ```

## To do / ideas

- Assign each app to its workspace (Slack → 4, Brave → 2…)
- Test the display assignment with the office monitor
