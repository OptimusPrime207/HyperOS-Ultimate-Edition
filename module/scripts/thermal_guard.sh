#!/system/bin/sh

MODDIR="${0%/*}"
STATE_DIR="/data/adb/hyperos_ultimate_edition"
LOG_FILE="$STATE_DIR/thermal.log"

mkdir -p "$STATE_DIR"

POLICY0="/sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq"
POLICY6="/sys/devices/system/cpu/cpufreq/policy6/scaling_max_freq"

ORIGINAL0="$STATE_DIR/original_policy0_max"
ORIGINAL6="$STATE_DIR/original_policy6_max"

THERMAL_ZONE="/sys/class/thermal/thermal_zone73/temp"

POLL_INTERVAL=3

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

is_supported_device() {
    DEVICE="$(getprop ro.product.device)"

    case "$DEVICE" in
        sweet|sweetin)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_superryzens() {
    uname -r | grep -iq "superryzens"
}

read_temp() {
    TEMP="$(cat "$THERMAL_ZONE" 2>/dev/null)"

    case "$TEMP" in
        ''|*[!0-9]*)
            echo 0
            ;;
        *)
            echo "$TEMP"
            ;;
    esac
}

save_original_limits() {

    if [ ! -f "$ORIGINAL0" ] && [ -f "$POLICY0" ]; then
        cat "$POLICY0" > "$ORIGINAL0"
    fi

    if [ ! -f "$ORIGINAL6" ] && [ -f "$POLICY6" ]; then
        cat "$POLICY6" > "$ORIGINAL6"
    fi
}

restore_original_limits() {

    if [ -f "$ORIGINAL0" ]; then
        ORIGINAL="$(cat "$ORIGINAL0" 2>/dev/null)"

        case "$ORIGINAL" in
            ''|*[!0-9]*)
                ;;
            *)
                echo "$ORIGINAL" > "$POLICY0" 2>/dev/null
                ;;
        esac
    fi

    if [ -f "$ORIGINAL6" ]; then
        ORIGINAL="$(cat "$ORIGINAL6" 2>/dev/null)"

        case "$ORIGINAL" in
            ''|*[!0-9]*)
                ;;
            *)
                echo "$ORIGINAL" > "$POLICY6" 2>/dev/null
                ;;
        esac
    fi
}

set_cpu_ceiling() {

    LEVEL="$1"

    case "$LEVEL" in

        80)
            # ~80% of each policy's maximum.
            # Mapped to the nearest supported frequency
            # not exceeding the target.
            echo 1497600 > "$POLICY0" 2>/dev/null
            echo 1843200 > "$POLICY6" 2>/dev/null
            ;;

        70)
            echo 1248000 > "$POLICY0" 2>/dev/null
            echo 1555200 > "$POLICY6" 2>/dev/null
            ;;

        62)
            echo 1017600 > "$POLICY0" 2>/dev/null
            echo 1324800 > "$POLICY6" 2>/dev/null
            ;;

        55)
            echo 1017600 > "$POLICY0" 2>/dev/null
            echo 1209600 > "$POLICY6" 2>/dev/null
            ;;

        50)
            echo 768000 > "$POLICY0" 2>/dev/null
            echo 1094400 > "$POLICY6" 2>/dev/null
            ;;

    esac
}

get_gaming_state() {

    if [ -f "$STATE_DIR/gaming_active" ]; then
        echo 1
    else
        echo 0
    fi
}

cleanup() {

    restore_original_limits

    rm -f \
        "$STATE_DIR/original_policy0_max" \
        "$STATE_DIR/original_policy6_max" \
        "$STATE_DIR/thermal_level"

    log_msg "Thermal guard stopped. Original CPU limits restored."

    exit 0
}

trap cleanup INT TERM EXIT


# --------------------------------------------------
# INITIAL VALIDATION
# --------------------------------------------------

if ! is_supported_device; then
    log_msg "Unsupported device. Thermal guard disabled."
    exit 0
fi

if ! is_superryzens; then
    log_msg "SuperRyzeNS kernel not detected. Thermal guard disabled."
    exit 0
fi

if [ ! -f "$POLICY0" ] || [ ! -f "$POLICY6" ]; then
    log_msg "Required CPUFreq interfaces unavailable."
    exit 0
fi

if [ ! -f "$THERMAL_ZONE" ]; then
    log_msg "cpu_therm sensor unavailable."
    exit 0
fi


# --------------------------------------------------
# START
# --------------------------------------------------

save_original_limits

log_msg "Thermal guard v2 initialized."
log_msg "Original policy0 max: $(cat "$ORIGINAL0" 2>/dev/null)"
log_msg "Original policy6 max: $(cat "$ORIGINAL6" 2>/dev/null)"

CURRENT_LEVEL=""

LAST_TEMP=0
LAST_GAME=0

TEMP_LEVEL=80
PENDING_LEVEL=80
PENDING_COUNT=0


# --------------------------------------------------
# MAIN LOOP
# --------------------------------------------------

while true; do

    GAME="$(get_gaming_state)"
    TEMP="$(read_temp)"

    if [ "$TEMP" -le 0 ]; then
        sleep "$POLL_INTERVAL"
        continue
    fi


    # ----------------------------------------------
    # Gaming started
    # ----------------------------------------------

    if [ "$GAME" = "1" ] && [ "$LAST_GAME" = "0" ]; then

        log_msg "Gaming mode detected."

        # Start gaming with 80% ceiling.
        set_cpu_ceiling 80

        CURRENT_LEVEL=80
        PENDING_LEVEL=80
        PENDING_COUNT=0

        log_msg "Gaming CPU ceiling: 80%"

    fi


    # ----------------------------------------------
    # Gaming active
    # ----------------------------------------------

    if [ "$GAME" = "1" ]; then

        TARGET_LEVEL=80

        TEMP_C="$TEMP"

        if [ "$TEMP_C" -lt 40000 ]; then
            TARGET_LEVEL=80

        elif [ "$TEMP_C" -lt 41000 ]; then
            TARGET_LEVEL=70

        elif [ "$TEMP_C" -lt 42000 ]; then
            TARGET_LEVEL=62

        elif [ "$TEMP_C" -lt 43000 ]; then
            TARGET_LEVEL=55

        else
            TARGET_LEVEL=50
        fi


        # ------------------------------------------
        # Two consecutive readings required
        # ------------------------------------------

        if [ "$TARGET_LEVEL" = "$PENDING_LEVEL" ]; then
            PENDING_COUNT=$((PENDING_COUNT + 1))
        else
            PENDING_LEVEL="$TARGET_LEVEL"
            PENDING_COUNT=1
        fi


        if [ "$PENDING_COUNT" -ge 2 ] &&
           [ "$CURRENT_LEVEL" != "$TARGET_LEVEL" ]; then

            set_cpu_ceiling "$TARGET_LEVEL"

            CURRENT_LEVEL="$TARGET_LEVEL"

            log_msg "CPU thermal level changed: ${TARGET_LEVEL}% | temp=${TEMP_C}m°C"

            PENDING_COUNT=0
        fi

    fi


    # ----------------------------------------------
    # Gaming ended
    # ----------------------------------------------

    if [ "$GAME" = "0" ] && [ "$LAST_GAME" = "1" ]; then

        restore_original_limits

        rm -f "$STATE_DIR/thermal_level"

        log_msg "Gaming ended. Original CPU limits restored."

        CURRENT_LEVEL=""
        PENDING_LEVEL=80
        PENDING_COUNT=0

    fi


    LAST_GAME="$GAME"

    sleep "$POLL_INTERVAL"

done
