@echo off
rem Download soundfont from http://www.schristiancollins.com/generaluser.php
PATH "c:\Program Files\VideoLAN\VLC";%PATH%
for %%i in (..\src\data\audio\*.mid) do call vlc -vvv "%%i" --sout=#transcode{acodec=mp3,channels=2,samplerate=44100,ab=128}:standard{access=file,dst=..\src\mp3audio\%%~ni.mp3} vlc://quit
