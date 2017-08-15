#!/bin/bash
#
# this is simple and usable script from a newbie
# based on some findings on the internet
# based on Ganesh V BitBar script (https://github.com/ganeshv/mtop)
# and Leo-G script (https://github.com/Leo-G/DevopsWiki/wiki/How-Linux-CPU-Usage-Time-and-Percentage-is-calculated)
# author: fadeouter (https://github.com/fadeouter/)



# IMPORTANT! Go to line 114 and set your number of CPU cores

graphWidth="50"           # CPU chart width in pixels, also a number of chart points
scale="1"				          # if you have HIDPI screen, set appropriate coeff. for scaling
svg_font_size="9"			    # probably you won't change this
svg_font_family="Ubuntu"  # set as GNOME Shell theme font
symbolic=""
#symbolic="-symbolic"			# uncomment to use monocolor icons


### LIGHT THEME (swap with DARK THEME to enable)

chart_system_color="silver"		    # CPU chart main color
chart_user_color="dimgray"	      # CPU chart main color
chart_io_color="greenyellow"	    # CPU chart main color

pie_fg_color=$chart_user_color		# pie foreground color
pie_bg_color=$chart_system_color	# pie background color
text_muted=$chart_user_color			# font color of partition mountpoint
diskbar_font="#333333"			      # font color of disk used space
diskbar_font_highlighted="green"	# font color of disk free space
diskbar_bg_color=$pie_bg_color		# disk bar bg color


### DARK THEME

chart_system_color="silver"		    # CPU chart main color
chart_user_color="dimgray"	      # CPU chart main color
chart_io_color="greenyellow"	    # CPU chart main color

pie_fg_color=$chart_user_color		# pie foreground color
pie_bg_color=$chart_system_color	# pie background color
text_muted=$chart_user_color			# font color of partition mountpoint
diskbar_font="#ffffff"			      # font color of disk used space
diskbar_font_highlighted="#7eff35"	# font color of disk free space
diskbar_bg_color=$pie_bg_color		# disk bar bg color

	
### SIZES AND POSITION OF SVG OBJECTS

icon_h=$(expr 12 \* $scale)
graph_h=$(expr 14 \* $scale)
graph_svg_w=$(expr $graphWidth + 14)
mem_bar_pos=$(expr $graphWidth + 5)
diskbar_h=$(expr 18 \* $scale)
diskbar_w=$(expr 120 \* $scale)
px='px'


################################################################
#
#  0. Settings
#
################################################################


SETTINGS="${HOME}/.argos-sysinfo.settings"

if [ ! -f "${SETTINGS}" ]; then
  touch "${SETTINGS}"
  echo "%on" > "${SETTINGS}"
  echo "memon" >> "${SETTINGS}"
fi

showPercents=$(grep -E "(%on|%off)" ${SETTINGS})
showMembar=$(grep -E "(memon|memoff)" ${SETTINGS})


if [ "$showMembar" == "memoff" ]; then
  graph_svg_w=$graphWidth
fi


################################################################
#
#  01. Memory
#
################################################################

raw_mem=$(free -m | grep Mem)
mem_used=$(echo $raw_mem | awk '{print $2 - $7}')
mem_full=$(echo $raw_mem | awk '{print $2}')
memPercent=$(echo $raw_mem | awk '{print ($3 / $2) * 100 }')
memPercentPie=$(echo $raw_mem | awk '{print 174 + (($3 / $2) * 174) }')

raw_swap=$(free -m | grep Swap)
swap_used=$(echo $raw_swap | awk '{print $3}')
swap_full=$(echo $raw_swap | awk '{print $2}')
swapPercent=$(echo $raw_swap | awk '{print ($3 / $2) * 100 }')
swapPercentPie=$(echo $raw_swap | awk '{print 174 + (($3 / $2) * 174) }')

