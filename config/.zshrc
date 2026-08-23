# STANDARD DOCKER IMAGE CONFIG

# Imagen inmutable: no preguntar ni auto-update de Oh My Zsh.
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true

# gitstatusd baked at /usr/share/gitstatus (any uid). Set before p10k.
: "${GITSTATUS_CACHE_DIR:=/usr/share/gitstatus}"
export GITSTATUS_CACHE_DIR

# Oh My Zsh lives in /usr/share (root:root). uid 1000 would otherwise
# skip compinit ("insecure directories") and Tab would do nothing.
ZSH_DISABLE_COMPFIX=true

# Ghost-text as you type. Must be set BEFORE oh-my-zsh loads the plugin.
# Plugin default `fg=8` / 256-grey is invisible on many dark terminals
# (p10k + xterm-256color). Cyan is visible; accept with → or End.
# `completion` still suggests when history is empty (`docker run --rm`).
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# p10k instant prompt tiene que ir arriba del todo (requisito de p10k).
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# zsh-completions: su src tiene que estar en fpath ANTES de que
# oh-my-zsh.sh llame a compinit. No llamar compinit a mano.
fpath+=("${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src")

# Bundled OMZ: git / extract / sudo / jsontools / safe-paste /
# fancy-ctrl-z / dirhistory. Custom clones: zsh-users + zsh-bat +
# you-should-use. No vscode (no `code` in the image). No fasd (no
# binary). syntax-highlighting then history-substring-search last.
plugins=(git extract sudo jsontools zsh-completions you-should-use safe-paste fancy-ctrl-z dirhistory zsh-bat zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)
source "$ZSH/oh-my-zsh.sh"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# jsontools needs node, python3, or ruby. This base has none (NodeBun
# has node → the plugin defines pp_json itself). jq is on PATH here.
if ! typeset -f pp_json >/dev/null 2>&1; then
  pp_json() { jq . "$@"; }
  is_json() {
    if jq -e . >/dev/null 2>&1; then
      print -r -- true
      return 0
    fi
    print -r -- false
    return 1
  }
  urlencode_json() { jq -sRr @uri; }
  urldecode_json() {
    local data
    data=$(cat)
    printf '%b\n' "${data//%/\\x}"
  }
fi

# History: write as you go (not only on exit). Empty docker --rm sessions
# still recall commands typed in THIS shell (Up / Ctrl-R).
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE
: >> "${HISTFILE}" 2>/dev/null || true

# Interactive aliases (ls→eza), zoxide, fzf. Same file bash/sh source.
[[ -r /usr/share/zsh-image/interactive.sh ]] && source /usr/share/zsh-image/interactive.sh
# Up/Down: history matching the prefix already typed. After fzf
# key-bindings (those are Ctrl-R / Ctrl-T / Alt-C — Tab stays native).
if typeset -f history-substring-search-up >/dev/null 2>&1; then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
  [[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
fi
# p10k / fzf wrap widgets. MANUAL_REBIND requires a second bind after that.
if typeset -f _zsh_autosuggest_bind_widgets >/dev/null; then
  _zsh_autosuggest_bind_widgets
fi
# docker run -t injects TERM=xterm (8 colors). p10k classic uses 256-color
# backgrounds (same force as v1.0.5). Keep the override.
export TERM=xterm-256color
if [[ -z "${LANG}" || "${LANG}" == "C" || "${LANG}" == "POSIX" ]]; then
  export LANG=C.UTF-8
fi
if [[ -z "${LC_ALL}" ]]; then
  export LC_ALL=C.UTF-8
fi

# Optional: docker run -e SUDO_PASSWORD=... → require that password.
[ -x /usr/local/bin/apply-sudo-password-on-boot.sh ] && /usr/local/bin/apply-sudo-password-on-boot.sh || true
# Copy a :ro ~/.ssh overlay into a 700 dir this uid owns (OpenSSH needs it).
[ -x /usr/local/bin/ssh-from-host ] && /usr/local/bin/ssh-from-host || true
if [[ -r /tmp/container-ssh-${UID}/env ]]; then
  source /tmp/container-ssh-${UID}/env
fi
# Host git identity (user.name / user.email). SSH keys do not set this.
[ -x /usr/local/bin/git-from-host ] && /usr/local/bin/git-from-host || true
if [[ -r /tmp/container-git-${UID}/env ]]; then
  source /tmp/container-git-${UID}/env
fi

# END OF STANDARD DOCKER IMAGE CONFIG
