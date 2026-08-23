# DockerZsh — tracker

**No planned fixes.**

Working tree is **v2.0.0**. Local smoke on `zsh-local:dev` (~249 MB)
passed: no ENTRYPOINT, `CMD zsh` / `SHELL sh`, HTTPS, sudo
NOPASSWD + `sudo-password` / `SUDO_PASSWORD`, helpers, fzf
bindings, catalogue PATH, git/ssh wrappers (bind at
`/${USER}/.gitconfig` and `/${USER}/.ssh`), `useradd` → zsh.

Hub is still **`cartagodocker/zsh:v1.0.5`**. That is publish, not a
code bug: `git tag v2.0.0` + workflow when you want it on Hub.
Do not retag `v1.0.5`. Then NodeBun (`FROM cartagodocker/zsh:v2.0.0`).
