# Base Ubuntu LTS. Pinneada al tag 24.04 (no latest).
# Tag de esta imagen: v2.0.0 (Hub sigue en v1.0.5 hasta git tag + push).
FROM ubuntu:24.04

ARG VERSION=2.0.0
ARG ROOT_HOME=/root
ARG SCRIPTS_HOME=/usr/local/bin

# Oh My Zsh + plugins + p10k: URLs y commits pinneados a lo que
# llevaba cartagodocker/zsh:v1.0.5, para no cambiar el look.
ARG OH_MY_ZSH_URL=https://github.com/ohmyzsh/ohmyzsh.git
ARG OH_MY_ZSH_SHA=d82669199b5d900b50fd06dd3518c277f0def869
ARG P10K_URL=https://github.com/romkatv/powerlevel10k.git
ARG P10K_SHA=c85cd0f02844ff2176273a450c955b6532a185dc
ARG ZSH_AUTOSUGGESTIONS_URL=https://github.com/zsh-users/zsh-autosuggestions
ARG ZSH_AUTOSUGGESTIONS_SHA=0e810e5afa27acbd074398eefbe28d13005dbc15
ARG ZSH_COMPLETIONS_URL=https://github.com/zsh-users/zsh-completions
ARG ZSH_COMPLETIONS_SHA=c160d09fddd28ceb3af5cf80e9253af80e450d96
ARG ZSH_SYNTAX_HIGHLIGHTING_URL=https://github.com/zsh-users/zsh-syntax-highlighting.git
ARG ZSH_SYNTAX_HIGHLIGHTING_SHA=5eb677bb0fa9a3e60f0eff031dc13926e093df92
ARG ZSH_BAT_URL=https://github.com/fdellwing/zsh-bat.git
ARG ZSH_BAT_SHA=467337613c1c220c0d01d69b19d2892935f43e9f

# zsh/p10k to /root (share_config_globally las publica).
# SSH: known_hosts oficiales + ssh_config.d. Las claves del host se
# montan en ~/.ssh:ro; ssh-wrap las copia a un dir 700 (OpenSSH rechaza
# 644/777 y no puede escribir known_hosts en un volumen :ro).
COPY config/.zshrc config/.p10k.zsh ${ROOT_HOME}/
COPY config/ssh/known_hosts /tmp/zsh-ssh-known_hosts
COPY config/ssh/50-container.conf /tmp/zsh-ssh-50-container.conf
COPY scripts/ ${SCRIPTS_HOME}/

