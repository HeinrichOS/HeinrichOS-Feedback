@echo off
setlocal
set "ROOT=%~dp0"
set "TARGET=%ROOT%release-source\HOS_SYSTEM\APP\PLAYER_V1_6\app\01_HTML"
copy /b "%ROOT%large-source-parts\app.js.part001"+"%ROOT%large-source-parts\app.js.part002"+"%ROOT%large-source-parts\app.js.part003"+"%ROOT%large-source-parts\app.js.part004"+"%ROOT%large-source-parts\app.js.part005"+"%ROOT%large-source-parts\app.js.part006"+"%ROOT%large-source-parts\app.js.part007"+"%ROOT%large-source-parts\app.js.part008"+"%ROOT%large-source-parts\app.js.part009"+"%ROOT%large-source-parts\app.js.part010"+"%ROOT%large-source-parts\app.js.part011"+"%ROOT%large-source-parts\app.js.part012"+"%ROOT%large-source-parts\app.js.part013" "%TARGET%\app.js" >nul
if errorlevel 1 exit /b %errorlevel%
copy /b "%ROOT%large-source-parts\f116_data.js.part001"+"%ROOT%large-source-parts\f116_data.js.part002"+"%ROOT%large-source-parts\f116_data.js.part003"+"%ROOT%large-source-parts\f116_data.js.part004"+"%ROOT%large-source-parts\f116_data.js.part005"+"%ROOT%large-source-parts\f116_data.js.part006"+"%ROOT%large-source-parts\f116_data.js.part007"+"%ROOT%large-source-parts\f116_data.js.part008"+"%ROOT%large-source-parts\f116_data.js.part009"+"%ROOT%large-source-parts\f116_data.js.part010"+"%ROOT%large-source-parts\f116_data.js.part011"+"%ROOT%large-source-parts\f116_data.js.part012" "%TARGET%\f116_data.js" >nul
if errorlevel 1 exit /b %errorlevel%
echo Reassembled app.js and f116_data.js.
certutil -hashfile "%TARGET%\app.js" SHA256
certutil -hashfile "%TARGET%\f116_data.js" SHA256
echo Expected f116_data.js SHA256:
echo 8F5659F10DB5811FB0637DD7CCCE986905765415E0AF6AD0D0FA557919060B89
exit /b 0