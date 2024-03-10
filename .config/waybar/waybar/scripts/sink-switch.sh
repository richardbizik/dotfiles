#!/bin/bash
speakers=$(pactl list short sinks | grep HiFi__hw_Audio__sink | awk '{print $2}')
headphones=$(pactl list short sinks | grep stereo-game | awk '{print $$2}')
arg="${1:-}"

activate_sink() {
	SINK="$1"
	pactl set-default-sink "$SINK"
	pactl list sink-inputs short | awk '{print $1}' | while read line; do
		pactl move-sink-input `echo $line` "$SINK"
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
