# DockerZsh — tracker de bugs (`FIXES.md`)

Documento **vivo**. Se borra cuando no queden bugs abiertos (ni docs
mentirosas). No es el README: el README describe el contrato publicado;
esto describe lo que **aún está mal** o **aún no está en Hub**.

| | |
|---|---|
| Working tree | **v1.0.6** (`ARG VERSION=1.0.6`) |
| Hub hoy | **`cartagodocker/zsh:v1.0.5`** (ene 2025, ~205 MB) |
| Tag git `v1.0.6` | **aún no** — no publicar hasta OK |
| Consumidor | NodeBun (siguiente publicación) pinnea **`FROM zsh:v1.0.6`**. Orden: Hub zsh 1.0.6 **antes** de construir NodeBun. |

Leyenda: `[ ]` abierto · `[~]` en curso · `[x]` hecho en el árbol 1.0.6 · `[–]` no se hará.

---

## Relación con NodeBun (no mezclar versiones)

- **zsh 1.0.6** = este árbol. CMD, sin ENTRYPOINT, sudo, certs, UTF-8, CLI extras, `dockerzsh`.
- **NodeBun (unreleased)** ya pinnea **`FROM zsh:v1.0.6`**. No se construye
  ni se publica hasta que 1.0.6 esté en Hub. Hasta entonces, el árbol
  NodeBun **no debe** revertirse a 1.0.5.
- Orden: tag+push zsh `v1.0.6` → smoke Hub → publicar NodeBun.

---

## Commits después de `v1.0.5` (qué rompió / qué arregló)

`git log v1.0.5..HEAD` (más el working tree sucio):

| Commit / árbol | Qué hizo | Efecto real |
|---|---|---|
| `c7ad3fd` *Añadimos zsh como variable SHELL* (ene 2025, **después** del tag v1.0.5, **antes** de publicarse de nuevo) | `ENV SHELL=zsh` (no es un path) | Hub `v1.0.5` inspect: `Entrypoint=["zsh"]` `Shell=["zsh","-c"]` `Env PATH only`. El `ENV SHELL=zsh` **no está** en la imagen de Hub: el tag se cortó en `40f6c1e`. Este commit **nunca se publicó**. |
| `94d6b0f` *fixes: enum some fixes…* (2026-08-23, en `main`) | Reescritura: clones pinneados, CMD, `SHELL sh`, sudo, certs, `share_config_globally`, workflows `GITHUB_ENV` | Arregla #1–#17, #23–#25 **en git**. **No está en Hub.** Quien `FROM zsh:v1.0.5` sigue con el Dockerfile viejo (`install.sh` de master, `\|\| true`, purge certs, ENTRYPOINT zsh, repo gierens, metapaquete `ssh`). |
| Working tree (sin commit) | `ARG VERSION=1.0.6`, CLI extras (`fd`/`rg`/`fzf`/`zoxide`/…), `dockerzsh`, workflow `--build-arg VERSION`, README/CHANGELOG | Contenido de **1.0.6**. Hasta el tag, Hub sigue siendo 1.0.5. |

**Conclusión:** los “fixes” recientes **no rompieron Hub** (Hub es 1.0.5, inmutable). Rompieron la **documentación** si se habla de CMD / no ENTRYPOINT como si ya fueran Hub. NodeBun **sí** pinnea `FROM zsh:v1.0.6` (correcto para la siguiente publicación). El build de NodeBun espera a que 1.0.6 esté en Hub.

El bug `ENTRYPOINT ["zsh"]` (`docker run img echo hello` → `can't open input file: echo`) es el Dockerfile **de 1.0.5**, no una regresión de 94d6b0f. 94d6b0f lo **arregla** en el árbol nuevo.

`ENV SHELL=zsh` de `c7ad3fd` era un path inválido; el árbol 1.0.6 usa `SHELL=/usr/bin/zsh`.

---

## Contrato 1.0.6 (no perder)

1. `docker run -it` → zsh + OMZ + p10k + eza/bat.
2. `docker run img bash` / `img sh` / `img tail -f /dev/null` **funcionan** (no ENTRYPOINT).
3. `RUN` de hijas en POSIX sh (`SHELL ["/bin/sh","-c"]`).
4. HTTPS (`ca-certificates`).
5. sudo NOPASSWD `ALL` (Compose `user: 1000:1000`). Globales `644`/`755`.
6. `LANG=C.UTF-8`. os_icon 🐳 (`🐳`); powerline/eza = Nerd Font **en el host**.
7. Helpers hijas: `add_text_to_zshrc`, `add_text_to_p10k`, `share_config_globally`.
8. `dockerzsh --help` lista lo que hay.

---

## Progreso

