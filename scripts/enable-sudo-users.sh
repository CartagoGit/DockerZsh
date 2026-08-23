#!/bin/sh
# Passwordless sudo for every login user. New users (useradd/adduser)
# join group sudo. Optional password is NOT baked at build: set it at
# runtime with SUDO_PASSWORD or `sudo-password`.
#
# Compose `user: 1000:1000` drops supplementary groups, so the rule is
# ALL, not %sudo. 755/644 on /usr/share/globally is the right default:
# uid 1000 edits via sudo, not by making the zshrc world-writable.
set -eu

printf '%s\n' \
  'Defaults !requiretty' \
  'Defaults lecture=never' \
  'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/share/bun/bin:/usr/share/fnm/bin"' \
  'ALL ALL=(ALL:ALL) NOPASSWD:ALL' \
  > /etc/sudoers.d/container-nopasswd
chmod 0440 /etc/sudoers.d/container-nopasswd
visudo -cf /etc/sudoers.d/container-nopasswd

if [ -f /etc/adduser.conf ]; then
  sed -i 's/^#*EXTRA_GROUPS=.*/EXTRA_GROUPS="sudo"/; s/^#*ADD_EXTRA_GROUPS=.*/ADD_EXTRA_GROUPS=1/; s|^#*DSHELL=.*|DSHELL=/usr/bin/zsh|' /etc/adduser.conf
fi

if [ -x /usr/sbin/useradd ] && [ ! -e /usr/sbin/useradd.real ]; then
  mv /usr/sbin/useradd /usr/sbin/useradd.real
fi

cat > /usr/local/sbin/useradd <<'WRAP'
#!/bin/sh
# After a successful useradd, put LOGIN in group sudo (and apply the
# optional container password). LOGIN is the leftover positional after
# options that take a value — not "the last token that is not a flag".
# `useradd -m alice -c "Full Name"` → alice, not "Full Name".
real=/usr/sbin/useradd.real
# Default login shell is zsh unless the caller passed -s/--shell.
# Do not inject -s on -D/--defaults: `useradd -D` lists defaults;
# `useradd -D -s …` would *set* the default shell.
shell_given=0
defaults_mode=0
prev=
for a in "$@"; do
  if [ "$prev" = 1 ]; then
    prev=
    continue
  fi
  case "$a" in
    --shell=*) shell_given=1 ;;
    --defaults) defaults_mode=1 ;;
    -s|--shell)
      shell_given=1
      prev=1
      ;;
    -D|--defaults)
      defaults_mode=1
      ;;
    -*)
      case "$a" in
        --*) ;;
        *s*) shell_given=1; prev=1 ;;
      esac
      case "$a" in
        --*) ;;
        *D*) defaults_mode=1 ;;
      esac
      ;;
  esac
done
if [ "$shell_given" = 0 ] && [ "$defaults_mode" = 0 ]; then
  "$real" -s /usr/bin/zsh "$@"
else
  "$real" "$@"
fi
st=$?
[ "$st" -eq 0 ] || exit "$st"
user=
while [ $# -gt 0 ]; do
  case "$1" in
    --)
      shift
      [ $# -gt 0 ] && user=$1
      break
      ;;
    --comment=*|--home-dir=*|--home=*|--base-dir=*|--expiredate=*|--inactive=*|--gid=*|--groups=*|--skel=*|--key=*|--password=*|--shell=*|--uid=*|--selinux-user=*|--root=*|--prefix=*|--selinux-range=*)
      shift
      ;;
    -c|--comment|-d|--home-dir|--home|-b|--base-dir|-e|--expiredate|-f|--inactive|-g|--gid|-G|--groups|-k|--skel|-K|--key|-p|--password|-s|--shell|-u|--uid|-Z|--selinux-user|-R|--root|-P|--prefix|--selinux-range)
      shift
      [ $# -gt 0 ] || break
      shift
      ;;
    --*)
      shift
      ;;
    -*)
      opt=${1#-}
      shift
      while [ -n "$opt" ]; do
        ch=${opt%"${opt#?}"}
        rest=${opt#?}
        case "$ch" in
          c|d|b|e|f|g|G|k|K|p|s|u|Z|R|P)
            if [ -n "$rest" ]; then
              opt=
            else
              [ $# -gt 0 ] && shift
              opt=
            fi
            ;;
          *)
            opt=$rest
            ;;
        esac
      done
      ;;
    *)
      user=$1
      shift
      ;;
  esac
done
if [ -n "$user" ] && id "$user" >/dev/null 2>&1; then
  usermod -aG sudo "$user" 2>/dev/null || true
  if [ -f /etc/sudoers.d/container-password ] && [ -f /etc/container-sudo-password ]; then
    pw=$(cat /etc/container-sudo-password)
    printf '%s\n' "${user}:${pw}" | chpasswd
  fi
fi
exit 0
WRAP
chmod 0755 /usr/local/sbin/useradd
ln -sfn /usr/local/sbin/useradd /usr/sbin/useradd

awk -F: '$3>=0 && $3<65534 && $7 !~ /(nologin|false)/ {print $1}' /etc/passwd \
  | while read -r u; do
      usermod -aG sudo "$u" 2>/dev/null || true
    done
