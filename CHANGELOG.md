# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.6] - unreleased (tag when Hub is updated)

Hub sigue en **v1.0.5** hasta `git tag v1.0.6` + push del workflow.
NodeBun (siguiente publicación) pinnea **`FROM cartagodocker/zsh:v1.0.6`**.
Orden: publicar zsh 1.0.6, **después** NodeBun.

### Added
- Passwordless `sudo` (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`) plus runtime
  `sudo-password` / `sudo-nopasswd` / `SUDO_PASSWORD`.
- `LANG=C.UTF-8` / `LC_ALL=C.UTF-8`.
- Docker Hub description workflow (same as NodeBun: Hub login JWT,
  `jq --rawfile`, push to `main` when `README.md` changes).
- CLI extras (daily-driver, no gcc/python/locales/man-db):
  `less`, `file`, `nano`, `vim-tiny` (`vi`), `fd`/`rg`/`fzf`/`zoxide`,
  archives (`unzip`/`zip`/`xz`/`bzip2`/`zstd`/`lz4`/`pigz`/`cpio`/`7zip`/`cabextract`),
  data (`jq`/`jo`/`xmllint`/`sqlite3`/`bc`/`hexdump`/`xxd`),
  net (`ping`/`tracepath`/`fping`/`dig`/`whois`/`mtr`/`nc`/`socat`/`ip`/`ss`/`openssl`/`tcpdump`/`iperf3`/`rsync`),
  sys (`htop`/`lsof`/`ncdu`/`duf`/`tmux`/`nnn`/`make`/`gpg`/`envsubst`/`pv`/`sponge`/`uuidgen`/`inotifywait`/`entr`/`strace`/`tig`/`git-extras`/`acl`/`setcap`/`expect`/`keychain`/`rlwrap`/`dos2unix`/`uchardet`/`colordiff`/`progress`/`htpasswd`).
- Oh My Zsh plugins `extract` and `sudo`; fzf key-bindings when present.
- `dockerzsh --help` catalogue of everything the image ships.
- SSH client: official GitHub/GitLab `known_hosts` baked at
  `/usr/share/ssh/known_hosts` and `/etc/ssh/ssh_known_hosts`. Host
  `known_hosts` (if the bind has one) is copied / merged into
  `/tmp/container-ssh-<uid>/known_hosts` (writable; `:ro` never
  written). Re-runs keep container-learned hosts. Invisible
  `ssh`/`scp`/`sftp` wrappers. Mount `~/.ssh:/${USER}/.ssh:ro` and
  type `ssh`. No sshd.

### Changed
- `dockerzsh --help`: each tool/helper now has a short what-it-does
  blurb, typical invocation, and image-specific caveats (TTY vs
  keep-alive, ssh bind-mount, sudo ALL vs %sudo, fzf bindings).
  Sections are filterable: `dockerzsh --shells`, `dockerzsh shells`,
  `dockerzsh shells network`, `dockerzsh --sections`. Documented in
  README “Catalogue CLI”.
- `CMD ["/usr/bin/zsh"]` instead of `ENTRYPOINT ["zsh"]`. Compose
  `command: ["tail", "-f", "/dev/null"]` and `docker run image bash`
  work. Interactive default is still zsh.
- `SHELL ["/bin/sh", "-c"]` so child Dockerfiles do not inherit
  `zsh -c` for `RUN`.
- `ENV SHELL=/usr/bin/zsh`. Login shells of `root` and `ubuntu` are zsh.
- Oh My Zsh / plugins / p10k cloned at pinned commits (v1.0.5 SHAs).
- `eza` from Ubuntu 24.04 (no gierens apt repo). `openssh-client` instead
  of the `ssh` metapackage (no sshd).
- `bat` at `/usr/local/bin/bat` → `batcat`.
- Global configs `644`/`755`; uid 1000 edits via sudo / `add_text_to_*`.
- `os_icon` is the 🐳 emoji (`🐳`). Powerline / eza icons still
  need a Nerd Font on the **host**.

### Fixed
- `ca-certificates` is no longer purged (git HTTPS works).
- Build `RUN` no longer ends with `|| true`.
- `share_config_globally` applies `--to` before computing the destination.
- `add_text_to_*` accept `--prepend` in any position; no double `echo -e`.
- `ssh-from-host` no longer wipes `known_hosts` on every run (would drop
  hosts learned via `accept-new`). Host file lines are merged in.

### Removed
- `fasd` plugin (binary was never installed).
- Oh My Zsh `install.sh` from `master` (replaced by pinned clone).
- Docker CLI (`docker-ce-cli` + compose plugin + `docker-wrap`).
  ~91 MiB installed; use `docker` on the host.
