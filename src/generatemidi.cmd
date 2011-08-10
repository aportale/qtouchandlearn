@echo off
rem Download abctools from http://ifdo.pugmarks.com/~seymour/runabc/top.html
set PATH=..\..\abctools;%PATH%
for %%i in (abcmidi\*.abc) do call abc2midi %%i -o data/audio/%%~ni.mid
