#!/usr/bin/env bash

killall -q polybar

while pgrep -u ${UID} -x polybar >/dev/null; do
	sleep 1
done

echo "---" | tee -a /tmp/${SELECTED_BAR[@]}

launch_poly_bar()
{
	local	bar_name="${1?}"
	local	monitor_index="${2?}"
	local	bar_monitor

	bar_monitor="$(xrandr --query | grep "${monitor_index}.* connected" | cut -d' ' -f1)"
	BAR_MONITOR=${bar_monitor} \
		polybar "${bar_name}" 2>&1 | \
			tee -a "/tmp/${bar_name}.log" & \
				disown
}

NB_MONITOR="$(xrandr --query | grep -E "[0-9]+ connected" | wc -l)"

case "${NB_MONITOR:-1}" in
	1)
		launch_poly_bar "primary_top_full" "DP"
	;;
	2)
		launch_poly_bar "primary_top_right" "HDMI"
		launch_poly_bar "secondary_top_left" "DP"
	;;
	*) notify-send "[POLYBAR]: found ${NB_MONITOR}, but no layout associated";
esac

echo "Bars launched..."
