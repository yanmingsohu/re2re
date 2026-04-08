set a=C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86
set o=commlib-export.txt

dumpbin /exports "%a%\imm32.lib" >> %o%
dumpbin /exports "%a%\kernel32.lib" >> %o%
dumpbin /exports "%a%\user32.lib" >> %o%
dumpbin /exports "%a%\gdi32.lib" >> %o%
dumpbin /exports "%a%\advapi32.lib" >> %o%
dumpbin /exports "%a%\ole32.lib" >> %o%
dumpbin /exports "%a%\winmm.lib" >> %o%
dumpbin /exports "%a%\ddraw.lib" >> %o%
dumpbin /exports "%a%\dsound.lib" >> %o%
dumpbin /exports "%a%\msacm32.lib" >> %o%
