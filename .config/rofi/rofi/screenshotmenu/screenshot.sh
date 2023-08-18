#!/bin/bash
 
# Current Theme
dir="$HOME/.config/rofi/screenshotmenu"
theme='screenshot'

entries="Active Screen Output Area Window"
 
# Options
area='area'
active='active'
screen='screen'
output='output'
window='window'

# selected=$(printf '%s\n' $entries | wofi --style=$HOME/.config/wofi/style.widgets.css --conf=$HOME/.config/wofi/config.screenshot | awk '{print tolower($1)}')
 
rofi_cmd() {
	rofi -dmenu \
		-p "Uptime: $uptime" \
		-mesg "Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi \
	  -monitor "$monitor"
}
run_rofi() {
	echo -e "$area\n$window\n$active\n$screen\n$output" | rofi_cmd
}

selected="$(run_rofi)"
case ${selected} in
  area)
    /usr/share/sway/scripts/grimshot --notify copy area;;
  active)
    /usr/share/sway/scripts/grimshot --notify copy active;;
  screen)
    /usr/share/sway/scripts/grimshot --notify copy screen;;
  window)
    /usr/share/sway/scripts/grimshot --notify copy window;;
  output)
    /usr/share/sway/scripts/grimshot --notify copy output;;
esac

