#!/bin/bash
speakers="alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink"
headphones="alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game"
arg="${1:-}"

activate_sink () {
	SINK="$1"
	pactl set-default-sink "$SINK"
	pactl list sinks-inputs | awk '{print $1}' | while read line; do
		pactl move-sink-input `echo $line` "$SINK"
	done
}

case "$arg" in
  --speakers)
		activate_sink "$speakers"
    notify-send "Switched to speakers! --speakers"
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
				notify-send "Switched to speakers! from headphones"
				echo ""
				;;
			*)
			  activate_sink "$speakers"
				notify-send "Switched to speakers! default"
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
