#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
# see http://redsymbol.net/articles/unofficial-bash-strict-mode/

# Written by pierriklassalas@gmail.com
# Simple brew update script.

# Add the /usr/local/bin to the PATH variable
PATH=/usr/local/bin:$PATH

# Define the variables
stdout_log="$HOME"/.brewupdate/stdout
stderr_log="$HOME"/.brewupdate/stderr
brew_exec="$(which brew)"

# Start and exit functions
start() {
echo "
~~~~~~~~~~~~~~~~~~~~~~~
Starting brew-update at $(date).
" | tee -a "$stdout_log" "$stderr_log" >/dev/null
}

finish() {
echo "
~~~~~~~~~~~~~~~~~~~~~~~
Finished brew-update at $(date).
" | tee -a "$stdout_log" "$stderr_log" >/dev/null
}

# Catch any error and print to stderr
my_trap_handler()
{
MYSELF="$0"               # equals to my script name
LASTLINE="$1"            # argument 1: last line of error occurence
LASTERR="$2"             # argument 2: error code of last command
echo "
${MYSELF}: line ${LASTLINE}: exit status of last command: ${LASTERR}
" >> "$stderr_log"
echo "
An error occured during the update. Please check the stderr log." >> "$stdout_log"
}

# Register the traps
trap 'my_trap_handler ${LINENO} $?' ERR
trap finish EXIT

# Start the script
start
# Run `brew update` command. Pipe the output to stdout, the error to stderr.
"$brew_exec" update 1>>"$stdout_log"  2>>"$stderr_log"
