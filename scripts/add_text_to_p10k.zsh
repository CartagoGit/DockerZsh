#!/bin/zsh

# Script to add text to the end of the .p10k.zsh file
TEXT=$(echo -e "$1")  # This will interpret \n as an actual new line
PREPEND="$2"  # Second argument is the flag for prepending text - It add text at the beginning of the file

P10K_HOME=/usr/share/globally/.p10k.zsh

if [[ "$PREPEND" == "--prepend" ]]; then
  # If --prepend flag is passed, add text at the beginning
  echo -e "$TEXT\n$(cat "$P10K_HOME")" > "$P10K_HOME";
else
  # Default action: Add text to the end
  echo -e "\n$TEXT" >> "$P10K_HOME";
fi

# Look examples in same script for zshrc