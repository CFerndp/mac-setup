# GoodHabitz: comprobaciones extra. Lo carga doctor.sh (usa sus ok/bad).
if python3 "$HOME/.config/reports/reports.py" unread >/dev/null 2>&1; then ok "Reports reader (goodhabitz)"
else bad "Reports reader does not run" "→ python3 ~/.config/reports/reports.py unread"; fi
