#!/system/bin/sh

ui_print " "
ui_print "================================="
ui_print " HyperOS Ultimate Edition"
ui_print " Version: v1.0.0"
ui_print " Author: OptimusPrime207"
ui_print "================================="
ui_print " "

# Device check
DEVICE="$(getprop ro.product.device)"

case "$DEVICE" in
    sweet|sweetin)
        ui_print "- Supported device: $DEVICE"
        ;;
    *)
        ui_print "! Unsupported device detected: $DEVICE"
        abort "! This module supports only sweet/sweetin."
        ;;
esac

# Kernel check
KERNEL="$(uname -r)"

if echo "$KERNEL" | grep -iq "ryze"; then
    ui_print "- SuperRyzeNS kernel detected"
else
    ui_print "! SuperRyzeNS kernel not detected"
    ui_print "! Continuing without guarantee"
fi

ui_print "- Installation complete"