mempie=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='$icon_h' height='$icon_h' viewBox='0 0 94.997788 94.997783' transform='translate($icon_h,0) scale(-1,1)'><circle cx='47.5' cy='47.5' r='47.5' fill='$pie_bg_color' /><circle cx='47.5' cy='47.5' r='9' fill='$pie_fg_color' /><path d='M47.499 19.844c15.273 0 27.655 12.381 27.655 27.655 0 15.273-12.382 27.655-27.655 27.655-15.274 0-27.655-12.382-27.655-27.655 0-15.273 12.381-27.655 27.655-27.655' fill='none' stroke='$pie_fg_color' stroke-width='39.688' stroke-dasharray='174' stroke-dashoffset='$memPercentPie' /></svg>"  | base64 -w 0)

swappie=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='$icon_h' height='$icon_h' viewBox='0 0 94.997788 94.997783' transform='translate($icon_h,0) scale(-1,1)'><circle cx='47.5' cy='47.5' r='47.5' fill='$pie_bg_color' /><circle cx='47.5' cy='47.5' r='9' fill='$pie_fg_color' /><path d='M47.499 19.844c15.273 0 27.655 12.381 27.655 27.655 0 15.273-12.382 27.655-27.655 27.655-15.274 0-27.655-12.382-27.655-27.655 0-15.273 12.381-27.655 27.655-27.655' fill='none' stroke='$pie_fg_color' stroke-width='39.688' stroke-dasharray='174' stroke-dashoffset='$swapPercentPie' /></svg>"  | base64 -w 0)



################################################################
#
#  02. CPU graph calculation
#
################################################################

# XXX must be equal to number of CPU cores: '...{ printf("%-4s %-s\n", $9 / XXX, $NF); }...'
top=$(top -o "%CPU" -bn 1 | head -n 14 | tail -n 7 | awk '{ printf("%-4s %-s\n", $9 / 4, $NF); }' | awk 1 ORS="\\\n")

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
         
cpu_icon=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='$graph_svg_w' height='100' viewBox='0 0 $graph_svg_w 100'> <g transform='translate(0,100) scale(1,-1)'> 
$svg_string
<g transform='translate($mem_bar_pos,0)'><path fill='none' stroke='$chart_system_color' stroke-width='4' d='M0,0 0,$memPercent'/>
<path fill='none' stroke='$chart_system_color' stroke-width='4' d='M7,0 7,$swapPercent'/>
</g></g></svg>" | base64 -w 0) 

################################################################
#
#  02.1 CPU Load
#
################################################################

loadavg=( $(< /proc/loadavg) )
load=${loadavg[0]}

################################################################
#
#  03. Temperature
#
################################################################

temp=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000 }')



################################################################
#
#  04. Output
#
################################################################

IMAGE_CPU="$CPU%"

if [ "$showPercents" == "%off" ]; then
  IMAGE_CPU=''
fi


echo "$IMAGE_CPU| image=$cpu_icon imageHeight=$graph_h imageWidth=$graph_svg_w" 

echo "---"

