#!/bin/bash

# This script is designed for Argos extension (https://extensions.gnome.org/extension/1176/argos/) 
# and allows informing on current CPU and memory consumption,
# IP address, ping to up to two servers, temperature, uptime, disks and processes.

# In order to properly work of the script, you need to set the number of CPU cores (see below) and adjust the size of the graphs
# depending on your screen size.

# Go to line 257 and set your number.
# XXX must be equal to a number of CPU cores: '...{ printf("%-4s %-s\n", $9 / XXX, $NF); }...'

# Based on Ganesh V BitBar script (https://github.com/ganeshv/mtop)
# and Leo-G script (https://github.com/Leo-G/DevopsWiki/wiki/How-Linux-CPU-Usage-Time-and-Percentage-is-calculated)
# Author: fadeouter (https://github.com/fadeouter/)


vpn_ip="1.2.3.4" 			# IP address to be hidden from menu bar if it equals to $vpn_ip
ping_1_name="GOOG"
ping_2_name="CLFL"
ping_1_addr="8.8.8.8"
ping_2_addr="1.1.1.1"


graphWidth="32"           		# CPU chart width in pixels, also a number of chart points
scale="2"				# if you have HIDPI screen, set appropriate coeff. for scaling
svg_font_family="Ubuntu"  		# set as GNOME Shell theme font
symbolic="-symbolic"			# if "-symbolic" set, then monocolor icons used


### THEME COLORS

chart_system_color="silver"		# CPU chart main color
chart_user_color="#324f5c"	      	# user processes color on chart
chart_io_color="#3bef3b"		# I/O processes color on chart

pie_fg_color="grey"			# memory pie foreground color
pie_bg_color="transparent"		# memory pie background color
text_muted="#333"			# font color of partition mountpoint


### SIZES AND POSITION OF SVG OBJECTS (not need to change this)

icon_h=$(expr 17 \* $scale)
graph_h=$(expr 15 \* $scale)
graph_svg_w=$(expr $graphWidth + 14)
mem_bar_pos=$(expr $graphWidth + 5)
px='px'


 



################################################################
#
#  01. Memory graph calculation
#
################################################################

raw_mem=$(free -m | grep Mem)
mem_used=$(echo $raw_mem | awk '{print $2 - $7}')
mem_full=$(echo $raw_mem | awk '{print $2}')
memPercent=$(echo $raw_mem | awk '{print ($3 / $2) * 100 }')
memPercentPie=$(echo $raw_mem | awk '{print 174 + (($3 / $2) * 174) }' | sed s/\,/\./)

raw_swap=$(free -m | grep Swap)
swap_used=$(echo $raw_swap | awk '{print $3}')
swap_full=$(echo $raw_swap | awk '{print $2}')
swapPercent=$(echo $raw_swap | awk '{print ($3 / $2) * 100 }')
swapPercentPie=$(echo $raw_swap | awk '{print 174 + (($3 / $2) * 174) }' | sed s/\,/\./)

mempie=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='$icon_h' height='$icon_h' viewBox='0 0 94.997788 94.997783' transform='translate($icon_h,0) scale(-1,1)'><path d='M47.499 19.844c15.273 0 27.655 12.381 27.655 27.655 0 15.273-12.382 27.655-27.655 27.655-15.274 0-27.655-12.382-27.655-27.655 0-15.273 12.381-27.655 27.655-27.655' fill='none' stroke='$pie_fg_color' stroke-width='38' stroke-dasharray='174' stroke-dashoffset='$memPercentPie' /><circle cx='47.5' cy='47.5' r='44' fill='transparent' stroke='$pie_fg_color' stroke-width='5' /><circle cx='47.5' cy='47.5' r='8' fill='$pie_bg_color' /></svg>"  | base64 -w 0)

swappie=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='$icon_h' height='$icon_h' viewBox='0 0 94.997788 94.997783' transform='translate($icon_h,0) scale(-1,1)'><path d='M47.499 19.844c15.273 0 27.655 12.381 27.655 27.655 0 15.273-12.382 27.655-27.655 27.655-15.274 0-27.655-12.382-27.655-27.655 0-15.273 12.381-27.655 27.655-27.655' fill='none' stroke='$pie_fg_color' stroke-width='39.688' stroke-dasharray='174' stroke-dashoffset='$swapPercentPie' /><circle cx='47.5' cy='47.5' r='44' fill='transparent' stroke='$pie_fg_color' stroke-width='5' /><circle cx='47.5' cy='47.5' r='8' fill='$pie_bg_color' /></svg>"  | base64 -w 0)



################################################################
#
#  02. CPU graph calculation
#
################################################################



HISTORY_FILE="${HOME}/.argos-sysinfo.cpu"
touch "${HISTORY_FILE}"
PREVIOUS=$(tail -$graphWidth "${HISTORY_FILE}")
PREV=$(tail -n 1 "${HISTORY_FILE}")
echo "$PREVIOUS" > "${HISTORY_FILE}"

