<h3>System monitor extension for Argos</h3>

This is extension I created specially for [Argos](https://github.com/p-e-w/argos) and linux-powered computers.
It is based on *free*, *top* and *vmstat* output.

It uses generated SVG images to display CPU consumption (bar chart) and to display memory and swap use (pie charts).

Please note that the CPU consumption is *very* approximate and it not accurate as well.

*TODO*

* rewrite pie charts implementation
* add disks usage charts
* beautify charts with power of SVG
* draw realtime charts

Do before you going to use script:

```sudo apt install top sysstat```

<h2>Screenshot</h2>

Explanation:
* top output (first 3 processes)
* total CPU consumption
* ```---```
* memory 
* swap
* ```---```
* disks

<img src="http://i.imgur.com/jH1oxNq.png">

