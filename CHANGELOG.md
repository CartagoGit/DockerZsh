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
- CLI extras: `less`, `file` (libmagic), `unzip`/`zip`/`xz`/`bzip2`, `jq`,
  `iputils-ping`, `tree`, `patch`, `nano`, `fd-find` (`fd`), `ripgrep` (`rg`),
  `duf`, `fzf`, `zoxide` (`z`), `tzdata`, `bind9-dnsutils`, `rsync`,
  `psmisc` (`killall`), `lsof`, `netcat-openbsd` (`nc`), `htop`, `sqlite3`,
  `traceroute`, `bsdextrautils` (`hexdump`).
- `dockerzsh --help` catalogue of everything the image ships.

### Changed
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
- `os_icon` is the 🐳 emoji (`U+1F433`). Powerline / eza icons still
  need a Nerd Font on the **host**.

### Fixed
- `ca-certificates` is no longer purged (git HTTPS works).
- Build `RUN` no longer ends with `|| true`.
- `share_config_globally` applies `--to` before computing the destination.
- `add_text_to_*` accept `--prepend` in any position; no double `echo -e`.

### Removed
- `fasd` plugin (binary was never installed).
- Oh My Zsh `install.sh` from `master` (replaced by pinned clone).
