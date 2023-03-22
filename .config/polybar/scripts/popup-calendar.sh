#!/bin/sh

BAR_HEIGHT=25  # polybar height
BORDER_SIZE=1  # border size from your wm settings
YAD_WIDTH=150  # 222 is minimum possible value
YAD_HEIGHT=193 # 193 is minimum possible value
DATE="$(date +"%a %d %H:%M")"

case "$1" in
--popup)
    if [ "$(xdotool getwindowfocus getwindowname)" = "yad-calendar" ]; then
        exit 0
    fi

    eval "$(xdotool getmouselocation --shell)"
    eval "$(xdotool getdisplaygeometry --shell)"

		: $((X = X - 640)) # screen offset
		: $((Y = Y - 2160)) # bottom screen offset
    # X
		: $((pos_x = ((WIDTH - YAD_WIDTH) / 2) - BORDER_SIZE + 640))

    # Y
		: $((pos_y = BAR_HEIGHT + BORDER_SIZE + BAR_HEIGHT))

    yad --calendar --undecorated --fixed --close-on-unfocus --no-buttons \
        --width="$YAD_WIDTH" --height="$YAD_HEIGHT" --posx="$pos_x" --posy="$pos_y" \
        --title="yad-calendar" --borders=0 >/dev/null &
    ;;
*)
    echo "$DATE"
    ;;
esac
