#!/bin/sh

columns=80

if [ -z $1 ]; then
	echo "No pkglist path"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "Cannot find $1"
	exit 2
fi

printf "%s\n" "Do you need to update the jails?"
for i in $(seq 10 1); do
	printf "%s%*s\r" "Countdown: $i" $((columns - (11 + ${#i}))) " "
	sleep 1
done
printf "%s%*s\n" "Continuing..." $((columns - (11 + ${#i}))) " "

for JAIL in $(poudriere jail -nlq); do
        for i in $(seq 0 2); do
                if [ $i -eq 1 ]; then
                        printf "|"
                        printf "%*s" $(( (${#JAIL} + (columns-2)) / 2 )) "$JAIL"
                        printf "%*s" $(( ((columns + 1) - ${#JAIL}) / 2 )) "|"
                else
			printf "%.0s-" $(seq 1 $columns)
                fi
                echo ''
        done
	poudriere bulk -f $1 -p local -tC -j $JAIL
        echo ''
done

