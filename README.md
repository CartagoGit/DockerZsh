# DockerZsh

## Repository

https://github.com/CartagoGit/DockerZsh

## DockerHub link

https://hub.docker.com/repository/docker/cartagodocker/zsh

## Description

Image for charging in other docker images to get zsh as shell default for root or for other existing or new users in the containers.

> Ubuntu 24.04. zsh + Oh My Zsh + Powerlevel10k. eza (fork activo de exa) y bat.
> curl, wget, git, openssh-client, ca-certificates, sudo (NOPASSWD). bash y sh siguen disponibles.
> `LANG=C.UTF-8`. Iconos de eza/p10k necesitan Nerd Font en **el terminal del host**.

---

# Usage

## Create Image

```bash
docker build -t zsh-image -f ./Dockerfile ./
```

## Create debug-container

```bash
docker run --rm -it --name zsh-container zsh-image
```

Interactive default is zsh (p10k). bash/sh are still there:

```bash
docker run --rm -it zsh-image bash
# inside zsh:
bash
sh
exit
```

## Create debug-container for user 1000:1000

```bash
docker run --rm -it --name zsh-container --user 1000:1000 zsh-image
```

## Upload docker image to dockerhub

GitHub Actions builds and pushes on git tags `v*`.

## To use in other docker images

Pin a version tag (not `latest`) so rebuilds stay reproducible.

```Dockerfile
FROM cartagodocker/zsh:v1.0.5
```

Child Dockerfiles should keep `SHELL ["/bin/sh", "-c"]` for `RUN` (this image already sets it). The user still gets zsh via `CMD`.

### sudo

Passwordless by default (`ALL ALL=(ALL:ALL) NOPASSWD:ALL`) so Compose `user: 1000:1000` (no supplementary groups) still works. Global configs stay `644`/`755`; uid 1000 edits them with `sudo` (or `add_text_to_zshrc`, which escalates). Optional password is runtime-only:

```bash
docker run --rm -it -e SUDO_PASSWORD=secret zsh-image
# inside:
sudo-password              # prompt
sudo-nopasswd              # back to NOPASSWD
```

---

# Scripts

## `add_text_to_zshrc` - To add commands or text in the .zshrc file

I added a script to the image that allows you to add commands or text to the .zshrc file context for all users.
The are an zsh file "add_text_to_zshrc.sh" that you can use to add text to the .zshrc file in the container.

for example:

### Example usage:

```bash
add_text_to_zshrc "alias my_command='echo Hi, Cartago!'".
```

### Example usage with --prepend flag:

It can be used to add text to the beginning of the file.

```bash
add_text_to_zshrc "alias my_command='echo Hi, Cartago!'" --prepend
```

### Example usage with multiline text:

It can be used to add multiline text.

```bash
add_text_to_zshrc "alias my_command='echo Hi, Cartago!'\nalias my_command2='echo Hi, Cartago!'" --prepend
```

### Other Example usage with multiline text:

```bash
add_text_to_zshrc "$(printf '%s\n' \
    'alias my_command="echo Hi, Cartago!"' \
    'alias my_command2="echo Goodbye, Cartago!"' \
    'echo "This is a test"' \
    'ls -ln')"
```

### Example to use multiline in other DockerFile

```Dockerfile
FROM cartagodocker/zsh:v1.0.5

RUN add_text_to_zshrc "$(printf '%s\n' \
    'alias my_command="echo Hi, Cartago!"' \
    'alias my_command2="echo Goodbye, Cartago!"' \
    'echo "This is a test"' \
    'ls -ln')" --prepend
```

## `add_text_to_p10k` - To add commands or text in the `.p10k.zsh` file

It works like the `add_text_to_zshrc` script but it adds the text to the `.p10k.zsh` file.

### Example usage:

```bash
add_text_to_p10k "typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose"
```

## `share_config_globally` - To share configuration between users in Dockerfile installations

You can use the script `share_config_globally` to share configuration between users in the container after install new dependencies or tools in inherit images.

### Example usage:

To share global installations with fnm.

When you install fnm it will create a folder with files in `/root/.local/share/fnm` for the root user.

But it will not be available for other users in the container. It could be a problem if you want to use fnm in other users and you need to install the node version for each user.

I added a script in the image that allows you to share them easily.

