@echo off
REM 切换到脚本所在目录的上级目录 (项目根目录)
cd /d "%~dp0.."

if exist "Core\Src\main.cpp" (
    if exist "Core\Src\main.c" del "Core\Src\main.c"
    ren "Core\Src\main.cpp" "main.c"
)