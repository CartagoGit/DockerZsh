# Base Ubuntu LTS
FROM ubuntu:24.04

ARG CONTAINER_USER=${CONTAINER_USER:-ubuntu}
ARG CONTAINER_GROUP=${CONTAINER_GROUP:-ubuntu}
ARG USER_UID=1000
ARG USER_GID=1000
ARG USER_HOME=/home/${CONTAINER_USER}
ARG USER_SHELL=/bin/zsh

ARG OH_MY_ZSH_URL=https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
ARG P10K_URL=https://github.com/romkatv/powerlevel10k.git
ARG EZA_URL=https://raw.githubusercontent.com/eza-community/eza/main/deb.asc

# Plugins for oh my zsh
ARG ZSH_AUTOSUGGESTIONS_URL=https://github.com/zsh-users/zsh-autosuggestions
ARG ZSH_COMPLETIONS_URL=https://github.com/zsh-users/zsh-completions
ARG ZSH_SYNTAX_HIGHLIGHTING_URL=https://github.com/zsh-users/zsh-syntax-highlighting.git
ARG ZSH_BAT_URL=https://github.com/fdellwing/zsh-bat.git

# ----------------> CREAR USUARIO
# Remove exiting 1000:1000 user and asign de default Ubuntu User for this image
RUN getent passwd ${USER_UID} && userdel -r $(getent passwd ${USER_UID} | cut -d: -f1) || true && \
    getent group ${USER_GID} && groupdel $(getent group ${USER_GID} | cut -d: -f1) || true &&\
    # Now creating the same user but with the designes name in Dockerfile
    groupadd -g ${USER_GID} ${CONTAINER_GROUP} && \
    useradd -u ${USER_UID} -g ${CONTAINER_GROUP} -ms ${USER_SHELL} ${CONTAINER_USER}

# Copy zsh and p10k config
COPY config/ ${USER_HOME}/

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg wget unzip build-essential git zsh bat eza ca-certificates \
    # Install zsh and oh-my-zsh
    && sh -c "$(curl -fsSL ${OH_MY_ZSH_URL})" \
    && mv /root/.oh-my-zsh ${USER_HOME}/.oh-my-zsh \
    && chown -R ${CONTAINER_USER}:${CONTAINER_GROUP} ${USER_HOME}/.oh-my-zsh \
    # Plugins to ohmyzsh
    && git clone ${ZSH_AUTOSUGGESTIONS_URL} ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone ${ZSH_COMPLETIONS_URL} ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-completions \
    && git clone ${ZSH_SYNTAX_HIGHLIGHTING_URL} ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone ${ZSH_BAT_URL} ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-bat \
    # Install Powerlevel10k
    && git clone --depth=1 ${P10K_URL} ${USER_HOME}/.oh-my-zsh/themes/powerlevel10k \
    # Install Eza to show info and icons in terminal with colors in container
    && mkdir -p /etc/apt/keyrings \
    && wget -qO- ${EZA_URL} | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list \
    && chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list \
    # Config Bat to change Cat
    && mkdir -p ${USER_HOME}/.local/bin  \
    && ln -s /usr/bin/batcat ${USER_HOME}/.local/bin/bat \
    # Change root privs to User privis
    && chown -R ${USER_UID}:${USER_GID} ${USER_HOME} \
    && chmod -R 755 ${USER_HOME} \
    # LClean cache and temps
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* tmp/* /root/.oh-my-zsh /root/.zshrc /root/.cache

USER ${CONTAINER_USER}
SHELL ["zsh", "-c"]
ENTRYPOINT ["zsh"]