If you wish to share the configuration with other users, you can use the script `share_config_globally` to symlink the configuration to the `/etc/skel` folder for new users, and to the existing users in the image.

Format:

```vbnet
    Usage: share_config_globally <src> [--to <destination_name --default= source folder name] [--base-src <source_base_path --default='/root'] [--permissions <permissions --default='755']]

    Parameters:
        src             Path to the source file or folder (required) (Dont need to be the full path, just the path from the base folder, for example: /.local/share/fnm)
      --to            Name of the destination folder (optional - default: source folder name)
      --base-src      Path to the source file or folder (optional - default: /root)
      --permissions   Permissions for the destination (optional, default: 755)

    Example:
        share_config_globally .local/share --to fnm --base-src /root --permissions 755

```

#### Example usage:

```
share_config_globally .local/share --to fnm --base-src /root --permissions 755
```

In this case `fnm` and `/root` will be the default values, so you can use the command without the last two parameters.

#### Example usage in Dockerfile with fnm:

```Dockerfile
FROM cartagodocker/zsh:v1.0.5
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip ca-certificates \
    && curl -fsSL ${FNM_URL} -o /tmp/fnm.zip \
    && mkdir -p ${FNM_BIN} \
    && unzip /tmp/fnm.zip -d ${FNM_BIN} \
    && chmod +x ${FNM_BIN}/fnm \
    && fnm completions --shell zsh > ${FNM_BIN}/_fnm \
    && fnm install ${NODE_DEFAULT_VERSION} \
    && fnm default ${NODE_DEFAULT_VERSION} \
    # It will create the folder /root/.local/share/fnm
    # Then you can share the configuration with the next command
    && share_config_globally .local/share/fnm
```


#### Other Example usage in Dockerfile with bun.js:

```Dockerfile
FROM cartagodocker/zsh:v1.0.5

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && curl -fsSL ${BUN_URL} | bash \
    # It will create the folder /root/.bun
    # Then you can share the configuration with the next command
    && share_config_globally .bun --to bun --base-src /root --permissions 777
```


---

# Fonts, ligatures and icons - theme

### The zsh theme use [``nerdfonts``](https://www.nerdfonts.com/font-downloads).

The image has been created with a config for `CaskaydiaCove Nerd Font` to look the theme correctly.

Icons (eza file glyphs, p10k powerline, the 🐳 os_icon) are **drawn by the host terminal**, not by the container. Linux/macOS/Windows all need a Nerd Font selected in that terminal (VS Code: `terminal.integrated.fontFamily`). Without it you get boxes/`?`, not a DockerZsh bug. Emoji (🐳) also needs a font with emoji (Windows Terminal / VS Code usually have one; some Linux VTE terminals do not). The image sets `LANG=C.UTF-8` so the bytes are valid UTF-8.

[Download CaskaydiaCove Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaCode.zip)

You can try other nerdfont for your host terminal, but is possible it doesn't look correctly.

[Link with all nerdfonts](https://www.nerdfonts.com/font-downloads)

Install the font in your system and configure your terminal to use it.

### To configure the font in the terminal

Once you have installed the font in your system, you need to configure your terminal to use it.

For example, to add in VsCode terminal.  add the next line in the `settings.json` vscode file:

```json
	"terminal.integrated.fontFamily": "'CaskaydiaCove Nerd Font'",
```

Or go to the VsCode settings and search for `terminal.integrated.fontFamily` and add the font name of your choice.


Read documentation if you are using another terminal like `gnome-terminal`, `konsole`, `alacritty`, `powershell`, etc.

Look your terminal configuration to add the font, like the before example.

---

# SSH

## To use ssh in the container. (Neccesary for git with ssh config)

If you have your ssh key in the default path `~/.ssh` you can use it. Otherwise you must to add the path to the ssh key in the container.

Open container with the next command:

```bash
docker run --rm -it --name ionic-cover-container -v ~/.ssh:~/.ssh:ro ionic-cover-image
```

In other path;

```bash
docker run --rm -it --name ionic-cover-container -v ~/your_path/.ssh:~/.ssh:ro ionic-cover-image
```

Or with docker compose:

```yaml
services:
    name_service:
        image: cartagodocker/ionic-cover
        volumes:
            - ~/.ssh:/~/.ssh:ro
```
