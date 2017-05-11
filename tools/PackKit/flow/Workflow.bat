::*****************************************************
::Name:Workflow.bat
::Desc:Work in this way
::Auth:Wawa
::Date:20160826
::*****************************************************

::Hide Commands
@echo off

::BackColor=black ForColor=Green
@color 02 

::Hide Command Window
::if "%1"=="h" goto begin
::start mshta vbscript:createobject("wscript.shell").run("""%~nx0"" h",0)(window.close)&&exit
:::begin

::Update.bat
::param 1 is svn exe path 
::param 2 is main resource direction
::Execute Recursively
::update tiny texture resources from art svn to local work direction

::Rename.exe
::param 1 is main resource direction
::Execute Recursively, Compatible Now
::make png file name to no downline split, such as btn_red.png to btnred.png

::RenameEx.exe
::param 1 is main resource direction
::Execute Recursively
::make png file name to long full name, such as public/head/boss.png to public_head_boss.png

::Const.exe
::param 1 is main resource direction, 
::param 2 is out header file direction
::Execute Recursively
::make png file name to key-value header file, such as ww_head_const.h include const char* PUBLIC_HEAD_BOSS = "public_head_boss.png";

::Pack.bat
::param 1 is texturepacker exe path
::param 2 is resource direction
::param 3 is output directio, include plist and png
::Execute Non Recursively
::make tiny resources pack to plist by tool named texturepacker

::Copy.bat
::param 1 is from direction
::param 2 is to direction
::Execute Necessary
::copy all file from direction to other direction

::Commit.bat
::param 1 is svn exe path 
::param 2 is main resource direction
::Execute Recursively
::commit out file include pilst and png to svn
cls
echo.
echo CurrentDate=%date%
echo CurrentTime=%time%
echo.

echo ----------Workflow Start----------
echo.

::SVN安装路径（路径中有空格的要加双引号，下同）
set svn="C:\Program Files (x86)\VisualSVN\bin\svn.exe"
::TP安装路径（路径中有空格的要加双引号，下同）
set tpr="C:\Program Files\CodeAndWeb\TexturePacker4.3.1\bin\TexturePacker.exe"

::美术资源纹理目录（小图）
set art="F:\WW\Columbus\resource\gameCenter_res\res\ddz3\trunk"
::程序资源纹理目录（大图）
set out="F:\out"

echo.

::rmdir /s /q %art%
::rmdir /s /q %out%
::md %art%
::md %out%

::更新美术目录
::svn up %art%

::修正重命名，成为标准文件命名
call RenameEa %art%
call RenameEx %art%

::生成头文件，必须是标准文件命名
call Const %art% %out%

::打包命令，输入到程序资源目录
::将当前目录下所有图片只能生成一份大图，所以为了更好的管理，建议分开设置。
call Pack %tpr% %art%/login %out%/login
call Pack %tpr% %art%/hall %out%/hall
call Pack %tpr% %art%/game %out%/game
::call Pack %tpr% %art% %out%

::提交程序目录
::svn ci %out%

echo.
echo ----------Workflow End----------