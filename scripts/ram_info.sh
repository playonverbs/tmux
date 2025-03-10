#!/usr/bin/env bash

# function for getting the refresh rate
get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z $option_value ]; then
    echo $default_value
  else
    echo $option_value
  fi
}

get_percent()
{
	case $(uname -s) in
		Linux)
			# percent=$(free -m | awk 'NR==2{printf "%.1f%%\n", $3*100/$2}')
			used_mem=$(free -g | grep Mem: | awk '{mem += $3} END {print mem}')
			total_mem=$(free -h | grep Mem: | awk '{mem += $2} END {print mem}')
			if (( $used_mem == 0 )); then
				memory_usage=$(free -m | grep Mem: | awk '{mem += $3} END {print mem}')
				echo $memory_usage\M\B/$total_mem\G\B
			else
				memory_usage=$(free -g | grep Mem: | awk '{mem += $3} END {print mem}')
				echo $memory_usage\G\B/$total_mem\G\B
			fi
		;;

		Darwin)
			# percent=$(ps -A -o %mem | awk '{mem += $1} END {print mem}')
			# Get used memory blocks with vm_stat, multiply by 4096 to get size in bytes, then convert to MiB
			used_mem=$(vm_stat | grep ' active\|wired ' | sed 's/[^0-9]//g' | paste -sd ' ' - | awk '{printf "%d\n", ($1+$2) * 4096 / 1048576}')
			total_mem=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2 $3}')
			if (( $used_mem < 1024 )); then
				echo $used_mem\M\B/$total_mem
			else
				memory=$(($used_mem/1024))
				echo $memory\G\B/$total_mem
			fi
		;;

		CYGWIN*|MINGW32*|MSYS*|MINGW*)
			# TODO - windows compatability
		;;
	esac
}

main()
{
	# storing the refresh rate in the variable RATE, default is 5
	RATE=$(get_tmux_option "@dracula-refresh-rate" 5)
	ram_percent=$(get_percent)
	echo "RAM $ram_percent"
	sleep $RATE
}

#run main driver
main
