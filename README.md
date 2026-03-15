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
./install.sh
```

Or install with GUI enabled:

```bash
./install.sh --gui
```

This creates a user-level systemd service that automatically starts when you log in.

The script will:
1. Create your user service directory under `~/.config/systemd/user/`
2. Install `RadioStreams.xspf` to `~/.local/share/vlc-radio/`
3. Install and enable the user systemd service
4. Optionally start the service immediately

**Note**: The `--gui` option modifies the service to use `vlc` (with GUI) instead of `cvlc` (headless). GUI mode may not display properly in background services without a display server.

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

Edit `~/.local/share/vlc-radio/RadioStreams.xspf`:

```bash
nano ~/.local/share/vlc-radio/RadioStreams.xspf
```

Then restart the service:

```bash
systemctl --user restart vlc-radio
```
