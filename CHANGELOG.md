# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.0.0] - unreleased (tag when Hub is updated)

Major bump from Hub **v1.0.5**: CMD without ENTRYPOINT, sudo, UTF-8,
daily CLI, SSH/git wrappers, no Docker inside, no `:latest`.
Hub stays on **v1.0.5** until `git tag v2.0.0` + workflow push.
NodeBun (next publication) pins **`FROM cartagodocker/zsh:v2.0.0`**.
Order: publish zsh 2.0.0, **then** NodeBun. Do not retag 1.0.5.

### Added
- Passwordless `sudo` (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`) plus runtime
  `sudo-password` / `sudo-nopasswd` / `SUDO_PASSWORD`.
- `LANG=C.UTF-8` / `LC_ALL=C.UTF-8`.
- Docker Hub description workflow (same as NodeBun: Hub login JWT,
  `jq --rawfile`, push to `main` when `README.md` changes).
- CLI extras (daily-driver, no gcc/python/locales/man-db).
  Size vs Hub v1.0.5: about **+123 MB uncompressed** / **+45–55 MB**
  on Hub (gzip). Named extras ~53 MB; `libicu74` (~35 MB) comes with
  `xmllint`. Docker CLI was **not** added (~91 MB). README “Image size”.
- Daily-driver packages:
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
  type `ssh`. No sshd. Missing keys: `ssh-wrap` says keys are
  required (example bind; destination can be any folder ending
  in `.ssh`), then OpenSSH still runs.
- Git identity from the host: `git-from-host` + `git-wrap`. Bind
  any `…/.gitconfig` (example `~/.gitconfig:/${USER}/.gitconfig:ro`)
  or `GIT_AUTHOR_NAME` + `GIT_AUTHOR_EMAIL`. SSH keys do not set
  the commit author. Missing identity: `git commit` says identity
  is required (example + other-folder) and exits 1
  (`user.useConfigOnly`; no `ubuntu@<container>`).

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
- `share_config_globally` applies `--to` before computing the destination;
  flags require a value (`--to --permissions` no longer eats `src`).
- `useradd` wrapper treats LOGIN as the leftover positional (so
  `useradd -m alice -c "Full Name"` joins `alice` to sudo, not the comment).
- `add_text_to_*` accept `--prepend` in any position; no double `echo -e`.
- GitHub Actions pinned to SHAs. Workflow no longer pushes `:latest`.
- `ZSH_IMAGE_VERSION` ENV so `dockerzsh --version` stays the zsh tag if a
  child overwrites `VERSION`.
- `ssh-from-host` no longer wipes `known_hosts` on every run (would drop
  hosts learned via `accept-new`). Host file lines are merged in.

### Removed
- `fasd` plugin (binary was never installed).
- Oh My Zsh `install.sh` from `master` (replaced by pinned clone).
- Docker inside the image (`docker-ce-cli` + compose plugin +
  `docker-wrap`). Use `docker` on the host. A child image can
  install a client if it needs one.
- Hub tag `:latest` is no longer published. Pin `v2.0.0`.
