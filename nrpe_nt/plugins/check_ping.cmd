@echo off
rem Ciro Iriarte
rem check_ping
rem Chequea q sea accesible un host
rem 
rem Uso: check_ping <TIMEOUT> <host>
rem

if hola%2 == hola goto args

c:\nrpe_nt\plugins\alive.exe /REPEAT=1 /TIMEOUT=%1 %2 > NUL

GOTO err%ERRORLEVEL%

rem Salidas

:args
echo Debe pasar dos argumentos, TIMEOUT y HOST
exit 3

:err0
echo OK - Host alive
exit 0

:err1
echo CRITICAL - Request timed out
exit 2

:err2
echo CRITICAL - Destination host unreachable
exit 2

:err3
echo CRITICAL - Destination network unreachable
exit 2

:err4
echo CRITICAL - Destination protocol unreachable
exit 2

:err5
echo CRITICAL - Destination port unreachable
exit 2

:err6
echo CRITICAL - Hardware error
exit 2

:err7
echo CRITICAL - TTL expired in transit
exit 2

:err8
echo CRITICAL - Bad Destination
exit 2

:err255
echo UNKNOWN - Other errors
exit 3