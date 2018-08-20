#!/bin/bash
# CI - Feb/2005


if [[ $# < 4 ]]
then
	echo "Sintaxis check_memory.sh <PVM|PM> <proceso> <WARN> <CRIT>"
else
	case "$1" in
	'PVM')
	    result=$(/cygdrive/c/nrpe_nt/plugins/pslist.exe -m  $2|grep $2|awk '{ print $5 }')
	    let result=result/1024
	    ;;
	'PM')
	    result=$(/cygdrive/c/nrpe_nt/plugins/pslist.exe -m  $2|grep $2|awk '{ print $4 }')
	    let result=result/1024
	    ;;
	*)
	    echo "Parametro no soportado";exit 3
	    ;;
	esac
	rcode=0;out=OK
#	if [[ $result > $3 ]];then
	if test $result -ge $3
	then
		rcode=1
		out=WARNING
	fi
#	if [[ $result > $4 ]]; then
	if test $result -ge $4
	then
		rcode=2
		out=CRITICAL
	fi
	if [[ $5 == 'GRA' ]]; then
		echo "$rcode;$1 $out - ${result}MB utilizados;$result"
	else
		echo "$1 $out - ${result}MB utilizados"
		exit $rcode
	fi
fi
