#!/system/bin/sh

STATE_DIR="/data/adb/hyperos_ultimate_edition"
LOG_FILE="$STATE_DIR/gaming.log"

mkdir -p "$STATE_DIR"

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_foreground_package() {
    dumpsys activity activities 2>/dev/null \
        | grep -m 1 "mResumedActivity" \
        | sed -n 's/.* u[0-9]\+ \([^ /}]\+\).*/\1/p'
}

is_game_package() {
    PKG="$1"

    [ -z "$PKG" ] && return 1

    # Packages containing these common game identifiers
    # are treated only as a fallback detection method.
    echo "$PKG" | grep -Eiq \
        'game|games|pubg|bgmi|codm|callofduty|freefire|mobilelegends|genshin|minecraft|asphalt|roblox|arena'
}

LAST_PACKAGE=""

log_msg "Gaming mode monitor started."

while true; do
    CURRENT_PACKAGE="$(get_foreground_package)"

    if [ "$CURRENT_PACKAGE" != "$LAST_PACKAGE" ]; then

        if is_game_package "$CURRENT_PACKAGE"; then
            log_msg "Gaming application detected: $CURRENT_PACKAGE"
            echo "1" > "$STATE_DIR/gaming_active"
        else
            if [ -f "$STATE_DIR/gaming_active" ]; then
                log_msg "Gaming application exited: $LAST_PACKAGE"
                rm -f "$STATE_DIR/gaming_active"
            fi
        fi

        LAST_PACKAGE="$CURRENT_PACKAGE"
    fi

    sleep 3
done
