local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 14.0

-- Tema Neon Noir (paleta propia, la misma que SketchyBar, los bordes y los editores)
config.colors = {
  background = '#0b0b12',
  foreground = '#d7d7e8',
  cursor_bg = '#ff2a6d',
  cursor_fg = '#0b0b12',
  cursor_border = '#ff2a6d',
  selection_bg = '#3a1f4f',
  selection_fg = '#ffffff',
  split = '#b967ff',
  ansi = {
    '#1a1a24', -- negro
    '#ff2a6d', -- rojo (magenta neón)
    '#00ff9f', -- verde
    '#f3e600', -- amarillo
    '#3d7bff', -- azul
    '#b967ff', -- magenta (violeta)
    '#05d9e8', -- cian
    '#d7d7e8', -- blanco
  },
  brights = {
    '#4a4a63',
    '#ff5c8a',
    '#5cffb8',
    '#fff35c',
    '#6b9bff',
    '#d199ff',
    '#5ef1ff',
    '#ffffff',
  },
  tab_bar = {
    background = '#0b0b12',
    active_tab = { bg_color = '#ff2a6d', fg_color = '#0b0b12' },
    inactive_tab = { bg_color = '#14141f', fg_color = '#6c6c8a' },
    inactive_tab_hover = { bg_color = '#1f1f2e', fg_color = '#05d9e8' },
    new_tab = { bg_color = '#0b0b12', fg_color = '#6c6c8a' },
    new_tab_hover = { bg_color = '#1f1f2e', fg_color = '#05d9e8' },
  },
}

-- Fondo semitransparente con desenfoque
config.window_background_opacity = 0.85
config.macos_window_background_blur = 30

-- Sin barra de título (AeroSpace ya coloca las ventanas); se puede redimensionar
config.window_decorations = 'RESIZE'
config.window_padding = { left = 12, right = 12, top = 12, bottom = 8 }

-- Pestañas abajo y solo cuando hay más de una
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

return config
