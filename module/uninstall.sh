#!/system/bin/sh

STATE_DIR="/data/adb/hyperos_ultimate_edition"

# Stop HUE background monitors.
pkill -f "$STATE_DIR" 2>/dev/null

# Remove module state and logs.
rm -rf "$STATE_DIR"

exit 0
