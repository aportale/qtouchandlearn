@echo off
for %%i in (data\*.ts) do call lupdate.exe -no-obsolete -locations none qml\touchandlearn\database.js qml\touchandlearn\LessonMenu.qml -ts  %%i
