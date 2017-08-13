<h2>System monitor extension for Argos with real CPU graph</h2>

This extension created specially for [Argos](https://github.com/p-e-w/argos) and linux-powered computers w/ GNOME shell.
This script uses power of SVG to draw charts.

As you see at screenshot, CPU chart has 3 colors: green for iowait consumption, dark grey for user comsumption, and light gray for overall CPU consumption.

Please note that the CPU consumption is approximate. It calculates by **/proc/stat** output, also as memory by **free**, temperature by **/sys/class/thermal/thermal_zone0/temp** and disks by **df** outputs.

<h3>TODO</h3>

* rewrite script in another lang
* find workaround for top issue
* add another improvements

<h3>Known bugs</h3>

Different configurations of **top** utility doesn't allow to show processes list (see opened issue here). 
To fix this, open script in text editor and replace `$9 / 2` to `$7 / 2`. Also you may need to change `head -n 10` to `head -n 13`. Also, you may need to change number of CPU cores (2, 4).
In further releases I will fix this by more elegant way.

<h2>Screenshot</h2>

<img src="https://raw.githubusercontent.com/fadeouter/sysinfo/master/screenshot.png">

<h2>License</h2>
GNU GPL v3.0 - https://www.gnu.org/licenses/gpl-3.0.en.html


