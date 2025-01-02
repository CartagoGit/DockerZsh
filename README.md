# DockerZsh

## DockerHub link

https://hub.docker.com/repository/docker/cartagodocker/zsh

## Description

Image for charging in other docker images to get zsh as shell default for root or for other existing or new users in the containers.

> This dockerfile use Ubuntu 24.04

## Create Image

```bash
docker build -t zsh-image -f ./Dockerfile ./
```

## Create debug-container

```bash
docker run --rm -it --name zsh-container zsh-image
```

## Create debug-container for user 1000:1000

```bash
docker run --rm -it --name zsh-container --user 1000:1000 zsh-image
```

## Upload docker image to dockerhub

With github actions in repository it will be update automaticatlly in DockerHub with the tag of branches.

## To use in other docker images

Just add the next line in the Dockerfile to base the other image on this one.

```Dockerfile
FROM cartagodocker/zsh:latest
```

## To add commands or text in the .zshrc file

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
FROM cartagodocker/zsh:latest

RUN add_text_to_zshrc "$(printf '%s\n' \
    'alias my_command="echo Hi, Cartago!"' \
    'alias my_command2="echo Goodbye, Cartago!"' \
    'echo "This is a test"' \
    'ls -ln')" --prepend
```

## To share configuration between users in Dockerfile installations

You can use the script `share-config-globaly` to share configuration between users in the container after install new dependencies or tools in inherit images.

### Example usage:

To share global installations with fnm.

When you install fnm it will create a folder with files in `/root/.local/share/fnm` for the root user.

But it will not be available for other users in the container. It could be a problem if you want to use fnm in other users and you need to install the node version for each user.

I added a script in the image that allows you to share them easily.

If you wish to share the configuration with other users, you can use the script `share-config-globaly` to copy the configuration to the `/etc/skel` folder for new users, and to the existing users in the image.

Format:

`share_config_globaly <source_path> [destination_name --default=name of the source folder] [root_path --default='/root']`

#### Example usage:

```
share_config_globaly .local/share/fnm fnm /root
```

In this case `fnm` and `/root` will be the default values, so you can use the command without the last two parameters.


## Fonts, ligatures and icons - theme

### The zsh theme use [``nerdfonts``](https://www.nerdfonts.com/font-downloads).

The image has been created with a config for `CaskaydiaCove Nerd Font` to look the theme correctly.

[Donwload CaskaydiaCove Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaCode.zip)

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