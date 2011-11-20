@echo off
for %%i in (..\originaldata\ts\*.ts) do call lupdate.exe -no-obsolete -locations none ..\src\qml\touchandlearn\database.js -ts %%i
