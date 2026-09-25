#!/system/bin/sh

MODDIR="${0%/*}"
STATE_DIR="/data/adb/hyperos_ultimate_edition"
LOG_FILE="$STATE_DIR/service.log"

mkdir -p "$STATE_DIR"

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_msg "========================================"
log_msg "HyperOS Ultimate Edition service started"
log_msg "========================================"

# Wait for Android to finish booting.
sleep 20

DEVICE="$(getprop ro.product.device)"
KERNEL="$(uname -r)"

log_msg "Device: $DEVICE"
log_msg "Kernel: $KERNEL"

case "$DEVICE" in
    sweet|sweetin)
        log_msg "Supported device detected: $DEVICE"
        ;;
    *)
        log_msg "Unsupported device. Service stopped."
        exit 0
        ;;
esac

# Prepare script permissions.
chmod 0755 "$MODDIR/scripts/"*.sh 2>/dev/null

# Check SuperRyzeNS kernel.
if echo "$KERNEL" | grep -iq "ryze"; then
    log_msg "SuperRyzeNS kernel detected."
else
    log_msg "SuperRyzeNS kernel not detected."
    log_msg "Compatibility is not guaranteed."
fi

# Start monitoring layers.
if [ -x "$MODDIR/scripts/thermal_guard.sh" ]; then
    "$MODDIR/scripts/thermal_guard.sh" &
    log_msg "Thermal monitor started."
fi

if [ -x "$MODDIR/scripts/gaming_mode.sh" ]; then
    "$MODDIR/scripts/gaming_mode.sh" &
    log_msg "Gaming monitor started."
fi

if [ -x "$MODDIR/scripts/battery.sh" ]; then
    "$MODDIR/scripts/battery.sh" &
    log_msg "Battery monitor started."
fi

if [ -x "$MODDIR/scripts/system_tweaks.sh" ]; then
    "$MODDIR/scripts/system_tweaks.sh" &
    log_msg "System optimization layer started."
fi

log_msg "All HyperOS Ultimate Edition services initialized."
