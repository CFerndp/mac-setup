# Trozos para ~/.zshrc (no está en el repo porque tiene más cosas personales).

# 1) Primera línea, antes del instant prompt de Powerlevel10k: fastfetch al abrir WezTerm.
[[ $TERM_PROGRAM == WezTerm ]] && command -v fastfetch >/dev/null && fastfetch

# 2) Justo después de `source ~/.p10k.zsh`: tema Neon Noir (colores del prompt y de fzf).
[[ -f ~/.config/neon-noir/theme.zsh ]] && source ~/.config/neon-noir/theme.zsh
