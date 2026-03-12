#!/bin/bash

# VLC Radio Installation Script
# This script installs the VLC Radio player as a user systemd service
#
# Usage:
#   ./install.sh          # Installs for current user

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/share/vlc-radio"
SERVICE_FILE="vlc-radio.service"
SERVICE_DIR="${HOME}/.config/systemd/user"
SERVICE_PATH="$SERVICE_DIR/$SERVICE_FILE"
TARGET_USER=$(whoami)
TARGET_GROUP=$(id -gn)

echo "Installing VLC Radio as a user systemd service..."
echo "  User: $TARGET_USER"
echo "  Group: $TARGET_GROUP"

# Check if VLC is installed
if ! command -v vlc &>/dev/null; then
    echo "Error: VLC is not installed. Please install VLC and try again."
    exit 1
fi
echo "✓ VLC found: $(command -v vlc)"

# Create user systemd directory
mkdir -p "$SERVICE_DIR"
echo "✓ Created user systemd directory: $SERVICE_DIR"

# Copy files (may need sudo for /usr/share)
if [ ! -f "$SCRIPT_DIR/RadioStreams.xspf" ]; then
    echo "Error: RadioStreams.xspf not found in $SCRIPT_DIR"
    exit 1
fi

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Note: Installation directory needs sudo to create: $INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
fi

# Copy service file to user directory
cp "$SCRIPT_DIR/$SERVICE_FILE" "$SERVICE_PATH"
echo "✓ Installed service file to: $SERVICE_PATH"

# Copy playlist file (may need sudo)
if [ -w "$INSTALL_DIR" ]; then
    cp "$SCRIPT_DIR/RadioStreams.xspf" "$INSTALL_DIR/RadioStreams.xspf"
    chmod 644 "$INSTALL_DIR/RadioStreams.xspf"
    echo "✓ Copied RadioStreams.xspf to $INSTALL_DIR"
else
    echo "Note: Cannot write to $INSTALL_DIR without sudo"
    sudo cp "$SCRIPT_DIR/RadioStreams.xspf" "$INSTALL_DIR/RadioStreams.xspf"
    sudo chmod 644 "$INSTALL_DIR/RadioStreams.xspf"
    sudo chown "$TARGET_USER:$TARGET_GROUP" "$INSTALL_DIR/RadioStreams.xspf"
    sudo chown "$TARGET_USER:$TARGET_GROUP" "$INSTALL_DIR"
    echo "✓ Copied RadioStreams.xspf to $INSTALL_DIR"
    echo "✓ Fixed ownership to $TARGET_USER:$TARGET_GROUP"
fi

# Reload user systemd daemon
systemctl --user daemon-reload
echo "✓ Reloaded user systemd daemon"

# Enable the service to start on login
systemctl --user enable vlc-radio.service
echo "✓ Enabled VLC Radio service on user login"

# Optional: Start the service now
read -p "Start VLC Radio service now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    systemctl --user start vlc-radio.service
    echo "✓ Started VLC Radio service"
    systemctl --user status vlc-radio.service
fi

echo ""
echo "Installation complete!"
echo ""
echo "Service management commands:"
echo "  Start:   systemctl --user start vlc-radio"
echo "  Stop:    systemctl --user stop vlc-radio"
echo "  Status:  systemctl --user status vlc-radio"
echo "  Logs:    journalctl --user-unit=vlc-radio.service -f"
echo "  Recent:  journalctl --user-unit=vlc-radio.service -n 100 --no-pager"
echo "  Disable: systemctl --user disable vlc-radio"
