@ECHO OFF
SET TSFILES=
FOR %%i IN (..\originaldata\ts\*.ts) DO call :addtotsfilelist %%i

linguist.exe %TSFILES%

:addtotsfilelist
set TSFILES=%1 %TSFILES%
goto :eof
