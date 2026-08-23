# DockerZsh — tracker

**No planned fixes.**

Working tree is **v2.0.0**. Local smoke on `zsh-local:dev` (~249 MB)
passed: no ENTRYPOINT, `CMD zsh` / `SHELL sh`, HTTPS, sudo
NOPASSWD + `sudo-password` / `SUDO_PASSWORD`, helpers, fzf
bindings, catalogue PATH, git/ssh wrappers (bind at
`/${USER}/.gitconfig` and `/${USER}/.ssh`), `useradd` → zsh,
`useradd -D` lists (does not set) defaults, `init.defaultBranch=main`,
per-uid `known_hosts`, `dockerzsh` skips helper probes / `ssh -V` is meta.

Tag **`v2.0.0`**. Pin `cartagodocker/zsh:v2.0.0`. Do not retag
`v1.0.5`. NodeBun uses `FROM cartagodocker/zsh:v2.0.0`.

Hub `full_description` max ~25 000 chars (`wc -m README.md`). Over
that, the description workflow authenticates then PATCH 400. Keep
the inventory; summarize wording. See `AGENTS.md`.
