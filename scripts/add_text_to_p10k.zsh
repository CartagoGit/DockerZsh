#!/bin/zsh

# Anade texto al .p10k.zsh global. Misma CLI que add_text_to_zshrc:
#   add_text_to_p10k "typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose"
#   add_text_to_p10k "..." --prepend

P10K_HOME=/usr/share/globally/.p10k.zsh

# 644 root:root: uid 1000 no escribe a pelo. NOPASSWD sudo (imagen) sí.
if [[ ! -w "$P10K_HOME" && "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
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
  echo "Usage: add_text_to_p10k <text> [--prepend]" >&2
  exit 1
fi

if [[ ! -f "$P10K_HOME" ]]; then
  echo "Error: $P10K_HOME does not exist" >&2
  exit 1
fi

if [[ "$PREPEND" -eq 1 ]]; then
  printf '%s\n%s\n' "$TEXT" "$(cat "$P10K_HOME")" > "$P10K_HOME"
else
  printf '\n%s\n' "$TEXT" >> "$P10K_HOME"
fi