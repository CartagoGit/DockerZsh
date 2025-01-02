# Base Ubuntu LTS
FROM ubuntu:24.04

ARG ROOT_HOME=/root
ARG SCRIPTS_HOME=/usr/local/bin

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
COPY config/ ${ROOT_HOME}/ 
COPY scripts/ ${SCRIPTS_HOME}/

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg wget git ssh zsh bat eza ca-certificates \
    # Change scripts to remove .zsh extension
    && for script in ${SCRIPTS_HOME}/*.zsh; do \
         if [ -f "$script" ]; then \
           mv "$script" "${script%.zsh}"; \
         fi; \
       done \
    # Install zsh and oh-my-zsh
    && sh -c "$(curl -fsSL ${OH_MY_ZSH_URL}) --keep-zshrc" \
    # Plugins to ohmyzsh
    && git clone ${ZSH_AUTOSUGGESTIONS_URL} ${ROOT_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone ${ZSH_COMPLETIONS_URL} ${ROOT_HOME}/.oh-my-zsh/custom/plugins/zsh-completions \
    && git clone ${ZSH_SYNTAX_HIGHLIGHTING_URL} ${ROOT_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone ${ZSH_BAT_URL} ${ROOT_HOME}/.oh-my-zsh/custom/plugins/zsh-bat \
    # Install Powerlevel10k
    && git clone --depth=1 ${P10K_URL} ${ROOT_HOME}/.oh-my-zsh/themes/powerlevel10k  \
    && share_config_globally .oh-my-zsh --to globally/.oh-my-zsh --base-src /root --permissions 755 \
    && share_config_globally .p10k.zsh --to globally/.p10k.zsh --permissions 755  \
    && share_config_globally .zshrc --to globally/.zshrc  \
    # Install Eza to show info and icons in terminal with colors in container
    && mkdir -p /etc/apt/keyrings \
    && wget -qO- ${EZA_URL} | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list \
    && chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list \
    # Change privs
    && chmod -R 755 ${SCRIPTS_HOME} \
    # Apply configuration to existing users' home directories
    # Ensure the root user also gets the configuration
    && for dir in /home/* /root /etc/skel; do \
    if [ -d "$dir" ]; then \
                # Config Bat to change Cat for every user
                mkdir -p "$dir/.local/bin"; \
                ln -s /usr/bin/batcat $dir/.local/bin/bat; \
                chown -R $(basename $dir):$(basename $dir) $dir || true; \
            fi; \
        done \
    # Remove packages used to install and clean them
    && apt-get remove --purge -y \
    gnupg ca-certificates \
    && apt-get autoremove -y \
    # Clean cache and temps
    && apt-get clean \
    && rm -rf '/var/lib/apt/lists/*' 'tmp/*'

SHELL ["zsh", "-c"]
ENTRYPOINT ["zsh"]