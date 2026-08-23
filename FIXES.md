# DockerZsh — guía de arreglos

Seguimiento de bugs, contrato de la imagen y recortes de tamaño.
Cuando un ítem se implemente, se marca y se anota **cómo** se arregló.

**Imagen auditada:** `cartagodocker/zsh:v1.0.5` (205 MB)  
**Fecha de auditoría:** 2026-08-23  
**Repo:** este (`DockerZsh`). Consumidor principal: `DockerNodeBun` (`FROM cartagodocker/zsh:v1.0.5`).

Leyenda de estado:

- `[ ]` pendiente
- `[~]` en curso
- `[x]` hecho
- `[–]` no se hará (con motivo)

---

## Contrato que no se pierde

Esto es lo que la imagen **tiene que seguir haciendo** tras los arreglos.
Si un cambio lo rompe, no vale.

1. **zsh preconfigurado por defecto** al abrir el contenedor (`docker run -it`).
   Oh My Zsh + Powerlevel10k + plugins + `.zshrc` / `.p10k.zsh` globales.
2. **eza y bat funcionan** para cualquier usuario (root, ubuntu/1000, usuarios nuevos vía `/etc/skel`):
   - `ls` → eza con iconos/colores
   - `bat` disponible (no solo `batcat`)
3. **Config compartida** entre root, usuarios existentes y usuarios nuevos
   (`/usr/share/globally` + `share_config_globally` + `/etc/skel`).
4. **Scripts helper** para hijas: `add_text_to_zshrc`, `add_text_to_p10k`,
   `share_config_globally`.
5. **git, curl, cliente ssh** disponibles (el README promete git/curl/ssh).
6. **Salir a bash/sh sin pelearse con zsh.**
   El contenedor arranca en zsh; `bash`, `sh` y `docker run imagen bash`
   tienen que funcionar. Los `RUN` de Dockerfiles hijas no pueden tragarse
   errores por `SHELL ["zsh", "-c"]`.
7. **HTTPS usable en runtime** (`git clone`, `curl` a GitHub, apt, registries).
   `ca-certificates` se queda. Las hijas no reinstalan Bun; **sí** hablan TLS.
8. **sudo NOPASSWD** para uid 1000 (Compose no carga grupo `sudo`). Los
   ficheros globales siguen `644`/`755`; se editan con `sudo` o con
   `add_text_to_*` (escalan solos). No se vuelve a `777` en `.zshrc`.
9. **UTF-8** (`LANG=C.UTF-8`) y glifo Docker de **Nerd Font** (`U+F308`),
   no el emoji 🐳 (falla en hosts sin fuente emoji).

Lo que **sí** puede cambiar (no es el producto):

- Quitar `openssh-server` (dejar cliente).
- Quitar repo apt de gierens (eza ya está en Ubuntu 24.04).
- `CMD` en vez de `ENTRYPOINT`.
- `SHELL` de build en POSIX sh (zsh sigue siendo el shell de usuario).
- Pins de git, `.dockerignore`, workflow, docs.

---

## Cómo se usa hoy (para no romper el hábito)

```bash
# interactivo → zsh con p10k
docker run --rm -it cartagodocker/zsh:v1.0.5

# usuario 1000:1000 (ubuntu)
docker run --rm -it --user 1000:1000 cartagodocker/zsh:v1.0.5
```

**Objetivo después del arreglo:** mismos comandos, mismo look, eza/bat de verdad,
y además:

```bash
docker run --rm -it imagen bash    # bash, no "can't open input file"
# dentro de zsh:
bash                               # subshell bash
sh                                 # dash
exit                               # volver a zsh (si era subshell)
```

Hijas (`DockerNodeBun`): `RUN` en `/bin/sh`; usuario interactivo sigue en zsh.

---

## exa vs eza (no se cambia de herramienta)

**Al revés de lo que parece por el nombre:**

| | **exa** (`ogham/exa`) | **eza** (`eza-community/eza`) |
|---|---|---|
| Qué es | El original, “modern ls” | Fork comunitario de exa |
| Estado | **Unmaintained** desde ~2023. Última release `v0.10.1` hace ~5 años. El propio README dice *“exa is unmaintained, use the fork eza instead”*. El repo no está archived porque el autor está inalcanzable. | **Activo**. Releases frecuentes (p.ej. v0.23.5). |
| Binario | `exa` | `eza` |
| Ubuntu 24.04 | Paquete `exa` viejo / en retirada | Paquete **`eza` 0.18.2** en el archive oficial |

Lo que **ya tienes en `.zshrc` y en la imagen v1.0.5** no es exa:

```zsh
alias ls='eza --icons --group-directories-first --color=always'
export EXA_COLORS="..."   # nombre viejo de la env var; eza también lee EZA_COLORS
```

El Dockerfile instala el paquete `eza` (`/usr/bin/eza`). El comentario del zshrc (“eza (exa)”) y `EXA_COLORS` son restos del nombre antiguo.

**Decisión:** nos quedamos en **eza**. No volver a `exa` (muerto). No hace falta el repo gierens para “tener eza”: Ubuntu 24.04 ya lo empaqueta. El look de `ls` no cambia.

Si alguien escribe `exa` en el contenedor, no existirá el comando (nunca se instaló). Si se quiere un alias de compatibilidad `alias exa=eza`, es opcional y no está en el contrato.

---

## Progreso