# Comentarios FUERA del bloque RUN (un # a mitad de \ trunca el
# instruction en parsers Docker/BuildKit). Contrato:
#   1. ca-certificates se queda (HTTPS en runtime: git, curl, apt).
#   2. eza del archive de Ubuntu (no repo gierens).
#   3. openssh-client (no el metapaquete ssh = server).
#   4. batcat -> /usr/local/bin/bat (PATH de cualquier uid).
#   5. clones pinneados --depth=1.
#   6. sin || true ciego; fallos de curl/git rompen el build.
#   7. sudo NOPASSWD (ALL, no %sudo): uid 1000 escribe globales con sudo,
#      no con 777 en .zshrc. Optional password via SUDO_PASSWORD / sudo-password.
#   8. LANG=C.UTF-8: eza/p10k/emoji necesitan UTF-8 (POSIX trunca iconos).
#   9. CLI extras: daily-driver kit for any uid / any host. No gcc, no
#      python, no locales, no man-db, no git-lfs/rclone/neovim (those
#      belong in child images). Extra layer vs previous extras ~34 MB.
#  10. No Docker inside the image (no docker-ce-cli, no dockerd).
#      Use docker on the host. A child image can apt-install a client
#      if it really needs one.
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl wget git openssh-client zsh bat eza ca-certificates sudo \
        less file nano vim-tiny tree patch fd-find ripgrep fzf zoxide \
        unzip zip xz-utils bzip2 zstd lz4 pigz cpio 7zip cabextract \
        jq jo libxml2-utils sqlite3 \
        iputils-ping iputils-tracepath fping bind9-dnsutils rsync \
        netcat-openbsd socat traceroute mtr-tiny whois iproute2 openssl \
        tcpdump apache2-utils iperf3 \
        psmisc lsof htop ncdu duf tzdata bsdextrautils moreutils pv bc \
        uuid-runtime acl libcap2-bin inotify-tools entr \
        gnupg gettext-base make strace xxd uchardet dos2unix colordiff expect \
        progress keychain rlwrap tig git-extras tmux nnn \
    && for script in ${SCRIPTS_HOME}/*.zsh; do \
         if [ -f "$script" ]; then \
           mv "$script" "${script%.zsh}"; \
         fi; \
       done \
    && chmod a+rx ${SCRIPTS_HOME}/add_text_to_zshrc \
                  ${SCRIPTS_HOME}/add_text_to_p10k \
                  ${SCRIPTS_HOME}/share_config_globally \
                  ${SCRIPTS_HOME}/enable-sudo-users.sh \
                  ${SCRIPTS_HOME}/sudo-password \
                  ${SCRIPTS_HOME}/sudo-nopasswd \
                  ${SCRIPTS_HOME}/apply-sudo-password-on-boot.sh \
                  ${SCRIPTS_HOME}/zsh-profile.sh \
                  ${SCRIPTS_HOME}/dockerzsh \
                  ${SCRIPTS_HOME}/ssh-from-host \
                  ${SCRIPTS_HOME}/ssh-wrap \
                  ${SCRIPTS_HOME}/git-from-host \
                  ${SCRIPTS_HOME}/git-wrap \
    && ln -sfn ${SCRIPTS_HOME}/ssh-wrap ${SCRIPTS_HOME}/ssh \
    && ln -sfn ${SCRIPTS_HOME}/ssh-wrap ${SCRIPTS_HOME}/scp \
    && ln -sfn ${SCRIPTS_HOME}/ssh-wrap ${SCRIPTS_HOME}/sftp \
    && ln -sfn ${SCRIPTS_HOME}/git-wrap ${SCRIPTS_HOME}/git \
    && install -d -m 0755 /usr/share/ssh /etc/ssh/ssh_config.d \
    && install -m 0644 /tmp/zsh-ssh-known_hosts /usr/share/ssh/known_hosts \
    && install -m 0644 /tmp/zsh-ssh-known_hosts /etc/ssh/ssh_known_hosts \
    && install -m 0644 /tmp/zsh-ssh-50-container.conf /etc/ssh/ssh_config.d/50-container.conf \
    && rm -f /tmp/zsh-ssh-known_hosts /tmp/zsh-ssh-50-container.conf \
    && clone_pinned() { \
         _url="$1"; _dest="$2"; _sha="$3"; \
         mkdir -p "$_dest"; \
         git init "$_dest"; \
         git -C "$_dest" remote add origin "$_url"; \
         git -C "$_dest" fetch --depth=1 origin "$_sha"; \
         git -C "$_dest" checkout --detach FETCH_HEAD; \
       } \
    && clone_pinned ${OH_MY_ZSH_URL} ${ROOT_HOME}/.oh-my-zsh ${OH_MY_ZSH_SHA} \
    && clone_pinned ${ZSH_AUTOSUGGESTIONS_URL} ${ROOT_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions ${ZSH_AUTOSUGGESTIONS_SHA} \
    && clone_pinned ${ZSH_COMPLETIONS_URL} ${ROOT_HOME}/.oh-my-zsh/custom/plugins/zsh-completions ${ZSH_COMPLETIONS_SHA} \
    && clone_pinned ${ZSH_SYNTAX_HIGHLIGHTING_URL} ${ROOT_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ${ZSH_SYNTAX_HIGHLIGHTING_SHA} \
    && clone_pinned ${ZSH_BAT_URL} ${ROOT_HOME}/.oh-my-zsh/custom/plugins/zsh-bat ${ZSH_BAT_SHA} \
    && clone_pinned ${P10K_URL} ${ROOT_HOME}/.oh-my-zsh/themes/powerlevel10k ${P10K_SHA} \
    && share_config_globally .oh-my-zsh --to globally/.oh-my-zsh --base-src /root --permissions 755 \
    && share_config_globally .p10k.zsh --to globally/.p10k.zsh --permissions 644 \
    && share_config_globally .zshrc --to globally/.zshrc --permissions 644 \
    && ln -sfn /usr/bin/batcat /usr/local/bin/bat \
    && ln -sfn /usr/bin/fdfind /usr/local/bin/fd \
    && chsh -s /usr/bin/zsh root \
    && if getent passwd ubuntu >/dev/null 2>&1; then chsh -s /usr/bin/zsh ubuntu; fi \
    && ${SCRIPTS_HOME}/enable-sudo-users.sh \
    && install -m 0644 ${SCRIPTS_HOME}/zsh-profile.sh /etc/profile.d/zsh-image.sh \
    && if [ -f /etc/bash.bashrc ]; then printf '\n# zsh-image login/non-login bash\n. /etc/profile.d/zsh-image.sh\n' >> /etc/bash.bashrc; fi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# SHELL de build POSIX: las hijas (DockerNodeBun) hacen RUN con quotes
# y $(...). zsh -c se parte o se traga errores. El usuario interactivo
# entra por CMD zsh, no por SHELL ni ENTRYPOINT.
# Sin ENTRYPOINT: `docker run imagen bash` lanza bash, no "can't open input file".
# VERSION = this image. Child images (nodebun) often set their own
# VERSION; ZSH_IMAGE_VERSION stays the zsh tag so dockerzsh --version
# does not lie after FROM.
ENV VERSION=${VERSION} \
    ZSH_IMAGE_VERSION=${VERSION} \
    SHELL=/usr/bin/zsh \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    GIT_SSH_COMMAND=/usr/local/bin/ssh
SHELL ["/bin/sh", "-c"]
CMD ["/usr/bin/zsh"]