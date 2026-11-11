# CLAUDE.md

Repo con la configuración del Mac de trabajo de Cristian: AeroSpace con los atajos
de Omarchy, Caps Lock como SUPER, barra SketchyBar y el tema propio Neon Noir.
Se habla en español, también en commits y comentarios. El README está en inglés:
al actualizarlo, escríbelo en inglés.

## Cómo está montado

- `dotfiles/` replica rutas de `~`. **Lo que hay en `~` son enlaces a este repo**
  (los crea `link.sh`), así que editar `~/.config/sketchybar/...` es editar el repo.
  Edita aquí, no copies archivos a `~`.
- `link.sh` enlaza y compila los helpers (Swift y AppleScript). Ejecútalo tras añadir
  un archivo nuevo que deba enlazarse (y añádelo a la lista de `link` del script).
- `doctor.sh` comprueba que todo está en marcha. Si añades una app, servicio o helper
  nuevo, añade también su comprobación ahí.
- `setup.sh` es la instalación completa en un Mac nuevo. Si instalas algo con
  Homebrew, añádelo aquí también.
- `snippets/` guarda lo que vive en archivos personales que no están en el repo
  (`~/.zshrc`, `settings.json` de Zed y VS Code). Si los cambias, actualiza el snippet.
- El README documenta todo lo instalado y configurado; mantenlo al día con cada cambio.
- Tras instalar algo con Homebrew, regenera el `Brewfile`:
  `brew bundle dump --file Brewfile --force --no-vscode`.

## Restricciones

- **Ordenador corporativo gestionado con Intune.** Solo software open source y
  conocido. Nada que pida desactivar SIP ni inyecte código en el sistema
  (yabai con scripting addition, cDock, MacForge…). Prefiere herramientas nativas
  o un helper propio pequeño a una dependencia de terceros.
- Taps de terceros: solo `felixkratz/formulae` y `nikitabobko/tap`, con
  `brew trust --formula` por fórmula, no por tap entero.
- Instalaciones con `sudo` (p. ej. casks con instalador .pkg) las tiene que lanzar el
  usuario en su terminal: pide la contraseña.
- Claude no tiene permiso de Grabación de pantalla: no puede hacer capturas para
  verificar lo visual. Verifica con `sketchybar --query` y pide al usuario que mire.

## Teclado y AeroSpace

- SUPER = Caps Lock → Karabiner lo convierte en `ctrl+alt+cmd`. En AeroSpace:
  `ctrl-alt-cmd-…` y `ctrl-alt-cmd-shift-…`. Combinaciones SUPER+Ctrl o SUPER+Alt no
  se distinguen de SUPER solo: no las uses.
- Teclado físico español ISO; `key-mapping.preset = 'qwerty'` usa posiciones físicas
  de EE. UU. (`minus`/`equal` son `'` y `¡`). Evita atajos con Option: rompen `@ # |`.
- Escritorios 1–5 en la pantalla externa (`'^(?!built-in)'`) y 6–10 en el portátil.
  Máximo dos pantallas.
- Validar y recargar: `aerospace reload-config --dry-run && aerospace reload-config`.

## SketchyBar

- **Filosofía: solo iconos.** El dato aparece al pasar el ratón en un tooltip debajo
  del icono, sin cambiar el ancho de la barra (`plugins/hover.sh`: `source` +
  `hover "texto"` + `"${HOVER_ARGS[@]}"`, suscribir el item a `mouse.entered mouse.exited`
  y llamar a `tip <item> <left|right>` en `sketchybarrc` justo antes de añadirlo).
  El clic abre un popup con más. El color del icono avisa de estados importantes
  (batería baja, CPU alta, música sonando).
- Islas: cada grupo de iconos va en un bracket con `island <nombre> <miembros…>` y
  las islas se separan con `gap`. Un item nuevo debe entrar en la isla que le toque.
- Popups: usa `$POPUP` para el estilo común, suscribe el item a `mouse.exited.global`
  y ciérralo en el script (o usa `plugins/popup.sh` si solo abre/cierra).
- `updates=when_shown` por defecto: un item que empieza oculto y debe mostrarse solo
  necesita `updates=on`.
- Notch: lo que crezca hacia el centro debe llamar a `python3 "$CONFIG_DIR/helpers/notch.py" fit &`
  al final de su script. Las posiciones de `bounding_rects` son coordenadas globales
  (el monitor externo está a la izquierda, con x negativas), y `notch.py` guarda los
  límites del notch en esas mismas coordenadas.
- Regex de items: SketchyBar no acepta `+`; usa `'/menu\..*/'`. Ojo con `'/space\..*/'`,
  que también coge `spaces.observer` y las islas `spaces.m*`.
- Los scripts corren desde un servicio de launchd sin el PATH de Homebrew: exporta
  `PATH="/opt/homebrew/bin:$PATH"` si llamas a `aerospace`, `SwitchAudioSource`, etc.
- Recargar: `sketchybar --reload`. Reiniciar servicio: `brew services restart sketchybar`.
- Probar un plugin sin ratón:
  `NAME=cpu SENDER=mouse.entered CONFIG_DIR=~/.config/sketchybar bash plugins/cpu.sh`
  y luego `sketchybar --query cpu`. Vuelve a lanzarlo con `mouse.exited` para dejarlo bien.
- No pruebes botones con efectos (play de música, cambiar dispositivo de audio…) sin
  avisar: afectan al usuario en directo. Si cambias algo para probar, déjalo como estaba.

## Fondo animado

- `neon-wallpaper/index.html` se pinta en canvas: vigila el consumo (mide con
  `ps -axo %cpu,comm | grep WebKit`). Nada de `shadowBlur` por fotograma ni
  redibujar la pantalla entera si no hace falta.
- Para ver una escena sin capturas de pantalla: sirve la carpeta con
  `python3 -m http.server --directory dotfiles/.config/neon-wallpaper` y ábrela en el
  navegador integrado (`index.html?mode=…`); el navegador sí permite capturas.
- Tras cambiar el helper: `swiftc -O wallpaper.swift -o wallpaper` y
  `launchctl kickstart -k gui/$(id -u)/com.cferndp.neon-wallpaper`.
- El arranque automático (LaunchAgent) lo activa el usuario con `wallpaper.sh on`;
  crear agentes de arranque está bloqueado para Claude.

## Tema Neon Noir

Paleta en `dotfiles/.config/sketchybar/colors.sh` (y repetida en WezTerm, bordes,
fastfetch, el tema de Zed y el snippet de VS Code; cambia todos a la vez):

| | Hex |
|---|---|
| Fondo | `#0b0b12` |
| Superficie | `#1f1f2e` |
| Apagado | `#6c6c8a` |
| Texto | `#d7d7e8` |
| Magenta (activo) | `#ff2a6d` |
| Cian (acento) | `#05d9e8` |
| Violeta | `#b967ff` |
| Verde | `#00ff9f` |
| Amarillo | `#f3e600` |
| Rojo | `#d1001f` |

La paleta también está en `.config/neon-noir/theme.zsh` (prompt y fzf), en el tema de
btop y en la config de lazygit.

Iconos: JetBrainsMono Nerd Font; iconos de apps con `sketchybar-app-font`
(`plugins/icon_map.sh`, de su release v3.0.21).

## Git

- Remoto `git@github.com:CFerndp/mac-setup.git`, rama `main`.
- Autor del repo: `CFerndp <CFerndp@users.noreply.github.com>` (configurado en local).
- Mensajes en español con Conventional Commits (`feat:`, `fix:`, `docs:`…).
- Antes de commitear, revisa que no se cuela nada sensible ni corporativo.
