#!/usr/bin/env python3
"""Evita que la barra se meta bajo el notch (la cámara) de la pantalla del portátil.

    notch.py detect   -> busca la pantalla con notch y guarda dónde empieza y acaba
                         (en coordenadas globales, como SketchyBar)
    notch.py fit      -> recorta lo que invade la zona del notch en esa pantalla

Qué recorta, en orden:
  - Menús de la app (si están a la vista): los que no caben pasan al botón »
  - Escritorios: primero se quitan los iconos de apps de los no activos y, si no
    basta, también del activo (queda solo el número)
  - Derecha: se acorta el título de la música

En pantallas sin notch no hace nada.
"""
import json
import math
import os
import subprocess
import sys
import time

TMP = os.environ.get("TMPDIR", "/tmp")
STATE = os.path.join(TMP, "sketchybar_notch")
MENUS_ON = os.path.join(TMP, "sketchybar_menus_on")
CONFIG_DIR = os.environ.get("CONFIG_DIR", os.path.expanduser("~/.config/sketchybar"))
SAFE = 8          # margen hasta el notch, en px
MORE_WIDTH = 34   # sitio que ocupa el botón »
MAX_MENUS = 15
RIGHT_ISLANDS = ["island.media", "island.tools", "island.io", "island.system", "island.clock"]
SB = "/opt/homebrew/bin/sketchybar"


def sb(*args):
    return subprocess.run([SB, *args], capture_output=True, text=True).stdout


def query(name):
    try:
        return json.loads(sb("--query", name))
    except json.JSONDecodeError:
        return None


def span(name, display):
    """(inicio, fin) del item en esa pantalla, o None si no se ve ahí."""
    d = query(name)
    if not d or d.get("geometry", {}).get("drawing") == "off":
        return None
    r = d.get("bounding_rects", {}).get(f"display-{display}")
    if not r or r["origin"][0] < -9000:
        return None
    return r["origin"][0], r["origin"][0] + r["size"][0]


def settle():
    time.sleep(0.08)


def detect():
    script = """
    ObjC.import("AppKit");
    var s = $.NSScreen.screens, out = "";
    for (var i = 0; i < s.count; i++) {
      var x = s.objectAtIndex(i), l = x.auxiliaryTopLeftArea, r = x.auxiliaryTopRightArea;
      if (l && l.size.width > 0) {
        // Coordenadas globales, igual que las que devuelve SketchyBar
        var ox = x.frame.origin.x;
        out = (i + 1) + " " + (ox + l.size.width) + " " + (ox + x.frame.size.width - r.size.width);
        break;
      }
    }
    out;
    """
    out = subprocess.run(["osascript", "-l", "JavaScript", "-e", script],
                         capture_output=True, text=True).stdout.strip()
    if out:
        with open(STATE, "w") as f:
            f.write(out)
    elif os.path.exists(STATE):
        os.remove(STATE)


def fit_menus(display, limit):
    titles = [query(f"menu.{i}")["label"]["value"] for i in range(1, MAX_MENUS + 1)]
    count = sum(1 for t in titles if t)
    args = []
    for i in range(1, count + 1):
        args += ["--set", f"menu.{i}", "drawing=on"]
    sb(*args, "--set", "menu.more", "drawing=off")
    settle()

    overflow = [i for i in range(1, count + 1)
                if (s := span(f"menu.{i}", display)) and s[1] > limit - MORE_WIDTH]
    sb("--remove", "/menu\\.more\\..*/")
    if not overflow:
        return

    args = []
    for i in overflow:
        args += ["--set", f"menu.{i}", "drawing=off",
                 "--add", "item", f"menu.more.{i}", "popup.menu.more",
                 "--set", f"menu.more.{i}", f"label={titles[i - 1]}", "icon.drawing=off",
                 f"click_script={CONFIG_DIR}/helpers/menus select {i}; {SB} --set menu.more popup.drawing=off"]
    sb(*args, "--set", "menu.more", "drawing=on")


def fit_spaces(display, limit, focused):
    def left_edge():
        ends = [s[1] for n in ("spaces.m1", "spaces.m2", "spaces.m3", "island.app")
                if (s := span(n, display))]
        return max(ends, default=0)

    if left_edge() <= limit:
        return
    on_display = [n for n in (f"space.{i}" for i in range(1, 11)) if span(n, display)]
    args = []
    for n in on_display:
        if n != f"space.{focused}":
            args += ["--set", n, "label.drawing=off"]
    if args:
        sb(*args)
        settle()
    if left_edge() > limit:
        sb("--set", f"space.{focused}", "label.drawing=off")


def fit_right(display, limit):
    starts = [s[0] for n in RIGHT_ISLANDS if (s := span(n, display))]
    if not starts or min(starts) >= limit:
        return
    media = query("media")
    if not media or media["label"]["drawing"] == "off":
        return
    overflow = limit - min(starts)
    chars = len(media["label"]["value"])
    keep = max(0, min(chars, media["label"].get("max_chars") or chars) - math.ceil(overflow / 8) - 1)
    if keep < 4:
        sb("--set", "media", "label.drawing=off")
    else:
        sb("--set", "media", f"label.max_chars={keep}")


def fit():
    if not os.path.exists(STATE):
        return
    display, left, right = open(STATE).read().split()
    left_limit, right_limit = float(left) - SAFE, float(right) + SAFE
    if os.path.exists(MENUS_ON):
        fit_menus(display, left_limit)
    else:
        focused = os.environ.get("FOCUSED_WORKSPACE") or subprocess.run(
            ["/opt/homebrew/bin/aerospace", "list-workspaces", "--focused"],
            capture_output=True, text=True).stdout.strip()
        fit_spaces(display, left_limit, focused)
    fit_right(display, right_limit)


if __name__ == "__main__":
    {"detect": detect, "fit": fit}.get(sys.argv[1] if len(sys.argv) > 1 else "", lambda: sys.exit(
        "Uso: notch.py detect | fit"))()
