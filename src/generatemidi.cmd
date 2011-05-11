@echo off
for %%i in (abcmidi\*.abc) do call abc2midi %%i -o data/%%~ni.mid
