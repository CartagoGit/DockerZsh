#!/bin/zsh

# Script to add text to the end of the .zshrc file
TEXT=$(echo -e "$1")  # This will interpret \n as an actual new line
PREPEND="$2"  # Second argument is the flag for prepending text - It add text at the beginning of the file

ZSHRC_HOME=/usr/share/globally/.zshrc

if [[ "$PREPEND" == "--prepend" ]]; then
  # If --prepend flag is passed, add text at the beginning
  echo -e "$TEXT\n$(cat "$ZSHRC_HOME")" > "$ZSHRC_HOME";
else
  # Default action: Add text to the end
  echo -e "\n$TEXT" >> "$ZSHRC_HOME";
fi


## Example usage:
# add_text_to_zshrc "alias my_command='echo Hi, Cartago!'".

## Example usage with --prepend flag:
# add_text_to_zshrc "alias my_command='echo Hi, Cartago!'" --prepend

## Example usage with jump lines:
# add_text_to_zshrc "alias my_command='echo Hi, Cartago!'\nalias my_command2='echo Hi, Cartago!'" --prepend

### Other Example usage:
# add_text_to_zshrc "$(printf '%s\n' \
#     'alias my_command="echo Hi, Cartago!"' \
#     'alias my_command2="echo Goodbye, Cartago!"' \
#     'echo "This is a test"' \
#     'ls -ln')"