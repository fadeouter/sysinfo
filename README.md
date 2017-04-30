<h3>System monitor extension for Argos with real CPU graph</h3>

This extension created specially for [Argos](https://github.com/p-e-w/argos) and linux-powered computers w/ GNOME shell.
It is based on *free*, *top* and *vmstat* output and uses power of SVG to draw charts.

Please note that the CPU consumption is *very* approximate. Also, the real time between script execution isn't 1 sec because of latency of top and vmstat output.

*TODO*

* add disks usage charts
* beautify charts with power of SVG
* rewrite script in another lang
* adopt code from [native System Monitor extension for GNOME Shell](https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet)

Do before you going to use script:

``sudo apt install top sysstat``

<h3>Known bugs</h3>
Top output on Archlinux don't show CPU. To fix this open script in text editor and replace `$9 / 2` to `$7 / 2`. In further releases I will fix this by more elegant way.


<h2>Screenshot</h2>

<img src="http://i.imgur.com/SSftwy4.png">

<h2>License</h2>
GNU GPL v3.0 - https://www.gnu.org/licenses/gpl-3.0.en.html
