@ECHO OFF
FOR %%i IN (originalartwork\*.svg) DO call python ..\..\scour\scour.py --create-groups --remove-metadata --strip-xml-prolog --enable-comment-stripping --indent=none --set-precision=4 -i %%i -o data\%%~ni.svg
