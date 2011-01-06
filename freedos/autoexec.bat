REM borrowed from the top of freedos\fdauto.bat
@echo off
SET DEBUG=N
SET NLSPATH=A:\FREEDOS
set dircmd=/P /OGN /4
set lang=EN
SET PATH=A:\FREEDOS;A:\DRIVER

REM get boot arguments
getargs >temp.bat
call temp.bat
del temp.bat

REM serial console redirect
if "%sercons%"=="" goto end
echo Redirecting console to %sercons%
if not "%baudhard%"=="" mode %sercons% baudhard=%baudhard%
if not "%baud%"=="" mode %sercons% baud=%baud%
ctty %sercons%
:end
