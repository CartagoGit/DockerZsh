# 🐳 cartagodocker/zsh

Ubuntu **24.04 LTS** with **zsh** as the default interactive shell — Oh My Zsh, Powerlevel10k, eza, bat, git, and passwordless sudo.

Base image for others (for example [`cartagodocker/nodebun`](https://hub.docker.com/r/cartagodocker/nodebun)). Root, uid `1000` (`ubuntu`), and later `useradd -m` users share the same `.zshrc` / `.p10k.zsh` / Oh My Zsh via `/usr/share/globally`.

The [nodebun README](https://github.com/CartagoGit/DockerNodeBun#readme) uses the **same section order**. This page is the contract for the shell base; NodeBun only documents runtimes it adds.

| | |
|---|---|
| 📦 GitHub | https://github.com/CartagoGit/DockerZsh |
| 🐋 Docker Hub | https://hub.docker.com/r/cartagodocker/zsh |
| 📝 Changelog | [CHANGELOG.md](./CHANGELOG.md) |

Pin a **version tag**. Do not use `latest` in production Dockerfiles.

```dockerfile
FROM cartagodocker/zsh:v2.0.0
```

Pin **`v2.0.0`**. There is no `latest`.

---

## 📦 What's in the image

| | Piece | Notes |
|---|---|---|
| 🐧 | OS | Ubuntu 24.04 LTS (Noble) |
| 🐚 | Interactive shell | zsh + Oh My Zsh + Powerlevel10k — `CMD ["/usr/bin/zsh"]` |
| 💻 | Other shells | `bash` and `sh` (dash) stay installed |
| 📂 | Listing / pager | `eza` (`ls`), `bat`, GNU `find` + `fd`, `rg`, `less`, `tree`, `nnn`, `ncdu`, `duf` — [Utilities](#utilities) |
| 🧰 | Daily CLI | Full inventory (every extra binary + our helpers): [Utilities](#utilities) |
| 📖 | Catalogue | `dockerzsh --help` — same inventory inside the container (see [Catalogue CLI](#catalogue-cli-dockerzsh)) |
| 🌐 | Network | `curl`, `wget`, `git`, **`openssh-client`** (no sshd), **`ca-certificates`**, `ip`/`ss`, `socat`, `tcpdump` |
| 🔐 | sudo | NOPASSWD for every uid (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`) |
| 🌍 | Locale | `LANG=C.UTF-8` · `LC_ALL=C.UTF-8` |
| 🧱 | Build `SHELL` | `["/bin/sh", "-c"]` — child `RUN` lines are POSIX, not zsh |

There is **no** `openssh-server`. There is **no** `ENTRYPOINT`: the process you pass to `docker run` / Compose `command:` is what runs.

**Not in this image** (keep it a shell base): `gcc`/`g++`, `python3`, `neovim`, `git-lfs`, `rclone`, `locales`, `man-db`, `nmap`, `file`, `7zip`, `xmllint`, `git-extras`, `gpg`/`gnupg`, `expect`/Tcl, `dig`/`nslookup` (`bind9-dnsutils` / `libicu`), `iperf3`, `rlwrap`, **no sshd**, **no Docker** (`dockerd` / `docker` CLI). Put those — or a Docker client — in a child image. Drive this container with `docker` on the **host**. Commit signing / `git-extras` belong on the host or in a child.

Container IP: `ip -4 addr`. DNS in use: `/etc/resolv.conf`. Resolve a name: `getent hosts github.com` (same resolver as `curl`/`git`).

The daily CLI is the set in [Utilities](#utilities) (`fd`, `rg`, `fzf`, `jq`, `unzip`, `tmux`, and the rest of that table). Extra toys (`tcpdump`, `htpasswd`) stay because they are small. Do **not** add `git-lfs`, `rclone`, `neovim`, or a Docker client here.

---

## 🧰 Utilities

This page is the contract for people **using** the image. Every extra CLI we install is in the tables below (Ubuntu 24.04 already has `cp`, `mv`, `grep`, `awk`, `sed`, `find`, `top`, … — those are not repeated).

Upstream tools: one-line what-it-is + a docs link. **Our** helpers (`add_text_to_zshrc`, `sudo-password`, …) are documented in this README — do not look for an Ubuntu man page.

Inside a running container the same inventory is `dockerzsh --help` (filter with `dockerzsh --listing`, `dockerzsh --helpers`, …).

### Shells

| Tool | What | Docs |
|---|---|---|
| `zsh` | Default interactive shell. Oh My Zsh + Powerlevel10k. This is `CMD`. | [zsh](https://zsh.sourceforge.io/Doc/) · [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) · [p10k](https://github.com/romkatv/powerlevel10k) |
| `bash` | GNU bash. `docker run IMAGE bash` or type `bash` inside zsh. | [manual](https://www.gnu.org/software/bash/manual/) |
| `sh` | POSIX sh (dash on Ubuntu). | [dash](https://manpages.ubuntu.com/manpages/noble/en/man1/dash.1.html) |

Oh My Zsh plugins in the image: `git`, `extract` (`extract` / `x`), `sudo`, `zsh-autosuggestions`, `zsh-completions`, `zsh-syntax-highlighting`, `zsh-bat`.

### Listing / viewing

| Tool | What | Docs |
|---|---|---|
| `eza` | Modern `ls` (colours, git, icons). Aliased as `ls` in interactive zsh. GNU `ls` stays `/usr/bin/ls`. | [eza](https://github.com/eza-community/eza) |
| `bat` | Syntax-highlighting `cat`. Debian name is `batcat`; `/usr/local/bin/bat` → `batcat`. | [bat](https://github.com/sharkdp/bat) |
| `fd` | Fast `find` (Debian name `fdfind`). GNU `find` stays `find`. | [fd](https://github.com/sharkdp/fd) |
| `rg` | Fast recursive grep (ripgrep). Honours `.gitignore`. | [ripgrep](https://github.com/BurntSushi/ripgrep) |
| `less` | Pager (`git log` / `git diff`). `q` to quit. | [less](https://www.greenwoodsoftware.com/less/) |
| `tree` | Directory tree. `eza --tree` is the colour alternative. | [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree) |
| `nnn` | Terminal file manager. | [nnn](https://github.com/jarun/nnn) |
| `ncdu` | Interactive disk usage. | [ncdu](https://dev.yorhel.nl/ncdu) |
| `duf` | Colourful `df`. | [duf](https://github.com/muesli/duf) |

### Edit / data

| Tool | What | Docs |
|---|---|---|
| `nano` | Small terminal editor. Ctrl+O save, Ctrl+X quit. | [nano](https://www.nano-editor.org/dist/latest/nano.html) |
| `vi` | `vim-tiny`. Not neovim (put that in a child). | [vim.tiny](https://manpages.ubuntu.com/manpages/noble/en/man1/vim.tiny.1.html) |
| `jq` | Query / transform JSON. | [jq manual](https://jqlang.github.io/jq/manual/) |
| `jo` | Build JSON from arguments. | [jo](https://github.com/jpmens/jo) |
| `sqlite3` | SQLite CLI. | [sqlite3](https://www.sqlite.org/cli.html) |
| `hexdump` / `xxd` | Dump file bytes. `xxd -r` reverses a dump. | [hexdump](https://manpages.ubuntu.com/manpages/noble/en/man1/hexdump.1.html) · [xxd](https://manpages.ubuntu.com/manpages/noble/en/man1/xxd.1.html) |
| `bc` | Arbitrary-precision calculator. | [bc](https://www.gnu.org/software/bc/manual/html_mono/bc.html) |
| `column` | Align columns (`bsdextrautils`). | [column](https://manpages.ubuntu.com/manpages/noble/en/man1/column.1.html) |

### Archives / text

| Tool | What | Docs |
|---|---|---|
| `unzip` / `zip` | zip archives. | [unzip](https://manpages.ubuntu.com/manpages/noble/en/man1/unzip.1.html) · [zip](https://manpages.ubuntu.com/manpages/noble/en/man1/zip.1.html) |
| `tar` / `gzip` | From Ubuntu. `tar -xzf archive.tar.gz`. | [tar](https://www.gnu.org/software/tar/manual/) · [gzip](https://www.gnu.org/software/gzip/manual/gzip.html) |
| `xz` | `.xz` / `.lzma`. | [xz](https://tukaani.org/xz/) |
| `bzip2` | `.bz2`. | [bzip2](https://sourceware.org/bzip2/manual/manual.html) |
| `zstd` | `.zst`. | [zstd](https://github.com/facebook/zstd) |
| `lz4` | `.lz4`. | [lz4](https://github.com/lz4/lz4) |
| `pigz` | Parallel gzip. | [pigz](https://zlib.net/pigz/) |
| `cpio` | cpio archives. | [cpio](https://www.gnu.org/software/cpio/manual/) |
| `cabextract` | Windows `.cab`. | [cabextract](https://www.cabextract.org.uk/) |
| `extract` / `x` | Oh My Zsh helper: picks unzip/tar/zstd from the extension. | [extract plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/extract) |
| `uchardet` | Detect text encoding. | [uchardet](https://www.freedesktop.org/wiki/Software/uchardet/) |
| `dos2unix` | CRLF → LF (Windows bind mounts). | [dos2unix](https://waterlan.home.xs4all.nl/dos2unix.html) |

### Network

| Tool | What | Docs |
|---|---|---|
| `curl` / `wget` | HTTP(S). `ca-certificates` is installed. | [curl](https://curl.se/docs/manpage.html) · [wget](https://www.gnu.org/software/wget/manual/wget.html) |
| `ssh` / `scp` / `sftp` | OpenSSH **client** only (no sshd). Bind host `~/.ssh` — [SSH](#ssh-client-only--no-sshd). | [ssh](https://man.openbsd.org/ssh.1) |
| `ping` | ICMP. Often needs `--cap-add NET_RAW`. | [ping](https://manpages.ubuntu.com/manpages/noble/en/man8/ping.8.html) |
| `tracepath` | Path MTU without root. | [tracepath](https://manpages.ubuntu.com/manpages/noble/en/man8/tracepath.8.html) |
| `fping` | Fast multi-host ping. | [fping](https://fping.org/) |
| `whois` | WHOIS. | [whois](https://manpages.ubuntu.com/manpages/noble/en/man1/whois.1.html) |
| `mtr` | traceroute + ping TUI (`mtr-tiny`). | [mtr](https://www.bitwizard.nl/mtr/) |
| `traceroute` | Classic traceroute. | [traceroute](https://manpages.ubuntu.com/manpages/noble/en/man8/traceroute.8.html) |
| `rsync` | Copy trees over ssh or locally. | [rsync](https://download.samba.org/pub/rsync/rsync.1) |
| `nc` | netcat (`netcat-openbsd`). | [nc](https://man.openbsd.org/nc.1) |
| `socat` | Bidirectional relay (unix sockets, TLS, exec). | [socat](http://www.dest-unreach.org/socat/doc/socat.html) |
| `ip` / `ss` | iproute2. Container IP: `ip -4 addr`. DNS: `/etc/resolv.conf`. Resolve: `getent hosts github.com` (no `dig`). | [ip](https://manpages.ubuntu.com/manpages/noble/en/man8/ip.8.html) · [ss](https://manpages.ubuntu.com/manpages/noble/en/man8/ss.8.html) |
| `openssl` | TLS, certs, digests. `openssl s_client -connect host:443`. | [openssl](https://www.openssl.org/docs/manpages.html) |
| `tcpdump` | Packet capture. Usually needs `NET_RAW` / `NET_ADMIN`. | [tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html) |
| `htpasswd` / `ab` | apache2-utils: basic-auth files; tiny HTTP bench. | [htpasswd](https://httpd.apache.org/docs/2.4/programs/htpasswd.html) · [ab](https://httpd.apache.org/docs/2.4/programs/ab.html) |

### System / git / process

| Tool | What | Docs |
|---|---|---|
| `git` / `tig` | git + TUI. SSH remotes: [SSH](#ssh-client-only--no-sshd). Commits need `user.name` / `user.email` (bind `~/.gitconfig`). | [git](https://git-scm.com/docs) · [tig](https://jonas.github.io/tig/doc/manual.html) |
| `make` | GNU make. No `gcc`/`g++` in this image. | [make](https://www.gnu.org/software/make/manual/make.html) |
| `envsubst` | Expand `$VARS` in files (`gettext-base`). | [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) |
| `htop` | Interactive process viewer (`top` is already in Ubuntu). | [htop](https://htop.dev/) |
| `lsof` | Open files / sockets. `lsof -i :3000`. | [lsof](https://manpages.ubuntu.com/manpages/noble/en/man8/lsof.8.html) |
| `killall` | Kill by name (`psmisc`). Also `pstree`, `fuser`. | [killall](https://manpages.ubuntu.com/manpages/noble/en/man1/killall.1.html) |
| `pv` | Pipe progress. | [pv](https://www.ivarch.com/programs/pv.shtml) |
| `sponge` | moreutils: write a file only after stdin ends. | [sponge](https://manpages.ubuntu.com/manpages/noble/en/man1/sponge.1.html) |
| `uuidgen` | Generate UUIDs. | [uuidgen](https://manpages.ubuntu.com/manpages/noble/en/man1/uuidgen.1.html) |
| `getfacl` / `setfacl` | POSIX ACLs. | [getfacl](https://manpages.ubuntu.com/manpages/noble/en/man1/getfacl.1.html) |
| `getcap` / `setcap` | File capabilities (`libcap2-bin`). | [setcap](https://manpages.ubuntu.com/manpages/noble/en/man8/setcap.8.html) |
| `inotifywait` | Watch files (`inotify-tools`). | [inotifywait](https://manpages.ubuntu.com/manpages/noble/en/man1/inotifywait.1.html) |
| `entr` | Run a command when files change. | [entr](https://eradman.com/entrproject/) |
| `strace` | Trace syscalls. | [strace](https://man7.org/linux/man-pages/man1/strace.1.html) |
| `progress` | Progress of an already-running `cp`/`mv`/`dd`. | [progress](https://github.com/Xfennec/progress) |
| `tmux` | Terminal multiplexer. | [tmux](https://github.com/tmux/tmux/wiki) |
| `keychain` | ssh-agent helper across shells. | [keychain](https://www.funtoo.org/Funtoo:Keychain) |
| `sudo` | Passwordless by default. Opt-in password: [sudo](#sudo). | [sudo](https://www.sudo.ws/docs/man/sudo.man/) |

### Extras

| Tool | What | Docs |
|---|---|---|
| `fzf` | Fuzzy finder. Interactive zsh: Ctrl-R / Ctrl-T / Alt-C. Also a pipe filter. | [fzf](https://github.com/junegunn/fzf) |
| `zoxide` | Smarter `cd`; command is `z`. | [zoxide](https://github.com/ajeetdsouza/zoxide) |
| `colordiff` | Colourful `diff`. | [colordiff](https://www.colordiff.org/) |
| `patch` | Apply unified diffs. | [patch](https://www.gnu.org/software/diffutils/manual/html_node/Invoking-patch.html) |

### Image helpers (ours — usage in this README)

These are not Ubuntu packages. Full CLI: [Scripts for child images](#scripts-for-child-images) and [sudo](#sudo). Catalogue: `dockerzsh --helpers`.

| Command | What |
|---|---|
| `add_text_to_zshrc` | Append/prepend to the shared `/usr/share/globally/.zshrc`. |
| `add_text_to_p10k` | Same, writes `.p10k.zsh`. |
| `share_config_globally` | Move a path into `/usr/share` and symlink it for every home + `/etc/skel`. |
| `sudo-password` | Require (or change) a sudo password at runtime. |
| `sudo-nopasswd` | Back to NOPASSWD. |
| `ssh-from-host` | Copy host SSH keys into a uid-owned `700` dir. Also runs from zshrc / `ssh`. You do not type this. |
| `git-from-host` | Import host `user.name` / `user.email`. Also runs from zshrc / `git`. You do not type this. |
| `dockerzsh` | This image’s catalogue CLI. |

`ssh` / `scp` / `sftp` / `git` on `PATH` are thin wrappers (`ssh-wrap` / `git-wrap`) around those helpers. Type the normal commands.

---

## 📏 Image size

| | Uncompressed (disk / `docker images`) | Compressed (Hub pull / layers) |
|---|---|---|
| `ubuntu:24.04` | ~78 MB | ~28 MB |
| Hub `zsh:v1.0.5` | ~205 MB | ~76 MB |
| `zsh:v2.0.0` | ~**249 MB** (`zsh-local:dev`) | Hub gzip layers |

v1.0.5 was zsh + eza/bat/git and little else. v2.0.0 adds a daily-driver kit without ICU/Python/`gnupg`/`7zip`. Ubuntu `git` still pulls **Perl**.

Not shipped (child image if needed): `xmllint`, `git-extras`, `file`, `7zip`, `gpg`, `expect`/Tcl, `dig`/`nslookup`, `iperf3`, `rlwrap`. `rsync` stays (C binary; no Python / `rrsync`).

`docker images` is uncompressed. Hub pull is gzip layers (smaller). Oh My Zsh + p10k clones are in both 1.0.5 and 2.0.0.

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

`ls` → eza with icons/colors. `bat` works. Powerlevel10k is the same
**classic 2-line** wizard as v1.0.5 (`gitstatusd` is baked at build, so
the first prompt does not fetch it). Starting in `/` shows a lock icon
(`DIR_SHOW_WRITABLE`) because `/` is not writable for uid 1000 — use
`-w /home/ubuntu` or bind your project. Inside zsh you can still
`bash`, `sh`, `exit`.

### 🧊 Keep-alive (Compose)

The container stays up **without** a shell. Typical:

```yaml
services:
  app:
    image: cartagodocker/zsh:v2.0.0
    command: ["tail", "-f", "/dev/null"]
    user: "1000:1000"
```

That process is **`tail`, not zsh**, and **not a TTY**. No prompt, no eza aliases, no p10k. Attach when you want the shell:

```bash
docker compose exec app zsh     # prompt + eza + bat + p10k
docker compose exec app bash
```

`docker run --rm image bash` and `docker run --rm image tail -f /dev/null` work because there is no ENTRYPOINT swallowing the command.

---

## 🔐 sudo

Default is **NOPASSWD** (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`). Global files
(`/usr/share/globally/.zshrc`) are `644` root:root. uid `1000` cannot
overwrite them directly — that is intentional. Use `sudo` or
`add_text_to_zshrc` (it escalates with NOPASSWD).

The password is **not baked** into the image. You turn it on at runtime.

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

At start (first interactive/login shell applies it via
`apply-sudo-password-on-boot.sh`):

```bash
docker run --rm -it -e SUDO_PASSWORD=secret cartagodocker/zsh:v2.0.0
```

How it works as uid 1000:

| State | `sudo-password` / `sudo-nopasswd` |
|---|---|
| NOPASSWD (default) | Escalates with `sudo -n` (no prompt). |
| Password already on | Escalates with `sudo` — type the **current** password, then the helper sets the new one (or drops it). |

`sudo-password` writes `/etc/container-sudo-password`, switches sudoers
from `NOPASSWD:ALL` to `ALL`, and `chpasswd`s every login user. Changing
the password overwrites that file and re-runs `chpasswd`. `sudo -k`
clears sudo’s ticket cache if an old password still seems to work.

Compose `user: "1000:1000"` drops extra groups, so the sudoers rule is
`ALL`, not `%sudo`.

---

## 🎨 Fonts and icons

The **container only emits Unicode**. The **host terminal** draws glyphs.

| | What | Needs on the host |
|---|---|---|
| 🔷 | Powerlevel10k separators, git icons, eza file icons | A [Nerd Font](https://www.nerdfonts.com/font-downloads) (CaskaydiaCove / Cascadia Code NF) |
| 🐳 | Prompt whale (`os_icon`) | An **emoji** font — Segoe UI Emoji (Windows), Apple Color Emoji (macOS), Noto Color Emoji (many Linux desktops). Some Linux terminals have none → tofu. Same Unicode everywhere; the font is local. |

VS Code:

```json
"terminal.integrated.fontFamily": "'Cascadia Code NF', 'CaskaydiaCove Nerd Font', Consolas, monospace"
```

Without a Nerd Font you get boxes on powerline / `ls` icons. That is not an image bug. There is no in-image fallback that still looks like p10k.

---

## 🧩 Scripts for child images

All write `/usr/share/globally/...` (every user). They `sudo` if needed.

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

Move something from a user home (default `/root`) to `/usr/share/<name>` and symlink it for `/root`, `/home/*`, `/etc/skel`.

```bash
share_config_globally .local/share/fnm
share_config_globally .oh-my-zsh --to globally/.oh-my-zsh --permissions 755
```

`--permissions` default is `755`. Use `777` only when every uid must write the shared tree (package caches, etc.).

---

## 🔑 SSH (client only — no sshd)

`openssh-client` is installed. Bind-mount host `~/.ssh` and type `ssh` / `git`. Root or any uid — one volume is enough.

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

`${USER}` is the **host** name. Docker needs an **absolute** target (`/${USER}/.ssh` → `/cartago/.ssh`), not `${USER}/.ssh`. That path is not `$HOME` in the container. The client finds any bind ending in `.ssh`, copies keys to a `700` dir this uid owns (OpenSSH rejects `644`/`777` and cannot write `known_hosts` on `:ro`), and `ssh`/`git` just work as root or as any other user.

**Git author is not the SSH key.** `git pull` / `git push` use the key. `git commit` needs `user.name` + `user.email`. Bind host `~/.gitconfig` the same way (or set `GIT_AUTHOR_NAME` + `GIT_AUTHOR_EMAIL`). The container path can be any absolute folder (`/${USER}/.gitconfig`, `/mnt/host-gitconfig`, …) as long as it ends in `.gitconfig`. Without that, `git commit` says identity is required (with an example) and exits `1` instead of inventing `ubuntu@<container>`.

Missing SSH keys: `ssh`/`scp`/`sftp` print that **keys are required**, with the usual bind example and a note that another directory is fine, then OpenSSH still runs.

**`known_hosts` — bringing the host file is optional, not required:**

The bind is the whole `~/.ssh` directory, so if the host has `known_hosts` it comes in with the keys. That is expected.

| Layer | Where | What |
|---|---|---|
| Official (baked) | `/usr/share/ssh/known_hosts` and `/etc/ssh/ssh_known_hosts` | GitHub / GitLab host keys. `GlobalKnownHostsFile`. Same content twice so `/usr/bin/ssh` still trusts them if someone bypasses the wrapper. |
| Your host file (if present) | copied / merged into `/tmp/container-ssh-<uid>/known_hosts` | Used as-is. New hosts (`accept-new`) are appended **there**, never on the `:ro` volume. Re-runs merge new host lines and keep container-learned hosts. |

Without a host `known_hosts`, GitHub / GitLab still work from the baked file. Other hosts are learned on first connect and stay in `/tmp` for this container lifetime.

**Agent** (key never enters the container) still works if you already use one:

```bash
docker run --rm -it \
  -v "$SSH_AUTH_SOCK":/ssh-agent \
  -e SSH_AUTH_SOCK=/ssh-agent \
  cartagodocker/zsh:v2.0.0
```

This is not SSH-into-the-container. Attach from the host: `docker exec -it … zsh`.

---

## 📖 Catalogue CLI (`dockerzsh`)

Inside a running container this image ships **`dockerzsh`**: a catalogue of every tool and helper, not the host `docker` CLI.

```bash
docker run --rm cartagodocker/zsh:v2.0.0 dockerzsh --help
docker compose exec app dockerzsh --help
```

The full dump is long on purpose (what each tool does, typical invocation, image caveats). Filter by **section**:

```bash
dockerzsh --sections | -s       # list ids
dockerzsh --shells              # one section
dockerzsh shells                # same (flag or bare id)
dockerzsh --section shells      # same
dockerzsh shells network        # several sections
dockerzsh --version | -v        # image identity (ZSH_IMAGE_VERSION)
dockerzsh --list | -l           # tool names from the catalogue
dockerzsh --list --version | -l -v
                                # probe every catalogue tool now
dockerzsh shells --version | shells -v
dockerzsh eza --version | eza -v
```

| Id | Section (every tool — same list as [Utilities](#utilities)) |
|---|---|
| `about` | What this image is (CMD, no ENTRYPOINT, TTY vs keep-alive) |
| `usage` | How to invoke `dockerzsh` |
| `shells` | `zsh`, `bash`, `sh` |
| `listing` | `eza`, `bat`, `fd`, `rg`, `less`, `tree`, `nnn`, `ncdu`, `duf` |
| `edit` | `nano`, `vi`, `jq`, `jo`, `sqlite3`, `hexdump`/`xxd`, `bc`, `column` |
| `archives` | `unzip`/`zip`, `tar`/`gzip`, `xz`, `bzip2`, `zstd`, `lz4`, `pigz`, `cpio`, `cabextract`, `extract`/`x`, `uchardet`, `dos2unix` |
| `network` | `curl`/`wget`, `ssh`/`scp`/`sftp`, `ping`, `tracepath`, `fping`, `whois`, `mtr`, `traceroute`, `rsync`, `nc`, `socat`, `ip`/`ss`, `openssl`, `tcpdump`, `htpasswd`/`ab` |
| `system` | `git`/`tig`, `make`, `envsubst`, `htop`, `lsof`, `killall`, `pv`, `sponge`, `uuidgen`, `getfacl`/`setfacl`, `getcap`/`setcap`, `inotifywait`, `entr`, `strace`, `progress`, `tmux`, `keychain`, `sudo` |
| `extras` | `fzf`, `zoxide`, `colordiff`, `patch` |
| `helpers` | `add_text_to_zshrc`, `add_text_to_p10k`, `share_config_globally`, `sudo-password`, `sudo-nopasswd`, `git-from-host`, `dockerzsh` |
| `fonts` | Host fonts + what is **not** in this image |

Unknown ids exit `2` and point at `--sections`. `--shells` and `shells` are the same id (`listing` also accepts `--ls`).

---

## 🚀 Build and publish

```bash
docker build --build-arg VERSION=2.0.0 -t zsh-local:dev -f ./Dockerfile ./
```

GitHub Actions (secrets `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD`; variable `DOCKERHUB_REPO`):

| Trigger | What happens |
|---|---|
| Git tag `v*` | Build + push `cartagodocker/zsh:<tag>` if that Hub tag is new (skip if it already exists). Create/replace a GitHub Release for the same tag. No Hub `:latest`. — [docker-hub-update.yml](./.github/workflows/docker-hub-update.yml) |
| Push to `main` that changes `README.md` | Docker Hub long description — [update-dockerhub-description.yml](./.github/workflows/update-dockerhub-description.yml) |

See [CHANGELOG.md](./CHANGELOG.md).