echo "<span color='$text_muted'>CPU </span>\t$CPU% | iconName=utilities-system-monitor"
echo "<span color='$text_muted'>Load</span>\t$load | imageHeight=$icon_h image=iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAABONJREFUSIm9VGtQVGUYfr5zds/uwi57FjG5BmjCqoDAguKKKThBkUMXdappJjWotHFGp6kms6GpH1aao6NNaBdkJrXSMcOxQWcQw4BZ87IIoiteuInLXvCw99vxnH5wGUAmqZl6fn7zzXN5v+95gf8YZAp3GAUtycyIZLPYCFW0SFNwul39rbb7Ld4QbwQQ/FcCBGBzYhM358UnlL2njowjfo786uYghEuxOmkayHS1uMNkvdd8p7fqfEfXLlEENxmPZLLDRKWmeE/209+nCmLsui4D8bsDkBMvAj4nBIGB4KbxgPaT8513435co/+ow68vW7+/trzTwtVO5KImHqjV6rWVC1efyHRI4hScn+TSSpwJeIfDEoAQECmFM1YPcuMioJQGiO4xElu16bkalmXLJ/LR45yroooP5K89vM1Ux6QRNaIoKWIoCvu8/aAAnA0G0COIECQUjvY5sXFJEqIiFeiwurD1mJH++s2iZ5qud1/i3P6bDwkQgK0u2ng63a3UpNFqVHAXoKVZ1AVtqA8N4vdQEH2CiL7gAzTYvbAHeCjkEqgUDLacMGFb6RxkzJDRurTUwoNnr1QB8I8TyE2c+0F54tIVkoBIougwaKVqrB/4A5d514iBcRABtPS5UNPaj92r0jE/Xg1ABKtSqAxdDr7XytWPfQMmb1ZmWdnlA2SXpRGdCKAhaEEI4iP/MS+IqO+w4c6AB5+f7sBLe+uxKG3W6wCYUWMKqWxB+4YjBn8fR85ajThmbobJfRcCxEfQD4EiwNwYFV5ZmICieTMg18SISeVf5Xt8wWYKANLiU7J9MpEIkWEonKVHaUL+lMkBQBCBlbkJWJHzOKRhcgiUQHQp8dnAcA8iNGxMzd0m+F1eEBG4cL99yuQjONVuhW944kzYINQsGzsqwEtF4lEK8FFDvv0DU3c/ggcUhQA91FtCURAIIaMCTo/Lkr/sSfiDQQgSgFxS4FrXjX8kULAgGaWLZ4NABC0Nx/GGtv5RAdPtjhY/S0SHnyetxhY0/tkMQghEcWpJCCE42XQbjJzBUl0SFIxcNF7vaQGGe8DzvJ0Jk5XXHP1FSWiC4hefBSNj0H2rc0oCy0qy8dQqPRpbelB97AIsg7ztnKHtfQChkaLxBJjxzqdb9HOz0olKHQG5QoGLjecfmYKiKZS+WoCE5GjMy0zG4uU5OHSobr/5nvU3YMyyazVe2Wk3W2wURcHc24efvzuIDVs2YVnJchDq4boRQrCkZBHerliDn745hd4uO0AxsN5z2Y0X278cuTd22Xnar7R163JyXvihsop6+a3XkPhEMtgoDXpudaJ4VQn4UAia6RoUPl8Al8OFopUFSJgZi+TZ8ThceRKp2hT+i4/3veEYdBkmE4DL4bxuaGhyb9767vLYpHgKBKirqcU8XTryCvXw+XyYHj0N+cV6SKU0rl68hjlZqVBHRkCrTeErNm//0GK2fTtuhBOSixzH7d7xyWdrrL1mGxGBm1dvIDMve+xwQAhBxsIM3L7WBfASWLsH7dsr9q7j7nM7gfErYFyCERGnw9l2+kTtkU7TLWmGbn7y/NysMAlNkf5eMyQSGjNnz4RcJhPdA66B4wdrqqsrD611cM5zE8mH7Pw9CIBIpUqZp03XZoeHK6MJQDxed7+pzXTZ5XQbAAxMRvy/4S8rG+8QrnGxdAAAAABJRU5ErkJggg=="
echo "<span color='$text_muted'>Mem</span>\t${mem_used%%.*} / ${mem_full%%.*} MiB | image=$mempie imageHeight=$icon_h"
echo "<span color='$text_muted'>Swap</span>\t${swap_used%%.*} / ${swap_full%%.*} MiB | image=$swappie imageHeight=$icon_h"
echo "<span color='$text_muted'>Temp</span>\t$temp C° | imageHeight=$icon_h image=PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHZpZXdCb3g9JzAgMCAxMzUuNDY2NjcgMTM1LjQ2NjY3JyBoZWlnaHQ9JzY0JyB3aWR0aD0nNjQnPjxkZWZzPjxtYXJrZXIgb3JpZW50PSdhdXRvJyBpZD0nYicgb3ZlcmZsb3c9J3Zpc2libGUnPjxwYXRoIGQ9J00uOTggMGExIDEgMCAxIDEtMiAwIDEgMSAwIDAgMSAyIDB6JyBmaWxsPScjZjU1JyBmaWxsLXJ1bGU9J2V2ZW5vZGQnIHN0cm9rZT0nI2Y1NScgc3Ryb2tlLXdpZHRoPScuMjY3Jy8+PC9tYXJrZXI+PG1hcmtlciBvcmllbnQ9J2F1dG8nIGlkPSdhJyBvdmVyZmxvdz0ndmlzaWJsZSc+PHBhdGggZD0nTS45OCAwYTEgMSAwIDEgMS0yIDAgMSAxIDAgMCAxIDIgMHonIGZpbGw9JyNjY2MnIGZpbGwtcnVsZT0nZXZlbm9kZCcgc3Ryb2tlPScjY2NjJyBzdHJva2Utd2lkdGg9Jy4yNjcnLz48L21hcmtlcj48L2RlZnM+PGcgc3Ryb2tlLXdpZHRoPScxNC43NzknPjxwYXRoIGQ9J002Ni4zNzggMTEyLjU5NmMuMDEzLTMxLjcyNi4wMjctNS42My4wNC05NS4yMzUnIGZpbGw9JyNjY2MnIHN0cm9rZT0nI2NjYycgc3Ryb2tlLWxpbmVjYXA9J3JvdW5kJyBtYXJrZXItc3RhcnQ9J3VybCgjYSknIHRyYW5zZm9ybT0ndHJhbnNsYXRlKC0xLjE4MiAtNC42ODcpIHNjYWxlKDEuMDM4MjQpJy8+PHBhdGggZD0nTTY2LjM3OCAxMTIuNTk2Yy4wMi0xNi4zMzguMDQtMi45LjA2LTQ5LjA0MycgZmlsbD0nI2Y1NScgc3Ryb2tlPScjZjU1JyBtYXJrZXItc3RhcnQ9J3VybCgjYiknIHRyYW5zZm9ybT0ndHJhbnNsYXRlKC0xLjE4MiAtNC42ODcpIHNjYWxlKDEuMDM4MjQpJy8+PC9nPjwvc3ZnPgo=c@t"

