#!/bin/bash
 
entries="Active Screen Output Area Window"
 
# selected=$(printf '%s\n' $entries | wofi --style=$HOME/.config/wofi/style.widgets.css --conf=$HOME/.config/wofi/config.screenshot | awk '{print tolower($1)}')
 
rofi_cmd() {
	rofi -dmenu \
		-p "Uptime: $uptime" \
		-mesg "Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi \
	  -monitor "$monitor"
}
run_rofi() {
	echo -e "$active\n$screen\n$output\n$area\n$window" | rofi_cmd
}

selected="$(run_rofi)"
case ${selected} in
  active)
    grimshot --notify copy active;;
  screen)
    grimshot --notify copy screen;;
  output)
    grimshot --notify copy output;;
  area)
    grimshot --notify copy area;;
  window)
    grimshot --notify copy window;;
esac
