@echo off
for %%i in (..\originaldata\ts\*.ts) do call lrelease.exe -nounfinished -removeidentical %%i -qm ..\src\TouchAndLearn\data\translations\%%~ni.qm
