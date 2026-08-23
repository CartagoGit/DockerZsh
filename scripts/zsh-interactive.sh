# Interactive sugar for zsh, bash, and POSIX sh (dash).
# Sourced, not executed. docker RUN / sh -c / bash -c stay alias-free
# (those shells are not interactive). dash also sources this via $ENV.
#
# Installed as /usr/share/zsh-image/interactive.sh (not on PATH).

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || true ;;
esac

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first --color=always'
fi
# cat → bat (zsh-bat does this in zsh only). --paging=never = cat, not a pager.
# GNU cat stays `rcat` / `/usr/bin/cat`.
if command -v bat >/dev/null 2>&1; then
  alias rcat='/usr/bin/cat'
  alias cat='bat --paging=never'
fi

EZA_COLORS="uu=36:gu=37:sn=32:sb=32:da=34:ur=34:uw=35:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36"
export EZA_COLORS
EXA_COLORS="$EZA_COLORS"
export EXA_COLORS

# Login bash: profile.d / bash.bashrc run first, then ~/.bashrc
# overwrites PS1. Aliases/zoxide/fzf init once. Prompt + ble.sh
# always re-apply at the end of ~/.bashrc.
_zsh_image_already=${ZSH_IMAGE_INTERACTIVE_RC:-}

_zoxide_init() {
  _shell=$1
  if ! command -v zoxide >/dev/null 2>&1; then
    return 0
  fi
  _zinit=$(zoxide init "$_shell" 2>/dev/null) || _zinit=
  if [ -n "$_zinit" ]; then
    eval "$_zinit"
  fi
  unset _zinit _shell
}

_fzf_source() {
  _kind=$1
  for _fzf_f in \
    "/usr/share/doc/fzf/examples/${_kind}" \
    "/usr/share/fzf/${_kind}" \
    "/usr/share/fzf/shell/${_kind}"
  do
    if [ -r "$_fzf_f" ]; then
      # shellcheck disable=SC1090
      . "$_fzf_f"
      break
    fi
  done
  unset _fzf_f _kind
}

if [ -n "${ZSH_VERSION:-}" ]; then
  if [ -z "$_zsh_image_already" ]; then
    _zoxide_init zsh
    # Key-bindings only (Ctrl-R / Ctrl-T / Alt-C). Do not steal Tab:
    # fzf's completion.zsh binds ^I and hides the native match list.
    # Ubuntu's key-bindings.zsh snapshots $options and evals them back
    # in an always-block. That restore includes `zle on`. zsh refuses
    # `setopt zle` when stdin is not a TTY (`docker run -i`, `zsh -ic`
    # in a pipe) → (eval):1: can't change option: zle. Skip then.
    # `docker run -it` / `exec -it` has a TTY: load as usual.
    if [ -t 0 ]; then
      _fzf_source key-bindings.zsh
    fi
  fi
  ZSH_IMAGE_INTERACTIVE_RC=1
elif [ -n "${BASH_VERSION:-}" ]; then
  if [ -z "$_zsh_image_already" ]; then
    _zoxide_init bash
    if [ -t 0 ]; then
      _fzf_source key-bindings.bash
    fi
  # Ubuntu .bashrc sources this only if the package exists; root's
  # snippet is commented out. Load once so Tab lists commands/files.
  if [ -z "${BASH_COMPLETION_VERSINFO:-}" ]; then
    if [ -r /usr/share/bash-completion/bash_completion ]; then
      # shellcheck disable=SC1091
      . /usr/share/bash-completion/bash_completion
    elif [ -r /etc/bash_completion ]; then
      # shellcheck disable=SC1091
      . /etc/bash_completion
    fi
  fi
  HISTFILE="${HISTFILE:-$HOME/.bash_history}"
  HISTSIZE="${HISTSIZE:-50000}"
  HISTFILESIZE="${HISTFILESIZE:-50000}"
  export HISTFILE HISTSIZE HISTFILESIZE
  shopt -s histappend 2>/dev/null || true
  bind 'set show-all-if-ambiguous on' 2>/dev/null || true
  bind 'set completion-ignore-case on' 2>/dev/null || true
  bind '"\e[A": history-search-backward' 2>/dev/null || true
  bind '"\e[B": history-search-forward' 2>/dev/null || true
  bind '"\eOA": history-search-backward' 2>/dev/null || true
  bind '"\eOB": history-search-forward' 2>/dev/null || true
  : >> "${HISTFILE}" 2>/dev/null || true
  fi
  ZSH_IMAGE_INTERACTIVE_RC=1
  # p10k-style ❯: green after 0, red after a failed command.
  _zsh_image_bash_prompt() {
    if [ "${_zsh_image_ec:-0}" -eq 0 ]; then
      printf '\001\033[32m\002❯\001\033[0m\002 '
    else
      printf '\001\033[31m\002❯\001\033[0m\002 '
    fi
  }
  case "${PROMPT_COMMAND-}" in
    *_zsh_image_ec=*) ;;
    *) PROMPT_COMMAND='_zsh_image_ec=$?; history -a'"${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
  esac
  PS1='$(_zsh_image_bash_prompt)'
  # Ghost-text (zsh-autosuggestions equivalent). Load on the *second*
  # source: /etc/bash.bashrc runs first (no TTY yet / PS1 overwritten
  # by ~/.bashrc). ~/.bashrc ends by sourcing this file again.
  # --lib then ble-attach: --attach=prompt never set BLE_VERSION here.
  if [ -n "$_zsh_image_already" ] && [ -z "${_ble_bash:-}" ] && [ -r /usr/share/blesh/ble.sh ]; then
    # shellcheck disable=SC1091
    . /usr/share/blesh/ble.sh --lib --norc
    if command -v ble-attach >/dev/null 2>&1; then
      ble-attach
    fi
  fi
else
  # dash has no chpwd; prompt hook is the POSIX-supported option.
  if command -v zoxide >/dev/null 2>&1; then
    _zinit=$(zoxide init posix --hook prompt 2>/dev/null) || _zinit=
    if [ -n "$_zinit" ]; then
      eval "$_zinit"
    fi
    unset _zinit
  fi
fi

unset -f _zoxide_init _fzf_source 2>/dev/null || true
