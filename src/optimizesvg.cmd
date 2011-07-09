@ECHO OFF
FOR %%i IN (originalartwork\*.svg) DO call python ..\..\scour\scour.py --enable-id-stripping --shorten-ids --protect-ids-prefix=id_ --remove-metadata --strip-xml-prolog --enable-comment-stripping --create-groups --indent=none --set-precision=4 -i %%i -o data\%%~ni.svg
