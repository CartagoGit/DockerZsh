#!/bin/zsh

# Script to share a file or folder globally. Every user and new user will have access to it. If some user change or create something in the shared folder, all users will use the same file or folder.

# Get Params
SRC=$1 #For example: /.local/share/fnm
# Default values
DEFAULT_PERMISSIONS="777"
DEFAULT_ROOT="/root"
DEST_DIR_NAME="" # OPTIONAL - For example: fnm - If not passed, the name of the source folder will be used
ROOT="" # OPTIONAL - Default value is /root. If you want to use another folder, pass it as the third argument. For example: /home/user
PERMISSIONS=${DEFAULT_PERMISSIONS} # OPTIONAL - Default value is 777. If you want to use another permission, pass it as the first argument. For example: 755

# Function to print the usage message
usage() {
    echo "Usage: $0 src --to <destination_name> --base-src <source_base_path> [--permissions <permissions --default='777']]"
    echo ""
    echo "Parameters:"
    echo "  src             Path to the source file or folder (required) (Dont need to be the full path, just the path from the base folder, for example: /.local/share/fnm)"
    echo "  --to            Name of the destination folder (optional - default: source folder name)"
    echo "  --base-src      Path to the source file or folder (optional - default: /root)"
    echo "  --permissions   Permissions for the destination (optional, default: 777)"
    echo ""
    echo "Example:"
    echo "  $0 .local/share --to fnm --base-src /root --permissions 755"
    exit 1
}

# Function to parse options
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
            *)
                SRC="$1"
                shift
                ;;
        esac
    done
}


# Parse input options
parse_options "$@"

# Validate permissions to ensure it's a valid number (octal format)
if [[ ! "$PERMISSIONS" =~ ^[0-7]{3}$ ]]; then
    echo "Error: Invalid permissions format. Please provide a valid octal permission value (e.g., 755, 777)."
    exit 1
fi
if [ -z "$ROOT" ]; then
    ROOT=${DEFAULT_ROOT}
fi

# Check if SRC is passed, if not show usage message
if [ -z "${SRC}" ]; then
    usage
fi

# VARIABLES
SKEL_DIR=/etc/skel
IS_SRC_FOLDER=false
SHARE_FOLDER=/usr/share
FULL_DEST_DIR=${SHARE_FOLDER}/${DEST_DIR_NAME}
ROOT_SRC=${ROOT}/${SRC}
DIR_PATH=$(dirname ${SRC})
FULL_DEST_DIR_PATH=$(dirname ${FULL_DEST_DIR})
DIR_NAME=$(basename ${SRC})

# If DEST_DIR_NAME is not passed, use the name of the source folder
if [ -z "${DEST_DIR_NAME}" ]; then
    DEST_DIR_NAME=${DIR_NAME}
fi

# Check if the source file exists
if [ ! -e "${ROOT_SRC}" ]; then
    echo "The source file or folder does not exist."
    exit 1
fi

# Change IS_SRC_FOLDER to true if the source is a folder
if [ -d "${ROOT_SRC}" ]; then
    IS_SRC_FOLDER=true
fi

# Create the destination folder if it does not exist
# Move the file or folder to the destination
if [ "${IS_SRC_FOLDER}" = true ]; then
    setopt globdots # To move hidden files
    mkdir -p ${FULL_DEST_DIR} || { echo "Error creating ${FULL_DEST_DIR}"; exit 1; }
    mv ${ROOT_SRC}/* ${FULL_DEST_DIR} || { echo "Error moving folder contents"; exit 1; }
    unsetopt globdots # To stop moving hidden files
    # If it is a folder, delete the original
    rm -rf "${ROOT_SRC}" || echo "Error deleting ${ROOT_SRC}"
else
    mkdir -p ${FULL_DEST_DIR_PATH} || { echo "Error creating ${FULL_DEST_DIR_PATH}" ; exit 1; }
    rm -rf ${FULL_DEST_DIR} || echo "Error deleting ${FULL_DEST_DIR}"
    mv ${ROOT_SRC} ${FULL_DEST_DIR} || { echo "Error moving file"; exit 1; }
fi 

# Give read and write permissions to the file/folder
chmod -R ${PERMISSIONS} ${FULL_DEST_DIR} 
# Apply the symbolic link to existing users
for dir in /home/* /root ${SKEL_DIR}; do 
    if [ -d "$dir" ]; then 
        mkdir -p $dir/${DIR_PATH}; 
        ln -s ${FULL_DEST_DIR} $dir/${SRC}; 
        chown -R $(basename $dir):$(basename $dir) $dir || true;
    fi; 
done
