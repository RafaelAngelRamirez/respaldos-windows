@echo off
set v=v0.1.0


REM El titulo
TITLE Gestor general de respaldos: %v%
cls

REM Este es el mensaje de error que se muestra cuando 
rem no se agrega un parametro. 
set msjError=respaldo.bat nombre-del-respaldo directorio-a-respladar dia [directorioDondeSeRespaldara]

rem El primer parametro define el nombre de los respaldos. 
rem Carpeta de respaldo
rem carpetas con fecha.
if "%1"=="" (
  echo Es necesario que definas el nombre que llevara el respaldo.
  echo %msjError%
  pause
  exit
)
set nombreDelRespaldo="%1"

rem El segundo paraemtro es el directorio que se quiere respaldar
if "%2"=="" (
  echo Es necesario que definas nombre del parametro
  echo %msjError%
  pause
  exit
)
set directorioACopiar="%2"

rem El tercer parametro corresponde al dia. El valor 
rem puede estar entre 1 - 7 y -1
if "%3"=="" (
  echo No definiste el parametro del dia de respaldo. 
  echo %msjError%
  pause
  exit
)
set diaDeRespaldo="%3"

if "%4"=="" (
    set directorioDondeSeRespaldara=C:\%nombreDelRespaldo%
) else (
    set directorioDondeSeRespaldara="%4"
)

rem Creamos el directorio de respaldo si no existe. 
if exist %directorioDondeSeRespaldara% (
    echo [ INFO ] El directorio de respaldo existe.
) else (

    echo [ INFO ] Se creara el directorio de respaldo en %directorioDondeSeRespaldara%
    mkdir %directorioDondeSeRespaldara%
    rem Si hay un error entonces detenemos el programa. 
     if errorlevel 1 (
         echo [ ERROR ] Hubo un error creando la carpeta... 
         echo [ INFO  ] No se pudo realizar el respaldo. 
         pause 
         exit
    )
)

echo [ INFO ] Nombre del respaldo: %nombreDelRespaldo%
echo [ INFO ] Directorio a copiar: %directorioACopiar%
echo [ INFO ] Directorio donde se respaldara: %directorioDondeSeRespaldara%

REM *******************************************************************************
REM ** Este script respalda una carpeta y despues la comprime. Si se define el dia de respaldo
REM ** este solo se hara el dia que se defina. Tambien se puede decir si es un
REM ** respaldo incremental o no. 
REM ** Para las copias completas semanales revisa la fecha actual y ejecuta el cambio de nombre
REM *******************************************************************************

REM Obtenemos lq fecha actual.
set anio=%date:~6,4%
set mes=%date:~3,2%
set diaMes=%date:~0,2%
set fecha=%anio%_%mes%_%diaMes%


REM ----------------------------------------------------
REM ----------------------------------------------------
REM //DEFINICION DE PARAMETROS PERSONALIZABLES. 

REM El dia de la semana para generar el respaldo completo. 
set diaRespaldoCompleto=%diaDeRespaldo%
set origenDeCopia=%directorioACopiar%

REM El nombre de la carpeta semanal que se generara. 
set directorio_RespaldoSemanal=%nombreDelRespaldo%_%fecha%
REM El nombre de la carpeta incremental. Esta es por si no existe. 
set directorio_RespaldoIncremental=%nombreDelRespaldo%_INCREMENTAL


set rutaBase_Destinos=%directorioDondeSeRespaldara%
set destino_completo=%rutaBase_Destinos%\%directorio_RespaldoSemanal%
set destino_incremental=%rutaBase_Destinos%\%directorio_RespaldoIncremental%

REM ----------------------------------------------------
REM ----------------------------------------------------

REM Este es el tiempo que dura en cerrarse la pantalla. Se modifica
REM dependiendo si es un respaldo incremental o uno normal. 
set tiempoDeCierre=0

REM // Este codigo llama la etiqueta DateToWeek que nos permite saber el dia 
REM     dw = Day of week
REM     cw = Semana del anio
REM     yn = El anio

call :DateToWeek %date:~6, 4% %date:~3, 2% %date:~0, 2% yn cw dw
REM  Obtenemos el nombre del dia de la semana. 
if "%dw%" == "1" ( set dia=Lunes )
if "%dw%" == "2" ( set dia=Martes )
if "%dw%" == "3" ( set dia=Miercoles )
if "%dw%" == "4" ( set dia=Jueves )
if "%dw%" == "5" ( set dia=Viernes )
if "%dw%" == "6" ( set dia=Sabado )
if "%dw%" == "7" ( set dia=Domingo )

