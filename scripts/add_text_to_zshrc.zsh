#!/bin/zsh

# Anade texto al .zshrc global (/usr/share/globally/.zshrc), que es el
# que enlazan todos los usuarios. Contrato que NodeBun ya usa:
#   add_text_to_zshrc "$(printf '%s\n' 'linea1' 'linea2')"
#   add_text_to_zshrc "alias x=y" --prepend

ZSHRC_HOME=/usr/share/globally/.zshrc

# 644 root:root: uid 1000 no escribe a pelo. NOPASSWD sudo (imagen) sí.
if [[ ! -w "$ZSHRC_HOME" && "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
  exec sudo -n "$0" "$@"
fi

PREPEND=0
TEXT=""

for arg in "$@"; do
  if [[ "$arg" == "--prepend" ]]; then
    PREPEND=1
  else
    TEXT="$arg"
  fi
done

if [[ -z "$TEXT" ]]; then
  echo "Usage: add_text_to_zshrc <text> [--prepend]" >&2
  exit 1
fi

if [[ ! -f "$ZSHRC_HOME" ]]; then
  echo "Error: $ZSHRC_HOME does not exist" >&2
  exit 1
fi

if [[ "$PREPEND" -eq 1 ]]; then
  printf '%s\n%s\n' "$TEXT" "$(cat "$ZSHRC_HOME")" > "$ZSHRC_HOME"
else
  printf '\n%s\n' "$TEXT" >> "$ZSHRC_HOME"
fi