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
