#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
INSTALLED_BIN="$INSTALL_DIR/firefox-profile-picker"
DESKTOP_SRC="$REPO_DIR/firefox-profile-picker.desktop"
DESKTOP_DEST="$DESKTOP_DIR/firefox-profile-picker.desktop"

echo "Installing Firefox Profile Picker..."

# Check for zenity dependency
if ! command -v zenity &>/dev/null; then
  echo "  Warning: zenity is not installed. Run: sudo apt install zenity"
fi

mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR"

# Install the script (drop .sh extension — standard for installed executables)
cp "$REPO_DIR/firefox-profile-picker.sh" "$INSTALLED_BIN"
chmod +x "$INSTALLED_BIN"
echo "  Script installed to $INSTALLED_BIN"

# Install the desktop file with the Exec path updated to match the install location
sed "s|^Exec=.*|Exec=$INSTALLED_BIN %u|" "$DESKTOP_SRC" > "$DESKTOP_DEST"
echo "  Desktop entry installed to $DESKTOP_DEST"

# Rebuild the user desktop database so GNOME sees the new entry
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

# Register as default handler for http and https links
xdg-mime default firefox-profile-picker.desktop x-scheme-handler/http
xdg-mime default firefox-profile-picker.desktop x-scheme-handler/https
echo "  Registered as default handler for http:// and https://"

# Warn if ~/.local/bin isn't on PATH yet (common on fresh Ubuntu installs before first logout)
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo ""
  echo "  Note: $INSTALL_DIR is not in your PATH."
  echo "  Add this to your ~/.bashrc or ~/.zshrc, then restart your shell:"
  echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo "Done. Firefox Profile Picker is now your default browser."
