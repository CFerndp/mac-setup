# Setup del Mac

Configuración de mi Mac para desarrollar: tiling con AeroSpace y los atajos de
Omarchy, Caps Lock como SUPER, barra SketchyBar y el tema propio Neon Noir.

## Uso

En un Mac nuevo:

```bash
git clone git@github.com:CFerndp/mac-setup.git
cd mac-setup
./setup.sh
```

`setup.sh` instala todo con Homebrew, aplica los ajustes de macOS y ejecuta `link.sh`.

`link.sh` enlaza cada archivo de `dotfiles/` en su sitio de `~` (si ya existe uno, lo
guarda como `.bak-<fecha>`) y compila los helpers de SketchyBar. Como son enlaces,
editar la config en `~` es editar el repo: basta con hacer commit.

Lo que no está en el repo porque son archivos personales con más cosas
(`~/.zshrc`, ajustes de Zed y VS Code) se aplica a mano desde `snippets/`.

## Estructura

```
dotfiles/            → se enlaza en ~ (misma ruta)
  .aerospace.toml
  .wezterm.lua
  .config/sketchybar/   barra: sketchybarrc, colors.sh, plugins/, helpers/
  .config/aerospace/    scripts de AeroSpace (minimizar / restaurar)
  .config/borders/      bordes de ventana
  .config/karabiner/    Caps Lock = SUPER
  .config/fastfetch/
  .config/neon-wallpaper/  fondo animado (index.html + helper wallpaper.swift)
  .config/zed/themes/neon-noir.json
snippets/            → trozos para pegar en ~/.zshrc, Zed y VS Code
setup.sh             → instalación completa
link.sh              → solo los enlaces y los helpers
```

## Instalado con Homebrew (`setup.sh`)

- **Apps:** Maccy, Shottr, AeroSpace, DBeaver, Postman, Ice, Stats,
  BetterDisplay, MonitorControl, AppCleaner, Keka, Karabiner-Elements
- **CLI:** btop, duti, fastfetch, SwitchAudioSource (`switchaudio-osx`, para el menú de audio de la barra)
- **Estética:** SketchyBar y JankyBorders (`borders`), del tap `felixkratz/formulae`
  (solo esas dos fórmulas marcadas como de confianza con `brew trust`). Se
  compilan en el Mac: necesitan Command Line Tools al día.
- **Fuentes:** JetBrains Mono Nerd Font, sketchybar-app-font
- Descartados: Rectangle (choca con AeroSpace), Starship (se mantiene Powerlevel10k)

## Archivos de configuración

| Archivo | Qué hace |
|---|---|
| `~/.aerospace.toml` | AeroSpace con los atajos de Omarchy |
| `~/.config/aerospace/minimize.sh` | Minimizar y restaurar ventanas (SUPER+M / SUPER+Shift+M); recuerda el orden en que se minimizaron |
| `~/.config/karabiner/karabiner.json` | Caps Lock = SUPER (ctrl+opt+cmd); un toque rápido = Bloq Mayús |
| `~/.wezterm.lua` | WezTerm: JetBrainsMono Nerd Font 14 pt, paleta Neon Noir, 85 % de opacidad con desenfoque, sin barra de título |
| `~/.config/sketchybar/` | Barra superior flotante y redondeada (ver abajo). Colores en `colors.sh`, scripts en `plugins/`, iconos de apps en `plugins/icon_map.sh` (de sketchybar-app-font v3.0.21) |
| `~/.config/borders/bordersrc` | Borde con degradado magenta→cian en la ventana activa |
| `~/.config/zed/themes/neon-noir.json` | Tema Neon Noir para Zed (se activa con `snippets/zed-settings.jsonc`) |
| `~/.config/fastfetch/config.jsonc` | fastfetch con el logo de Apple en degradado neón |
| `~/.zshrc` (fuera del repo) | Oh My Zsh + Powerlevel10k. Primera línea: fastfetch, solo en WezTerm (`snippets/zshrc.sh`) |
| VS Code `settings.json` (fuera del repo) | Terminal externa = WezTerm y colores Neon Noir sobre "Default Dark Modern" (`snippets/vscode-neon-noir.jsonc`) |

## Ajustes del sistema

- WezTerm abre los scripts (`.sh`, `.command`, `.tool`, `.zsh`, `.bash`) y los enlaces `ssh://`, `telnet://` y `man` (con `duti`)
- Repetición de teclas rápida, sin popup de acentos al mantener una tecla
- Finder muestra archivos ocultos y extensiones
- Capturas en `~/Screenshots`
- Barra de menú de macOS oculta (aparece al llevar el ratón arriba); SketchyBar ocupa su lugar

## Estética: tema Neon Noir (paleta propia, cyberpunk oscuro)

