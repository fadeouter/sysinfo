<h2>System monitor extension for Argos with real CPU graph</h2>

This extension created specially for [Argos](https://github.com/p-e-w/argos) and linux-powered computers w/ GNOME shell.
It is based on **free**, **top**, **df** and **vmstat** output and uses power of SVG to draw charts.

Please note that the CPU consumption is **very** approximate. It calculates only by first 6 processes of **top** output. See previous releases to 

<h3>TODO</h3>

* beautify charts with power of SVG
* rewrite script in another lang
* adopt code from [native System Monitor extension for GNOME Shell](https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet)

<h3>Known bugs</h3>

Different configurations of **top** utility doesn't allow to show processes and it's CPU consumtion (see opened issue here). 
To fix this, open script in text editor and replace `$9 / 2` to `$7 / 2`. Also you may need to change `head -n 10` to `head -n 13`. Also, you may need to change 2 to 4 - this is how many cores in your CPU.
In further releases I will fix this by more elegant way.

<h2>Screenshot</h2>

<img src="https://raw.githubusercontent.com/fadeouter/sysinfo/master/screenshot.png"> <img src="https://raw.githubusercontent.com/fadeouter/sysinfo/master/screenshot_w.png">

<h2>License</h2>
GNU GPL v3.0 - https://www.gnu.org/licenses/gpl-3.0.en.html


