#!/bin/sh

for JAIL in $(poudriere jail -nlq); do
	for i in $(seq 0 2); do
		columns=80
		if [ $i -eq 1 ]; then
			printf "|"
			printf "%*s" $(( (${#JAIL} + (columns-2)) / 2 )) "$JAIL"
			printf "%*s" $(( ((columns + 1) - ${#JAIL}) / 2 )) "|"
		else
			printf "%.0s-" $(seq 1 $columns)
		fi
		echo ''
	done
	poudriere jail -u -j $JAIL
	echo ''
done
