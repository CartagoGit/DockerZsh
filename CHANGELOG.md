# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- GitHub Release on tag push (`docker-hub-update.yml`). If a Release
  for that tag already exists, it is deleted and recreated. Hub is
  unchanged: existing Hub tags are skipped (delete them on Hub to
  republish the image).

### Changed
- README “What's in the image” no longer truncates the daily CLI
  (`…`). New **Utilities** section lists every extra binary with a
  docs link; image helpers (`add_text_to_*`, `sudo-password`, …)
  are documented in this README. Catalogue CLI table matches.

### Fixed
- `dockerzsh eza -v` / `--list --version` treated `eza version` as a
  path (`"version": No such file`). Probe now skips those error
  lines and reads the `v0.18.2` line from `eza --version`.

## [2.0.0] - 2026-08-23

Major bump from **v1.0.5**: CMD without ENTRYPOINT, sudo, UTF-8,
daily CLI, SSH/git wrappers, no Docker inside, no `:latest`.
Pin **`cartagodocker/zsh:v2.0.0`**. Child images (NodeBun) use
`FROM cartagodocker/zsh:v2.0.0`.

### Added
- Passwordless `sudo` (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`) plus runtime
  `sudo-password` / `sudo-nopasswd` / `SUDO_PASSWORD`.
- `LANG=C.UTF-8` / `LC_ALL=C.UTF-8`.
- Docker Hub description workflow (same as NodeBun: Hub login JWT,
  `jq --rawfile`, push to `main` when `README.md` changes).
- CLI extras (daily-driver, no gcc/python/locales/man-db).
  No ICU/Python/`gnupg`/`7zip`/`file`. Ubuntu `git` still needs
  Perl. Docker CLI was **not** added. README “Image size”
  (~249 MB uncompressed locally).
- Daily-driver packages:
  `less`, `nano`, `vim-tiny` (`vi`), `fd`/`rg`/`fzf`/`zoxide`,
  archives (`unzip`/`zip`/`xz`/`bzip2`/`zstd`/`lz4`/`pigz`/`cpio`/`cabextract`),
  data (`jq`/`jo`/`sqlite3`/`bc`/`hexdump`/`xxd`),
  net (`ping`/`tracepath`/`fping`/`whois`/`mtr`/`nc`/`socat`/`ip`/`ss`/`openssl`/`tcpdump`/`rsync`),
  sys (`htop`/`lsof`/`ncdu`/`duf`/`tmux`/`nnn`/`make`/`envsubst`/`pv`/`sponge`/`uuidgen`/`inotifywait`/`entr`/`strace`/`tig`/`acl`/`setcap`/`keychain`/`dos2unix`/`uchardet`/`colordiff`/`progress`/`htpasswd`).
- Oh My Zsh plugins `extract` and `sudo`; fzf key-bindings (Ubuntu
  Docker images drop `/usr/share/doc`; this tree keeps
  `/usr/share/doc/fzf/examples`).
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
  `dockerzsh shells network`, `dockerzsh --sections | -s`.
  `--version | -v` is image identity. Tool versions are discovered
  from catalogue headings: `dockerzsh --list --version | -l -v`,
  `dockerzsh shells --version | shells -v`, `dockerzsh eza -v`.
  Documented in README “Catalogue CLI”.
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
- `useradd -D` / `--defaults` is not rewritten to
  `useradd -D -s /usr/bin/zsh` (that would *set* the default shell
  instead of listing it). Creating a user without `-s` still gets zsh.
- `add_text_to_*` accept `--prepend` in any position; no double `echo -e`.
- GitHub Actions pinned to SHAs. Workflow no longer pushes `:latest`.
- `ZSH_IMAGE_VERSION` ENV so `dockerzsh --version` stays the zsh tag if a
  child overwrites `VERSION`.
- `ssh-from-host` no longer wipes `known_hosts` on every run (would drop
  hosts learned via `accept-new`). Host file lines are merged in.
- `git-from-host` / `ssh-from-host`: a miss on the first candidate
  (`$HOME/.gitconfig` / `~/.ssh`) no longer aborts the scan under
  `set -e`, so a bind at `/${USER}/.gitconfig` or `/${USER}/.ssh` is
  found.
- `useradd` without `-s` uses `/usr/bin/zsh` (skel already has the
  shared `.zshrc`).
- Ubuntu Docker images drop `/usr/share/doc`; fzf key-bindings are
  kept via `path-include=/usr/share/doc/fzf/examples/*`.
- `git init` of pinned clones sets `init.defaultBranch=main` so the
  build log is not flooded with Git 2.28+ hints. Runtime
  `git config --system init.defaultBranch` is **main** (not master).
- `dockerzsh --list --version` does not probe `ssh-from-host` /
  `git-from-host` (helpers, not versioned binaries). `ssh --version`
  / `-V` is treated as meta in `ssh-wrap` (no missing-keys hint).
- Fallback `UserKnownHostsFile` is `/tmp/container-ssh-%i/known_hosts`
  (per uid). The shared `/tmp/container-ssh-known-hosts` copy is gone.
- `sudo-password` can change the password after one is already
  required: it escalates with `sudo` (current password), not only
  `sudo -n`. Same pattern as `sudo-nopasswd`.
- Powerlevel10k `gitstatusd` is downloaded at **build** into
  `/usr/share/gitstatus` (`GITSTATUS_CACHE_DIR`). Any uid sees it;
  the first prompt does not print “fetching gitstatusd”.
- Prompt colors: `docker run -t` injects `TERM=xterm` (8 colors).
  v1.0.5 forced `TERM=xterm-256color` in `.zshrc`; a later change
  kept the 8-color value (`${TERM:-…}`) so p10k segment backgrounds
  vanished. Restored the v1.0.5 override (zshrc, profile, ENV).

### Removed
- `fasd` plugin (binary was never installed).
- Oh My Zsh `install.sh` from `master` (replaced by pinned clone).
- Docker inside the image (`docker-ce-cli` + compose plugin +
  `docker-wrap`). Use `docker` on the host. A child image can
  install a client if it needs one.
- Hub tag `:latest` is no longer published. Pin `v2.0.0`.
- Slim kit (install in a child if needed): `xmllint` (`libicu74`),
  `git-extras`, `file` (`libmagic-mgc`), `7zip`, `gpg`/`gnupg`,
  `expect`/Tcl, `dig`/`nslookup` (`bind9-dnsutils` / ICU), `iperf3`
  (Ubuntu package wants a daemon; no systemd here), `rlwrap`
  (pulls Python). `rsync` stays; Python/`rrsync` do not. `git` keeps
  Perl (Ubuntu `git` depends on it). DNS: `/etc/resolv.conf` +
  `getent hosts`.