REM Para mostrar el nombre del dia que esta programado el respaldo completo. 
if "%diaRespaldoCompleto%" == "1" ( set diaRespaldoCompletoNombre=Lunes)
if "%diaRespaldoCompleto%" == "2" ( set diaRespaldoCompletoNombre=Martes)
if "%diaRespaldoCompleto%" == "3" ( set diaRespaldoCompletoNombre=Miercoles)
if "%diaRespaldoCompleto%" == "4" ( set diaRespaldoCompletoNombre=Jueves)
if "%diaRespaldoCompleto%" == "5" ( set diaRespaldoCompletoNombre=Viernes)
if "%diaRespaldoCompleto%" == "6" ( set diaRespaldoCompletoNombre=Sabado)
if "%diaRespaldoCompleto%" == "7" ( set diaRespaldoCompletoNombre=Domingo)


REM //Si es sabado entonces hacemos un respaldo socompleto. 
echo ---------------------------------------------
echo [ RESPALDO AUTOMATIZADO DE FICHEROS ]
echo ---------------------------------------------
echo [ i ] Este es un script automatizado para el respaldo. 
echo Por favor no cierres esta ventana hasta que finalize. 

echo ---------------------------------------------
echo Este es el nombre del respaldo %destino_incremental% !!!!!!!! 4

echo [ i ] Este script esta programado para generar los respaldos completos el %diaRespaldoCompletoNombre%.

if "%dw%" == "%diaRespaldoCompleto%" OR -1 == %diaRespaldoCompleto% ( 
    
    echo [ + ] Es %dia%. Esta programado un respaldo completo. 
    if not exist %destino_completo% (
        echo [ + ] Cambiando nombre de directorio incremental para dejarlo fijo. 
        
        REM Nos movemos al directorio de respaldos para poder renombrar. 
        CD %rutaBase_Destinos%
        
        REM Renombramos el directorio.  
        REN %directorio_RespaldoIncremental% %directorio_RespaldoSemanal%
        echo %directorio_RespaldoIncremental% %directorio_RespaldoSemanal%
        

        set tiempoDeCierre=3600

    ) else (
        echo [ + ] No es necesario generar el respaldo completo. Ya se genero. 
        set tiempoDeCierre=60
    )
    

) 
echo [ + ] Se generara un respaldo incremental.

echo %origenDeCopia% g %destino_incremental%
set "esp=%destino_incremental:"=%"
set "name=%name:"=%"

REM Si el directorio no existe lo creamos. 
if not exist %destino_incremental% (
    echo [ ! ] El destino para el respaldo incremental se creara. 
    MD %destino_incremental%
)

echo [ + ] Iniciando respaldo incremental.
robocopy %origenDeCopia% %esp% /MIR /FFT /R:3 /W:10 /Z /NP /NDL

echo [ ok ] Termino la ejecucion de este lote. Esta ventana se cerrara automaticamente:

REM ping -n 6 localhost >nul
REM timeout %tiempoDeCierre%
pause


goto :EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DateToWeek %yy% %mm% %dd% yy cw dw
::
:: By: Ritchie Lawrence, Updated 2002-11-20. Version 1.1
::
:: Func: Returns an ISO 8601 Week date from a calendar date.
::       For NT4/2K/XP.
::
:: Args: %1 year component to be converted, 2 or 4 digits (by val)
:: %2 month component to be converted, leading zero ok (by val)
:: %3 day of month to be converted, leading zero ok (by val)
::       %4 var to receive year, 4 digits (by ref)
::       %5 var to receive calendar week, 2 digits, 01 to 53 (by ref)
::       %6 var to receive day of week, 1 digit, 1 to 7 (by ref)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal ENABLEEXTENSIONS
set yy=%1&set mm=%2&set dd=%3
if 1%yy% LSS 200 if 1%yy% LSS 170 (set yy=20%yy%) else (set yy=19%yy%)
set /a dd=100%dd%%%100,mm=100%mm%%%100
set /a z=14-mm,z/=12,y=yy+4800-z,m=mm+12*z-3,Jd=153*m+2
set /a Jd=Jd/5+dd+y*365+y/4-y/100+y/400-32045
set /a y=yy+4798,Jp=y*365+y/4-y/100+y/400-31738,t=Jp+3,Jp=t-t%%7
set /a y=yy+4799,Jt=y*365+y/4-y/100+y/400-31738,t=Jt+3,Jt=t-t%%7
set /a y=yy+4800,Jn=y*365+y/4-y/100+y/400-31738,t=Jn+3,Jn=t-t%%7
set /a Jr=%Jp%,yn=yy-1,yn+=Jd/Jt,yn+=Jd/Jn
if %Jd% GEQ %Jn% (set /a Jr=%Jn%) else (if %Jd% GEQ %Jt% set /a Jr=%Jt%)
set /a diff=Jd-Jr,cw=diff/7+1,wd=diff%%7,wd+=1
if %cw% LSS 10 set cw=0%cw%
endlocal&set %4=%yn%&set %5=%cw%&set %6=%wd%&goto :EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

