#!/bin/bash
# Nagios Plugin Bash Script - check_open_files.sh
#Esta secuencia de comandos comprueba el nú de archivos actualmente abiertos para el usuario especificado con el umbral WARNING y CRITICAL especificado
#
# Comprobar los parametros que faltan
if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
        echo "Parametros que faltan! Sintaxis: ./check_cantidad_procesos.sh USER WARNING_LIMITE CRITICAL_LIMITE"
        exit 2
fi

# Numero de procesos por usuario
proceso=`/bin/ps -mU $1 |wc -l`

# Verificar si el numero de procesos actualmente es menor al parametro de umbral WARNING
if [[ "$proceso" -lt "$2" ]]; then
        echo "OK - Cantidad de procesos es $proceso"
        exit 0
fi

# Verificar si el numero de procesos actualmente es mayor al parametro de umbral WARNING y que es menor al parametro e umbral CRITICAL

if [[ "$proceso" -ge "$2" ]] && [[ "$proceso" -le "$3" ]]; then
        echo "WARNING - Cantidad de procesos es  $proceso"
        exit 1
fi

# Verifica si el numero de procesos  es mayor que el parametro de umbral CRITICAL

if [[ "$proceso" -gt "$3" ]]; then
        echo "CRITICAL - Cantidad de procesos $proceso"
        exit 2
fi
