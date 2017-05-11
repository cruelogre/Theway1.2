@echo off
cd /d %~dp0
lua LocalBugFix.lua %1
pause