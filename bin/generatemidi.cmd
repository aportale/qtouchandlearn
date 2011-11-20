@echo off
rem Download abctools from http://ifdo.pugmarks.com/~seymour/runabc/top.html
set PATH=..\..\abctools;%PATH%
for %%i in (..\originaldata\abcmidi\*.abc) do call abc2midi %%i -o ../src/data/audio/%%~ni.mid
