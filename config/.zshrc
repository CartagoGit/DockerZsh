
# STANDARD DOCKER IMAGE CONFIG

# Deactivate update prompt
DISABLE_UPDATE_PROMPT=true
ZSH_UPDATE_DELAY=0


#p10k config
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Set personal aliases, overriding those provided by oh-my-zsh libs
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

autoload -Uz compinit
compinit

# Load oh-my-zsh and plugins
plugins=(fasd git vscode zsh-autosuggestions zsh-completions zsh-syntax-highlighting jsontools zsh-bat)
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Config for eza (exa) and colors
alias ls='eza --icons --group-directories-first --color=always'
export EXA_COLORS="uu=36:gu=37:sn=32:sb=32:da=34:ur=34:uw=35:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36"
export TERM=xterm-256color

# END OF STANDARD DOCKER IMAGE CONFIG
