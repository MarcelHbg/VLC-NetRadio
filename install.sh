#!/bin/bash

# VLC Radio Installation Script
# This script installs the VLC Radio player as a user systemd service
#
# Usage:
#   ./install.sh          # Installs for current user (headless with cvlc)
#   ./install.sh --gui    # Installs with GUI enabled (uses vlc instead of cvlc)

set -e

# Parse command line arguments
GUI_MODE=false
if [ "$1" == "--gui" ]; then
    GUI_MODE=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.local/share/vlc-radio"
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

# Create user systemd directory if it doesn't exist
if [ ! -d "$SERVICE_DIR" ]; then
    mkdir -p "$SERVICE_DIR"
    echo "✓ Created user systemd directory: $SERVICE_DIR"
fi

# Create installation directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    echo "✓ Created installation directory: $INSTALL_DIR"
fi

# Copy files
if [ ! -f "$SCRIPT_DIR/RadioStreams.xspf" ]; then
    echo "Error: RadioStreams.xspf not found in $SCRIPT_DIR"
    exit 1
fi

# Copy service file to user directory
cp "$SCRIPT_DIR/$SERVICE_FILE" "$SERVICE_PATH"
echo "✓ Installed service file to: $SERVICE_PATH"

# Modify service for GUI mode if requested
if [ "$GUI_MODE" = true ]; then
    sed -i 's|/usr/bin/cvlc|/usr/bin/vlc|g' "$SERVICE_PATH"
    echo "✓ Modified service to use VLC with GUI"
fi

# Copy playlist file
if [ ! -f "$INSTALL_DIR/RadioStreams.xspf" ]; then
    msg="✓ Copied RadioStreams.xspf to $INSTALL_DIR"
else
    msg="✓ Overwrote RadioStreams.xspf in $INSTALL_DIR"
fi
cp "$SCRIPT_DIR/RadioStreams.xspf" "$INSTALL_DIR/RadioStreams.xspf"
echo $msg

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
echo ""
echo "Note: Use './install.sh --gui' to reinstall with GUI enabled."
