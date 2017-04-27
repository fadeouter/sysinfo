<h3>System monitor extension for Argos with real CPU graph</h3>

This is extension I created specially for [Argos](https://github.com/p-e-w/argos) and linux-powered computers.
It is based on *free*, *top* and *vmstat* output and uses power of SVG to draw charts.

Please note that the CPU consumption is *very* approximate. Also, the real time between script execution isn't 1 sec because of latency of top and vmstat output.

*TODO*

* add disks usage charts
* beautify charts with power of SVG

Do before you going to use script:

```sudo apt install top sysstat```

<h2>Screenshot</h2>

<img src="http://i.imgur.com/SSftwy4.png">

