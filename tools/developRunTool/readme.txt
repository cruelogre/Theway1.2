#Lua脚本快速开发运行工具

~
因为现在win下，编译好EXE后，纯脚本开发，可以直接使用这个脚本去快速，
copy资源到运行环境，并且打开EXE

--------------------------------------------------------------------------------------------------------------------------
配置：
--------------------------------------------------------------------------------------------------------------------------
[SystemResolution]
copytoDebugWin32 = true     #是否Copy到DebugWin32
copyPath = F:\developer_folder\branches\branch_lua\WW_DDZ_PLUS\Resources\scripts #开发脚本文件夹目录
targetPath = F:\developer_folder\branches\branch_lua\WW_DDZ_PLUS\proj.win32\Debug.win32\scripts  #debugwin32脚本文件夹目录
runDebugWin32exePath = F:\developer_folder\branches\branch_lua\WW_DDZ_PLUS\proj.win32\Debug.win32\WW_DDZ_PLUS.exe  #win32可执行文件

[xxtea]
XXTEAKey = 2dxLua  #秘钥
XXTEASign = XXTEA  #签名
targetScrPath = F:\developer_folder\branches\branch_lua\WW_DDZ_PLUS\proj.win32\Debug.win32\scripts  #xxtea文件放在哪

--------------------------------------------------------------------------------------------------------------------------
命令行：
--------------------------------------------------------------------------------------------------------------------------
scriptDevTool.py -help   查看帮助
scriptDevTool.py -copy   只将资源复制到DebugWin32下，不执行exe
scriptDevTool.py -run    执行exe  开发的时候，先把文件Copy到DebugWin32下，再执行exe
scriptDevTool.py -luacompile    将文件加密到指定文件夹 ，需要配置ddzAuto.conf的 xxtea
scriptDevTool.py -runasluac    将文件加密，执行



