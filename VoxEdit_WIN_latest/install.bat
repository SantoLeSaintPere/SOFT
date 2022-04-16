@echo off
pushd "%~dp0"
echo Registering .vxm files to %CD%\VoxEdit.exe
echo.

OPENFILES >NUL 2>&1
IF ERRORLEVEL 1 (
	echo Installation requires administrative priviledges.
	echo Please run install.bat as Administrator.
	echo To do this, right click on install.bat and choose "Run as Administrator".
	echo.
	echo Press any key to close this window.
	pause >nul
	popd
	exit /B 0
)

assoc .vxm=VoXelModel
ftype VoXelModel="%CD%\java\bin\javaw" -Xms512M -Xmx4096M -D"java.ext.dirs=%CD%\lib" -cp "%CD%\lib" VoxEdit "%%1"
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.vxm /f /v BrowserFlags /t REG_DWORD /d 0x00000000
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.vxm /f /v EditFlags  /t REG_DWORD /d 0x00000000
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.vxm /f /v PerceivedType /t REG_SZ /d "gamemedia"
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.vxm\DefaultIcon /f /ve /t REG_SZ /d "%CD%\data\icon.ico,0"
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Classes\VoXelModel\DefaultIcon /f /ve /t REG_SZ /d "%CD%\data\icon.ico,0"
%windir%\system32\ie4uinit.exe -show

echo Registration successful!
echo Press any key to close this window.
pause >nul
popd
exit /B 0
