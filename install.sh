#!/system/bin/sh

FONT_DIR="/storage/emulated/0/customly-fonted/"
CONFIG_FILE="/data/custom_font_config.txt"
DEFAULT_FONT_FILE="/system/fonts/Roboto-Regular.ttf"
SYSTEM_FONT_FILE="/system/fonts/CustomFont.ttf"

# Read the current font selection from the config file
if [ -f "$CONFIG_FILE" ]; then
    CURRENT_FONT="$(cat "$CONFIG_FILE")"
else
    CURRENT_FONT="$DEFAULT_FONT_FILE"
fi

# Get the list of font files in the font directory
FONT_FILES=("$FONT_DIR"*.ttf)
NUM_FILES="${#FONT_FILES[@]}"
CURRENT_INDEX=0

# Find the index of the current font file
for ((i=0; i<NUM_FILES; i++)); do
    if [ "${FONT_FILES[$i]}" = "$CURRENT_FONT" ]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Function to update the config file with the selected font
update_config_file() {
    echo "${FONT_FILES[$CURRENT_INDEX]}" > "$CONFIG_FILE"
    echo "Font updated: ${FONT_FILES[$CURRENT_INDEX]}"
}

# Set the current font
mount -o remount,rw /system
cp "$CURRENT_FONT" "$SYSTEM_FONT_FILE"
chmod 644 "$SYSTEM_FONT_FILE"
mount -o remount,ro /system

# Main loop for font selection
while true; do
    # Wait for volume key press
    while true; do
        KEY_STATE=$(getevent -lc 1 /dev/input/event*)
        if echo "$KEY_STATE" | grep -q "KEY_VOLUMEUP" ; then
            CURRENT_INDEX=$(( (CURRENT_INDEX + 1) % NUM_FILES ))
            update_config_file
            break
        elif echo "$KEY_STATE" | grep -q "KEY_VOLUMEDOWN" ; then
            CURRENT_INDEX=$(( (CURRENT_INDEX - 1 + NUM_FILES) % NUM_FILES ))
            update_config_file
            break
        fi
    done

    # Set the current font
    mount -o remount,rw /system
    cp "${FONT_FILES[$CURRENT_INDEX]}" "$SYSTEM_FONT_FILE"
    chmod 644 "$SYSTEM_FONT_FILE"
    mount -o remount,ro /system
done