### Hecho en el árbol 1.0.6 (no en Hub v1.0.5)

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
| 17 | README = contrato 1.0.6 (pin `v1.0.6`, nota Hub aún 1.0.5) | media | [x] |
| 18 | Workflow descripción Hub (JWT + `jq --rawfile`) | baja | [x] |
| 20 | uid 1000 login zsh | media | [x] (#3) |
| 23 | sudo NOPASSWD en **esta** imagen | crítica | [x] |
| 24 | `LANG=C.UTF-8` / `LC_ALL` | alta | [x] |
| 25 | os_icon 🐳 `🐳` (no NF `U+F308`) | alta | [x] |
| 26 | `ARG VERSION=1.0.6` + `ENV VERSION` + `--build-arg` en workflow | media | [x] |
| 27 | CLI extras + `dockerzsh` | baja | [x] |
| 28 | `.gitignore` (estaba vacío) | baja | [x] |
| 35 | `known_hosts` baked + copia/merge del host en `/tmp` | media | [x] |
| 36 | Quitar Docker CLI (~91 MiB: docker-ce-cli + compose) | media | [x] |

### Abiertos (código / docs / CI)

| # | Ítem | Pri | Estado | Notas |
|---|---|---|---|---|
| 19 | Pin `ubuntu:24.04` por digest | baja | [–] | Se queda el tag `24.04` para recoger security updates al rebuild. |
| 21 | Adelgazar más | baja | [x] parcial | ~200 MB local vs 205 MB Hub. No borrar `.git` de OMZ. |
| 29 | **1.0.6 no está en Hub** | crítica | [ ] | Hasta `git tag v1.0.6` + workflow, consumidores siguen en 1.0.5. README ya avisa. |
| 30 | Workflow Hub usa tags móviles (`checkout@v4`, buildx `@v3`, login `@v3`) | media | [ ] | NodeBun pinnea SHA. Supply-chain. |
| 31 | Workflow publica `:latest` y el README dice “no uses latest” | media | [ ] | Política dual: documentar o dejar de pushear `latest`. |
| 32 | `share_config_globally`: `shift 2` sin comprobar `$2` | baja | [ ] | `--to` / `--base-src` / `--permissions` sueltos se comen el `src`. |
| 33 | `useradd` wrapper: último arg no-flag = usuario | baja | [ ] | `useradd -m alice -c "foo"` puede asociar mal. |
| 34 | `fzf` key-bindings en `.zshrc` | baja | [x] | `.zshrc` sourcea `/usr/share/doc/fzf/examples/key-bindings.zsh` (noble: sin gzip). |
| 35 | Este `FIXES.md` contradecía el contrato (U+F308 vs 🐳; #18 hecho y pendiente) | docs | [x] | Este rewrite. |

---

## Análisis de abiertos

### 29 — Hub ≠ árbol

**Qué pasa:** `docker inspect cartagodocker/zsh:v1.0.5` → `Entrypoint=["zsh"]`, `Cmd=null`, `Shell=["zsh","-c"]`. Local `zsh-local:dev` → `Entrypoint=null`, `Cmd=["/usr/bin/zsh"]`, `Shell=["/bin/sh","-c"]`.

**Por qué importa:** el **tag Hub NodeBun 2.0.0** (sobre zsh 1.0.5) hereda el ENTRYPOINT. `docker run nodebun node --version` → `can't open input file: node`. El árbol NodeBun unreleased pinnea 1.0.6 y **deja** de heredarlo cuando se construya contra Hub 1.0.6.

**Arreglo:** tag + push 1.0.6. **Después** se construye/publica NodeBun (ya pinnea 1.0.6). Las hijas que aún usen Hub `zsh:v1.0.5` necesitan `--entrypoint` hasta entonces.

### 30 — Actions sin pin SHA

`94d6b0f` subió `checkout@v3`→`v4` (arregla el `env:` roto) pero dejó tags móviles. Un retag de `v4` cambia el workflow sin commit nuestro.

### 31 — `:latest`

El workflow pushea `IMAGE_LATEST`. El README pide pin de versión. No es un bug de runtime; es política. O se documenta “latest = último v\*” o se deja de pushear.

### 32 / 33 — parsers frágiles

No pican el build (el Dockerfile pasa args completos). Pican a una hija que invoque mal el helper.

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

Eso es el baseline. 1.0.6 lo sustituye; **no** se retaggea 1.0.5.

---

## Diario

| Fecha | Qué |
|---|---|
| 2026-08-23 | Auditoría Hub v1.0.5. |
| 2026-08-23 | `94d6b0f` en main: reescritura (aún sin tag). |
| 2026-08-23 | Working tree = **1.0.6**. NodeBun unreleased pinnea **1.0.6**. Orden: Hub zsh primero. |
| 2026-08-23 | Quitar Docker CLI (~91 MiB). `known_hosts` del bind se copia/merge; no wipe en re-run. |

## Cola de publicación (no corre sola)

1. Smoke `zsh-local:dev` contra la checklist 1.0.6 (`docker run img echo hello`, `bash`, `tail`, `git ls-remote https://…`, `sudo -n id` uid 1000, `bat`/`eza`/`fd`/`rg`, `dockerzsh --help`).
2. Commit + `git tag v1.0.6` + push. Workflow construye Hub.
3. **Después** construir/publicar NodeBun (ya tiene `FROM zsh:v1.0.6`).
