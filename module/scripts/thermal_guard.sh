#!/system/bin/sh

MODDIR="${0%/*}"
STATE_DIR="/data/adb/hyperos_ultimate_edition"
LOG_FILE="$STATE_DIR/thermal.log"

mkdir -p "$STATE_DIR"

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_msg "Thermal guard initialized."

# Only operate on supported devices.
DEVICE="$(getprop ro.product.device)"

case "$DEVICE" in
    sweet|sweetin)
        ;;
    *)
        log_msg "Unsupported device: $DEVICE"
        exit 0
        ;;
esac

# Detect available thermal zones.
THERMAL_ZONES="/sys/class/thermal"

if [ ! -d "$THERMAL_ZONES" ]; then
    log_msg "Thermal interface unavailable."
    exit 0
fi

log_msg "Thermal interface detected."

# This version only monitors temperature.
# CPU limits will be added after the supported
# SuperRyzeNS interfaces are verified.

while true; do
    MAX_TEMP=0

    for zone in "$THERMAL_ZONES"/thermal_zone*; do
        [ -f "$zone/temp" ] || continue

        TEMP="$(cat "$zone/temp" 2>/dev/null)"

        case "$TEMP" in
            ''|*[!0-9]*)
                continue
                ;;
        esac

        # Most Android thermal values are reported in millidegrees Celsius.
        if [ "$TEMP" -gt "$MAX_TEMP" ]; then
            MAX_TEMP="$TEMP"
        fi
    done

    if [ "$MAX_TEMP" -gt 0 ]; then
        log_msg "Maximum thermal-zone temperature: ${MAX_TEMP}m°C"
    fi

    sleep 10
done
