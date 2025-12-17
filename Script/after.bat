@echo off
set BAT_NAME=%~n0

REM 1. 执行原有的 PowerShell 脚本 (修改 .uvprojx 配置，将 main.c 标记为 C++)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0%BAT_NAME%.ps1" %*

REM 2. 将 main.c 改回 main.cpp (适配 EIDE)
cd /d "%~dp0.."
if exist "Core\Src\main.c" (
    echo [INFO] Renaming main.c back to main.cpp...
    REM 如果此时意外存在 main.cpp，先删除它，确保使用 CubeMX 生成后的新文件
    if exist "Core\Src\main.cpp" del "Core\Src\main.cpp"
    ren "Core\Src\main.c" "main.cpp"
)
endlocal