if [$PREV == '']; then
  PREV="0 0 0 0"
fi

PREV_TOTAL=$(echo $PREV | awk '{print $1}' )
PREV_IDLE=$(echo $PREV | awk '{print $2}' )
PREV_USER=$(echo $PREV | awk '{print $3}' )
PREV_IO=$(echo $PREV | awk '{print $4}' )

STAT=(`sed -n 's/^cpu\s//p' /proc/stat`)
IDLE=${STAT[3]}

TOTAL=0
for VALUE in "${STAT[@]}"; do
  let "TOTAL=$TOTAL+$VALUE"
done

let "USER=$TOTAL-${STAT[0]}"
let "IO=$TOTAL-${STAT[4]}"
let "DIFF_IDLE=$IDLE-$PREV_IDLE"
let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
let "DIFF_USER=$USER-$PREV_USER"
let "DIFF_IO=$IO-$PREV_IO"
let "CPU=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
let "CPU_USER=CPU-((1000*($DIFF_USER-$DIFF_IDLE)/$DIFF_USER+5)/10)"
let "CPU_IO=CPU-((1000*($DIFF_IO-$DIFF_IDLE)/$DIFF_IO+5)/10)"


echo "$TOTAL   $IDLE    $USER    $IO    $CPU   $CPU_USER   $CPU_IO" >> "${HISTORY_FILE}"


COUNTER=0
while [ $COUNTER -lt $graphWidth ]; do    
    fullCpuBar=$(sed -n $COUNTER\p ${HISTORY_FILE} | awk '{print $5}')
    ioCpuBar=$(sed -n $COUNTER\p ${HISTORY_FILE} | awk '{print ($5-$7)}')
    userCpuBar=$(sed -n $COUNTER\p ${HISTORY_FILE} | awk '{print $6}')
    old_string=$svg_string
    new_string="<path fill='none' stroke='$chart_system_color' stroke-width='1' d='M$COUNTER,0 $COUNTER,$fullCpuBar'/><path fill='none' stroke='$chart_io_color' stroke-width='1' d='M$COUNTER,$ioCpuBar $COUNTER,$fullCpuBar'/><path fill='none' stroke='$chart_user_color' stroke-width='1' d='M$COUNTER,0 $COUNTER,$userCpuBar'/>"
    svg_string=$old_string$new_string
    let COUNTER=COUNTER+1 
done
         
cpu_icon=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='$graph_svg_w' height='100' viewBox='0 0 $graph_svg_w 100'> <g transform='translate(0,80) scale(1,-0.6)'> 
$svg_string
<g transform='translate($mem_bar_pos,0)'><path fill='none' stroke='$chart_system_color' stroke-width='4' d='M0,0 0,$memPercent'/><path fill='none' stroke='$chart_system_color' stroke-width='4' d='M0,96 0,100'/>
<path fill='none' stroke='$chart_system_color' stroke-width='4' d='M7,0 7,$swapPercent'/>
</g></g></svg>" | base64 -w 0) 


################################################################
#
#  03. IP info
#
################################################################

EXTERNAL_IP_DIG=$(dig +short myip.opendns.com @resolver1.opendns.com)
#EXTERNAL_IP_DIG2=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | egrep -o '[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+/[0-9]+')
PING_1=$(ping -i 1 -c 1 $ping_1_addr | tail -1 | awk '{print $4}' | cut -d '/' -f 2 | cut -d "." -f1)
PING_2=$(ping -i 1 -c 1 $ping_2_addr | tail -1 | awk '{print $4}' | cut -d '/' -f 2 | cut -d "." -f1)


if [ "$EXTERNAL_IP_DIG" = "" ]; then
	EXTERNAL_IP_DIG=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | egrep -o '[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+/[0-9]+')
fi


if [ "$EXTERNAL_IP_DIG" = $vpn_ip ]; then
  echo "| image=$cpu_icon imageHeight=$graph_h imageWidth=$graph_svg_w" 
  echo "---"
  echo "IP \t\t$EXTERNAL_IP_DIG | iconName=network-transmit-receive imageHeight=$icon_h"  
else 
  EXTERNAL_IP_CUT=$( echo "$EXTERNAL_IP_DIG" | cut -d "." -f1-2)
  echo "$EXTERNAL_IP_CUT| image=$cpu_icon imageHeight=$graph_h imageWidth=$graph_svg_w" 
  echo "---" 
  echo "IP\t\t$EXTERNAL_IP_DIG | iconName=network-transmit-receive imageHeight=$icon_h" 
fi

echo "$ping_1_name\t$PING_1 ms | iconName=view-more-horizontal-symbolic imageHeight=$icon_h" 
echo "$ping_2_name\t$PING_2 ms | iconName=view-more-horizontal-symbolic imageHeight=$icon_h"
wait

echo "---"


################################################################
#
#  04. Memory piecharts
#
################################################################
 
echo "Mem \t${mem_used%%.*} / ${mem_full%%.*} MiB | image=$mempie imageHeight=$icon_h"

