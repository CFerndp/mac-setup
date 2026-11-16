#!/usr/bin/env python3
"""GoodHabitz (work/goodhabitz). Reports de las automatizaciones de Orca (~/Reports/<carpeta>/YYYY-MM-DD.md).

  reports.py scan        limpia (una vez al día), avisa de los nuevos con una
                         notificación y lista los no leídos: ruta<TAB>carpeta<TAB>fecha<TAB>título
  reports.py unread      solo lista los no leídos (mismo formato)
  reports.py open [ruta] marca el report como leído, genera el lector y lo abre
  reports.py read-all    marca todo como leído

Un report es un .md con fecha en el nombre. Los demás .md de las carpetas (p. ej.
sources.md) salen en el lector como referencia: nunca cuentan como no leídos ni se borran.
El estado (leídos, avisados, última limpieza) está en ~/Reports/.state.json.
Pensado para el python3 del sistema (3.9): solo biblioteca estándar.
"""
import datetime as dt
import html
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path.home() / "Reports"
STATE = ROOT / ".state.json"
READER = ROOT / "index.html"
HERE = Path(__file__).resolve().parent
MARKED = HERE / "vendor" / "marked.min.js"
TEMPLATE = HERE / "reader.html"

RETENTION_DAYS = {"ai-weekly": 28}  # el resto, 7 días
DEFAULT_RETENTION = 7
SETTLE_SECONDS = 30  # no avisar de un fichero que aún se está escribiendo
DATED = re.compile(r"^(\d{4}-\d{2}-\d{2})\.md$")


def load_state():
    try:
        return json.loads(STATE.read_text())
    except (OSError, ValueError):
        return None


def save_state(state):
    tmp = STATE.with_suffix(".tmp")
    tmp.write_text(json.dumps(state, indent=1, sort_keys=True))
    tmp.replace(STATE)


def title_of(path):
    try:
        with path.open(encoding="utf-8") as f:
            for line in f:
                if line.startswith("# "):
                    return line[2:].strip()
    except OSError:
        pass
    return path.stem


def tldr_of(path):
    """Primer bullet del TL;DR, sin Markdown, para la notificación."""
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return ""
    m = re.search(r"^##\s*TL;DR\s*$(.*?)(?=^## |\Z)", text, re.M | re.S)
    block = m.group(1) if m else text
    for line in block.splitlines():
        line = line.strip()
        if line.startswith(("- ", "* ")):
            line = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", line[2:])
            line = re.sub(r"[*_`]", "", line)
            return line if len(line) <= 140 else line[:137] + "…"
    return ""


def scan_files():
    """Todos los .md de ~/Reports/<carpeta>/, con su fecha si la tienen."""
    files = []
    if not ROOT.is_dir():
        return files
    for folder in sorted(p for p in ROOT.iterdir() if p.is_dir() and not p.name.startswith(".")):
        for f in folder.glob("*.md"):
            m = DATED.match(f.name)
            files.append({
                "path": f,
                "rel": f"{folder.name}/{f.name}",
                "folder": folder.name,
                "date": m.group(1) if m else None,
            })
    return files


def init_state(files):
    # La primera vez no se avisa de lo que ya había (pero sí cuenta como no leído)
    return {"read": [], "notified": [f["rel"] for f in files], "cleaned": ""}


def cleanup(state, files):
    today = dt.date.today()
    if state.get("cleaned") == today.isoformat():
        return files
    kept = []
    for f in files:
        if f["date"]:
            keep = RETENTION_DAYS.get(f["folder"], DEFAULT_RETENTION)
            try:
                age = (today - dt.date.fromisoformat(f["date"])).days
            except ValueError:
                age = 0
            if age > keep:
                f["path"].unlink(missing_ok=True)
                continue
        kept.append(f)
    alive = {f["rel"] for f in kept}
    state["read"] = [r for r in state.get("read", []) if r in alive]
    state["notified"] = [r for r in state.get("notified", []) if r in alive]
    state["cleaned"] = today.isoformat()
    return kept


