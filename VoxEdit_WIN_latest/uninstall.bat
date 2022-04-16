@echo off
pushd "%~dp0"
echo Deregistering .vxm files
echo.

OPENFILES >NUL 2>&1
IF ERRORLEVEL 1 (
	echo Uninstallation requires administrative priviledges.
	echo Please run uninstall.bat as Administrator.
	echo To do this, right click on uninstall.bat and choose "Run as Administrator".
	echo.
	echo Press any key to close this window.
	pause >nul
	popd
	exit /B 0
)

assoc .vxm=
ftype VoXelModel=
reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.vxm /f
reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\VoXelModel /f
%windir%\system32\ie4uinit.exe -show

echo Deregistration successful!
echo Press any key to close this window.
pause >nul
popd
exit /B 0
