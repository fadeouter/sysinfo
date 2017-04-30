#!/bin/bash
#
# this is simple and usable script from a newbie
# based on some findings on the internet
# based on Ganesh V BitBar script (https://github.com/ganeshv/mtop)
# author: fadeouter (https://github.com/fadeouter/)
# before use: sudo apt install top sysstat


bg_color="#c9dfe5"	# graph background color
fg_color="#555555"	# graph foreground color
hw="16px"		# adjust this variable to your screen DPI


################################################################
#
#  CPU
#
################################################################

CPU=$(echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')]|awk '{ printf("%-4s", $1"%"); }')
top=$(top -o "%CPU" -bn 1 | tr -d '[]|' | head -n 10 | tail -n 3 |  awk '{ printf("%-4s %-s\n", $9 / 2, $12); }' | awk 1 ORS="\\\n")
top_cpu=$(echo $top | sed 's/\\n/ /g' | awk '{ print $1 + $3 + $5}')

if [ "$top_cpu" \> "$CPU" ]; then
CPU=$(echo "$top_cpu"|awk '{ printf("%-4s", $1"%"); }')
fi

cpu_bar_height=$(echo $CPU | grep -o '[0-9]*') 



########### cpu bar - uncomment this if you want to see bar and delete or comment out cpu graph part

#cpu_icon=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='$hw' height='$hw' viewBox='0 0 120px 120px'><g transform='translate(0,120) scale(1, -1)'><rect rx='7px' y='10px' x='20px' height='100px' width='60px' fill='$bg_color' /><rect rx='7px' y='10px' x='20px' height='$cpu_bar_height' width='60px' fill='$fg_color' /></g></svg>" | base64 -w 0)



########### cpu graph ################

HISTORY_FILE="${HOME}/.cpu.history"
touch "${HISTORY_FILE}"
PREVIOUS=$(tail -10 "${HISTORY_FILE}")
echo "$PREVIOUS" > "${HISTORY_FILE}"
echo "$cpu_bar_height" >> "${HISTORY_FILE}"

CPU_GRAPH=$(cat $HISTORY_FILE | tr "\n" "\t" | awk '{print(100-$1,"L 10,"100-$2,"20,"100-$3,"30,"100-$4,"40,"100-$5,"50,"100-$6,"60,"100-$7,"70,"100-$8,"80,"100-$9,"90,"100-$10,"100,"100-$11)}')

#cpu_icon=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='16px' height='16px' viewBox='0 0 100 100'> <g transform='translate(0,0)'> <path style='fill:none;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-opacity:1;stroke-width:2px;' d='$CPU_GRAPH' /> </g></svg>" | base64 -w 0) # graph style

cpu_icon=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='30px' height='30px' viewBox='0 0 100 100'> <g transform='translate(0,0)'> <path style='fill:$fg_color;fill-opacity:1;fill-rule:evenodd;' d='M 0,100 V $CPU_GRAPH l 0,100' /> </g></svg>" | base64 -w 0) # fill style

########### cpu graph end ############



echo "| image=$cpu_icon imageHeight=16 imageWidth=28" #remove imageWidth property if you use bar instead of graph

echo "---"
echo "<b>$CPU</b> CPU | image=$cpu_icon imageHeight=16 font=monospace size=10"

echo "$top| font=monospace size=10 iconName=utilities-system-monitor  bash=gnome-system-monitor terminal=false"

echo "---"

################################################################
#
#  Mem
#
################################################################

raw_mem=$(free -m | grep Mem)
raw_swap=$(free -m | grep Swap)
mem_used=$(echo $raw_mem | awk '{print $2 - $7}')
mem_D=$(echo $raw_mem | awk '{print (($2 - $7) / $2) * 10}' | awk '{ printf("%.0f\n", $1); }' | awk '{print $0"0"}')
mem_full=$(echo $raw_mem | awk '{print $2}')
swap_used=$(echo $raw_swap | awk '{print $3}')
swap_full=$(echo $raw_swap | awk '{print $2}')
swap_D=$(echo $raw_swap | awk '{print ($3 / $2) * 10 }' | awk '{ printf("%.0f\n", $1); }' | awk '{print $0"0"}')


pie_start="<svg width='$hw' height='$hw' viewBox='0 0 90.146759 90.144005'><g transform='translate(-59.928 -103.428)'><circle cx='105' cy='148.5' r='45.979' fill='$bg_color'/>"
pie_00="</g></svg>"
pie_10="<path d='M105 103.52a44.98 44.98 0 0 1 26.438 8.592L105 148.5z' fill='$fg_color' /></g></svg>"
pie_20="<path d='M105 103.52a44.98 44.98 0 0 1 42.777 31.08L105 148.5z' fill='$fg_color' /></g></svg>"
pie_30="<path d='M105 103.52a44.98 44.98 0 0 1 36.388 18.542 44.98 44.98 0 0 1 6.39 40.337L105 148.5z' fill='$fg_color' /></g></svg>"
pie_40="<path d='M105 103.52a44.98 44.98 0 0 1 44.98 44.98A44.98 44.98 0 0 1 105 193.48V148.5z' fill='$fg_color' /></g></svg>"
pie_50="<path d='M105 103.52a44.98 44.98 0 0 1 44.98 44.98A44.98 44.98 0 0 1 105 193.48V148.5z' fill='$fg_color' /></g></svg>"
pie_60="<path d='M105 103.52a44.98 44.98 0 0 1 42.777 31.08 44.98 44.98 0 0 1-16.34 50.288 44.98 44.98 0 0 1-52.875 0L105 148.5z' fill='$fg_color' /></g></svg>"
pie_70="<path d='M105 103.52a44.98 44.98 0 0 1 44.732 40.278 44.98 44.98 0 0 1-35.38 48.698 44.98 44.98 0 0 1-52.13-30.097L105 148.5z' fill='$fg_color' /></g></svg>"
pie_80="<path d='M105 103.52a44.98 44.98 0 0 1 42.777 31.08 44.98 44.98 0 0 1-16.34 50.288 44.98 44.98 0 0 1-52.875 0 44.98 44.98 0 0 1-16.34-50.287L105 148.5z' fill='$fg_color' /></g></svg>"
pie_90="<path d='M105 103.52a44.98 44.98 0 0 1 44.425 37.944 44.98 44.98 0 0 1-30.526 49.813 44.98 44.98 0 0 1-53.976-22.357 44.98 44.98 0 0 1 13.638-56.808L105 148.5z' fill='$fg_color' /></g></svg>"
pie_100="<circle cx='105' cy='148.5' r='44.979' fill='$fg_color' /></g></svg>"

pie_sw="pie_$swap_D"
pie_sw=$(echo "${!pie_sw}")
pie_sw=$(echo "$pie_start$pie_sw" | base64 -w 0)

pie_mem="pie_$mem_D"
pie_mem=$(echo "${!pie_mem}")
pie_mem=$(echo "$pie_start$pie_mem" | base64 -w 0)

echo "Mem: ${mem_used%%.*} / ${mem_full%%.*} MiB | image=$pie_mem"
echo "Swap: ${swap_used%%.*} / ${swap_full%%.*} MiB | image=$pie_sw"

echo "---"

################################################################
#
#  Disk cap
#
################################################################

OLDIFS=$IFS
name=()
used=()
free=()
cap=()
capacity=()

get_disk_stats() {
    local IFS=$'\n'
    local i dfdata

    dfdata=($(df -H))

    IFS=$OLDIFS
    for ((i = 0; i < ${#dfdata[@]}; i++)); do
        line=(${dfdata[$i]})
        if [[ "${line[0]}" == /dev/mapper* ]] || [[ "${line[0]}" == /dev/sd* ]]; then
            name+=("${line[5]}")
            cap+=("${line[1]}")
            used+=("${line[2]}")
            free+=("${line[3]}")
            capacity+=("${line[4]/\%}")
        fi
    done
}

get_disk_stats

for ((i = 0; i < ${#capacity[@]}; i++)); do
	echo "${cap[$i]}   <span color='#555555' font='10'>${name[$i]}</span> | iconName=drive-harddisk-system length=20"
	echo "${used[$i]} / <span color='green'>${free[$i]}</span> (${capacity[$i]} %)| refresh=false  iconName=image-filter-symbolic"
        echo "---"
done
echo "Check free space | iconName=baobab bash=baobab terminal=false"
echo "Open System Monitor | iconName=utilities-system-monitor bash=gnome-system-monitor terminal=false"

