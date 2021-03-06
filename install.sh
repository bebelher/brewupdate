#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
# see http://redsymbol.net/articles/unofficial-bash-strict-mode/

# Written by pierriklassalas@gmail.com
# Simple brew update script.

# TODO(check if wget is installed when downloading the files; if not, default to curl)
# TODO(update script script_sha256)

# Repository address
REPOSITORY="https://raw.githubusercontent.com/bebelher/brewupdate/master"

# Define the constants
PATH=/usr/local/bin:$PATH
user_agents="$HOME/Library/LaunchAgents"
plist="$user_agents/brewupdate.job.plist"
install_path="$HOME"/.brewupdate

scratch="$(mktemp -d)"
SCRIPT_CHECKSUM="7a83a58a9b4f2ee47ba85a03396005e2cf25308d3dbce941d19673c1b8b1abd6"
PLIST_CHECKSUM="a4be079d17cbe683a3ce9eff206b210660335464cea863d6fbb01b67a71eb970"

echo "$SCRIPT_CHECKSUM" > "$scratch"/script_checksum
echo "$PLIST_CHECKSUM" > "$scratch"/plist_checksum

# Functions to be executed on error and exit
finish() {
echo "Removing temporary folder..."
rm -rf "$scratch"
}

# Catch any error and print to stderr
my_trap_handler()
{
MYSELF="$0"               # equals to my script name
LASTLINE="$1"            # argument 1: last line of error occurence
LASTERR="$2"             # argument 2: error code of last command
echo "
${MYSELF}: line ${LASTLINE}: exit status of last command: ${LASTERR}
"
# Insert additional code
}

# Register the traps
trap 'my_trap_handler ${LINENO} $?' ERR
trap finish EXIT

# Move the main script to the home folder
# Create the folder if it does not exist
if [ ! -d "$install_path" ]; then
  echo "$install_path not found. Creating..."
  mkdir "$install_path"
fi

# Download and verify the script
echo "Downloading the script..."

if hash wget > /dev/null 2>&1; then
  wget -q -O "$scratch"/brewupdate.sh "$REPOSITORY/brewupdate.sh"
else
  curl -s -o "$scratch"/brewupdate.sh "$REPOSITORY/brewupdate.sh"
fi

shasum -a 256 -p "$scratch"/brewupdate.sh \
  | awk '{print $1}' > "$scratch"/script_sha256

echo "Verifying checksum of the downloaded file..."
if diff -q "$scratch"/script_sha256 "$scratch"/script_checksum >/dev/null; then
  echo "Matched!"
else
  echo "The checksums did not match. Please try again."
  echo "If the problem occurs again, please report the issue."
  exit 1
fi

echo ""
echo "Copying the update script..."

if [ ! -f "$install_path"/brewupdate.sh ]; then
  echo "Script not found! Copying..."
  cp -p "$scratch"/brewupdate.sh "$install_path"
else
  if diff -q "$scratch"/brewupdate.sh "$install_path"/brewupdate.sh >/dev/null; then
    echo "The actual script is the same as the downloaded one."
    echo "Not copied."
  else
    echo "Replacing the existing script..."
    cp -pf "$scratch"/brewupdate.sh "$install_path"
  fi
fi

if [ ! -x "$install_path"/brewupdate.sh ]; then
  echo "Making the script executable..."
  chmod +x "$install_path"/brewupdate.sh
fi

# Download and verify the plist file
echo ""
echo "Downloading the plist file..."

if hash wget > /dev/null 2>&1; then
  wget -q -O "$scratch"/brewupdate.job.plist "$REPOSITORY/brewupdate.job.plist"
else
  curl -s -o "$scratch"/brewupdate.job.plist "$REPOSITORY/brewupdate.job.plist"
fi

shasum -a 256 -p "$scratch"/brewupdate.job.plist \
  | awk '{print $1}' > "$scratch"/plist_sha256

echo "Verifying checksum of the downloaded file..."
if diff -q "$scratch"/plist_sha256 "$scratch"/plist_checksum >/dev/null; then
  echo "Matched!"
else
  echo "The checksums did not match. Please try again."
  echo "If the problem occurs again, please report the issue."
  exit 1
fi

# Fill the plist file with the correct path
/usr/libexec/PlistBuddy -c \
  "Add :ProgramArguments:0 string '/bin/sh'" \
  "$scratch/brewupdate.job.plist"
/usr/libexec/PlistBuddy -c \
  "Add :ProgramArguments:1 string '$install_path/brewupdate.sh'" \
  "$scratch/brewupdate.job.plist"


# Check if the plist is already on the computer
if [ ! -f "$plist" ]; then
  echo "Plist not found! Copying..."
  cp -p "$scratch/brewupdate.job.plist" "$user_agents"
  # Check if the process is running, and unload it
  if launchctl list | grep brewupdate.job >/dev/null; then
    echo "Found a running instance of brewupdate.job."
    echo "Unloading..."
    launchctl unload brewupdate.job.plist
  fi
  echo "Loading the plist file..."
  launchctl load "$plist"
else
  if diff -q "$scratch"/brewupdate.job.plist "$plist" >/dev/null; then
    echo "The actual plist file is the same as the downloaded one."
    echo "Exit..."
  else
    echo "Unloading the plist file..."
    launchctl unload "$plist"
    echo "Replacing the existing plist file..."
    cp -pf "$scratch/brewupdate.job.plist" "$user_agents"
    echo "Loading the plist file..."
    launchctl load "$plist"
  fi
fi

echo ""
echo "Installation script finished properly. Exiting."
