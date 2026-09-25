#!/system/bin/sh

STATE_DIR="/data/adb/hyperos_ultimate_edition"
LOG_FILE="$STATE_DIR/battery.log"

mkdir -p "$STATE_DIR"

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_msg "Battery monitor started."

while true; do
    BATTERY_LEVEL="$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)"
    BATTERY_TEMP="$(cat /sys/class/power_supply/battery/temp 2>/dev/null)"

    [ -z "$BATTERY_LEVEL" ] && BATTERY_LEVEL="unknown"
    [ -z "$BATTERY_TEMP" ] && BATTERY_TEMP="unknown"

    log_msg "Battery: ${BATTERY_LEVEL}% | Temperature: ${BATTERY_TEMP}"

    sleep 60
done