def notify(title, body, subtitle):
    script = ('on run argv\n'
              'display notification (item 2 of argv) with title (item 1 of argv) '
              'subtitle (item 3 of argv) sound name "Glass"\n'
              'end run')
    subprocess.run(["osascript", "-e", script, title, body or "Report nuevo", subtitle],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def pretty(folder):
    """gh-daily → GH daily; stack-daily → Stack daily."""
    words = folder.split("-")
    first = words[0].upper() if len(words[0]) <= 2 else words[0].capitalize()
    return " ".join([first] + words[1:])


def unread(state, files):
    read = set(state.get("read", []))
    out = [f for f in files if f["date"] and f["rel"] not in read]
    return sorted(out, key=lambda f: (f["date"], f["folder"]), reverse=True)


def print_list(items):
    for f in items:
        print("\t".join([str(f["path"]), f["folder"], f["date"], title_of(f["path"])]))


def cmd_scan():
    files = scan_files()
    state = load_state() or init_state(files)
    files = cleanup(state, files)
    now = dt.datetime.now().timestamp()
    notified = set(state.get("notified", []))
    for f in files:
        if not f["date"] or f["rel"] in notified:
            continue
        try:
            if now - f["path"].stat().st_mtime < SETTLE_SECONDS:
                continue
        except OSError:
            continue
        notify(f"{pretty(f['folder'])} listo", tldr_of(f["path"]), title_of(f["path"]))
        state.setdefault("notified", []).append(f["rel"])
    save_state(state)
    print_list(unread(state, files))


def cmd_unread():
    files = scan_files()
    state = load_state() or init_state(files)
    print_list(unread(state, files))


def build(state, files, current):
    read = set(state.get("read", []))
    data = []
    for f in sorted(files, key=lambda f: (f["folder"], f["date"] or "", f["rel"])):
        data.append({
            "id": f["rel"],
            "folder": f["folder"],
            "label": pretty(f["folder"]),
            "date": f["date"],
            "title": title_of(f["path"]),
            "unread": bool(f["date"]) and f["rel"] not in read,
            "md": f["path"].read_text(encoding="utf-8", errors="replace"),
        })
    payload = json.dumps({"reports": data, "current": current}, ensure_ascii=False)
    payload = payload.replace("</", "<\\/")  # que ningún report cierre el <script>
    page = TEMPLATE.read_text(encoding="utf-8")
    page = page.replace("/*MARKED*/", MARKED.read_text(encoding="utf-8"))
    page = page.replace("/*DATA*/null", payload)
    page = page.replace("{{generated}}", html.escape(dt.datetime.now().strftime("%d/%m %H:%M")))
    READER.write_text(page, encoding="utf-8")


def cmd_open(arg):
    files = scan_files()
    state = load_state() or init_state(files)
    current = None
    if arg:
        p = Path(arg).expanduser().resolve()
        for f in files:
            if f["path"].resolve() == p:
                current = f["rel"]
        if current and current not in state["read"]:
            state["read"].append(current)
    else:
        pending = unread(state, files)
        current = pending[0]["rel"] if pending else None
        if current:
            state["read"].append(current)
    save_state(state)
    build(state, files, current)
    subprocess.run(["open", str(READER)])


def cmd_read_all():
    files = scan_files()
    state = load_state() or init_state(files)
    state["read"] = sorted({f["rel"] for f in files if f["date"]})
    save_state(state)


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "scan"
    ROOT.mkdir(exist_ok=True)
    if cmd == "scan":
        cmd_scan()
    elif cmd == "unread":
        cmd_unread()
    elif cmd == "open":
        cmd_open(sys.argv[2] if len(sys.argv) > 2 else None)
    elif cmd == "read-all":
        cmd_read_all()
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
