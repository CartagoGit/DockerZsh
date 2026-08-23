# DockerZsh — tracker de bugs (`FIXES.md`)

Documento **vivo**. Se borra cuando no queden bugs abiertos (ni docs
mentirosas). No es el README: el README describe el contrato publicado;
esto describe lo que **aún está mal** o **aún no está en Hub**.

| | |
|---|---|
| Working tree | **v2.0.0** (`ARG VERSION=2.0.0`) |
| Hub hoy | **`cartagodocker/zsh:v1.0.5`** (ene 2025, ~205 MB) |
| Tag git `v2.0.0` | **aún no** — no publicar hasta OK |
| Consumidor | NodeBun pinnea **`FROM cartagodocker/zsh:v2.0.0`**. Orden: Hub zsh 2.0.0 **antes** de construir NodeBun. |

Leyenda: `[ ]` abierto · `[x]` hecho en el árbol 2.0.0 · `[–]` no se hará.

---

## Relación con NodeBun (no mezclar versiones)

- **zsh 2.0.0** = este árbol. CMD, sin ENTRYPOINT, sudo, certs, UTF-8, CLI extras, `dockerzsh`.
- **NodeBun (unreleased)** pinnea **`FROM cartagodocker/zsh:v2.0.0`**. No se construye
  ni se publica hasta que 2.0.0 esté en Hub.
- Hub `v1.0.5` es inmutable. **No se retaggea.** Esta NodeBun no se construye sobre 1.0.5.
- Orden: tag+push zsh `v2.0.0` → smoke Hub → publicar NodeBun.

---

## Commits después de `v1.0.5` (qué rompió / qué arregló)

`git log v1.0.5..HEAD` (más el working tree sucio):

| Commit / árbol | Qué hizo | Efecto real |
|---|---|---|
| `c7ad3fd` *Añadimos zsh como variable SHELL* (ene 2025, **después** del tag v1.0.5, **antes** de publicarse de nuevo) | `ENV SHELL=zsh` (no es un path) | Hub `v1.0.5` inspect: `Entrypoint=["zsh"]` `Shell=["zsh","-c"]` `Env PATH only`. El `ENV SHELL=zsh` **no está** en la imagen de Hub: el tag se cortó en `40f6c1e`. Este commit **nunca se publicó**. |
| `94d6b0f` *fixes: enum some fixes…* (2026-08-23, en `main`) | Reescritura: clones pinneados, CMD, `SHELL sh`, sudo, certs, `share_config_globally`, workflows `GITHUB_ENV` | Arregla #1–#17, #23–#25 **en git**. **No está en Hub.** Quien `FROM zsh:v1.0.5` sigue con el Dockerfile viejo (`install.sh` de master, `\|\| true`, purge certs, ENTRYPOINT zsh, repo gierens, metapaquete `ssh`). |
| Working tree (sin commit) | `ARG VERSION=2.0.0`, CLI extras, `dockerzsh`, no `:latest`, Actions SHA, parsers | Contenido de **2.0.0**. Hasta el tag, Hub sigue siendo 1.0.5. |

**Conclusión:** los “fixes” recientes **no rompieron Hub** (Hub es 1.0.5, inmutable). NodeBun pinnea `FROM cartagodocker/zsh:v2.0.0`. El build de NodeBun espera a que 2.0.0 esté en Hub. No se retaggea 1.0.5.

El bug `ENTRYPOINT ["zsh"]` (`docker run img echo hello` → `can't open input file: echo`) es el Dockerfile **de 1.0.5**, no una regresión de 94d6b0f. 94d6b0f lo **arregla** en el árbol nuevo.

`ENV SHELL=zsh` de `c7ad3fd` era un path inválido; el árbol 2.0.0 usa `SHELL=/usr/bin/zsh`.

---

## Contrato 2.0.0 (no perder)

