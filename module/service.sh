#!/system/bin/sh

MODDIR="${0%/*}"
LOG_DIR="/data/adb/hyperos_ultimate_edition"
LOG_FILE="$LOG_DIR/service.log"

mkdir -p "$LOG_DIR"

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_msg "========================================"
log_msg "HyperOS Ultimate Edition service started"
log_msg "========================================"

# Give Android services time to finish booting.
sleep 20

DEVICE="$(getprop ro.product.device)"
KERNEL="$(uname -r)"

log_msg "Device: $DEVICE"
log_msg "Kernel: $KERNEL"

case "$DEVICE" in
    sweet|sweetin)
        log_msg "Supported device detected."
        ;;
    *)
        log_msg "Unsupported device. Service stopped."
        exit 0
        ;;
esac

if echo "$KERNEL" | grep -iq "ryze"; then
    log_msg "SuperRyzeNS kernel detected."
else
    log_msg "SuperRyzeNS kernel not detected."
    log_msg "Compatibility is not guaranteed."
fi

log_msg "HyperOS Ultimate Edition initialization complete."
