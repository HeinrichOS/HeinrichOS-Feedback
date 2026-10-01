@echo off
setlocal
set "ROOT=%~dp0"
set "SRC=%ROOT%release-source\HOS_SYSTEM\LAUNCHER\HeinrichOSLauncher.cs"
set "ICO=%ROOT%release-source\HOS_SYSTEM\LAUNCHER\heinrichos.ico"
set "OUTDIR=%ROOT%build"
set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%CSC%" (echo ERROR: .NET Framework C# compiler not found.& exit /b 2)
if not exist "%OUTDIR%" mkdir "%OUTDIR%"
"%CSC%" /nologo /target:winexe /optimize+ /platform:anycpu /win32icon:"%ICO%" /reference:System.dll /reference:System.Drawing.dll /reference:System.Windows.Forms.dll /out:"%OUTDIR%\HeinrichOS.exe" "%SRC%"
if errorlevel 1 exit /b %errorlevel%
echo Built: %OUTDIR%\HeinrichOS.exe
certutil -hashfile "%OUTDIR%\HeinrichOS.exe" SHA256
exit /b 0