echo "---"

echo "$top| font=monospace size=9 iconName=utilities-system-monitor$symbolic  bash=gnome-system-monitor terminal=false"



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

get_disk_stats() {
    local IFS=$'\n'
    local i dfdata

    dfdata=($(df -lH | grep "/dev/mapper*\|/dev/sd*" | grep -v "/boot\|/shm" ))

    IFS=$OLDIFS
    for ((i = 0; i < ${#dfdata[@]}; i++)); do
        line=(${dfdata[$i]})
            name+=("${line[5]}")
            cap+=("${line[1]}")
            used+=("${line[2]}")
            free+=("${line[3]}")
            capacity+=("${line[4]/\%}")
    done
}

get_disk_stats

height="10"
disk_icon="drive-harddisk-system$symbolic"

for ((i = 0; i < ${#capacity[@]}; i++)); do

if [[ ${name[$i]} = \/media* ]]; then
disk_icon="drive-removable-media$symbolic"
fi
    echo "---"
    echo "${cap[$i]}   <span color='$text_muted' font='10'>${name[$i]}</span> | iconName=$disk_icon  imageHeight=$icon_h length=20 bash='nautilus ${name[$i]}' terminal=false"
    #echo "${used[$i]} / <span color='green'>${free[$i]}</span> (${capacity[$i]} %)| refresh=false  iconName=image-filter$symbolic"
    diskbar_green=$(echo ${capacity[$i]} | awk '{print 255 - $0 * 2.55 }' | awk '{ printf("%.0f\n", $1); }')
    diskbar_red=$(echo ${capacity[$i]} | awk '{print $0 * 2.55 }' | awk '{ printf("%.0f\n", $1); }')
    diskbar_color="rgba($diskbar_red,$diskbar_green,0,0.7)"
    diskbar=$(echo "<svg xmlns='http://www.w3.org/2000/svg' width='$diskbar_w$px' height='$diskbar_h$px' viewBox='0 0 100 11'> <rect width='100' height='2' x='0' y='$height' fill='$diskbar_bg_color' rx='1px'/> <rect width='${capacity[$i]}' height='2' x='0' y='$height' fill='$diskbar_color' rx='1px'/> <text x='0' y='7' font-size='$svg_font_size' font-family='$svg_font_family'><tspan fill='$diskbar_font'>${used[$i]} / <tspan fill='$diskbar_font_highlighted'>${free[$i]}</tspan> (${capacity[$i]} %)</tspan></text> </svg>" | base64 -w 0)
    echo "|image=$diskbar iconName=baobab$symbolic imageHeight=$diskbar_h"
done


################################################################
#
#  6. Settings rendering
#
################################################################


echo "---"
echo "Settings | iconName=gnome-settings$symbolic"

slon="PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHdpZHRoPScyNCcgaGVpZ2h0PScyNCcgdmlld0JveD0nMCAwIDM3MCAzNzAnPjxwYXRoIGQ9J00yNzMgODhIOTdjLTUzLjUgMC05NyA0My42LTk3IDk3czQzLjUgOTcgOTcgOTdoMTc2YzUzLjUgMCA5Ny00My42IDk3LTk3cy00My41LTk3LTk3LTk3em0tMTE3LjYgOTdjMCAyOC44LTIzLjQgNTIuMi01Mi4yIDUyLjItMjguOCAwLTUyLjItMjMuNC01Mi4yLTUyLjIgMC0yOC44IDIzLjQtNTIuMiA1Mi4yLTUyLjIgMjguOCAwIDUyLjIgMjMuNCA1Mi4yIDUyLjJ6JyB0cmFuc2Zvcm09J3RyYW5zbGF0ZSgzNzAsIDApIHNjYWxlKC0xLCAxKScgZmlsbD0nZ3JlZW4nIC8+PC9zdmc+Cg=="
sloff="PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHdpZHRoPScyNCcgaGVpZ2h0PScyNCcgdmlld0JveD0nMCAwIDM3MCAzNzAnPjxwYXRoIGQ9J00yNzMgODhIOTdjLTUzLjUgMC05NyA0My42LTk3IDk3czQzLjUgOTcgOTcgOTdoMTc2YzUzLjUgMCA5Ny00My42IDk3LTk3cy00My41LTk3LTk3LTk3em0tMTE3LjYgOTdjMCAyOC44LTIzLjQgNTIuMi01Mi4yIDUyLjItMjguOCAwLTUyLjItMjMuNC01Mi4yLTUyLjIgMC0yOC44IDIzLjQtNTIuMiA1Mi4yLTUyLjIgMjguOCAwIDUyLjIgMjMuNCA1Mi4yIDUyLjJ6JyBmaWxsPSdyZWQnIC8+PC9zdmc+Cg=="


if [ "$showPercents" == "%on" ]; then
	echo "--Show CPU usage | refresh=true bash='sed -i -e s/%on/%off/g ${SETTINGS}' terminal=false image=$slon"
elif  [ "$showPercents" == "%off" ]; then
	echo "--Show CPU usage | refresh=true bash='sed -i -e s/%off/%on/g ${SETTINGS}' terminal=false image=$sloff"
fi


if [ "$showMembar" == "memon" ]; then
	echo "--Show memory bars | refresh=true bash='sed -i -e s/memon/memoff/g ${SETTINGS}' terminal=false image=$slon"
elif  [ "$showMembar" == "memoff" ]; then
	echo "--Show memory bars | refresh=true bash='sed -i -e s/memoff/memon/g ${SETTINGS}' terminal=false image=$sloff"
fi




