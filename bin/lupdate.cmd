@echo off
for %%i in (..\originaldata\ts\*.ts) do call lupdate.exe -no-obsolete -locations none ..\src\TouchAndLearn\database.js -ts %%i
