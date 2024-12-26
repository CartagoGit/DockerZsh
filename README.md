# DockerZsh

Image for charging in other docker images to get zsh as shell default for root or for other existing or new users in the containers.

## Create Image

``docker build -t zsh-image -f ./Dockerfile ./``

## Create debug-container

``docker run --rm -it --name zsh-container zsh-image``

## Create debug-container for user 1000:1000

``docker run --rm -it --name zsh-container --user 1000:1000 zsh-image``
