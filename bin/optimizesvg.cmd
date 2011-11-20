@ECHO OFF
FOR %%i IN (..\originaldata\graphics\*.svg) DO call python ..\..\scour\scour.py --enable-id-stripping --shorten-ids --protect-ids-prefix=id_ --remove-metadata --strip-xml-prolog --enable-comment-stripping --create-groups --indent=none --set-precision=4 -i %%i -o ..\src\data\graphics\%%~ni.svg
