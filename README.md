# 🐳 cartagodocker/zsh

Ubuntu **24.04 LTS** with **zsh** as the default interactive shell — Oh My Zsh, Powerlevel10k, eza, bat, git, and passwordless sudo.

Base image for others (for example [`cartagodocker/nodebun`](https://hub.docker.com/r/cartagodocker/nodebun)). Root, uid `1000` (`ubuntu`), and later `useradd -m` users share the same `.zshrc` / `.p10k.zsh` / Oh My Zsh via `/usr/share/globally`.

| | |
|---|---|
| 📦 GitHub | https://github.com/CartagoGit/DockerZsh |
| 🐋 Docker Hub | https://hub.docker.com/r/cartagodocker/zsh |
| 📝 Changelog | [CHANGELOG.md](./CHANGELOG.md) |

Pin a **version tag**. Do not use `latest` in production Dockerfiles.

```dockerfile
FROM cartagodocker/zsh:v1.0.6
```

> Hub still has **`v1.0.5`** until this tree is tagged `v1.0.6` and the workflow pushes. Pin `v1.0.6` once it is on Hub.

---

## 📦 What's in the image

| | Piece | Notes |
|---|---|---|
| 🐧 | OS | Ubuntu 24.04 LTS (Noble) |
| 🐚 | Interactive shell | zsh + Oh My Zsh + Powerlevel10k — `CMD ["/usr/bin/zsh"]` |
| 💻 | Other shells | `bash` and `sh` (dash) stay installed |
| 📂 | Listing / pager | `eza` (ls), `bat` (cat), GNU `find` + `fd`, `rg`, `nnn`, `ncdu`/`duf` |
| 🧰 | Daily CLI | archives, `jq`/`jo`/`sqlite3`, `ip`/`ss`/`openssl`, `tmux`, `make`, `gpg`, `vi`/`nano`, `fzf`/`zoxide` — see `dockerzsh --help` |
| 📖 | Catalogue | `dockerzsh --help` — lists every tool; filter with `dockerzsh --shells` (see [Catalogue CLI](#catalogue-cli-dockerzsh)) |
| 🌐 | Network | `curl`, `wget`, `git`, **`openssh-client`** (no sshd), **`ca-certificates`**, `dig`, `socat`, `tcpdump` |
|  | sudo | NOPASSWD for every uid (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`) |
| 🌍 | Locale | `LANG=C.UTF-8` · `LC_ALL=C.UTF-8` |
| 🧱 | Build `SHELL` | `["/bin/sh", "-c"]` — child `RUN` lines are POSIX, not zsh |

There is **no** `openssh-server`. There is **no** `ENTRYPOINT`: the process you pass to `docker run` / Compose `command:` is what runs.

**Not in this image** (keep it a shell base): `gcc`/`g++`, `python3`, `neovim`, `git-lfs`, `rclone`, `locales`, `man-db`, `nmap`, **no sshd**, **no Docker CLI** (`docker-ce-cli` + compose is ~91 MiB installed). Put compilers in a child image. Use `docker` on the host.

---

## ▶️ How to run it

Two different jobs. Mix them up and it looks like “eza is broken”.

### 🖥️ Interactive prompt (eza, bat, p10k)

Needs a **TTY** (`-it` or `exec -it`).

```bash
docker run --rm -it cartagodocker/zsh:v1.0.6
docker run --rm -it --user 1000:1000 cartagodocker/zsh:v1.0.6
docker exec -it <container> zsh
```

`ls` → eza with icons/colors. `bat` works. Powerlevel10k draws the prompt. Inside zsh you can still `bash`, `sh`, `exit`.

### 🧊 Keep-alive (Compose)

The container stays up **without** a shell. Typical:

```yaml
services:
  app:
    image: cartagodocker/zsh:v1.0.6
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

Global files (`/usr/share/globally/.zshrc`) are `644` root:root. uid `1000` cannot overwrite them directly — that is intentional. Use `sudo` or `add_text_to_zshrc` (it escalates with NOPASSWD).

```bash
docker run --rm -it --user 1000:1000 cartagodocker/zsh:v1.0.6
# inside:
sudo -n id                 # default: no password
sudo-password              # prompt; afterwards sudo asks for it
sudo-password 'secret'     # from arg (visible in ps)
sudo-nopasswd              # back to NOPASSWD
```

Password at start (not baked into the image):

```bash
docker run --rm -it -e SUDO_PASSWORD=secret cartagodocker/zsh:v1.0.6
```

Compose `user: "1000:1000"` drops extra groups, so the sudoers rule is `ALL`, not `%sudo`.

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
FROM cartagodocker/zsh:v1.0.6
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
    image: cartagodocker/zsh:v1.0.6
    volumes:
      - ~/.ssh:/${USER}/.ssh:ro
```

```bash
docker run --rm -it \
  -v "$HOME/.ssh:/$USER/.ssh:ro" \
  cartagodocker/zsh:v1.0.6
# inside: ssh git@github.com
```

`${USER}` is the **host** name. Docker needs an **absolute** target (`/${USER}/.ssh` → `/cartago/.ssh`), not `${USER}/.ssh`. That path is not `$HOME` in the container. The client finds any bind ending in `.ssh`, copies keys to a `700` dir this uid owns (OpenSSH rejects `644`/`777` and cannot write `known_hosts` on `:ro`), and `ssh`/`git` just work as root or as any other user.

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
  cartagodocker/zsh:v1.0.6
```

This is not SSH-into-the-container. Attach from the host: `docker exec -it … zsh`.

---

## 📖 Catalogue CLI (`dockerzsh`)

Inside a running container this image ships **`dockerzsh`**: a catalogue of every tool and helper, not the host `docker` CLI.

```bash
docker run --rm cartagodocker/zsh:v1.0.6 dockerzsh --help
docker compose exec app dockerzsh --help
```

The full dump is long on purpose (what each tool does, typical invocation, image caveats). Filter by **section**:

```bash
dockerzsh --sections            # list ids
dockerzsh --shells              # one section
dockerzsh shells                # same (flag or bare id)
dockerzsh --section shells      # same
dockerzsh shells network        # several sections
dockerzsh --version             # VERSION + zsh --version
```

| Id | Section |
|---|---|
| `about` | What this image is (CMD, no ENTRYPOINT, TTY vs keep-alive) |
| `usage` | How to invoke `dockerzsh` |
| `shells` | `zsh` / `bash` / `sh` |
| `listing` | `eza`, `bat`, `fd`, `rg`, `nnn`, `ncdu`, `duf`, … |
| `edit` | `nano`, `vi`, `jq`, `jo`, `sqlite3`, … |
| `archives` | zip/tar/7z, `extract`, `dos2unix`, … |
| `network` | `curl`, `ssh`/`scp`/`sftp`, `dig`, `socat`, … |
| `system` | `git`, `htop`, `tmux`, `sudo`, … |
| `extras` | `fzf`, `zoxide`, `colordiff`, `patch` |
| `helpers` | `add_text_to_zshrc`, `share_config_globally`, `sudo-password`, … |
| `fonts` | Host fonts + what is **not** in this image |

Unknown ids exit `2` and point at `--sections`. `--shells` and `shells` are the same id (`listing` also accepts `--ls`).

---

## 🚀 Build and publish

```bash
docker build --build-arg VERSION=1.0.6 -t zsh-local:dev -f ./Dockerfile ./
```

GitHub Actions (secrets `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD`; variable `DOCKERHUB_REPO`):

| Trigger | What happens |
|---|---|
| Git tag `v*` | Build + push `cartagodocker/zsh:<tag>` and `:latest` — [docker-hub-update.yml](./.github/workflows/docker-hub-update.yml) |
| Push to `main` that changes `README.md` | Docker Hub long description — [update-dockerhub-description.yml](./.github/workflows/update-dockerhub-description.yml) |

See [CHANGELOG.md](./CHANGELOG.md) for unreleased vs published tags.
