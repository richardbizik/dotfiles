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
    /usr/share/sway/scripts/grimshot --notify copy active;;
  screen)
    /usr/share/sway/scripts/grimshot --notify copy screen;;
  output)
    /usr/share/sway/scripts/grimshot --notify copy output;;
  area)
    /usr/share/sway/scripts/grimshot --notify copy area;;
  window)
    /usr/share/sway/scripts/grimshot --notify copy window;;
esac