| Color | Hex | Uso |
|---|---|---|
| Fondo | `#0b0b12` | Fondos |
| Magenta | `#ff2a6d` | Activo, cursor, palabras clave |
| Cian | `#05d9e8` | Acentos, funciones |
| Violeta | `#b967ff` | Tipos, borde de la barra |
| Verde | `#00ff9f` | Strings |
| Amarillo | `#f3e600` | Números, avisos |
| Texto | `#d7d7e8` | Texto |

No usa extensiones de terceros: en Zed es un tema propio y en VS Code son ajustes de color.

### Barra (SketchyBar)

**Filosofía:** solo iconos. El dato aparece al pasar el ratón (con `plugins/hover.sh`)
y el clic lleva a más. Los colores avisan sin tener que pasar el ratón. Los menús
emergentes se cierran solos al sacar el ratón de la barra.

La barra es transparente y los iconos van en **islas** (brackets con fondo propio),
como en la config de FelixKratz: escritorios (una por pantalla) · app activa |
música · herramientas · entrada/salida · sistema · fecha.

- **Izquierda:**
  - Escritorios de cada pantalla con los iconos de sus apps, animados al cambiar.
    Los pinta un solo script (`plugins/spaces.sh`, lanzado por el item oculto
    `spaces.observer`) en vez de uno por escritorio.
  - App activa: su icono (nombre al pasar el ratón). **Clic: los escritorios se
    cambian por los menús de la app** (Archivo, Edición…), y otro clic los devuelve.
    Así no hace falta la barra de macOS.
- **Derecha:**

  | Icono | Al pasar el ratón | Clic | Otros |
  |---|---|---|---|
  | Música del navegador (magenta = suena, gris = pausa) | Título | Fuente, estado, anterior / play-pausa / siguiente, "Ir a la pestaña" | |
  | Slack, Teams, Outlook (solo si hay sin leer) | Nº sin leer | Abre la app | |
  | Capturas | — | Shottr: área, pantalla, ventana, con scroll; grabación de macOS | |
  | Docker (verde = hay contenedores, oculto si Docker no corre) | Nº en marcha | Lista; clic en uno abre sus logs en WezTerm | |
  | Altavoz y micro | Nombres | Elegir dispositivo | Clic derecho: ajustes de sonido |
  | Teclado | Distribución (US / ES / ABC) | Cambiar | |
  | Volumen (el icono indica el nivel) | % | Deslizador, silencio y controles de reproducción | Rueda: subir/bajar. Clic derecho: ajustes de sonido |
  | Red (Wi-Fi, cable o rojo sin conexión) | Tipo e IP | Ajustes de Wi-Fi / red del sistema | |
  | CPU (cian / amarillo ≥ 50 % / rojo ≥ 80 %) | % | Monitor de Actividad | |
  | Batería (verde / amarillo / rojo si está baja) | %, cargando o tiempo restante | — | |
  | Fecha "L 09/11 10:37" | Fecha completa | — | |

  Lo que suena puede salir solo como "YouTube Music" cuando esa web no pone la
  canción en el título de la pestaña (por ejemplo, en pausa).
- `topmost=on`: la barra queda por encima de la barra de macOS cuando esta aparece.
- Los menús de la app usan `helpers/menus` (`menus.swift`): `menus list` y
  `menus select <n>`. Idea de FelixKratz reescrita en Swift con APIs públicas. Necesita
  permiso de Accesibilidad para SketchyBar.
- **Notch (cámara del portátil):** `helpers/notch.py` detecta la pantalla con notch
  (`detect`) y, cuando algo crece hacia la cámara, lo recorta (`fit`):
  - menús de la app que no caben → botón **»** con un desplegable con el resto;
  - escritorios → pierden los iconos de apps (primero los no activos) y queda el número;
  - título de la música → se acorta.

  Se ejecuta tras cada cambio de escritorio, app, música o avisos, y al conectar o
  desconectar pantallas. En pantallas sin notch no hace nada.
- `updates=when_shown` por defecto: los scripts no corren si su item no se ve. Los
  items que empiezan ocultos y se muestran solos (avisos, Docker, música) llevan
  `updates=on`.
- El selector de teclado usa `helpers/inputsource`, una herramienta propia en Swift
  (`inputsource.swift`, compilada con `swiftc -O inputsource.swift -o inputsource`).
  Comandos: `list`, `current`, `select <id>`.
- Los controles de reproducción usan `helpers/mediakey` (`mediakey.swift`), que pulsa
  las teclas multimedia del sistema: `mediakey play|next|previous`. La primera vez
  macOS puede pedir permiso de Accesibilidad para SketchyBar.
- "Lo que suena" lee el título de las pestañas con `helpers/music_tabs.scpt` y cambia
  de pestaña con `helpers/focus_tab.scpt` (AppleScript; los `.applescript` son el
  código fuente, se compilan con `osacompile`). Sabe si suena por la marca
  "Playing audio" que el navegador pone en `pmset -g assertions`. Solo consulta los
  navegadores que ya están abiertos. YouTube Music no pone el artista en el título,
  así que ahí solo sale la canción.