1. `docker run -it` → zsh + OMZ + p10k + eza/bat.
2. `docker run img bash` / `img sh` / `img tail -f /dev/null` **funcionan** (no ENTRYPOINT).
3. `RUN` de hijas en POSIX sh (`SHELL ["/bin/sh","-c"]`).
4. HTTPS (`ca-certificates`).
5. sudo NOPASSWD `ALL` (Compose `user: 1000:1000`). Globales `644`/`755`.
6. `LANG=C.UTF-8`. os_icon 🐳 (`🐳`); powerline/eza = Nerd Font **en el host**.
7. Helpers hijas: `add_text_to_zshrc`, `add_text_to_p10k`, `share_config_globally`.
8. `dockerzsh --help` lista lo que hay. `ZSH_IMAGE_VERSION` es el tag zsh si una hija pisa `VERSION`.
9. No `:latest` en Hub. Pin `v2.0.0`.

---

## Progreso

### Hecho en el árbol 2.0.0 (no en Hub v1.0.5)

| # | Ítem | Pri | Estado |
|---|---|---|---|
| 1 | No purgar `ca-certificates` | crítica | [x] |
| 2 | Quitar `\|\| true` ciego; `rm -rf /tmp/*` | crítica | [x] |
| 3 | `ENTRYPOINT` → `CMD ["/usr/bin/zsh"]`; `chsh` root/ubuntu | crítica | [x] |
| 4 | OMZ pinneado (no `install.sh` de master) | alta | [x] |
| 5 | eza del archive Ubuntu (no gierens) | alta | [x] |
| 6 | `bat` → `/usr/local/bin/bat` | crítica | [x] |
| 7 | Quitar plugin `fasd` (binario nunca instalado) | media | [x] |
| 8 | `.zshrc`: no auto-update OMZ, `EZA_COLORS`, zoxide init | alta | [x] |
| 9 | `share_config_globally`: `--to` antes del destino; `ln -sfn`; no `chown -R` | alta | [x] |
| 10 | Pins git (SHAs de v1.0.5, look estable) | media | [x] |
| 11 | Workflow Hub: `GITHUB_REF_NAME` → `$GITHUB_ENV` (el de v1.0.5 no expandía `${GITHUB_REF#…}` en `env:`) | media | [x] |
| 12 | `SHELL ["/bin/sh","-c"]` para hijas | crítica | [x] |
| 13 | `openssh-client` (no metapaquete `ssh`/sshd) | media | [x] |
| 14 | `add_text_to_*`: `--prepend` en cualquier posición; `printf` | media | [x] |
| 16 | `.dockerignore` | baja | [x] |
| 17 | README = contrato 2.0.0 (pin `v2.0.0`, nota Hub aún 1.0.5) | media | [x] |
| 18 | Workflow descripción Hub (JWT + `jq --rawfile`) | baja | [x] |
| 19 | Pin `ubuntu:24.04` por digest | baja | [–] | tag `24.04` para security updates al rebuild |
| 20 | uid 1000 login zsh | media | [x] (#3) |
| 21 | Adelgazar más | baja | [x] parcial |
| 23 | sudo NOPASSWD en **esta** imagen | crítica | [x] |
| 24 | `LANG=C.UTF-8` / `LC_ALL` | alta | [x] |
| 25 | os_icon whale emoji (no NF `U+F308`) | alta | [x] |
| 26 | `ARG VERSION=2.0.0` + `ENV VERSION` + `ZSH_IMAGE_VERSION` + `--build-arg` | media | [x] |
| 27 | CLI extras + `dockerzsh` | baja | [x] |
| 28 | `.gitignore` (estaba vacío) | baja | [x] |
| 30 | Workflow Hub pinneado a SHA | media | [x] |
| 31 | Workflow **no** publica `:latest` | media | [x] |
| 32 | `share_config_globally`: flags requieren valor | baja | [x] |
| 33 | `useradd` wrapper: LOGIN = leftover positional | baja | [x] |
| 34 | `fzf` key-bindings en `.zshrc` | baja | [x] |
| 35 | `known_hosts` baked + copia/merge del host en `/tmp` | media | [x] |
| 36 | Sin Docker dentro (ni CLI ni dockerd; hija si hace falta) | media | [x] |
| 37 | Identidad git del host (`git-from-host` / `git-wrap`) | media | [x] |

### Abiertos

| # | Ítem | Pri | Estado | Notas |
|---|---|---|---|---|
| 29 | **2.0.0 no está en Hub** | crítica | [ ] | Hasta `git tag v2.0.0` + workflow. No publicar hasta el árbol esté listo. |

---

## Análisis de abiertos

### 29 — Hub ≠ árbol

**Qué pasa:** `docker inspect cartagodocker/zsh:v1.0.5` → `Entrypoint=["zsh"]`, `Cmd=null`, `Shell=["zsh","-c"]`. Local `zsh-local:dev` → `Entrypoint=null`, `Cmd=["/usr/bin/zsh"]`, `Shell=["/bin/sh","-c"]`.

**Arreglo:** tag + push **v2.0.0** cuando el árbol esté listo. **Después** NodeBun (`FROM cartagodocker/zsh:v2.0.0`). **No se retaggea 1.0.5.**

### 37 — git identity

SSH autentica pull/push. El autor del commit es `user.name` / `user.email`.
Bind `~/.gitconfig:/${USER}/.gitconfig:ro` (barra inicial, mismo truco que
`~/.ssh`). Sin eso, `git-wrap` imprime el how-to y sale 1 en
`commit`/`merge`/`rebase`/… — no inventa `ubuntu@<id>`.

### 34 — fzf

Cerrado en el árbol: `.zshrc` recorre las rutas Debian/Ubuntu y sourcea
el primer `key-bindings.zsh` / `completion.zsh` legible. En noble el
deb `fzf` 0.44.1 deja esos ficheros **sin gzip** en
`/usr/share/doc/fzf/examples/`. Ctrl-R / Ctrl-T / Alt-C cargan en zsh
interactivo. `dockerzsh extras` ya no dice “if present”.

---

## v1.0.5 publicado (referencia; no se parchea ese tag)

Confirmado en la imagen local `cartagodocker/zsh:v1.0.5`:

```text
Entrypoint=["zsh"]  Cmd=null  Shell=["zsh","-c"]
ENV: solo PATH
```

Dockerfile del tag (`git show v1.0.5:Dockerfile`):

- `curl | sh` OMZ desde `master`
- clones de plugins **sin** SHA
- repo apt gierens para eza (eza ya está en Ubuntu)
- `apt-get remove --purge gnupg ca-certificates`
- `rm -rf … tmp/* || true` (el `|| true` cubre **todo** el `RUN`)
- `ENTRYPOINT ["zsh"]` + `SHELL ["zsh","-c"]`
- `chown -R $(basename $dir)` sobre homes
- no sudo, no UTF-8, bat solo vía `~/.local/bin` (no en PATH de uid 1000 sin ese dir)

Eso es el baseline. 2.0.0 lo sustituye; **no** se retaggea 1.0.5.

---

## Diario

| Fecha | Qué |
|---|---|
| 2026-08-23 | Auditoría Hub v1.0.5. |
| 2026-08-23 | `94d6b0f` en main: reescritura (aún sin tag). |
| 2026-08-23 | Working tree = **2.0.0**. NodeBun pinnea **zsh:v2.0.0**. Orden: Hub zsh primero. |
| 2026-08-23 | Sin Docker dentro (CLI/dockerd). `known_hosts` del bind se copia/merge; no wipe en re-run. |
| 2026-08-23 | #30 SHA, #31 no latest, #32/#33 parsers, #34 fzf. |

## Cola de publicación (no corre sola)

1. Smoke `zsh-local:dev` (`docker run img echo hello`, `bash`, `sh`, `tail`, `git ls-remote https://…`, `sudo -n id` uid 1000, `bat`/`eza`/`fd`/`rg`, `dockerzsh --help`).
2. Commit + `git tag v2.0.0` + push. Workflow construye Hub (`v2.0.0` only, no `:latest`).
3. **Después** construir/publicar NodeBun (`FROM cartagodocker/zsh:v2.0.0`).
