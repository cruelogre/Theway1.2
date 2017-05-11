::*****************************************************
::Name:Pack.bat
::Desc:Packing tiny Resource to plist
::Auth:Wawa
::Date:20160826
::Param:%1 is texurepacker exe path %2 is src dir, %3 is out dir
::Extra:install TexturePacker3.0.9, especialy same version
::Extra:More detailed for http://post.justbilt.com/2013/12/12/use_tp_on_command_line/
::*****************************************************

::Hide Commands
@echo off

echo.
echo ----------Pack Start----------
echo.
for /f "delims=" %%i in ("%2") do set name=%%~ni
%1 --sheet %3/%name%.png --data %3/%name%.plist %2 --no-trim --allow-free-size --format cocos2d
pngquant -f --ext .png --quality 50-80 %3/%name%.png
echo.

echo ----------Pack End----------