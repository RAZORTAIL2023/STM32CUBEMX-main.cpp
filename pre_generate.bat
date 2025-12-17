@echo off
REM ============================================================================
REM Pre-Generation Script for STM32CubeMX
REM Purpose: Rename main.cpp back to main.c before CubeMX regenerates files
REM Usage: Configure this script in STM32CubeMX Project Settings as 
REM        "Pre Code Generation" script
REM ============================================================================

setlocal enabledelayedexpansion

echo ========================================
echo STM32CubeMX Pre-Generation Script
echo ========================================

REM Find all main.cpp files in Core/Src directory
set "FOUND=0"
for /r "Core\Src" %%f in (main.cpp) do (
    if exist "%%f" (
        set "FOUND=1"
        echo Found main.cpp: %%f
        
        REM Get the directory and filename without extension
        set "FILEPATH=%%f"
        set "DIRPATH=%%~dpf"
        set "NEWFILE=%%~dpnf.c"
        
        echo Renaming to: !NEWFILE!
        ren "%%f" "main.c"
        
        if exist "!NEWFILE!" (
            echo [SUCCESS] Renamed %%f to main.c
        ) else (
            echo [ERROR] Failed to rename %%f
        )
    )
)

if !FOUND!==0 (
    echo [INFO] No main.cpp found in Core\Src - this is normal for first run
)

echo ========================================
echo Pre-Generation Complete
echo ========================================

endlocal
exit /b 0
