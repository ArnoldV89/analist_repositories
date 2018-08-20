#!/bin/bash
# Nagios Plugin Bash Script - check_open_files.sh
#Esta secuencia de comandos comprueba el nú de archivos actualmente abiertos para el usuario especificado con el umbral WARNING y CRITICAL especificado
#
# Comprobar los parametros que faltan
if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
        echo "Parametros que faltan! Sintaxis: ./check_archivos_abiertos.sh USER WARNING_LIMITE CRITICAL_LIMITE"
        exit 2
fi
# Numero de archivos abiertos actualmente
ofiles=$(sudo /usr/sbin/lsof |grep $1 |grep REG |wc -l)

# Verificar si el numero de archivos abiertos actualmente es menor al parametro de umbral WARNING
if [[ "$ofiles" -lt "$2" ]]; then
        echo "OK - Number of open files is $ofiles"
        exit 0
fi

# Verificar si el numero de archivos abiertos actualmente es mayor al parametro de umbral WARNING y que es menor al parametro e umbral CRITICAL

if [[ "$ofiles" -gt "$2" ]] && [[ "$ofiles" -lt "$3" ]]; then
        echo "WARNING - Number of open files is $ofiles"
        exit 1
fi

# Verifica si el numero de archivos actualmente abiertos es mayor que el parametro de umbral CRITICAL

if [[ "$ofiles" -gt "$3" ]]; then
        echo "CRITICAL - Number of open files is $ofiles"
        exit 2
fi
