#!/bin/zsh

# Comparte un fichero o carpeta de un usuario (por defecto /root) con
# todos los homes existentes y /etc/skel. Mueve el origen a
# /usr/share/<destino> y deja un symlink en cada home.
#
# Uso:
#   share_config_globally <src> [--to <nombre>] [--base-src <root>] [--permissions <octal>]
#
# <src> es relativo a --base-src (default /root). Ejemplo:
#   share_config_globally .local/share/fnm
#   share_config_globally .oh-my-zsh --to globally/.oh-my-zsh --permissions 755

DEFAULT_PERMISSIONS="755"
DEFAULT_ROOT="/root"

SRC=""
DEST_DIR_NAME=""
ROOT=""
PERMISSIONS="$DEFAULT_PERMISSIONS"

usage() {
    echo "Usage: $0 <src> [--to <destination_name>] [--base-src <source_base_path>] [--permissions <octal>]"
    echo ""
    echo "Parameters:"
    echo "  src             Path relative to --base-src (required). Example: .local/share/fnm"
    echo "  --to            Name under /usr/share (optional, default: basename of src)"
    echo "  --base-src      Directory that prefixes src (optional, default: /root)"
    echo "  --permissions   Octal mode for the shared copy (optional, default: 755)"
    echo ""
    echo "Example:"
    echo "  $0 .local/share/fnm --to fnm --base-src /root --permissions 755"
    exit 1
}

parse_options() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --to)
                DEST_DIR_NAME="$2"
                shift 2
                ;;
            --base-src)
                ROOT="$2"
                shift 2
                ;;
            --permissions)
                PERMISSIONS="$2"
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            *)
                SRC="$1"
                shift
                ;;
        esac
    done
}

parse_options "$@"

# Escribe en /usr/share y /etc/skel: uid 1000 usa NOPASSWD sudo.
if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    exec sudo -n "$0" "$@"
fi

if [[ ! "$PERMISSIONS" =~ ^[0-7]{3,4}$ ]]; then
    echo "Error: Invalid permissions format. Use octal (e.g. 755, 644, 777)."
    exit 1
fi

if [ -z "$ROOT" ]; then
    ROOT="$DEFAULT_ROOT"
fi

if [ -z "$SRC" ]; then
    usage
fi

# Quitar slash inicial para que ROOT/SRC no sea path absoluto.
SRC="${SRC#/}"

SKEL_DIR=/etc/skel
SHARE_FOLDER=/usr/share
DIR_NAME="$(basename "$SRC")"
DIR_PATH="$(dirname "$SRC")"

# Default de --to ANTES de calcular el destino (bug v1.0.5:
# sin --to copiaba a /usr/share/ vacio).
if [ -z "$DEST_DIR_NAME" ]; then
    DEST_DIR_NAME="$DIR_NAME"
fi

FULL_DEST_DIR="${SHARE_FOLDER}/${DEST_DIR_NAME}"
ROOT_SRC="${ROOT}/${SRC}"
FULL_DEST_DIR_PATH="$(dirname "$FULL_DEST_DIR")"

if [ ! -e "$ROOT_SRC" ]; then
    echo "The source file or folder does not exist: ${ROOT_SRC}"
    exit 1
fi

if [ -d "$ROOT_SRC" ]; then
    setopt globdots
    mkdir -p "$FULL_DEST_DIR" || { echo "Error creating ${FULL_DEST_DIR}"; exit 1; }
    mv "$ROOT_SRC"/* "$FULL_DEST_DIR" || { echo "Error moving folder contents"; exit 1; }
    unsetopt globdots
    rm -rf "$ROOT_SRC" || echo "Error deleting ${ROOT_SRC}"
else
    mkdir -p "$FULL_DEST_DIR_PATH" || { echo "Error creating ${FULL_DEST_DIR_PATH}"; exit 1; }
    rm -rf "$FULL_DEST_DIR"
    mv "$ROOT_SRC" "$FULL_DEST_DIR" || { echo "Error moving file"; exit 1; }
fi

chmod -R "$PERMISSIONS" "$FULL_DEST_DIR"

for dir in /home/* /root "$SKEL_DIR"; do
    if [ -d "$dir" ]; then
        if [ "$DIR_PATH" != "." ]; then
            mkdir -p "$dir/${DIR_PATH}"
        fi
        ln -sfn "$FULL_DEST_DIR" "$dir/${SRC}"
        # Solo el symlink, nunca -R (seguiria el link y chown del
        # arbol global al ultimo usuario del bucle).
        case "$dir" in
            /root)
                chown -h root:root "$dir/${SRC}" 2>/dev/null || true
                ;;
            /etc/skel)
                ;;
            /home/*)
                owner="$(stat -c '%U' "$dir" 2>/dev/null || true)"
                if [ -n "$owner" ] && [ "$owner" != "UNKNOWN" ]; then
                    chown -h "$owner:$owner" "$dir/${SRC}" 2>/dev/null || true
                fi
                ;;
        esac
    fi
done
