# 🐳 cartagodocker/zsh

Ubuntu **24.04 LTS** with **zsh** as the default interactive shell — Oh My Zsh, Powerlevel10k, eza, bat, git, passwordless sudo.

Base for others (e.g. [`cartagodocker/nodebun`](https://hub.docker.com/r/cartagodocker/nodebun)). Root, uid `1000` (`ubuntu`), and later `useradd -m` users share `.zshrc` / `.p10k.zsh` / Oh My Zsh via `/usr/share/globally`.

The [nodebun README](https://github.com/CartagoGit/DockerNodeBun#readme) uses the **same section order**. This page is the shell-base contract; NodeBun only documents runtimes it adds.

| | |
|---|---|
| 📦 GitHub | https://github.com/CartagoGit/DockerZsh |
| 🐋 Docker Hub | https://hub.docker.com/r/cartagodocker/zsh |
| 📝 Changelog | [CHANGELOG.md](./CHANGELOG.md) |

Pin a **version tag**. No `latest` in production.

```dockerfile
FROM cartagodocker/zsh:v2.0.0
```

---

## 📦 What's in the image

| | Piece | Notes |
|---|---|---|
| 🐧 | OS | Ubuntu 24.04 LTS (Noble) |
| 🐚 | Interactive shell | zsh + Oh My Zsh + Powerlevel10k — `CMD ["/usr/bin/zsh"]` |
| 💻 | Other shells | `bash` and `sh` (dash) stay installed |
| 📂 | Listing / pager | `eza` (`ls`), `bat`, GNU `find` + `fd`, `rg`, `less`, `tree`, `nnn`, `ncdu`, `duf` — [Utilities](#utilities) |
| 🧰 | Daily CLI | Every extra binary + our helpers: [Utilities](#utilities) |
| 📖 | Catalogue | `dockerzsh --help` — same inventory in-container ([Catalogue CLI](#catalogue-cli-dockerzsh)) |
| 🌐 | Network | `curl`, `wget`, `git`, **`openssh-client`** (no sshd), **`ca-certificates`**, `ip`/`ss`, `socat`, `tcpdump` |
| 🔐 | sudo | NOPASSWD for every uid (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`) |
| 🌍 | Locale | `LANG=C.UTF-8` · `LC_ALL=C.UTF-8` |
| 🧱 | Build `SHELL` | `["/bin/sh", "-c"]` — child `RUN` lines are POSIX, not zsh |

No `openssh-server`, no `ENTRYPOINT`: `docker run` / Compose `command:` is the process.

**Not in this image** (shell base): `gcc`/`g++`, `python3`, `neovim`, `git-lfs`, `rclone`, `locales`, `man-db`, `nmap`, `file`, `7zip`, `xmllint`, `git-extras`, `gpg`/`gnupg`, `expect`/Tcl, `dig`/`nslookup` (`bind9-dnsutils` / `libicu`), `iperf3`, `rlwrap`, **no sshd**, **no Docker** (`dockerd` / `docker` CLI). Those — or a Docker client / commit signing — go in a child or on the **host**.

Container IP: `ip -4 addr`. DNS: `/etc/resolv.conf`. Resolve: `getent hosts github.com` (same as `curl`/`git`). Daily CLI: [Utilities](#utilities). Small extras (`tcpdump`, `htpasswd`) stay.

---

## 🧰 Utilities

Extra CLIs we install (Ubuntu already has `cp`, `mv`, `grep`, `awk`, `sed`, `find`, `top`, …). Each table is **name → docs**. Image caveats: interactive zsh/bash/sh alias `ls`→eza and `cat`→bat (`--paging=never`; `rcat` is GNU cat); GNU `ls`/`find` stay; Debian names `batcat`/`fdfind`; `jsontools` uses `jq` (no node/python/ruby); Tab stays native (no `fzf-tab` / `zsh-autocomplete`); no `vscode`/`fasd`; no sshd; no `gcc`. In-container: `dockerzsh --help`.

### Shells

| Tool | Docs |
|---|---|
| `zsh` | [zsh](https://zsh.sourceforge.io/Doc/) · [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) · [p10k](https://github.com/romkatv/powerlevel10k) |
| `bash` | [manual](https://www.gnu.org/software/bash/manual/) · [ble.sh](https://github.com/akinomyoga/ble.sh) |
| `sh` | [dash](https://manpages.ubuntu.com/manpages/noble/en/man1/dash.1.html) |

`zsh` is `CMD`. Interactive bash: eza/bat, zoxide, fzf keys, Tab, ble.sh, green/red `❯`. Interactive sh: eza + zoxide (no fzf keys). `sh -c` stays POSIX. Plugins: interactive zsh only (`dockerzsh --plugins`).

| Plugin | Docs |
|---|---|
| `git` | [git](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git) |
| `extract` / `x` | [extract](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/extract) |
| `sudo` | [sudo](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sudo) |
| `jsontools` | [jsontools](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/jsontools) |
| `zsh-autosuggestions` | [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) |
| `zsh-completions` | [zsh-completions](https://github.com/zsh-users/zsh-completions) |
| `zsh-syntax-highlighting` | [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) |
| `zsh-history-substring-search` | [history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) |
| `you-should-use` | [you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use) |
| `safe-paste` | [safe-paste](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/safe-paste) |
| `fancy-ctrl-z` | [fancy-ctrl-z](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fancy-ctrl-z) |
| `dirhistory` | [dirhistory](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dirhistory) |
| `zsh-bat` | [zsh-bat](https://github.com/fdellwing/zsh-bat) |

### Listing / viewing

| Tool | Docs |
|---|---|
| `eza` | [eza](https://github.com/eza-community/eza) |
| `bat` | [bat](https://github.com/sharkdp/bat) |
| `fd` | [fd](https://github.com/sharkdp/fd) |
| `rg` | [ripgrep](https://github.com/BurntSushi/ripgrep) |
| `less` | [less](https://www.greenwoodsoftware.com/less/) |
| `tree` | [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree) |
| `nnn` | [nnn](https://github.com/jarun/nnn) |
| `ncdu` | [ncdu](https://dev.yorhel.nl/ncdu) |
| `duf` | [duf](https://github.com/muesli/duf) |

### Edit / data

| Tool | Docs |
|---|---|
| `nano` | [nano](https://www.nano-editor.org/dist/latest/nano.html) |
| `vi` | [vim.tiny](https://manpages.ubuntu.com/manpages/noble/en/man1/vim.tiny.1.html) |
| `jq` | [jq](https://jqlang.github.io/jq/manual/) |
| `jo` | [jo](https://github.com/jpmens/jo) |
| `sqlite3` | [sqlite3](https://www.sqlite.org/cli.html) |
| `hexdump` / `xxd` | [hexdump](https://manpages.ubuntu.com/manpages/noble/en/man1/hexdump.1.html) · [xxd](https://manpages.ubuntu.com/manpages/noble/en/man1/xxd.1.html) |
| `bc` | [bc](https://www.gnu.org/software/bc/manual/html_mono/bc.html) |
| `column` | [column](https://manpages.ubuntu.com/manpages/noble/en/man1/column.1.html) |

### Archives / text

| Tool | Docs |
|---|---|
| `unzip` / `zip` | [unzip](https://manpages.ubuntu.com/manpages/noble/en/man1/unzip.1.html) · [zip](https://manpages.ubuntu.com/manpages/noble/en/man1/zip.1.html) |
| `tar` / `gzip` | [tar](https://www.gnu.org/software/tar/manual/) · [gzip](https://www.gnu.org/software/gzip/manual/gzip.html) |
| `xz` | [xz](https://tukaani.org/xz/) |
| `bzip2` | [bzip2](https://sourceware.org/bzip2/manual/manual.html) |
| `zstd` | [zstd](https://github.com/facebook/zstd) |
| `lz4` | [lz4](https://github.com/lz4/lz4) |
| `pigz` | [pigz](https://zlib.net/pigz/) |
| `cpio` | [cpio](https://www.gnu.org/software/cpio/manual/) |
| `cabextract` | [cabextract](https://www.cabextract.org.uk/) |
| `extract` / `x` | [extract](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/extract) |
| `uchardet` | [uchardet](https://www.freedesktop.org/wiki/Software/uchardet/) |
| `dos2unix` | [dos2unix](https://waterlan.home.xs4all.nl/dos2unix.html) |

### Network

| Tool | Docs |
|---|---|
| `curl` / `wget` | [curl](https://curl.se/docs/manpage.html) · [wget](https://www.gnu.org/software/wget/manual/wget.html) |
| `ssh` / `scp` / `sftp` | [ssh](https://man.openbsd.org/ssh.1) — [SSH in this image](#ssh-client-only--no-sshd) |
| `ping` | [ping](https://manpages.ubuntu.com/manpages/noble/en/man8/ping.8.html) |
| `tracepath` | [tracepath](https://manpages.ubuntu.com/manpages/noble/en/man8/tracepath.8.html) |
| `fping` | [fping](https://fping.org/) |
| `whois` | [whois](https://manpages.ubuntu.com/manpages/noble/en/man1/whois.1.html) |
| `mtr` | [mtr](https://www.bitwizard.nl/mtr/) |
| `traceroute` | [traceroute](https://manpages.ubuntu.com/manpages/noble/en/man8/traceroute.8.html) |
| `rsync` | [rsync](https://download.samba.org/pub/rsync/rsync.1) |
| `nc` | [nc](https://man.openbsd.org/nc.1) |
| `socat` | [socat](http://www.dest-unreach.org/socat/doc/socat.html) |
| `ip` / `ss` | [ip](https://manpages.ubuntu.com/manpages/noble/en/man8/ip.8.html) · [ss](https://manpages.ubuntu.com/manpages/noble/en/man8/ss.8.html) |
| `openssl` | [openssl](https://www.openssl.org/docs/manpages.html) |
| `tcpdump` | [tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html) |
| `htpasswd` / `ab` | [htpasswd](https://httpd.apache.org/docs/2.4/programs/htpasswd.html) · [ab](https://httpd.apache.org/docs/2.4/programs/ab.html) |

No `dig`. IP: `ip -4 addr`. DNS: `/etc/resolv.conf`. Resolve: `getent hosts github.com`. `ping`/`tcpdump` often need `NET_RAW` / `NET_ADMIN`.

### System / git / process

| Tool | Docs |
|---|---|
| `git` / `tig` | [git](https://git-scm.com/docs) · [tig](https://jonas.github.io/tig/doc/manual.html) — [SSH](#ssh-client-only--no-sshd) |
| `make` | [make](https://www.gnu.org/software/make/manual/make.html) |
| `envsubst` | [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) |
| `htop` | [htop](https://htop.dev/) |
| `lsof` | [lsof](https://manpages.ubuntu.com/manpages/noble/en/man8/lsof.8.html) |
| `killall` | [killall](https://manpages.ubuntu.com/manpages/noble/en/man1/killall.1.html) |
| `pv` | [pv](https://www.ivarch.com/programs/pv.shtml) |
| `sponge` | [sponge](https://manpages.ubuntu.com/manpages/noble/en/man1/sponge.1.html) |
| `uuidgen` | [uuidgen](https://manpages.ubuntu.com/manpages/noble/en/man1/uuidgen.1.html) |
| `getfacl` / `setfacl` | [getfacl](https://manpages.ubuntu.com/manpages/noble/en/man1/getfacl.1.html) |
| `getcap` / `setcap` | [setcap](https://manpages.ubuntu.com/manpages/noble/en/man8/setcap.8.html) |
| `inotifywait` | [inotifywait](https://manpages.ubuntu.com/manpages/noble/en/man1/inotifywait.1.html) |
| `entr` | [entr](https://eradman.com/entrproject/) |
| `strace` | [strace](https://man7.org/linux/man-pages/man1/strace.1.html) |
| `progress` | [progress](https://github.com/Xfennec/progress) |
| `tmux` | [tmux](https://github.com/tmux/tmux/wiki) |
| `keychain` | [keychain](https://www.funtoo.org/Funtoo:Keychain) |
| `sudo` | [sudo](https://www.sudo.ws/docs/man/sudo.man/) — [sudo in this image](#sudo) |

### Extras

| Tool | Docs |
|---|---|
| `fzf` | [fzf](https://github.com/junegunn/fzf) |
| `zoxide` | [zoxide](https://github.com/ajeetdsouza/zoxide) |
| `colordiff` | [colordiff](https://www.colordiff.org/) |
| `patch` | [patch](https://www.gnu.org/software/diffutils/manual/html_node/Invoking-patch.html) |

fzf keys (Ctrl-R / Ctrl-T / Alt-C) in interactive zsh/bash only. Tab stays native. dash: no fzf keys. `z` is zoxide.

### Image helpers (ours)

Not Ubuntu packages. `ssh`/`scp`/`sftp`/`git` on `PATH` wrap these — type the normal commands.

| Command | Docs |
|---|---|
| `add_text_to_zshrc` | [Scripts](#scripts-for-child-images) |
| `add_text_to_p10k` | [Scripts](#scripts-for-child-images) |
| `share_config_globally` | [Scripts](#scripts-for-child-images) |
| `sudo-password` | [sudo](#sudo) |
| `sudo-nopasswd` | [sudo](#sudo) |
| `ssh-from-host` | [SSH](#ssh-client-only--no-sshd) |
| `git-from-host` | [SSH](#ssh-client-only--no-sshd) |
| `dockerzsh` | [Catalogue](#catalogue-cli-dockerzsh) |

---

## 📏 Image size

| | Uncompressed (disk / `docker images`) | Compressed (Hub pull / layers) |
|---|---|---|
| `ubuntu:24.04` | ~78 MB | ~28 MB |
| Hub `zsh:v1.0.5` | ~205 MB | ~76 MB |
| `zsh:v2.0.0` | ~**249 MB** (`zsh-local:dev`) | Hub gzip layers |

v1.0.5 was zsh + eza/bat/git. v2.0.0 is a daily-driver kit without ICU/Python/`gnupg`/`7zip`. Ubuntu `git` still pulls **Perl**. Not shipped (child if needed): `xmllint`, `git-extras`, `file`, `7zip`, `gpg`, `expect`/Tcl, `dig`/`nslookup`, `iperf3`, `rlwrap`. `rsync` stays (C; no Python / `rrsync`). `docker images` is uncompressed; Hub pull is gzip. Oh My Zsh + p10k are in both 1.0.5 and 2.0.0.

---

## ▶️ How to run it

Two different jobs. Mix them up and it looks like “eza is broken”.

### 🖥️ Interactive prompt (eza, bat, p10k)

Needs a **TTY** (`-it` or `exec -it`).

```bash
docker run --rm -it cartagodocker/zsh:v2.0.0
docker run --rm -it --user 1000:1000 -w /home/ubuntu cartagodocker/zsh:v2.0.0
docker exec -it <container> zsh
```

`ls` → eza. `bat` works. p10k is the same **classic 2-line** wizard as v1.0.5 (`gitstatusd` baked at build). Starting in `/` shows a lock (`DIR_SHOW_WRITABLE`) for uid 1000 — use `-w /home/ubuntu` or bind the project. Inside zsh: `bash`, `sh`, `exit`. Interactive **bash**/**sh** also alias `ls`→eza (zoxide; bash gets fzf keys) — **no p10k**. `sh -c` / Dockerfile `RUN` load no aliases.

### 🧊 Keep-alive (Compose)

The container stays up **without** a shell. Typical:

```yaml
services:
  app:
    image: cartagodocker/zsh:v2.0.0
    command: ["tail", "-f", "/dev/null"]
    user: "1000:1000"
```

That process is **`tail`, not a shell**, and **not a TTY**. No prompt, no eza aliases, no p10k. Attach:

```bash
docker compose exec app zsh     # prompt + eza + bat + p10k
docker compose exec app bash
```

`docker run --rm image bash` and `docker run --rm image tail -f /dev/null` work — no ENTRYPOINT swallows the command.

---

## 🔐 sudo

Default **NOPASSWD** (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`). Global files (`/usr/share/globally/.zshrc`) are `644` root:root — uid `1000` cannot overwrite them. Use `sudo` or `add_text_to_zshrc` (NOPASSWD). Password is **not baked**; turn it on at runtime.

```bash
docker run --rm -it --user 1000:1000 cartagodocker/zsh:v2.0.0
# inside:
sudo -n id                 # default: no password

sudo-password              # TTY prompt (hidden); afterwards sudo asks
sudo-password 'secret'     # from arg (visible in `ps`)
SUDO_PASSWORD=secret sudo-password   # from env

sudo-password 'new-secret' # change it (needs the *current* sudo password
                           # once one is already required)
sudo-nopasswd              # back to NOPASSWD (needs the current password)
```

At start (first interactive/login shell via `apply-sudo-password-on-boot.sh`):

```bash
docker run --rm -it -e SUDO_PASSWORD=secret cartagodocker/zsh:v2.0.0
```

As uid 1000: NOPASSWD (default) escalates with `sudo -n`. Once a password is on, the helper uses `sudo` — type the **current** password, then it sets the new one (or drops it).

`sudo-password` writes `/etc/container-sudo-password`, switches sudoers `NOPASSWD:ALL` → `ALL`, and `chpasswd`s every login user. Changing it overwrites that file and re-runs `chpasswd`. `sudo -k` drops the ticket cache. Compose `user: "1000:1000"` drops extra groups, so the rule is `ALL`, not `%sudo`.

---

## 🎨 Fonts and icons

The **container only emits Unicode**. The **host terminal** draws glyphs.

| | What | Needs on the host |
|---|---|---|
| 🔷 | Powerlevel10k separators, git icons, eza file icons | A [Nerd Font](https://www.nerdfonts.com/font-downloads) (CaskaydiaCove / Cascadia Code NF) |
| 🐳 | Prompt whale (`os_icon`) | An **emoji** font — Segoe UI Emoji (Windows), Apple Color Emoji (macOS), Noto Color Emoji (Linux). Some Linux terminals have none → tofu. Same Unicode; the font is local. |

VS Code:

```json
"terminal.integrated.fontFamily": "'Cascadia Code NF', 'CaskaydiaCove Nerd Font', Consolas, monospace"
```

Without a Nerd Font you get boxes on powerline / `ls` icons — not an image bug. No in-image fallback still looks like p10k.

---

## 🧩 Scripts for child images

All write `/usr/share/globally/...` (every user). `sudo` if needed.

### `add_text_to_zshrc`

```bash
add_text_to_zshrc "alias hello='echo hi'"
add_text_to_zshrc "alias hello='echo hi'" --prepend
add_text_to_zshrc "$(printf '%s\n' \
    'alias hello="echo hi"' \
    'alias bye="echo bye"')"
```

```dockerfile
FROM cartagodocker/zsh:v2.0.0
RUN add_text_to_zshrc "$(printf '%s\n' \
    'alias hello="echo hi"')"
```

### `add_text_to_p10k`

Same CLI, writes `.p10k.zsh`.

```bash
add_text_to_p10k "typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose"
```

### `share_config_globally`

Move a path from a user home (default `/root`) to `/usr/share/<name>` and symlink it for `/root`, `/home/*`, `/etc/skel`.

```bash
share_config_globally .local/share/fnm
share_config_globally .oh-my-zsh --to globally/.oh-my-zsh --permissions 755
```

`--permissions` default `755`. Use `777` only when every uid must write the shared tree (package caches).

---

## 🔑 SSH (client only — no sshd)

`openssh-client` is installed. Bind host `~/.ssh` and type `ssh` / `git`. Root or any uid — one volume.

```yaml
services:
  dev:
    image: cartagodocker/zsh:v2.0.0
    volumes:
      - ~/.ssh:/${USER}/.ssh:ro
      - ~/.gitconfig:/${USER}/.gitconfig:ro
```

```bash
docker run --rm -it \
  -v "$HOME/.ssh:/$USER/.ssh:ro" \
  -v "$HOME/.gitconfig:/$USER/.gitconfig:ro" \
  cartagodocker/zsh:v2.0.0
# inside: ssh git@github.com
#         git commit   # author = host user.name, not ubuntu@id
```

`${USER}` is the **host** name. Docker needs an **absolute** target (`/${USER}/.ssh` → `/cartago/.ssh`), not `${USER}/.ssh` (not `$HOME` in the container). The client finds any bind ending in `.ssh` and copies keys to a uid-owned `700` dir (OpenSSH rejects `644`/`777` and cannot write `known_hosts` on `:ro`). Root or any uid.

**Git author is not the SSH key.** `git pull`/`push` use the key; `git commit` needs `user.name` + `user.email`. Bind host `~/.gitconfig` (or `GIT_AUTHOR_NAME` + `GIT_AUTHOR_EMAIL`). Any absolute path ending in `.gitconfig` works. Without it, `git commit` says identity is required and exits `1` — no invented `ubuntu@<container>`.

Missing keys: `ssh`/`scp`/`sftp` print **keys are required** (bind example; another directory is fine), then OpenSSH still runs.

**`known_hosts` is optional.** Binding `~/.ssh` brings the host file if present.

| Layer | Where | What |
|---|---|---|
| Official (baked) | `/usr/share/ssh/known_hosts` and `/etc/ssh/ssh_known_hosts` | GitHub / GitLab keys. `GlobalKnownHostsFile`. Same content twice so `/usr/bin/ssh` still trusts them if the wrapper is bypassed. |
| Your host file (if present) | copied / merged into `/tmp/container-ssh-<uid>/known_hosts` | Used as-is. New hosts (`accept-new`) append **there**, never on the `:ro` volume. Re-runs merge new lines and keep container-learned hosts. |

Without a host `known_hosts`, GitHub / GitLab still work from the baked file. Other hosts are learned on first connect and stay in `/tmp` for this container.

**Agent** (key never enters the container) still works if you already use one:

```bash
docker run --rm -it \
  -v "$SSH_AUTH_SOCK":/ssh-agent \
  -e SSH_AUTH_SOCK=/ssh-agent \
  cartagodocker/zsh:v2.0.0
```

Not SSH-into-the-container. Attach: `docker exec -it … zsh`.

---

## 📖 Catalogue CLI (`dockerzsh`)

In-container **`dockerzsh`** catalogues every tool and helper — not the host `docker` CLI.

```bash
docker run --rm cartagodocker/zsh:v2.0.0 dockerzsh --help
docker compose exec app dockerzsh --help
```

The full dump is long on purpose. Filter by **section**:

```bash
dockerzsh --sections | -s       # list ids
dockerzsh --shells              # one section
dockerzsh --plugins             # Oh My Zsh plugins (interactive zsh)
dockerzsh shells                # same (flag or bare id)
dockerzsh --section shells      # same
dockerzsh shells network        # several sections
dockerzsh --version | -v        # image identity (ZSH_IMAGE_VERSION)
dockerzsh --list | -l           # tool names
dockerzsh --list --version | -l -v   # probe every catalogue tool now
dockerzsh shells --version | shells -v
dockerzsh eza --version | eza -v
```

| Id | Section (every tool — same list as [Utilities](#utilities)) |
|---|---|
| `about` | What this image is (CMD, no ENTRYPOINT, TTY vs keep-alive) |
| `usage` | How to invoke `dockerzsh` |
| `shells` | `zsh`, `bash`, `sh` |
| `plugins` | Oh My Zsh plugins (interactive zsh only) — [Utilities](#utilities) |
| `listing` | `eza`, `bat`, `fd`, `rg`, `less`, `tree`, `nnn`, `ncdu`, `duf` |
| `edit` | `nano`, `vi`, `jq`, `jo`, `sqlite3`, `hexdump`/`xxd`, `bc`, `column` |
| `archives` | `unzip`/`zip`, `tar`/`gzip`, `xz`, `bzip2`, `zstd`, `lz4`, `pigz`, `cpio`, `cabextract`, `extract`/`x`, `uchardet`, `dos2unix` |
| `network` | `curl`/`wget`, `ssh`/`scp`/`sftp`, `ping`, `tracepath`, `fping`, `whois`, `mtr`, `traceroute`, `rsync`, `nc`, `socat`, `ip`/`ss`, `openssl`, `tcpdump`, `htpasswd`/`ab` |
| `system` | `git`/`tig`, `make`, `envsubst`, `htop`, `lsof`, `killall`, `pv`, `sponge`, `uuidgen`, `getfacl`/`setfacl`, `getcap`/`setcap`, `inotifywait`, `entr`, `strace`, `progress`, `tmux`, `keychain`, `sudo` |
| `extras` | `fzf`, `zoxide`, `colordiff`, `patch` |
| `helpers` | `add_text_to_zshrc`, `add_text_to_p10k`, `share_config_globally`, `sudo-password`, `sudo-nopasswd`, `git-from-host`, `dockerzsh` |
| `fonts` | Host fonts + what is **not** in this image |

Unknown ids exit `2` (`--sections`). `--shells` and `shells` are the same id (`listing` also accepts `--ls`).

---

## 🚀 Build and publish

```bash
docker build --build-arg VERSION=2.0.0 -t zsh-local:dev -f ./Dockerfile ./
```

GitHub Actions (secrets `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD`; variable `DOCKERHUB_REPO`):

| Trigger | What happens |
|---|---|
| Git tag `v*` | Build + push `cartagodocker/zsh:<tag>` if new (skip if it exists). Create/replace a GitHub Release. No Hub `:latest`. — [docker-hub-update.yml](./.github/workflows/docker-hub-update.yml) |
| Push to `main` that changes `README.md` | Hub long description (`full_description` ≤ ~25 000 chars) — [update-dockerhub-description.yml](./.github/workflows/update-dockerhub-description.yml) |

See [CHANGELOG.md](./CHANGELOG.md).
