# Tema Neon Noir para la shell. Se carga en ~/.zshrc justo después de ~/.p10k.zsh
# (ver snippets/zshrc.sh). Colores de colors.sh de SketchyBar.

# --- Powerlevel10k (estilo classic): solo se cambian colores ---
typeset -g POWERLEVEL9K_BACKGROUND='#14141f'
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#05d9e8'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#6c6c8a'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#5ef1ff'
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#00ff9f'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#b967ff'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#f3e600'
typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND='#6c6c8a'
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND='#00ff9f'
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND='#00ff9f'
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#ff2a6d'
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND='#ff2a6d'
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND='#ff2a6d'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#b967ff'
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#05d9e8'
typeset -g POWERLEVEL9K_DIRENV_FOREGROUND='#f3e600'
typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND='#00ff9f'
typeset -g POWERLEVEL9K_TIME_FOREGROUND='#b967ff'
for _m in VIINS VICMD VIVIS VIOWR; do
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_${_m}_FOREGROUND='#ff2a6d'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_${_m}_FOREGROUND='#d1001f'
done
unset _m
(( ! $+functions[p10k] )) || p10k reload

# --- fzf ---
export FZF_DEFAULT_OPTS="--color=bg+:#1f1f2e,bg:-1,spinner:#ff2a6d,hl:#ff2a6d \
--color=fg:#d7d7e8,header:#b967ff,info:#6c6c8a,pointer:#ff2a6d \
--color=marker:#05d9e8,fg+:#ffffff,prompt:#05d9e8,hl+:#ff5c8a,border:#3a3a52 \
--border=rounded --pointer='▶' --marker='✓'"
