#!/bin/sh
#
# Version 0.0.2 - Jan/2009
# Changes: added device verification
#
# by Thiago Varela - thiago@iplenix.com
#
# --------------------------------------
#
# Version 0.0.3 - Dec/2011
# Changes:
#  - changed values from bytes to mbytes
#  - fixed bug to get traffic data without comma but point
#  - current values are displayed now, not average values (first run of iostat)
#
# by Philipp Niedziela - pn@pn-it.com
#
# --------------------------------------
#
# Version 0.0.4 - Apr/2012
# Changes:
#  - Added device name to plugin output
#  - Disk verification improved using iostat itself instead of relying
#    on /dev/$disk in order to work on LVM-based (/dev/mapper/$disk) setups.
#
# by Tom De Vylder - info@penumbra.be
#
# Version 0.0.5 - Oct/2015
# Changes:
#  - Se tiran los resultados a un archivo tmp para optimizar el tiempo y se imprimen los promedios
#
# Victor Acosta vic.ad94@gmail.com
iostat=`which iostat 2>/dev/null`
bc=`which bc 2>/dev/null`
function help {
echo -e "\n\tThis plugin shows the I/O usage of the specified disk, using the iostat external program.\n\tIt prints three statistics: Transactions per second (tps), Kilobytes per second\n\tread from the disk (KB_read/s) and and written to the disk (KB_written/s)\n\n$0:\n\t-d <disk>\t\tDevice to be checked (without the full path, eg. sda)\n\t-c <tps>,<read>,<wrtn>\tSets the CRITICAL level for tps, KB_read/s and KB_written/s, respectively\n\t-w <tps>,<read>,<wrtn>\tSets the WARNING level for tps, KB_read/s and KB_written/s, respectively\n"
        exit -1
}
# Ensuring we have the needed tools:
( [ ! -f $iostat ] || [ ! -f $bc ] ) && \
        ( echo "ERROR: You must have iostat and bc installed in order to run this plugin\n\tuse: apt-get install iostat bc\n" && exit -1 )
# Getting parameters:
while getopts "d:w:c:h" OPT; do
        case $OPT in
                "d") disk=$OPTARG;;
                "w") warning=$OPTARG;;
                "c") critical=$OPTARG;;
                "h") help;;
        esac
done
# Adjusting the three warn and crit levels:
crit_tps=`echo $critical | cut -d, -f1`
crit_read=`echo $critical | cut -d, -f2`
crit_written=`echo $critical | cut -d, -f3`
warn_tps=`echo $warning | cut -d, -f1`
warn_read=`echo $warning | cut -d, -f2`
warn_written=`echo $warning | cut -d, -f3`
# Checking parameters:
[ ! $(iostat | awk {'print $1'} | grep -x $disk) ] && echo "ERROR: Device incorrectly specified" && help
( [ "$warn_tps" == "" ] || [ "$warn_read" == "" ] || [ "$warn_written" == "" ] || \
  [ "$crit_tps" == "" ] || [ "$crit_read" == "" ] || [ "$crit_written" == "" ] ) &&
        echo "ERROR: You must specify all warning and critical levels" && help
( [[ "$warn_tps" -ge  "$crit_tps" ]] || \
  [[ "$warn_read" -ge  "$crit_read" ]] || \
  [[ "$warn_written" -ge  "$crit_written" ]] ) && \
  echo "ERROR: critical levels must be highter than warning levels" && help
# iostat parameters:
#   -m: megabytes
#   -k: kilobytes

# Realizando el chequeo y tirando a un archivo tmp para despues parsear y sacar el promedio
tmpfile=/tmp/iostatsceck-tmpfile.tmp
$iostat $disk -m -d 1 7 | grep $disk | tail -6 > $tmpfile

# Parseando y sacando el promedio
tps=$(cat $tmpfile | awk '{ SUM += $2 } END  {print SUM/NR}')
read=$(cat $tmpfile | awk '{ SUM += $3 } END  {print SUM/NR}')
written=$(cat $tmpfile | awk '{ SUM += $4 } END  {print SUM/NR}')

# Una vez que se cargaron las variables se elimina el archivo tmp
rm -rf $tmpfile
#fixing bug to display current values and not average values until last reboot

# "Converting" values to float (string replace , with .)
tps=${tps/,/.}
read=${read/,/.}
written=${written/,/.}
# Comparing the result and setting the correct level:
if ( [ "`echo "$tps >= $crit_tps" | bc`" == "1" ] || [ "`echo "$read >= $crit_read" | bc -q`" == "1" ] || \
     [ "`echo "$written >= $crit_written" | bc`" == "1" ] ); then
        msg="CRITICAL"
        status=2
else if ( [ "`echo "$tps >= $warn_tps" | bc`" == "1" ] || [ "`echo "$read >= $warn_read" | bc`" == "1" ] || \
          [ "`echo "$written >= $warn_written" | bc`" == "1" ] ); then
                msg="WARNING"
                status=1
     else
        msg="OK"
        status=0
     fi
fi
# Printing the results:
echo "$msg - I/O stats $disk tps=$tps MB_read/s=$read MB_written/s=$written | tps=$tps;$warn_tps;$crit_tps; MB_read/s=$read;$warn_read;$crit_read; MB_written/s=$written;$warn_written;$crit_written;"
# Bye!
exit $status
