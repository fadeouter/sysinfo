#!/bin/bash
#
# this is simple and usable script from a newbie
# based on some findings on the internet
# based on Ganesh V BitBar script (https://github.com/ganeshv/mtop)
# author: fadeouter (https://github.com/fadeouter/)
# before use: sudo apt install top systat


raw_mem=$(free -m | grep Mem)
raw_swap=$(free -m | grep Swap)
mem_used=$(echo $raw_mem | awk '{print $2 - $7}')
mem_full=$(echo $raw_mem | awk '{print $2}')
mem=$(echo $raw_mem | awk '{print (($2 - $7)/$2) * 100.0}')
swap_used=$(echo $raw_swap | awk '{print $3}')
swap_full=$(echo $raw_swap | awk '{print $2}')
swap=$(echo $raw_swap | awk '{print $3/$2 * 100.0}')
CPU=$(echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')])
top=$(top -bn 1 | grep -v "top\|Tasks\|Cpu\|KiB" | awk '{ printf("%-8s %-8s\n", $9, $12); }' | head -n 5 | tail -n+3 | awk 1 ORS="\\\\n" )

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

echo "<b>$CPU%</b>   ${mem%%.*}/${swap%%.*} | size=10 iconName=utilities-system-monitor-symbolic"
echo "---"
echo "Mem:   ${mem_used%%.*} / ${mem_full%%.*} MiB"
echo "Swap:   ${swap_used%%.*} / ${swap_full%%.*} MiB"
echo "---"
echo "$top | font=monospace size=12 trim=true"
echo "---"

get_disk_stats

for ((i = 0; i < ${#capacity[@]}; i++)); do
	echo "${cap[$i]}   <span color='#555555' font='10'>${name[$i]}</span> | iconName=drive-harddisk-system length=20"
	echo "${used[$i]} / <span color='green'>${free[$i]}</span> (${capacity[$i]} %)| refresh=false  iconName=image-filter-symbolic"
        echo "---"
done

echo "Check free space | iconName=baobab bash=baobab terminal=false"
echo "Open System Monitor | iconName=utilities-system-monitor bash=gnome-system-monitor terminal=false"
