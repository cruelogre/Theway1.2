@echo off
echo %1
cd /d %~dp0
lua Lua2XmlTool.lua %1
pause