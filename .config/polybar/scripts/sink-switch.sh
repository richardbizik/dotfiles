#!/bin/bash
speakers="alsa_output.pci-0000_0d_00.4.analog-stereo"
headphones="alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game"
arg="${1:-}"

activate_sink () {
	SINK="$1"
	pacmd set-default-sink "$SINK"
	pacmd list-sink-inputs | grep index | while read line; do
		pacmd move-sink-input `echo $line | cut -f2 -d' '` "$SINK"
	done
}

case "$arg" in
  --speakers)
		activate_sink "$speakers"
    notify-send "Switched to speakers!"
		echo ""
    ;;
  --headphones)
		activate_sink "$headphones"
    notify-send "Switched to headphones!"
		echo ""
    ;;
  --toggle)
		current=$(pactl get-default-sink)
		case "$current" in
			$speakers)
				activate_sink "$headphones"
				notify-send "Switched to headphones!"
				echo ""
			  ;;
			$headphones)
				activate_sink "$speakers"
				notify-send "Switched to speakers!"
				echo ""
				;;
			*)
			  activate_sink "$speakers"
				notify-send "Switched to speakers!"
				echo ""
		esac
    ;;
  *)
		current=$(pactl get-default-sink)
		case "$current" in
			$speakers)
				echo ""
			  ;;
			$headphones)
				echo ""
				;;
		  *)
				echo "$current"
		esac
    ;;
esac
