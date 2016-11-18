#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
# see http://redsymbol.net/articles/unofficial-bash-strict-mode/

# Written by pierriklassalas@gmail.com
# Simple brew update script.

# Add the /usr/local/bin to the PATH variable.
PATH=/usr/local/bin:$PATH

# Set the installation path.
install_path="$HOME"/.brewupdate/

# Get the current absolute path.
current_path="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/)"

# Create the folder if it does not exist.
if [ ! -d "$install_path" ]; then
  mkdir "$install_path"
fi

# Move the main script to the home folder.
# Make the script executable if needed.
if [ ! -f "$install_path"/brewupdate.sh ]; then
  cp -p "$current_path"/brewupdate.sh "$install_path"
  if [ ! -x "$install_path"/brewupdate.sh ]; then
    chmod +x "$install_path"/brewupdate.sh
  fi
else
  cp -pf "$current_path"/brewupdate.sh "$install_path"
  if [ ! -x "$install_path"/brewupdate.sh ]; then
    chmod +x "$install_path"/brewupdate.sh
  fi
fi
