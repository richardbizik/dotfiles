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
    grimshot --notify copy area;;
  active)
    grimshot --notify copy active;;
  screen)
    grimshot --notify copy screen;;
  window)
    grimshot --notify copy window;;
  output)
    grimshot --notify copy output;;
esac

