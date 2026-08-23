# STANDARD DOCKER IMAGE CONFIG

# Imagen inmutable: no preguntar ni auto-update de Oh My Zsh.
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true

# p10k instant prompt tiene que ir arriba del todo (requisito de p10k).
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# zsh-completions: su src tiene que estar en fpath ANTES de que
# oh-my-zsh.sh llame a compinit. No llamar compinit a mano.
fpath+=("${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src")

# fasd no se instala (binario ausente). git/vscode/jsontools/zsh-bat
# y los tres zsh-users sí.
plugins=(git vscode zsh-autosuggestions zsh-completions zsh-syntax-highlighting jsontools zsh-bat)
source "$ZSH/oh-my-zsh.sh"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# eza (fork activo de exa, abandonado). ls con iconos/colores.
# EZA_COLORS es el nombre actual; EXA_COLORS se deja por compat.
alias ls='eza --icons --group-directories-first --color=always'
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
export EZA_COLORS="uu=36:gu=37:sn=32:sb=32:da=34:ur=34:uw=35:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36"
export EXA_COLORS="$EZA_COLORS"
export TERM="${TERM:-xterm-256color}"
if [[ -z "${LANG}" || "${LANG}" == "C" || "${LANG}" == "POSIX" ]]; then
  export LANG=C.UTF-8
fi
if [[ -z "${LC_ALL}" ]]; then
  export LC_ALL=C.UTF-8
fi

# Optional: docker run -e SUDO_PASSWORD=... → require that password.
[ -x /usr/local/bin/apply-sudo-password-on-boot.sh ] && /usr/local/bin/apply-sudo-password-on-boot.sh || true

# END OF STANDARD DOCKER IMAGE CONFIG
