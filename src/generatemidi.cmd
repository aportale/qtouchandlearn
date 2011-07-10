@echo off
set PATH=..\..\abctools;%PATH%
for %%i in (abcmidi\*.abc) do call abc2midi %%i -o data/audio/%%~ni.mid
