# DockerZsh

## DockerHub link

https://hub.docker.com/repository/docker/cartagodocker/zsh

## Description

Image for charging in other docker images to get zsh as shell default for root or for other existing or new users in the containers.

> This dockerfile use Ubuntu 24.04

## Create Image

````bash
docker build -t zsh-image -f ./Dockerfile ./
````

## Create debug-container

````bash
docker run --rm -it --name zsh-container zsh-image
````

## Create debug-container for user 1000:1000

````bash
docker run --rm -it --name zsh-container --user 1000:1000 zsh-image
````

## Upload docker image to dockerhub

With github actions in repository it will be update automaticatlly in DockerHub with the tag of branches.

## To use in other docker images

Just add the next line in the Dockerfile to base the other image on this one.

````Dockerfile 
FROM cartagodocker/zsh:latest
````

## To add commands or text in the .zshrc file

I added a script to the image that allows you to add commands or text to the .zshrc file context for all users.
The are an zsh file "add_text_to_zshrc.sh" that you can use to add text to the .zshrc file in the container.

for example:

### Example usage:

````bash
add_text_to_zshrc "alias my_command='echo Hi, Cartago!'".
````

### Example usage with --prepend flag:

It can be used to add text to the beginning of the file.

````bash
add_text_to_zshrc "alias my_command='echo Hi, Cartago!'" --prepend
````

### Example usage with multiline text:

It can be used to add multiline text.

````bash
add_text_to_zshrc "alias my_command='echo Hi, Cartago!'\nalias my_command2='echo Hi, Cartago!'" --prepend
````

### Other Example usage with multiline text:

````bash
add_text_to_zshrc "$(printf '%s\n' \
    'alias my_command="echo Hi, Cartago!"' \
    'alias my_command2="echo Goodbye, Cartago!"' \
    'echo "This is a test"' \
    'ls -ln')"
`````

### Example to use multiline in other DockerFile

````Dockerfile
FROM cartagodocker/zsh:latest

RUN add_text_to_zshrc "$(printf '%s\n' \
    'alias my_command="echo Hi, Cartago!"' \
    'alias my_command2="echo Goodbye, Cartago!"' \
    'echo "This is a test"' \
    'ls -ln')" --prepend
````
