@echo off
for %%i in (ts\*.ts) do call lrelease.exe -nounfinished -removeidentical %%i -qm data\translations\%%~ni.qm
