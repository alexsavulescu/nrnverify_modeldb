#!/bin/bash
# show the models that have no run info

awk '
{++cnt}
/ [0-9][0-9]*$/ { cnt = 0
	line = $0
}
/^$/ {
	if (cnt == 1) { print line }
}
' < nrnziprun.dat
