#!/bin/sh
# Login/non-login POSIX profile: UTF-8 + optional sudo password on boot.
# Installed as /etc/profile.d/zsh-image.sh (sourced by login bash/sh).
# zshrc also calls apply-sudo-password-on-boot.sh for interactive zsh.

if [ -z "${LANG:-}" ] || [ "${LANG}" = "C" ] || [ "${LANG}" = "POSIX" ]; then
  LANG=C.UTF-8
  export LANG
fi
if [ -z "${LC_ALL:-}" ]; then
  LC_ALL=C.UTF-8
  export LC_ALL
fi
# docker run -t injects TERM=xterm (8 colors). Same override as v1.0.5 zshrc.
TERM=xterm-256color
export TERM

# Child images may overwrite VERSION. Keep the zsh tag if Docker ENV survived.
if [ -n "${ZSH_IMAGE_VERSION:-}" ]; then
  export ZSH_IMAGE_VERSION
fi
if [ -z "${GITSTATUS_CACHE_DIR:-}" ]; then
  GITSTATUS_CACHE_DIR=/usr/share/gitstatus
  export GITSTATUS_CACHE_DIR
fi

if [ -x /usr/local/bin/apply-sudo-password-on-boot.sh ]; then
  /usr/local/bin/apply-sudo-password-on-boot.sh || true
fi

if [ -x /usr/local/bin/ssh-from-host ]; then
  /usr/local/bin/ssh-from-host || true
fi
_ssh_env="/tmp/container-ssh-$(id -u)/env"
if [ -r "$_ssh_env" ]; then
  # shellcheck disable=SC1090
  . "$_ssh_env"
fi
unset _ssh_env

if [ -x /usr/local/bin/git-from-host ]; then
  /usr/local/bin/git-from-host || true
fi
_git_env="/tmp/container-git-$(id -u)/env"
if [ -r "$_git_env" ]; then
  # shellcheck disable=SC1090
  . "$_git_env"
fi
unset _git_env