| # | Ítem | Tipo | Prioridad | Estado |
|---|------|------|-----------|--------|
| 1 | No purgar `ca-certificates` | bug | crítica | [x] |
| 2 | Quitar `\|\| true` ciego; `rm -rf /tmp/*` | bug | crítica | [x] |
| 3 | `ENTRYPOINT` → `CMD`; `SHELL=/usr/bin/zsh`; login shell | bug + contrato bash | crítica | [x] |
| 4 | Instalador Oh My Zsh (`--unattended --keep-zshrc`) | bug | alta | [x] |
| 5 | Quitar repo gierens; eza de Ubuntu | bug | alta | [x] |
| 6 | `bat` en PATH (`/usr/local/bin/bat`) | bug + contrato eza/bat | crítica | [x] |
| 7 | Plugin `fasd` (quitar o instalar) | bug | media | [x] |
| 8 | `.zshrc`: compinit, updates, `EZA_COLORS` | bug | alta | [x] |
| 9 | `share_config_globally` (`--to`, `ln -sfn`, chown, perms) | bug | alta | [x] |
| 10 | Pins de git (SHAs de v1.0.5) | higiene | media | [x] |
| 11 | Workflow Docker Hub (`GITHUB_ENV`, tag) | CI | media | [x] |
| 12 | `SHELL ["/bin/sh", "-c"]` para builds hijas | bug | crítica | [x] |
| 13 | `openssh-client` en vez de metapaquete `ssh` | tamaño + superficie | media | [x] |
| 14 | `add_text_to_zshrc` / `add_text_to_p10k` (flags, echo -e) | bug | media | [x] |
| 15 | Permisos git de scripts (`100755`) | higiene | baja | [x] |
| 16 | `.dockerignore` | higiene | baja | [x] |
| 17 | README (p10k example, pin de tag, ssh/certs) | docs | media | [x] |
| 18 | Workflow descripción Docker Hub (auth JWT) | CI | baja | [ ] |
| 19 | `ubuntu:24.04` por digest (opcional) | higiene | baja | [ ] |
| 20 | Usuario `ubuntu` uid 1000 + login zsh | contrato | media | [x] cubierto por #3 |
| 21 | Adelgazar sin quitar función | tamaño | baja | [x] parcial (~203 MB vs 205 MB) |
| 22 | Scripts `add_*` ejecutables en shebang POSIX/zsh | higiene | baja | [x] cubierto por #14/#15 |
| 23 | sudo NOPASSWD en **esta** imagen (no 777) | contrato | crítica | [x] |
| 24 | `LANG=C.UTF-8` (iconos/eza) | bug | alta | [x] |
| 25 | os_icon emoji 🐳 (`U+1F433`), no Nerd Font `U+F308` | contrato | alta | [x] |

**Hechos:** 1–17, 20–25 (21 parcial).  
**Pendientes:** #18 (JWT Hub → cola 4), #19 (digest, no: nos quedamos en tag 24.04). **No bump / no tag** hasta OK.  
**Smoke local 2026-08-23 (retest uno a uno, FAILCOUNT=0):** no ENTRYPOINT, echo/bash/sh, `docker run img tail` OK, git HTTPS, sudo uid 1000, bat/eza, no sshd, no gierens, LANG=C.UTF-8. os_icon ahora 🐳 (`f0 9f 90 b3`) tras rebuild.

---

## Detalle por ítem

### 1. `ca-certificates` se instala y se borra

**Qué pasa:** el `RUN` final hace `apt-get remove --purge gnupg ca-certificates`.
En v1.0.5 no existe `/etc/ssl/certs/ca-certificates.crt`.
`git ls-remote https://github.com/...` → `server certificate verification failed. CAfile: none`.

**Por qué importa aunque las hijas ya traigan Bun:** el paquete no instala runtimes;
es el bundle de CAs para **cualquier HTTPS** (git, npm/bun install, apt, curl).
NodeBun lo reinstala hoy como parche.

