#!/bin/bash

# VLC Radio Deinstallation Script
# This script removes the VLC Radio player user systemd service
#
# Usage:
#   ./deinstall.sh       # Removes the VLC Radio service and files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.local/share/vlc-radio"
SERVICE_FILE="vlc-radio.service"
SERVICE_DIR="${HOME}/.config/systemd/user"
SERVICE_PATH="$SERVICE_DIR/$SERVICE_FILE"

echo "Deinstalling VLC Radio user systemd service..."
echo "  User: $(whoami)"

# Check if service is running and stop it
if systemctl --user is-active --quiet vlc-radio.service 2>/dev/null; then
    echo "Stopping VLC Radio service..."
    systemctl --user stop vlc-radio.service
    echo "✓ Stopped VLC Radio service"
fi

# Disable the service
if systemctl --user is-enabled --quiet vlc-radio.service 2>/dev/null; then
    echo "Disabling VLC Radio service..."
    systemctl --user disable vlc-radio.service
    echo "✓ Disabled VLC Radio service"
fi

# Remove service file
if [ -f "$SERVICE_PATH" ]; then
    rm "$SERVICE_PATH"
    echo "✓ Removed service file: $SERVICE_PATH"
fi

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "✓ Removed installation directory: $INSTALL_DIR"
fi

# Reload user systemd daemon
systemctl --user daemon-reload
echo "✓ Reloaded user systemd daemon"

# Clean up empty systemd directory
if [ -d "$SERVICE_DIR" ] && [ -z "$(ls -A "$SERVICE_DIR")" ]; then
    rmdir "$SERVICE_DIR"
    echo "✓ Removed empty systemd directory: $SERVICE_DIR"
fi

echo ""
echo "Deinstallation complete!"
echo ""
echo "VLC Radio has been completely removed from your system."