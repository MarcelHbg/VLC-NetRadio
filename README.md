# VLC-NetRadio

Plays internet radio streams via VLC on user login using a systemd user service.

## Requirements

- VLC (`vlc`)
- systemd

## Files

| File | Description |
|------|-------------|
| `RadioStreams.xspf` | Playlist file containing the radio stream URLs |
| `vlc-radio.service` | systemd service unit file |
| `install.sh` | Installation script |

## Installation

Install for your user (no sudo required):

```bash
chmod +x install.sh && ./install.sh
```

This creates a user-level systemd service that automatically starts when you log in.

The script will:
1. Create your user service directory under `~/.config/systemd/user/`
2. Install `RadioStreams.xspf` to `/usr/share/vlc-radio/`
3. Install and enable the user systemd service
4. Optionally start the service immediately

## Service Management

| Command | Description |
|---------|-------------|
| `systemctl --user start vlc-radio` | Start the service |
| `systemctl --user stop vlc-radio` | Stop the service |
| `systemctl --user status vlc-radio` | Show status |
| `systemctl --user disable vlc-radio` | Disable autostart on login |
| `journalctl --user-unit=vlc-radio.service -f` | View logs |
| `journalctl --user-unit=vlc-radio.service -n 100 --no-pager` | View recent logs |

If `journalctl --user` reports `No journal files were opened due to insufficient permissions`, use `--user-unit` as shown above. If needed, add your user to the journal-reader group once and re-login:

```bash
sudo usermod -aG systemd-journal $USER
```

## Adding or Editing Streams

Edit `/usr/share/vlc-radio/RadioStreams.xspf`:

```bash
sudo nano /usr/share/vlc-radio/RadioStreams.xspf
```

Then restart the service:

```bash
systemctl --user restart vlc-radio
```
