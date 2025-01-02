#!/bin/zsh

# Script to share a file or folder globally. Every user and new user will have access to it. If some user change or create something in the shared folder, all users will use the same file or folder.

# Get Params
SRC=$1 #For example: /.local/share/fnm
DEST_DIR_NAME=$2 # OPTIONAL - For example: fnm - If not passed, the name of the source folder will be used
ROOT=${3:-"/root"} # OPTIONAL - Default value is /root. If you want to use another folder, pass it as the third argument. For example: /home/user

# Check if SRC is passed, if not show usage message
if [ -z "${SRC}" ]; then
    echo "Usage: $0 <source_path> [destination_name --default=name of the source folder] [root_path --default='/root']"
    exit 1
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
chmod -R 755 ${FULL_DEST_DIR} 
# Apply the symbolic link to existing users
for dir in /home/* /root ${SKEL_DIR}; do 
    if [ -d "$dir" ]; then 
        mkdir -p $dir/${DIR_PATH}; 
        ln -s ${FULL_DEST_DIR} $dir/${SRC}; 
        chown -R $(basename $dir):$(basename $dir) $dir || true;
    fi; 
done