if [ ${swap_used%%.*} != 0 ]; then
	echo "Swap\t${swap_used%%.*} / ${swap_full%%.*} MiB | image=$swappie imageHeight=$icon_h"
fi



################################################################
#
#  03. Temperature
#
################################################################

temp=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000 }')


echo "Temp\t$temp C°| imageHeight=$icon_h image=PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHZpZXdCb3g9JzAgMCAxMzUuNDY2NjcgMTM1LjQ2NjY3JyBoZWlnaHQ9JzY0JyB3aWR0aD0nNjQnPjxkZWZzPjxtYXJrZXIgb3JpZW50PSdhdXRvJyBpZD0nYicgb3ZlcmZsb3c9J3Zpc2libGUnPjxwYXRoIGQ9J00uOTggMGExIDEgMCAxIDEtMiAwIDEgMSAwIDAgMSAyIDB6JyBmaWxsPScjZjU1JyBmaWxsLXJ1bGU9J2V2ZW5vZGQnIHN0cm9rZT0nI2Y1NScgc3Ryb2tlLXdpZHRoPScuMjY3Jy8+PC9tYXJrZXI+PG1hcmtlciBvcmllbnQ9J2F1dG8nIGlkPSdhJyBvdmVyZmxvdz0ndmlzaWJsZSc+PHBhdGggZD0nTS45OCAwYTEgMSAwIDEgMS0yIDAgMSAxIDAgMCAxIDIgMHonIGZpbGw9JyNjY2MnIGZpbGwtcnVsZT0nZXZlbm9kZCcgc3Ryb2tlPScjY2NjJyBzdHJva2Utd2lkdGg9Jy4yNjcnLz48L21hcmtlcj48L2RlZnM+PGcgc3Ryb2tlLXdpZHRoPScxNC43NzknPjxwYXRoIGQ9J002Ni4zNzggMTEyLjU5NmMuMDEzLTMxLjcyNi4wMjctNS42My4wNC05NS4yMzUnIGZpbGw9JyNjY2MnIHN0cm9rZT0nI2NjYycgc3Ryb2tlLWxpbmVjYXA9J3JvdW5kJyBtYXJrZXItc3RhcnQ9J3VybCgjYSknIHRyYW5zZm9ybT0ndHJhbnNsYXRlKC0xLjE4MiAtNC42ODcpIHNjYWxlKDEuMDM4MjQpJy8+PHBhdGggZD0nTTY2LjM3OCAxMTIuNTk2Yy4wMi0xNi4zMzguMDQtMi45LjA2LTQ5LjA0MycgZmlsbD0nI2Y1NScgc3Ryb2tlPScjZjU1JyBtYXJrZXItc3RhcnQ9J3VybCgjYiknIHRyYW5zZm9ybT0ndHJhbnNsYXRlKC0xLjE4MiAtNC42ODcpIHNjYWxlKDEuMDM4MjQpJy8+PC9nPjwvc3ZnPgo=c@t"


################################################################
#
#  04. Uptime
#
################################################################

up=$(uptime | sed 's/,.*//' | sed 's/.*up//' | xargs)
echo "Time\t$up | iconName=preferences-system-time$symbolic"
echo "---"

################################################################
#
#  05. Disk
#
################################################################


OLDIFS=$IFS
name=()
used=()
free=()
cap=()
capacity=()
disk_icon="drive-harddisk-system$symbolic"

get_disk_stats() {
    local IFS=$'\n'
    local i dfdata

    dfdata=($(df -lH | grep "/dev/mapper*\|/dev/sd*\|/dev/dm*\|/dev/nvme*" | grep -v "/boot\|/shm" ))

    IFS=$OLDIFS
    for ((i = 0; i < ${#dfdata[@]}; i++)); do
        line=(${dfdata[$i]})
            name+=("${line[5]}")
            cap+=("${line[1]}")
            usedcap+=("${line[3]/\G}")
            free+=("${line[4]}")
            capacity+=("${line[4]/\%}")
    done
}

get_disk_stats


for ((i = 0; i < ${#capacity[@]}; i++)); do

	if [[ ${name[$i]} = \/media* ]]; then
		disk_icon="drive-removable-media$symbolic"
	fi

	echo "${usedcap[$i]}Gb  <span color='#777'>${free[$i]}</span>  <span color='#555'>${cap[$i]}</span>  <span color='grey'>${name[$i]}</span>| iconName=$disk_icon imageHeight=$diskbar_h bash=baobab terminal=false font='monospace' size=8"
done

################################################################
#
#  6. Process list
#
################################################################

top=$(top -o "%CPU" -bn 1 | head -n 14 | tail -n 7 | awk '{ printf("%1.0f  %s\n", $9 / 8, $NF); }' | awk 1 ORS="\\\n")	# set here number of CPU cores
echo "---"
echo "$top| font='monospace' size=8 bash=gnome-system-monitor terminal=false iconName=view-restore-symbolic"

echo "---"
echo "Update| refresh=true iconName=view-refresh-symbolic"


