<h2>System monitor extension for Argos with real CPU graph</h2>

This extension created specially for [Argos](https://github.com/p-e-w/argos) and linux-powered computers w/ GNOME shell.
It is based on **free**, **top**, **df** and **vmstat** output and uses power of SVG to draw charts.

Please note that the CPU consumption is **very** approximate. Also, the real time between script execution isn't 1 sec because of latency of top and vmstat output.

<h3>TODO</h3>

* beautify charts with power of SVG
* rewrite script in another lang
* adopt code from [native System Monitor extension for GNOME Shell](https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet)

Do before you going to use script: `sudo apt install top sysstat`

<h3>Known bugs</h3>

Different configurations of **top** utility doesn't allow to show processes and it's CPU consumtion (see opened issue here). 
To fix this, open script in text editor and replace `$9 / 2` to `$7 / 2`. Also you may need to change `head -n 10` to `head -n 13`.
In further releases I will fix this by more elegant way.


<h2>Screenshot</h2>

<img src="https://raw.githubusercontent.com/fadeouter/sysinfo/master/screenshot.png">

<h3>Light theme</h3>

Replace variables in start of script to use with light Shell/GTK theme:

`
chart_color="rgba(0,0,0,0.8)"			# CPU chart main color
fg_color="rgba(0,0,0,0.5)"			# pie foreground color
bg_color="rgba(125,125,125,0.2)"		# pie background color
hw="16px"					# adjust this variable to your screen DPI
font_style="font-size='9' font-family='Lato'"	# replace Lato with your system font name (for disk usage bars)
font_partition="#555555"			# font color of partition mountpoint
font_color="#333333"				# font color of disk used space
font_cap="green"				# font color of disk free space
`

<h2>License</h2>
GNU GPL v3.0 - https://www.gnu.org/licenses/gpl-3.0.en.html


