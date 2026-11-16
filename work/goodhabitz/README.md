# GoodHabitz only

Everything here is specific to the GoodHabitz work machine. To reuse the repo at another
company, delete this folder; `link.sh`, `doctor.sh` and `sketchybarrc` pick up `work/*`
generically and don't reference it by name.

- `links`: paths under `dotfiles/` that `link.sh` symlinks into `~`.
- `doctor.sh`: extra checks, sourced by the main `doctor.sh`.
- `dotfiles/.config/reports/`: reader, notifications and cleanup for the reports the
  Orca automations write to `~/Reports`.

## Reports (Orca automations)

The scheduled Orca automations (GH daily, Stack daily, AI weekly…) write Markdown
reports to `~/Reports/<folder>/YYYY-MM-DD.md`, outside any repo.
`dotfiles/.config/reports/reports.py` (system Python, standard library only) handles them:

- **Bar item:** defined in `sketchybar-tools.sh` (loaded by `sketchybarrc`), script `bar.sh`.
  Magenta = unread. Hover: unread count. Click: unread list (click one to open it in the
  reader), "Abrir el lector" and "Marcar todo como leído".
- **Notification:** the bar's `reports` item runs `reports.py scan` every minute. A new
  report (once it hasn't changed for 30 s) triggers a native macOS notification with the
  first TL;DR bullet. Any new folder in `~/Reports` is picked up automatically.
- **Reader:** `reports.py open [file]` builds `~/Reports/index.html` from `reader.html`
  (Neon Noir, sidebar per folder, unread dot) with the reports and
  `vendor/marked.min.js` (marked v12.0.2, MIT) inlined, and opens it in the default
  browser. Opening a report from the bar marks it as read; reading it inside the page
  only clears the dot on screen.
- **Cleanup:** once a day, dated reports older than 7 days are deleted (`ai-weekly`:
  28 days, because its prompt reads the previous ones). Undated files such as
  `ai-weekly/sources.md` are shown as references and never deleted.
- State (read, notified, last cleanup) lives in `~/Reports/.state.json`. On the first
  run the existing reports count as unread but are not notified.
- Other commands: `reports.py unread`, `reports.py read-all`.
