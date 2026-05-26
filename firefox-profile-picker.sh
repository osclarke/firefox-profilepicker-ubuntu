#!/usr/bin/env bash

# Find firefox binary (works for snap, apt, and other installs)
FIREFOX_BIN=$(command -v firefox)
if [ -z "$FIREFOX_BIN" ]; then
  zenity --error --text="Firefox not found!"
  exit 1
fi

# Get the link to open
URL="$1"

# Check known profiles.ini locations (snap, then apt/standard)
for candidate in \
  "$HOME/snap/firefox/common/.mozilla/firefox/profiles.ini" \
  "$HOME/.mozilla/firefox/profiles.ini"; do
  if [ -f "$candidate" ]; then
    PROFILES_INI="$candidate"
    break
  fi
done

if [ -z "$PROFILES_INI" ]; then
  zenity --error --text="No Firefox profiles.ini found!"
  exit 1
fi

# Get list of profiles by parsing profiles.ini
PROFILES=($(awk -F= '/^\[Profile[0-9]+\]/{p=1} p&&/^Name=/{print $2; p=0}' "$PROFILES_INI"))

if [ ${#PROFILES[@]} -eq 0 ]; then
  zenity --error --text="No Firefox profiles found!"
  exit 1
fi

# Prompt user to choose a profile
PROFILE=$(zenity --list --column="Profile" "${PROFILES[@]}" --title="Open Link With..." --text="Choose a Firefox Profile" --height=300)

if [ -z "$PROFILE" ]; then
  # User cancelled
  exit 0
fi

# Find the profile path
PROFILE_PATH=$(awk -v name="$PROFILE" -F= '
/^\[Profile[0-9]+\]/{p=0}
/^Name=/ && $2==name{p=1}
/^Path=/ && p{print $2; exit}
' "$PROFILES_INI")

if [ -z "$PROFILE_PATH" ]; then
  zenity --error --text="Profile path not found!"
  exit 1
fi

# Launch firefox with the selected profile
"$FIREFOX_BIN" -P "$PROFILE" --new-tab "$URL" &