**Arreglo previsto:**
- Dejar `ca-certificates`.
- Sí se puede purgar `gnupg` si ya no hay repo gierens (#5).

**Cómo se arregló:** ya no se instala `gnupg` ni se purga nada al final. `ca-certificates` queda. Smoke: `git ls-remote https://github.com/ohmyzsh/ohmyzsh.git` → SHA; `/etc/ssl/certs/ca-certificates.crt` presente.

---

### 2. `|| true` al final del `RUN` + `tmp/*`

**Qué pasa:**

```dockerfile
&& rm -rf /var/lib/apt/lists/* tmp/* || true
```

Por precedencia, **toda** la cadena del `RUN` queda bajo `|| true`.
Si falla el curl de OMZ o un clone, Docker marca el layer OK.
`tmp/*` es relativo al cwd, no `/tmp/*`.

**Arreglo previsto:**
- Quitar el `|| true`.
- `rm -rf /var/lib/apt/lists/* /tmp/*`.
- Comentarios **fuera** de líneas con `\`, mismo criterio que NodeBun
  (un `#` a mitad de continuación puede truncar el instruction).

**Cómo se arregló:** el `RUN` termina en `apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*` sin `|| true`. Comentarios fuera del bloque.

---

### 3. `ENTRYPOINT ["zsh"]` + `ENV SHELL=zsh` + passwd en bash

**Qué pasa (confirmado en v1.0.5):**

```text
docker run --rm cartagodocker/zsh:v1.0.5 echo hello
# zsh: can't open input file: echo
```

`zsh` interpreta el comando como fichero. NodeBun **hereda** `Entrypoint=["zsh"]`.
`ENV SHELL=zsh` no es un path válido. En `/etc/passwd`, root y ubuntu siguen en `/bin/bash`.

**Contrato bash/sh (pedido explícito):**
- Arranque interactivo = zsh preconfigurado.
- `bash` y `sh` existen y se pueden lanzar **dentro** del contenedor (`bash`, `sh`, `exit`).
- `docker run imagen bash` / `docker run imagen sh` ejecutan ese binario, no zsh-como-script.
- Scripts POSIX de hijas (`#!/bin/sh`, `RUN apt-get...`) no pasan por zsh.

**Arreglo previsto:**
- Quitar `ENTRYPOINT`.
- `CMD ["zsh"]` (o `CMD ["/usr/bin/zsh"]`) → `docker run -it imagen` abre zsh;
  `docker run imagen bash` abre bash.
- `ENV SHELL=/usr/bin/zsh`.
- `chsh` (o `usermod -s`) de root y ubuntu a `/usr/bin/zsh` para logins (`su -`, ssh).
- Ubuntu 24.04 ya trae bash y dash (`/bin/sh` → dash). No hace falta instalar nada extra.
- No usar `ENTRYPOINT ["zsh", "-c"]` ni wrapper que impida `bash`.

**Cómo se arregló:** `CMD ["/usr/bin/zsh"]`, sin ENTRYPOINT. `ENV SHELL=/usr/bin/zsh`. `chsh` de root y ubuntu a `/usr/bin/zsh`. Smoke: `docker run img echo hello` → `hello`; `docker run img bash` → bash; `docker run img sh` → sh.

**Matiz:** `docker run img -c '...'` ya **no** funciona (`-c` no es un binario). Hay que `docker run img zsh -c '...'`. Interactivo `docker run -it img` sigue abriendo zsh (CMD). Es el contrato Docker correcto.

---

### 4. Instalador Oh My Zsh mal invocado

**Qué pasa:**

```dockerfile
sh -c "$(curl -fsSL ${OH_MY_ZSH_URL}) --keep-zshrc"
```

`--keep-zshrc` queda **dentro** del script de `-c`. La forma documentada:

```bash
sh -c "$(curl -fsSL URL)" "" --unattended --keep-zshrc
```

En build no-TTY OMZ desactiva CHSH/RUNZSH solo, por eso no se cuelga.
El quoting sigue siendo frágil.

**Arreglo previsto:**
- `RUNZSH=no CHSH=no sh -c "$(curl -fsSL ...)" "" --unattended --keep-zshrc`
  (o equivalente con env).
- El `.zshrc` nuestro ya está en `/root` **antes** del install (`COPY config/`),
  así que `--keep-zshrc` es correcto.

**Cómo se arregló:** se dejó de usar `install.sh` de master. Clone pinneado de ohmyzsh al SHA de v1.0.5 (`git init` + `fetch --depth=1 origin <sha>`). El `.zshrc` nuestro se comparte después con `share_config_globally`.

---

### 5. Repo gierens de eza inútil (eza **sí** se queda)

**Qué pasa:** Ubuntu 24.04 ya instala `eza 0.18.2`. El Dockerfile:
1. instala `eza` de Ubuntu
2. añade `deb.gierens.de` + gpg
3. **no** hace otro `apt-get update && apt-get install eza`
4. borra `gnupg`

Queda `gierens.list` en la imagen. Un `apt-get update` en hijas puede fallar.

**Contrato:** `ls` alias a **eza** con iconos. No se quita eza. No se vuelve a **exa** (proyecto abandonado; ver sección “exa vs eza”).

**Arreglo previsto:**
- Instalar `eza` solo desde Ubuntu (`apt-get install eza`).
- Borrar `ARG EZA_URL` y el bloque wget/gpg/sources.list.
- Sin gierens, `gnupg` y `wget` dejan de ser necesarios para el build
  (`curl` cubre descargas).

**Cómo se arregló:** `apt-get install eza` del archive Ubuntu. Sin `EZA_URL`, sin gpg, sin `gierens.list`. `wget` se **deja** (el README lo promete; no es peso del bug). Smoke: no existe `/etc/apt/sources.list.d/gierens.list`; `ls` interactivo es alias a eza 0.18.2.

---

### 6. `bat` no está en PATH (bat **sí** se queda)

**Qué pasa:** Debian/Ubuntu el binario se llama `batcat`.
El Dockerfile pone `~/.local/bin/bat → /usr/bin/batcat`.
Ese dir **no** está en el PATH de `docker run -it` como root:

```text
bat not found
batcat is /usr/bin/batcat
```

Login de ubuntu (`su - ubuntu`) sí lo ve porque `.profile` añade `~/.local/bin`.

El plugin `zsh-bat` espera el comando `bat`.

**Arreglo previsto:**
- `ln -sfn /usr/bin/batcat /usr/local/bin/bat` (PATH de todos los uid).
- Se puede dejar también el symlink en homes por compatibilidad, o quitarlo
  para no duplicar.
- Alias `cat` **no** es obligatorio (zsh-bat suele alias `cat=bat` si el plugin
  carga). Verificar tras el build que `bat --version` y el plugin no gritan.

**Cómo se arregló:** `ln -sfn /usr/bin/batcat /usr/local/bin/bat`. Ya no se crean `~/.local/bin/bat` por usuario. Smoke root y uid 1000: `command -v bat` → `/usr/local/bin/bat`; `bat --version` → 0.24.0.

---

### 7. Plugin `fasd` sin binario

**Qué pasa:** `plugins=(fasd ...)` y no hay paquete/binario `fasd`.
`type fasd` → not found. En v1.0.5 el startup no imprimió error ruidoso,
pero el plugin no hace nada.

**Arreglo previsto (elegir uno):**
- **A (recomendado):** quitar `fasd` de `plugins=(...)`. Nadie lo está usando
  de verdad si el binario nunca estuvo.
- **B:** instalar `fasd` (no está en Ubuntu 24.04 archive de forma limpia;
  suele ser clone/binario a mano). Más peso, más mantenimiento.

Decisión: **A**, salvo que en el uso diario se recuerde `z`/`fasd`.
Oh My Zsh ya trae `z` como plugin si se quiere jump de directorios más adelante
(no activar ahora para no cambiar hábitos).

**Cómo se arregló:** opción A. `fasd` fuera de `plugins=(...)`. Binario no instalado. Smoke: `command -v fasd` → no fasd; startup interactivo sin stderr.

---

### 8. `.zshrc`: orden de `compinit`, updates, colores eza

**Qué pasa:**
- `compinit` **antes** de `oh-my-zsh.sh`.
- `zsh-completions` exige su `src` en `fpath` **antes** de `compinit`.
- `ZSH_UPDATE_DELAY=0` no es variable de OMZ.
- Falta `DISABLE_AUTO_UPDATE=true` (imagen inmutable; no queremos que
  OMZ intente git pull en el clone compartido).
- `EXA_COLORS` es el nombre viejo; eza 0.18 acepta ambos, mejor `EZA_COLORS`
  (se puede exportar los dos).

**Arreglo previsto:**

```zsh
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true
# fpath de zsh-completions ANTES de compinit
fpath+=(${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions/src)
# no llamar compinit a mano: oh-my-zsh.sh ya lo hace
plugins=(git vscode zsh-autosuggestions zsh-completions zsh-syntax-highlighting jsontools zsh-bat)
source $ZSH/oh-my-zsh.sh
```

Mantener bloque p10k instant prompt **arriba del todo** (requisito de p10k).
Mantener `alias ls='eza --icons --group-directories-first --color=always'`.

**Cómo se arregló:** `DISABLE_AUTO_UPDATE=true`; sin `ZSH_UPDATE_DELAY`; sin `compinit` a mano; `fpath+=` de zsh-completions antes de `source oh-my-zsh.sh`; `EZA_COLORS` + `EXA_COLORS` (compat). Instant prompt sigue arriba. Smoke: `zsh -ic 'whence ls'` → alias eza; plugins listados sin fasd; stderr vacío.

---

### 9. `share_config_globally`

**Qué pasa:**
1. `FULL_DEST_DIR=${SHARE_FOLDER}/${DEST_DIR_NAME}` se calcula **antes** del
   default de `--to` → sin `--to` el destino es `/usr/share/` (vacío).
   El README documenta `share_config_globally .local/share/fnm` sin `--to`.
2. `ln -s` sin `-f`: segundo run o destinos ocupados fallan.
3. `chown $(basename $dir)` sobre `/etc/skel` → `skel:skel` (no existe).
4. Default `777`; `.zshrc` global en v1.0.5 está `rwxrwxrwx`.

El Dockerfile actual **sí** pasa `--to`, por eso la imagen base se salva.

**Arreglo previsto:**
- Resolver `DEST_DIR_NAME` **antes** de `FULL_DEST_DIR`.
- `ln -sfn`.
- No chown de `/etc/skel` a un user inventado; para `/home/*` usar el owner
  real del home (`stat`) no `basename` a ciegas. `/root` → root:root.
- Default de permisos `755` para dirs, `644` para ficheros; el flag
  `--permissions` sigue existiendo (NodeBun/bun pueden pedir 777 a propósito).
- El shebang puede quedarse `#!/bin/zsh` (el script usa `setopt globdots`).
  Documentar que hijas con `SHELL sh` deben invocarlo con `zsh -c` o el
  binario ya en PATH (es zsh, funciona como ejecutable).

**Cómo se arregló:** default de `--to` **antes** de `FULL_DEST_DIR`; `ln -sfn`; `chown -h` solo del symlink (nunca `-R`, que seguiría el link y chown del árbol global); no chown de `/etc/skel`; default perms `755` (`644` para `.zshrc`/`.p10k.zsh` en el Dockerfile). Shebang `#!/bin/zsh`.

---

### 10. Builds no reproducibles (pins)

**Qué pasa:** clones a default branch sin tag. Rebuild ≠ misma imagen.

**SHAs en v1.0.5** (para pinnear y no cambiar el look de meses de uso):

| Repo | HEAD en v1.0.5 |
|------|----------------|
| ohmyzsh/ohmyzsh | `d82669199b5d900b50fd06dd3518c277f0def869` |
| romkatv/powerlevel10k | `c85cd0f02844ff2176273a450c955b6532a185dc` |
| zsh-users/zsh-autosuggestions | `0e810e5afa27acbd074398eefbe28d13005dbc15` |
| zsh-users/zsh-completions | `c160d09fddd28ceb3af5cf80e9253af80e450d96` |
| zsh-users/zsh-syntax-highlighting | `5eb677bb0fa9a3e60f0eff031dc13926e093df92` |
| fdellwing/zsh-bat | `467337613c1c220c0d01d69b19d2892935f43e9f` |

**Arreglo previsto:**
- `ARG` con esos commits.
- `git clone --depth=1` + checkout del commit (o `git fetch --depth=1 origin <sha>`).
- OMZ: o bien el installer con `REMOTE`/`BRANCH`, o clone manual del repo
  pinneado (más reproducible que `install.sh` de `master`).

**Cómo se arregló:** `ARG` con esos 6 SHA. Helper `clone_pinned` en el `RUN`: `git init` + `fetch --depth=1 origin <sha>` + `checkout --detach FETCH_HEAD`. Verificado a mano contra GitHub antes del build.

---

### 11. Workflow `docker-hub-update.yml`

**Qué pasa:**
- `env.IMAGE_TAG` usa `'${GITHUB_REF#refs/tags/}'` (Actions no expande eso).
- `echo ... >> GITHUB_ENV` sin `$` en un sitio.
- `VERSION_TAG` se imprime y no se exporta; el check “tag exists” usa vacío.

**Arreglo previsto:**
- Un step que exporte `VERSION_TAG=${GITHUB_REF_NAME}` a `$GITHUB_ENV`.
- `IMAGE_TAG=${{ secrets.DOCKERHUB_USERNAME }}/${{ vars.DOCKERHUB_REPO }}:${{ env.VERSION_TAG }}`.
- Bump de actions a v4 si se toca el fichero (`checkout`, `setup-buildx`, `login`).
- No cambiar el trigger (`push` de tags `v*`) ni el esquema de tags.

**Cómo se arregló:** step `Set image tags` escribe `VERSION_TAG=${GITHUB_REF_NAME}`, `IMAGE_TAG` y `IMAGE_LATEST` en `$GITHUB_ENV`. Actions: checkout@v4, setup-buildx@v3, login@v3. Trigger `v*` igual.

---

### 12. `SHELL ["zsh", "-c"]` rompe `RUN` de hijas

**Qué pasa:** NodeBun lo documenta: un `RUN` largo con quotes/`$(...)` se parte
o se traga errores (`fnm env` inválido → eval vacío → layer OK).
Por eso NodeBun fuerza `SHELL ["/bin/sh", "-c"]`.

**Contrato:** el **usuario** entra en zsh; el **build** de hijas usa POSIX sh.

**Arreglo previsto:**
- En esta imagen: `SHELL ["/bin/sh", "-c"]` (o no tocar SHELL: Ubuntu default es sh).
- `CMD ["zsh"]` cubre el interactivo (#3).
- Documentar en README: hijas que quieran zsh en `RUN` lo ponen ellas;
  no es el default de build.

**Cómo se arregló:** `SHELL ["/bin/sh", "-c"]`. Inspect de `zsh-local:dev`: `Shell=["/bin/sh","-c"]`. README lo menciona.

---

### 13. Metapaquete `ssh` = cliente + servidor

**Qué pasa:** `apt-get install ssh` mete `openssh-client` + `openssh-server` + sftp.
No hay servicio sshd. Peso (~2–3 MB) y superficie. El README dice “ssh”;
el uso real es git+cliente (`git clone git@...`, `ssh github.com`).

**Arreglo previsto:** `openssh-client` en vez de `ssh`. Quitar server/sftp.
Si alguien necesita sshd en una hija, que lo instale ahí.

**Cómo se arregló:** `apt-get install openssh-client`. Smoke: `command -v ssh` OK; no `sshd`; `openssh-server` no instalado.

---

### 14. `add_text_to_zshrc` / `add_text_to_p10k`

**Qué pasa:**
- `--prepend` solo cuenta si es `$2` (no se puede `cmd --prepend "text"`).
- `TEXT=$(echo -e "$1")` y luego otro `echo -e` → doble interpretación.
- README del p10k llama a `add_text_to_zshrc` por error.

NodeBun usa:

```dockerfile
RUN add_text_to_zshrc "$(printf '%s\n' \
    '...' \
    )"
```

Eso es `$1` = texto multilínea, sin `--prepend`. Hay que **seguir aceptando**
ese contrato.

**Arreglo previsto:**
- Parsear args: último `--prepend` es flag; el resto es el texto
  (o `$1` texto y cualquier arg `--prepend`).
- Un solo `printf '%s\n'` / `print -r` sin doble `echo -e`.
- Seguir escribiendo solo `/usr/share/globally/.zshrc` (diseño global).
- Shebang `#!/bin/zsh` o reescribir en `sh` para que un `RUN` con SHELL sh
  los ejecute igual (hoy el kernel usa shebang; **sí funcionan** desde sh
  si el fichero es ejecutable). Verificar tras chmod.

**Cómo se arregló:** loop de args; `--prepend` en cualquier posición; un `printf` (sin doble `echo -e`). Contrato NodeBun (`add_text_to_zshrc "$(printf '%s\n' ...)"`) verificado: `ADD_TEXT_OK`. Shebang `#!/bin/zsh`.

---

### 15. Permisos de scripts en git

**Qué pasa:** `add_text_to_*.zsh` están `100644`; `share_config_globally.zsh`
está `100755`. El Dockerfile hace `chmod -R 755` después del rename, así
que en la imagen sale bien.

**Arreglo previsto:** `git update-index --chmod=+x` en los tres `.zsh`
(y los destinos sin extensión si se versionan).

**Cómo se arregló:** los tres scripts en git `100755`. El Dockerfile además hace `chmod a+rx` tras quitar la extensión `.zsh`.

---

### 16. `.dockerignore`

**Qué pasa:** no hay. El contexto manda `.git`, `.github`, README, LICENSE.

**Arreglo previsto:** ignore `.git`, `.github`, `*.md` salvo si algún `COPY`
los necesita (hoy `COPY` solo `config/` y `scripts/`). No ignorar `config/`
ni `scripts/`.

**Cómo se arregló:** `.dockerignore` con `.git`, `.github`, `.gitignore`, `*.md`, `LICENSE`. Build context ~98 KB.

---

### 17. README

**Qué pasa:**
- `add_text_to_p10k` documentado con `add_text_to_zshrc`.
- `FROM cartagodocker/zsh:latest` (NodeBun ya pinnea `v1.0.5`).
- “ssh” sin decir que es el cliente.
- No menciona bash/sh, ni `ca-certificates`, ni que `SHELL` de build es sh.
- Typo `automaticatlly`, `Donwload`.
- Usage de `share_config_globally` no coincide con el bug del `--to`.

**Arreglo previsto:** actualizar al contrato real cuando el Dockerfile esté
cerrado. Pinnear tag de ejemplo (`vX.Y.Z`). Documentar:

```bash
docker run --rm -it imagen          # zsh
docker run --rm -it imagen bash     # bash
# dentro: bash | sh | exit
```

**Cómo se arregló:** README: eza (no exa), cliente ssh, bash/sh, pin de tag en ejemplos (`v1.0.5` como ilustración; el próximo release será el tag nuevo), `add_text_to_p10k` correcto, default `--permissions 755`, typo Download.

---

### 18. Workflow descripción Docker Hub

**Qué pasa:** `Authorization: JWT ${DOCKERHUB_PASSWORD}`. Hub ya no usa ese
login JWT clásico de forma fiable; hace falta token/PAT. Actions en v2/v3.

**Arreglo previsto:** no bloquear el arreglo de la imagen. Si se toca:
login-action + API actual, o dejar nota de “puede estar muerto”.
Verificar con un push a `main` que cambie el README **después** de la imagen.

**Cómo se arregló:** no tocado. No bloquea el runtime. Verificar en un push a `main` que cambie el README **después** de publicar la imagen.

---

### 19. `FROM ubuntu:24.04` sin digest

**Qué pasa:** el tag LTS se mueve. Rebuilds no son bit-a-bit.

**Arreglo previsto:** opcional. Pin digest cuando se publique el próximo tag
(`ubuntu:24.04@sha256:...`). No es el #10 (plugins); es la base.

**Cómo se arregló:** aplazado a propósito. El tag `24.04` es LTS; pin digest en el próximo release si se quiere bit-a-bit.

---

### 20. Usuario `ubuntu` (uid 1000) login shell

Cubierto por **#3**: `chsh` de ubuntu a zsh. `docker run --user 1000:1000 -it`
sin `-l` usa `CMD zsh` y carga `~/.zshrc` si zsh es interactivo (sí con `-it`).
Verificar en el smoke test que `id` es 1000 y el prompt es p10k.

---

### 21. Adelgazar sin quitar función

No es bug. Hacerlo **después** de que 1–9 y 12 estén verdes, midiendo
`docker images` antes/después.

| Cambio | Ahorro aprox. | ¿Pierde función? | ¿Lo hacemos? |
|--------|----------------|------------------|--------------|
| #13 openssh-client vs ssh | 2–3 MB | No | Sí (va con #13) |
| #5 sin gierens | poco + menos rotura | No | Sí |
| `--depth=1` en plugins (#10) | ~6 MB de `.git` | No | Sí |
| Borrar `.git` de OMZ/plugins | ~10 MB | Sí: `omz update` | **No** (por si acaso) |
| Quitar `wget` | ~1 MB | No si curl cubre | Sí, si #5 |
| Quitar `git-man` | ~2 MB | Manpages git | Opcional |
| `rm` docs/man/apt lists | 1–5 MB | No | Sí (ya se limpian lists) |
| Borrar plugins OMZ no usados | ~10 MB | Activar plugin extra a mano | **No** |

Techo realista: unas decenas de MB, no bajar a 80 MB.
Suelo: Ubuntu + git + zsh-common + bat + eza.

**Cómo se arregló:** v1.0.5 = 205 MB; `zsh-local:dev` = 200 MB. Cayó #13 + #5 + clones `--depth=1`. No se borró `.git` de OMZ ni plugins extra. `wget` se dejó.

---

## Orden de implementación (cuando se retome)

No mezclar docs/CI con el runtime en el mismo paso si se puede evitar.

1. **Dockerfile runtime** — #1 #2 #3 #4 #5 #6 #12 #13 (y pins #10 si no duele).
2. **Scripts** — #9 #14 #15.
3. **`.zshrc`** — #7 #8 (eza/bat aliases).
4. **Higiene repo** — #16 `.dockerignore`.
5. **Build local y smoke** (abajo).
6. **README + workflows** — #11 #17 #18.
7. **Adelgazado extra** — #21 lo que no haya caído ya.
8. **Tag** y bump en NodeBun de `FROM cartagodocker/zsh:v1.0.5` → nuevo tag
   (quitar reinstall de `ca-certificates` solo si el smoke HTTPS pasa).

---

## Smoke test (definición de “terminado”)

Correr contra la imagen **recién buildeada** (no v1.0.5):

```bash
IMG=zsh-local  # docker build -t zsh-local .

# 1. zsh -c explícito (sin ENTRYPOINT, -c solo no es un binario)
docker run --rm "$IMG" zsh -c 'echo ZSH_OK; echo SHELL=$SHELL'
# esperado: ZSH_OK, SHELL=/usr/bin/zsh

# 2. bash y sh como comando del contenedor
docker run --rm "$IMG" bash -lc 'echo BASH_OK; echo $BASH_VERSION'
docker run --rm "$IMG" sh -c 'echo SH_OK'

# 3. eza y bat en PATH (root, no login)
docker run --rm "$IMG" zsh -c 'command -v eza; command -v bat; ls --version | head -1; bat --version | head -1'

# 4. HTTPS
docker run --rm "$IMG" zsh -c 'git ls-remote https://github.com/ohmyzsh/ohmyzsh.git HEAD | head -1'

# 5. usuario 1000
docker run --rm --user 1000:1000 "$IMG" zsh -c 'id; command -v bat; command -v eza; test -L ~/.zshrc && echo zshrc_ok'

# 6. hijas: RUN POSIX no usa zsh
# (inspeccionar) Shell=["/bin/sh","-c"]  Entrypoint=[]  Cmd=["zsh"]

# 7. dentro, salir a bash y volver — manual:
# docker run --rm -it "$IMG"
# bash
# echo $BASH_VERSION
# exit
```

Fallos conocidos de v1.0.5 que tienen que pasar a verde: 1, 2 (echo hello),
3 (bat), 4 (git HTTPS).

---

## Relación con DockerNodeBun

Cuando esta imagen se publique con tag nuevo:

- Pinnear `FROM cartagodocker/zsh:vX.Y.Z` (no `latest`).
- NodeBun ya hace `SHELL ["/bin/sh", "-c"]` — se puede dejar por defensa.
- Si #1 está hecho, el `apt-get install ca-certificates` de NodeBun es
  redundante (no hace daño dejarlo).
- NodeBun hereda hoy `Entrypoint=["zsh"]` — el #3 lo limpia también ahí
  **sin tocar NodeBun**, en cuanto rebase de base.
- `add_text_to_zshrc` del Dockerfile NodeBun tiene que seguir funcionando
  byte-a-byte (#14).

No bump de NodeBun hasta smoke de zsh en verde **y** el checklist humano
del prompt (icono Docker en Linux/Mac/Windows con Nerd Font).

Cuando se bumpee NodeBun **hereda** sudo de zsh. Alinear = **no
pisar** los binarios de la base. No es “borrar a ciegas”.

### Qué no se borra nunca (runtime)

En un contenedor NodeBun **siguen existiendo** (vienen de zsh):

- `/usr/local/bin/sudo-password`
- `/usr/local/bin/sudo-nopasswd`
- `/usr/local/bin/apply-sudo-password-on-boot.sh`
- `/usr/local/bin/enable-sudo-users.sh` (ya ejecutado en el build de zsh)
- `/etc/sudoers.d/container-nopasswd`
- CLI idéntica: `sudo-password`, `sudo-nopasswd`, `SUDO_PASSWORD=…`

El usuario no nota el cambio. No se “apaga” sudo.

### Qué sí se deja de copiar (solo el *repo* NodeBun, en el bump)

Hoy `COPY ./scripts /usr/local/bin` pisa **todo** lo que se llame igual.
Eso **no** es heredar: es sustituir. Los de NodeBun escriben
`/etc/sudoers.d/nodebun`; los de zsh, `container-nopasswd`. Dos drop-ins
juntos → NOPASSWD gana y `sudo-password` “no hace nada”.

Alinear de verdad (cuando se toque NodeBun, no ahora):

```dockerfile
# MAL (hoy): pisa sudo-password de zsh
COPY ./scripts ${BIN_HOME}

# BIEN: copiar solo lo que NodeBun añade, nunca los 4 de sudo
COPY scripts/bun_wrapper.zsh scripts/in-bash scripts/in-sh \
     scripts/only-in-container scripts/skip-if-container \
     scripts/nodebun-profile.sh ${BIN_HOME}/
```

Los 4 scripts sudo **se borran del repo NodeBun** en el bump (git
ya tiene el histórico; no hace falta carpeta `legacy-`). En runtime
**siguen** porque los aporta zsh.

No re-`apt-get install sudo`. No re-ejecutar `enable-sudo-users.sh`.
Quitar de `add_text_to_zshrc` la línea duplicada de
`apply-sudo-password-on-boot.sh` (ya está en el `.zshrc` de zsh).

Regla: **solo se deja de instalar/copiar lo que la base ya aporta**.
Nada de `rm` en runtime. Nada de borrar `container-nopasswd`.

---

## Fallback del os_icon (por qué no hay “se ve en cualquiera”)

p10k / Oh My Zsh **no detectan** si el terminal del host tiene Nerd Font.
El prompt es una cadena UTF-8. Elige el glifo **en build**, no en runtime.

| Fallback | Qué pasa con Nerd Font | Qué pasa sin Nerd Font |
|----------|------------------------|-------------------------|
| `U+F308` (ahora) | Icono Docker correcto | Caja / `?` / tofu |
| Emoji 🐳 | Depende: NF no trae emoji; sale si el host tiene fuente emoji | A veces OK (Windows Terminal), a menudo caja (VTE Linux) |
| ASCII `[docker]` | Se ve **siempre**, también *con* NF → feo, rompe powerline | Se ve |
| Dos glifos a la vez (`🐳`) | Ruido, peor | Ruido |

Oh My Zsh/p10k **dependen** de Nerd Font para *todo* el look (separadores
`\uE0B0`, iconos de git, eza). Un fallback solo en `os_icon` no arregla
el resto: sin NF el prompt entero se rompe. Detectar fuente desde el
contenedor (OSC queries, `fc-list` del host) es frágil, lento y no
existe en Windows/VS Code remoto de forma fiable.

Contrato: **1 fuente Nerd Font en el host**. README + settings.json
ejemplo. No hay magia dentro de la imagen.

En **este** Windows: `CascadiaCodeNF.ttf` **está** en
`C:\Windows\Fonts`. VS Code no la usa (`terminal.integrated.fontFamily`
vacío). Arreglo de host, no de imagen:

```json
"terminal.integrated.fontFamily": "'Cascadia Code NF', Consolas, monospace"
```

---

## Las 5 cosas que quedan (detalle)

### A. NodeBun `COPY ./scripts` pisa sudo de zsh

No es un bug de DockerZsh. Es el único riesgo al heredar.
`COPY ./scripts /usr/local/bin` sustituye binarios con el **mismo
nombre**. Alinear = COPY selectivo (arriba). Los scripts pueden
quedarse en el repo NodeBun; **no se copian**. No se `rm` nada
dentro del contenedor. Sudo **sigue**.

### B. Línea duplicada de `apply-sudo-password-on-boot.sh`

El `.zshrc` de zsh ya tiene:

```zsh
[ -x /usr/local/bin/apply-sudo-password-on-boot.sh ] && /usr/local/bin/apply-sudo-password-on-boot.sh || true
```

NodeBun vuelve a meterla con `add_text_to_zshrc`. El script tiene
flag `/run/container-sudo-password-applied` → la segunda llamada
es no-op. No rompe. En el bump se quita del Dockerfile NodeBun
para no ensuciar el zshrc. **No es urgente.**

### C. eza `--icons` en pipe / sin TTY

`eza --icons` default es `auto`: sin TTY no emite glifos (correcto,
para no ensuciar logs). `docker run -it` (uso real) sí. Tests con
`| od` no ven iconos; `eza --icons=always` sí. **No es bug de
usuario.** El alias `ls='eza --icons --color=always'` en TTY
interactivo pinta iconos y colores.

### D. Workflow descripción Docker Hub (#18)

`.github/workflows/update-dockerhub-description.yml` usa
`Authorization: JWT ${DOCKERHUB_PASSWORD}`. Hub dejó el login JWT
clásico; hace falta PAT/token. Si el README cambia en `main`, el
job puede fallar o no actualizar la descripción de Hub. **No
afecta a construir ni a usar la imagen.** Se toca cuando se
publique el tag, no bloquea runtime.

### E. `FROM ubuntu:24.04` sin digest (#19)

El tag LTS se mueve (security updates). Rebuilds de zsh no son
bit-a-bit iguales. Los plugins SÍ están pinneados por SHA.
Opcional: `ubuntu:24.04@sha256:…` en el próximo release. **No
rompe función.**

Extra de host (no imagen): VS Code de este PC sin
`terminal.integrated.fontFamily` → no se ve `U+F308` aunque
Cascadia Code NF esté instalada.

---

## Diario de cambios

Añadir una línea por sesión cuando se implemente.

| Fecha | Qué | Notas |
|-------|-----|-------|
| 2026-08-23 | Auditoría v1.0.5 + este documento | Sin cambios de código todavía. Usuario pidió guía antes de parchear. |
| 2026-08-23 | Aclaración exa vs eza | exa está abandonado; eza es el fork activo. La imagen ya usa eza (`alias ls=eza`). No se vuelve a exa. |
| 2026-08-23 | Implementación 1–17 + smoke `zsh-local:dev` | FAILCOUNT=0. 200 MB. Pendiente publicar tag y #18/#19. |
| 2026-08-23 | sudo en zsh + 755/644 + C.UTF-8 + icono NF | 777 no. uid 1000 escribe con sudo. os_icon `U+F308`. Sin bump NodeBun. |
| 2026-08-23 | NodeBun hereda sudo; no alinear nombres | El bump **deja de copiar** los 4 scripts sudo (siguen en la imagen vía zsh). No rm en runtime. Host Windows: CascadiaCodeNF instalada, VS Code **sin** `terminal.integrated.fontFamily`. |
| 2026-08-23 | Cola “cuando digas sí” | 1 publicar zsh · 2 COPY selectivo NodeBun + borrar 4 scripts del repo (git history) · 3 TTY explicado, no hay parche · 4 workflow README=NodeBun · 5 Ubuntu 24.04 vigente, no 26.04. |
| 2026-08-23 | Helpers, TTY, digest, 24 vs 26, fallback NF | 1 bloqueado a cero bugs. 4 = README+CHANGELOG ambos repos + workflow Hub. 5 = 24.04 no 26.04. Fallback NF no es automático; documentar. |

---

## Notas de diseño (para no reabrir debates)

- **zsh default, bash disponible:** no es un contenedor “solo zsh”.
  Es zsh de producto + POSIX para scripts y para quien escriba `bash`.
- **eza/bat no se negocian:** se arreglan para que funcionen de verdad
  (`ls` alias, `bat` en `/usr/local/bin`).
- **No borrar plugins OMZ ni `.git`:** meses de uso; `omz` extra debe
  poder activarse.
- **Un solo `RUN` grande** se mantiene (menos layers), comentarios fuera
  de las continuaciones `\`.
- **No multi-stage** salvo que más adelante se pida; el ahorro extra no
  justifica el lío con `/usr/share/globally`.
- **755/644 + sudo, nunca 777 en zshrc global.** uid 1000 no pisa la
  config de todos. `add_text_to_*` y `share_config_globally` hacen
  `sudo -n` si no son root.
- **Iconos = fuente del HOST.** El contenedor solo emite UTF-8. Linux,
  macOS y Windows ven el mismo glifo si el terminal usa Nerd Font
  (CaskaydiaCove). El emoji 🐳 no se usa: no está en Nerd Font y
  depende de una fuente emoji que muchos Linux/Windows no tienen.
- **No hay fallback fiable de icono Docker.** p10k no pregunta al
  terminal “¿tienes Nerd Font?”. Un fallback ASCII (`[docker]`) se
  vería *siempre*, también con Nerd Font (feo). Un fallback emoji
  vuelve al problema original. Ver sección “Fallback del os_icon”.
- **`only-in-container` / `skip-if-container` / `in-bash` / `in-sh`**
  son helpers de **NodeBun** (detectar si estás en el contenedor, o
  lanzar bash/sh con profile). No son sudo. En el bump **se copian**.
  No se tocan, no se “alinean” con zsh.

---

## Cola — cuando el usuario diga “sí” (no ejecutada)

Orden acordado 2026-08-23. Nada de esto corre hasta el OK explícito.
**Todavía no hay tag ni bump.**

### 1. Publicar DockerZsh — BLOQUEADO a “cero bugs más”

No tag hasta revisión exhaustiva + OK. NodeBun no se toca en este paso.
Incluye: commit, tag `v*`, smoke contra el tag publicado.

### 2. Alinear NodeBun (añadir lo suyo, no pisar zsh)

- `FROM cartagodocker/zsh:<tag-nuevo>`.
- `COPY` **selectivo**: `bun_wrapper.zsh`, `in-bash`, `in-sh`,
  `only-in-container`, `skip-if-container`, `nodebun-profile.sh`.
- **Borrar del repo NodeBun** los 4 scripts sudo (git history basta):
  `sudo-password`, `sudo-nopasswd`, `enable-sudo-users.sh`,
  `apply-sudo-password-on-boot.sh`.
- No reinstalar sudo. Quitar línea duplicada de boot en zshrc NodeBun.
- Runtime: sudo **sigue** (binarios de zsh). CLI igual.

### 3. TTY — no es código

Ver sección “TTY vs `--tail`”. `--tail` no entra al contenedor.
Entrar con `-it` / VS Code = TTY. eza iconos OK. Sin parche.

### 4. Docs + autopublicar README en Hub

- Reescribir **README + CHANGELOG de DockerZsh** (hoy zsh no tiene
  CHANGELOG) a la realidad: CMD no ENTRYPOINT, sudo, eza, bat,
  Ubuntu 24.04, bash/sh, Nerd Font obligatoria, helpers de hijas.
- Reescribir **README + CHANGELOG de NodeBun** en el bump: hereda
  sudo/certs/CMD de zsh; COPY selectivo; quitar “zsh as entrypoint”
  si ya no aplica; documentar los 4 helpers.
- Workflow Hub de zsh = el de NodeBun (login JWT + `jq --rawfile` +
  `workflow_dispatch`). Ambos README se auto-publican al push a
  `main` cuando cambia `README.md`.

### 5. Ubuntu 24.04 LTS (Noble), no 26.04 por ahora

Rebuild `FROM ubuntu:24.04` (parches Noble). NodeBun hereda al
bumpear. Documentar “Ubuntu 24.04 LTS” en ambos README.
**No** saltar a 26.04 en este lote (LTS nueva, eza/bat/zsh distintos;
hace falta smoke aparte). Digest = pin `sha256:`; no lo usamos ahora
(queremos que `24.04` recoja security updates al rebuild).

Host (fuera de estas 5): VS Code `terminal.integrated.fontFamily`
= `'Cascadia Code NF'` para ver el icono Docker en este Windows.

---

## Helpers NodeBun (se COPIAN en el bump; no son sudo)

Viven en `DockerNodeBun/scripts/`. Detectan `/.dockerenv` o
`IS_INTO_CONTAINER=true`. Uso típico: el **mismo** `package.json` /
Makefile en el host y dentro del contenedor.

### `in-bash`

Lanza **bash --login** (carga `/etc/profile.d/nodebun.sh`).
Desde zsh, para snippets que **no** son zsh-safe
(`set -o pipefail`, arrays bash, etc.).

```bash
in-bash                         # bash interactivo
in-bash -c 'set -o pipefail; …'
in-bash script.sh
```

### `in-sh`

Igual con **POSIX sh** (`/bin/sh -l`, dash en Ubuntu).
`case` POSIX, scripts `#!/bin/sh`.

```bash
in-sh
in-sh -c 'case $1 in … esac'
```

### `only-in-container`

El comando **solo corre dentro** del contenedor. Fuera: error
(o exit 1 si se usa como predicado).

```bash
only-in-container bun run test      # en el host: no ejecuta
only-in-container && echo in-docker # predicado, exit 0/1
```

### `skip-if-container`

Al revés: **no-op dentro**, corre en el host. Típico: `adb`,
daemons del host que no tienen sentido en el contenedor.

```bash
skip-if-container adb start-server
```

No se “alinean” con zsh. En el bump se copian tal cual.

---

## TTY vs `--tail` (punto 3)

**TTY** = hay un terminal (teclado + pantalla). Lo pide `-t`
(`docker run -it`, `docker exec -it`, terminal de VS Code).

**`--tail`** (`docker logs --tail 100`) **no entra** al contenedor:
solo lee las últimas N líneas de logs. No tiene que ver con TTY.

| Cómo entras | ¿TTY? | eza iconos `auto` |
|-------------|-------|-------------------|
| `docker run -it imagen` | sí | sí |
| `docker exec -it cid zsh` | sí | sí |
| VS Code “attach” al contenedor | sí (el integrado es TTY) | sí |
| `docker run imagen zsh -c 'ls'` | no | no (glifos off; colores según `--color=always`) |
| `docker logs --tail` | no aplica | no estás dentro |
| `docker exec cid ls` (sin `-t`) | no | no |

Si “entras” de verdad (`-it` o terminal VS Code), **sí hay TTY**.
`--tail` no es entrar.

---

## Digest (punto 5)

Una imagen Docker se identifica por **tag** (`ubuntu:24.04`) o por
**digest** (`ubuntu:24.04@sha256:abc123…`).

- El **tag** se puede mover: hoy 24.04 es un SHA, mañana Canonical
  publica parches y el mismo tag apunta a otro SHA.
- El **digest** es esa capa concreta, inmutable.

`FROM ubuntu:24.04` = “la 24.04 que haya el día del build”
(updates de seguridad). `FROM ubuntu:24.04@sha256:…` = bit-a-bit
igual siempre, hasta que cambies el SHA a mano.

No es obligatorio. Reproducibilidad fuerte = digest. LTS al día =
tag `24.04` y rebuild.

### 24.04 vs 26.04 (agosto 2026)

Ciclo Ubuntu: LTS en abril de años pares. **24.04 Noble** (abr 2024,
soporte hasta 2029) y **26.04 Resolute** (abr 2026). En Docker Hub
`ubuntu:latest` apunta a 26.04; `24.04` / `noble` siguen publicados.

| | 24.04 | 26.04 |
|---|---|---|
| Qué es | LTS anterior, madura | LTS nueva (~4 meses) |
| Esta imagen hoy | `FROM ubuntu:24.04` | no |
| Riesgo de saltar | — | paquetes (`eza`, `bat`, zsh) cambian; hay que smoke otra vez; NodeBun hereda el salto |

**Recomendación:** quedarse en **24.04** hasta smoke explícito en
26.04 (eza/bat/sudo/fnm). No ir a `latest` ni a 26.10 (no LTS).
Rebuild de 24.04 = parches de seguridad de Noble, no cambio de
release. Documentar “Ubuntu 24.04 LTS (Noble)” en ambos README.
Saltar a 26.04 es decisión de producto aparte, no parte del arreglo
de bugs.

---

## Fallback de iconos para quien NO tiene Nerd Font

El tofu/caja que ves en PCs ajenos **no se puede arreglar desde la
imagen de forma automática**. El contenedor envía Unicode
(`U+F308`, powerline `\uE0B0`, iconos eza). El **host** elige el
glifo. Si la fuente no lo tiene, el OS pinta un cuadrado. p10k
tiene `POWERLEVEL9K_MODE=nerdfont-v3`: **todo** el tema (no solo
el ballenita) asume Nerd Font. Un fallback solo en `os_icon` deja
rotos separadores, git e `ls`.

No existe “si no tienes NF, usa esta otra fuente del contenedor”:
las fuentes las carga el terminal del **host**, no Docker.

Opciones reales (ninguna es magia):

1. **Documentar** (README + Hub): instalar Cascadia Code NF /
   CaskaydiaCove y `terminal.integrated.fontFamily`. Es el contrato
   actual. Quien no lo haga verá tofu. Es lo que ya pasa.
2. **Opt-in ASCII** (no auto): `docker run -e P10K_ASCII=1` y un
   `.p10k-ascii.zsh` generado con el wizard en modo ascii (sin
   powerline). Prompt más pobre, se lee en Consolas. Hay que
   **generar** esa config; no se detecta sola.
3. **No poner os_icon** y dejar el resto NF: el Docker deja de
   tofu-ear; el resto del prompt sigue feo sin NF.

No implementamos (2) hasta que lo pidas: duplica p10k y no arregla
eza. La vía honesta es (1) bien documentada en ambos README.
