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

> Hub still has **`v1.0.5`** until this tree is tagged `v2.0.0` and the workflow pushes. Pin `v2.0.0` once it is on Hub. There is no `latest`.

---

## 📦 What's in the image

| | Piece | Notes |
|---|---|---|
| 🐧 | OS | Ubuntu 24.04 LTS (Noble) |
| 🐚 | Interactive shell | zsh + Oh My Zsh + Powerlevel10k — `CMD ["/usr/bin/zsh"]` |
| 💻 | Other shells | `bash` and `sh` (dash) stay installed |
| 📂 | Listing / pager | `eza` (ls), `bat` (cat), GNU `find` + `fd`, `rg`, `nnn`, `ncdu`/`duf` |
| 🧰 | Daily CLI | archives, `jq`/`jo`/`sqlite3`, `ip`/`ss`/`openssl`, `tmux`, `make`, `vi`/`nano`, `fzf`/`zoxide` — see `dockerzsh --help` |
| 📖 | Catalogue | `dockerzsh --help` — lists every tool; filter with `dockerzsh --shells` (see [Catalogue CLI](#catalogue-cli-dockerzsh)) |
| 🌐 | Network | `curl`, `wget`, `git`, **`openssh-client`** (no sshd), **`ca-certificates`**, `ip`/`ss`, `socat`, `tcpdump` |
| 🔐 | sudo | NOPASSWD for every uid (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`) |
| 🌍 | Locale | `LANG=C.UTF-8` · `LC_ALL=C.UTF-8` |
| 🧱 | Build `SHELL` | `["/bin/sh", "-c"]` — child `RUN` lines are POSIX, not zsh |

There is **no** `openssh-server`. There is **no** `ENTRYPOINT`: the process you pass to `docker run` / Compose `command:` is what runs.

**Not in this image** (keep it a shell base): `gcc`/`g++`, `python3`, `neovim`, `git-lfs`, `rclone`, `locales`, `man-db`, `nmap`, `file`, `7zip`, `xmllint`, `git-extras`, `gpg`/`gnupg`, `expect`/Tcl, `dig`/`nslookup` (`bind9-dnsutils` / `libicu`), `iperf3`, `rlwrap`, **no sshd**, **no Docker** (`dockerd` / `docker` CLI). Put those — or a Docker client — in a child image. Drive this container with `docker` on the **host**. Commit signing / `git-extras` belong on the host or in a child.

Container IP: `ip -4 addr`. DNS in use: `/etc/resolv.conf`. Resolve a name: `getent hosts github.com` (same resolver as `curl`/`git`).

The daily CLI is already the useful set (`fd`/`rg`/`fzf`/`jq`/`unzip`/`tmux`/…). Extra toys (`tcpdump`/`htpasswd`) stay because they are small. Do **not** add `git-lfs`, `rclone`, `neovim`, or a Docker client here.

---

## 📏 Image size

| | Uncompressed (disk / `docker images`) | Compressed (Hub pull / layers) |
|---|---|---|
| `ubuntu:24.04` | ~78 MB | ~28 MB |
| Hub `zsh:v1.0.5` | ~205 MB | ~76 MB |
| This tree (`v2.0.0`) | ~**249 MB** (`zsh-local:dev`) | Hub gzip after first tag |

v1.0.5 was zsh + eza/bat/git and little else. v2.0.0 adds a daily-driver kit without ICU/Python/`gnupg`/`7zip`. Ubuntu `git` still pulls **Perl**.

Not shipped (child image if needed): `xmllint`, `git-extras`, `file`, `7zip`, `gpg`, `expect`/Tcl, `dig`/`nslookup`, `iperf3`, `rlwrap`. `rsync` stays (C binary; no Python / `rrsync`).

`docker images` is uncompressed. Hub pull is gzip layers (smaller). Oh My Zsh + p10k clones are in both 1.0.5 and 2.0.0.

Exact Hub compressed bytes for **v2.0.0** appear after the first tagged push.

---

## ▶️ How to run it

Two different jobs. Mix them up and it looks like “eza is broken”.

### 🖥️ Interactive prompt (eza, bat, p10k)

Needs a **TTY** (`-it` or `exec -it`).

```bash
docker run --rm -it cartagodocker/zsh:v2.0.0
docker run --rm -it --user 1000:1000 cartagodocker/zsh:v2.0.0
docker exec -it <container> zsh
```

`ls` → eza with icons/colors. `bat` works. Powerlevel10k draws the prompt. Inside zsh you can still `bash`, `sh`, `exit`.

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

| Id | Section |
|---|---|
| `about` | What this image is (CMD, no ENTRYPOINT, TTY vs keep-alive) |
| `usage` | How to invoke `dockerzsh` |
| `shells` | `zsh` / `bash` / `sh` |
| `listing` | `eza`, `bat`, `fd`, `rg`, `nnn`, `ncdu`, `duf`, … |
| `edit` | `nano`, `vi`, `jq`, `jo`, `sqlite3`, … |
| `archives` | zip/tar/`extract`, `dos2unix`, … |
| `network` | `curl`, `ssh`/`scp`/`sftp`, `ip`/`ss`, `socat`, … |
| `system` | `git`, `htop`, `tmux`, `sudo`, … |
| `extras` | `fzf`, `zoxide`, `colordiff`, `patch` |
| `helpers` | `add_text_to_zshrc`, `share_config_globally`, `sudo-password`, … |
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
| Git tag `v*` | Build + push `cartagodocker/zsh:<tag>` only. No `latest`. — [docker-hub-update.yml](./.github/workflows/docker-hub-update.yml) |
| Push to `main` that changes `README.md` | Docker Hub long description — [update-dockerhub-description.yml](./.github/workflows/update-dockerhub-description.yml) |

See [CHANGELOG.md](./CHANGELOG.md) for unreleased vs published tags.
