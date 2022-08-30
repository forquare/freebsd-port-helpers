#!/bin/sh

columns=80

testport () {
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
		poudriere testport -v -b latest -p local ${2:+-z $2} -j $JAIL -o ${1}
		echo ''
	done
}

if [ -z $1 ]; then
	echo "No package entered"
	exit 1
fi

if [ ! -d /usr/ports/$1 ]; then
	echo "Cannot find $1"
	exit 2
fi

printf "%s\n" "Do you need to update the jails or run 'poudriere options'?"
for i in $(seq 5 1); do
	printf "%s%*s\r" "Countdown: $i" $((columns - (11 + ${#i}))) " "
	sleep 1
done
printf "%s%*s\n" "Continuing..." $((columns - (11 + ${#i}))) " "

if [ ! -z $2 ]; then
	options=$(echo $2 | tr ',' ' ')
	for option in ${options}; do
		testport $1 $option
	done
else
	testport $1
fi
