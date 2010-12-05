@echo off
for %%i in (ts\*.ts) do call lupdate.exe -no-obsolete -locations none qml\touchandlearn\database.js qml\touchandlearn\LessonMenu.qml -ts %%i
