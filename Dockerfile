# Base Ubuntu LTS
FROM ubuntu:24.04

ARG USER_UID=1000
ARG USER_GID=1000
ARG TEMPLATE_HOME=/etc/skel

# Urls to install Oh my zsh, p10k and Eza
ARG OH_MY_ZSH_URL=https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
ARG P10K_URL=https://github.com/romkatv/powerlevel10k.git
ARG EZA_URL=https://raw.githubusercontent.com/eza-community/eza/main/deb.asc

# Plugins for Oh my zsh
ARG ZSH_AUTOSUGGESTIONS_URL=https://github.com/zsh-users/zsh-autosuggestions
ARG ZSH_COMPLETIONS_URL=https://github.com/zsh-users/zsh-completions
ARG ZSH_SYNTAX_HIGHLIGHTING_URL=https://github.com/zsh-users/zsh-syntax-highlighting.git
ARG ZSH_BAT_URL=https://github.com/fdellwing/zsh-bat.git

# Copy zsh and p10k config to template for existing users and new users
COPY config/ ${TEMPLATE_HOME}/ 

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg wget unzip build-essential git zsh bat eza ca-certificates \
    # Install zsh and oh-my-zsh
    && sh -c "$(curl -fsSL ${OH_MY_ZSH_URL})" \
    && mv /root/.oh-my-zsh ${TEMPLATE_HOME}/.oh-my-zsh \
    # Plugins to ohmyzsh
    && git clone ${ZSH_AUTOSUGGESTIONS_URL} ${TEMPLATE_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone ${ZSH_COMPLETIONS_URL} ${TEMPLATE_HOME}/.oh-my-zsh/custom/plugins/zsh-completions \
    && git clone ${ZSH_SYNTAX_HIGHLIGHTING_URL} ${TEMPLATE_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone ${ZSH_BAT_URL} ${TEMPLATE_HOME}/.oh-my-zsh/custom/plugins/zsh-bat \
    # Install Powerlevel10k
    && git clone --depth=1 ${P10K_URL} ${TEMPLATE_HOME}/.oh-my-zsh/themes/powerlevel10k \
    # Install Eza to show info and icons in terminal with colors in container
    && mkdir -p /etc/apt/keyrings \
    && wget -qO- ${EZA_URL} | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list \
    && chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list \
    # Config Bat to change Cat
    && mkdir -p ${TEMPLATE_HOME}/.local/bin  \
    && ln -s /usr/bin/batcat ${TEMPLATE_HOME}/.local/bin/bat \
    # Change privs
    && chmod -R 755 ${TEMPLATE_HOME} \
     # Apply configuration to existing users' home directories
    # Ensure the root user also gets the configuration
    && for dir in /home/* /root; do \
            if [ -d "$dir" ]; then \
                cp -r ${TEMPLATE_HOME}/.oh-my-zsh $dir/.oh-my-zsh; \
                cp ${TEMPLATE_HOME}/.zshrc $dir/.zshrc; \
                cp ${TEMPLATE_HOME}/.local/bin/bat $dir/.local/bin/bat
                chown -R $(basename $dir):$(basename $dir) $dir/.oh-my-zsh $dir/.zshrc; \
            fi; \
        done \
    # Clean cache and temps
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* tmp/* /root/.oh-my-zsh /root/.zshrc /root/.cache

USER ${USER_UID}:${USER_GID}
SHELL ["zsh", "-c"]
ENTRYPOINT ["zsh"]