### Servicios

- SketchyBar y JankyBorders arrancan solos con `brew services`. Para reiniciarlos:

  ```bash
  brew services restart sketchybar
  brew services restart borders
  ```

- AeroSpace avisa a SketchyBar en cada cambio de escritorio (`exec-on-workspace-change`)
  y deja 46 px arriba en la pantalla externa para la barra (flota a 6 px y mide 32). En el portátil macOS ya
  reserva la franja del notch, así que ahí solo hay 10 px.
- Para volver a la barra de macOS: Ajustes del Sistema → Centro de control →
  "Ocultar y mostrar automáticamente la barra de menús" → Nunca, y
  `brew services stop sketchybar`.

## Fondo animado

`dotfiles/.config/neon-wallpaper/`:

- `index.html`: animación Neon Noir en canvas. Modos con `?mode=`:
  - `freefall` (**monitor externo, por defecto**): una figura cae con los brazos
    abiertos entre muros de rascacielos que suben; la lluvia sube y abajo solo hay
    niebla. Opresión y libertad;
  - `edge` (**portátil, por defecto**): una figura sentada de espaldas al borde de una
    azotea sobre una ciudad inmensa, con lluvia fina, un rótulo roto «NO EXIT» y algún
    relámpago violeta;
  - `city`: ciudad nocturna con sol synthwave y suelo de neón en movimiento;
  - `minimal`: casi negro con retícula tenue, barrido lento y cursor de terminal.

  Para usar otros, cambia los argumentos del helper en el plist
  (`--external city --builtin minimal`) y vuelve a ejecutar `wallpaper.sh on`.
- `wallpaper.swift`: helper propio que pone esa página en una ventana al nivel del
  escritorio de cada pantalla (debajo de los iconos y de todo). Hace lo que Plash, que
  ya no es open source. Se rehace solo al conectar o quitar pantallas. AeroSpace no lo
  gestiona. Opciones: `--external <modo>` y `--builtin <modo>`.
- `wallpaper.sh on` lo compila y lo deja arrancando al iniciar sesión (LaunchAgent
  `com.cferndp.neon-wallpaper`); `wallpaper.sh off` lo quita. **Hay que ejecutarlo a
  mano** (no lo hace `setup.sh`):

  ```bash
  ~/.config/neon-wallpaper/wallpaper.sh on
  ```

- Consumo: resolución normal (no Retina), entre 12 y 24 fps según la escena, sin
  desenfoques por fotograma y solo se redibuja lo que hace falta. Unos 20 % de un núcleo en total con las dos pantallas.

## AeroSpace

- **SUPER = Caps Lock.**
- **Pantallas:** escritorios 1–5 en la pantalla externa (cualquiera que no sea la del
  portátil) y 6–10 en el portátil. Si solo está el portátil, van todos ahí. Supone
  un máximo de dos pantallas.
- **Atajos:**

  | Atajo | Acción |
  |---|---|
  | SUPER + Enter | WezTerm |
  | SUPER + Shift + B / Enter | Brave |
  | SUPER + Shift + N / F / T | Zed / Finder / btop |
  | SUPER + Espacio | Lanzador de apps |
  | SUPER + Shift + Espacio | Barra: alternar escritorios / menús de la app |
  | SUPER + C | Captura de área (Shottr) |
  | SUPER + W / Q | Cerrar ventana |
  | SUPER + flechas | Mover el foco |
  | SUPER + Shift + flechas | Mover la ventana |
  | SUPER + J | Cambiar la división horizontal/vertical |
  | SUPER + L | Mosaico / acordeón (si las ventanas no salen lado a lado, es esto) |
  | SUPER + T | Flotante / mosaico |
  | SUPER + F | Pantalla completa |
  | SUPER + M | Minimizar al Dock |
  | SUPER + Shift + M | Restaurar la última minimizada (si no, las de la app activa) |
  | SUPER + `'` / `¡` (+ Shift) | Ancho (alto) − / + |
  | SUPER + 1…0 | Ir al escritorio |
  | SUPER + Shift + 1…0 | Mover la ventana al escritorio |
  | SUPER + Tab / Shift + Tab | Escritorio siguiente / anterior |
  | SUPER + `º` | Último escritorio |
  | SUPER + Shift + `º` | Pasar el escritorio al otro monitor |
  | SUPER + Shift + `Ñ` | Modo servicio: `r` reinicia el layout, `Esc` recarga la config |

- **Diagnóstico:**

  ```bash
  aerospace list-monitors
  aerospace list-workspaces --all --format '%{workspace} → %{monitor-name}'
  aerospace list-windows --all --format '%{workspace} | %{app-name} | %{window-layout}'
  ```

## Pendiente / ideas

- Asignar cada app a su escritorio (Slack → 4, Brave → 2…)
- ¿SUPER + Shift + B debería abrir Chrome en vez de Brave?
- Probar la asignación de pantallas con el monitor de la oficina
