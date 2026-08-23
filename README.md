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
| 📂 | Listing / pager | `eza` (ls), `bat` (cat), GNU `find` + `fd`, `rg` (ripgrep) |
| 🧰 | Small CLI | `less`, `file`, `jq`, `unzip`/`zip`/`xz`/`bzip2`, `tree`, `patch`, `nano`, `ping`, `dig`, `nc`, `rsync`, `htop`, `lsof`, `sqlite3`, `duf`, `fzf`, `zoxide` (`z`) |
| 📖 | Catalogue | `dockerzsh --help` — lists every tool this image ships |
| 🌐 | Network | `curl`, `wget`, `git`, `openssh-client`, **`ca-certificates`** |
| 🔐 | sudo | NOPASSWD for every uid (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`) |
| 🌍 | Locale | `LANG=C.UTF-8` · `LC_ALL=C.UTF-8` |
| 🧱 | Build `SHELL` | `["/bin/sh", "-c"]` — child `RUN` lines are POSIX, not zsh |

There is **no** `openssh-server`. There is **no** `ENTRYPOINT`: the process you pass to `docker run` / Compose `command:` is what runs.

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

## 🔑 SSH (git over SSH)

Client only. Mount keys from the host:

```bash
docker run --rm -it -v ~/.ssh:/root/.ssh:ro cartagodocker/zsh:v1.0.6
```

```yaml
services:
  dev:
    image: cartagodocker/zsh:v1.0.6
    volumes:
      - ~/.ssh:/root/.ssh:ro
```

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
