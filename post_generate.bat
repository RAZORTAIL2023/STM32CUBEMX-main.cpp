@echo off
REM ============================================================================
REM Post-Generation Script for STM32CubeMX
REM Purpose: 1. Rename main.c to main.cpp after CubeMX generates files
REM          2. Update Keil project files to reference main.cpp
REM Usage: Configure this script in STM32CubeMX Project Settings as 
REM        "Post Code Generation" script
REM ============================================================================

setlocal enabledelayedexpansion

echo ========================================
echo STM32CubeMX Post-Generation Script
echo ========================================

REM ====================
REM Step 1: Rename main.c to main.cpp
REM ====================
echo.
echo Step 1: Renaming main.c to main.cpp...
echo ----------------------------------------

set "FOUND_MAIN=0"
for /r "Core\Src" %%f in (main.c) do (
    if exist "%%f" (
        set "FOUND_MAIN=1"
        echo Found main.c: %%f
        
        REM Get the new filename
        set "FILEPATH=%%f"
        set "NEWFILE=%%~dpnf.cpp"
        
        echo Renaming to: !NEWFILE!
        ren "%%f" "main.cpp"
        
        if exist "!NEWFILE!" (
            echo [SUCCESS] Renamed %%f to main.cpp
        ) else (
            echo [ERROR] Failed to rename %%f
            exit /b 1
        )
    )
)

if !FOUND_MAIN!==0 (
    echo [WARNING] No main.c found in Core\Src
)

REM ====================
REM Step 2: Update Keil project files (.uvprojx)
REM ====================
echo.
echo Step 2: Updating Keil project files...
echo ----------------------------------------

set "FOUND_KEIL=0"
for /r %%f in (*.uvprojx) do (
    if exist "%%f" (
        set "FOUND_KEIL=1"
        echo Found Keil project: %%f
        
        REM Create a temporary file
        set "TEMPFILE=%%f.tmp"
        
        REM Use PowerShell to replace main.c with main.cpp in the project file
        REM Multiple replace operations to target specific XML elements
        powershell -Command "$content = Get-Content '%%f' -Raw; $content = $content -replace '(<FileName>)main\.c(</FileName>)', '$1main.cpp$2'; $content = $content -replace '([\\/])main\.c', '$1main.cpp'; $content | Set-Content '!TEMPFILE!' -NoNewline"
        
        if exist "!TEMPFILE!" (
            REM Replace original file with updated file
            move /y "!TEMPFILE!" "%%f" > nul
            echo [SUCCESS] Updated %%f
        ) else (
            echo [ERROR] Failed to update %%f
        )
    )
)

if !FOUND_KEIL!==0 (
    echo [INFO] No Keil project files (.uvprojx) found
    echo [INFO] If using other IDEs, manual project configuration may be needed
)

REM ====================
REM Step 3: Update Keil project files (.uvoptx) - optional settings file
REM ====================
echo.
echo Step 3: Updating Keil options files...
echo ----------------------------------------

set "FOUND_KEIL_OPT=0"
for /r %%f in (*.uvoptx) do (
    if exist "%%f" (
        set "FOUND_KEIL_OPT=1"
        echo Found Keil options file: %%f
        
        REM Create a temporary file
        set "TEMPFILE=%%f.tmp"
        
        REM Use PowerShell to replace main.c with main.cpp in the options file
        REM Multiple replace operations to target specific XML elements
        powershell -Command "$content = Get-Content '%%f' -Raw; $content = $content -replace '(<FileName>)main\.c(</FileName>)', '$1main.cpp$2'; $content = $content -replace '([\\/])main\.c', '$1main.cpp'; $content | Set-Content '!TEMPFILE!' -NoNewline"
        
        if exist "!TEMPFILE!" (
            REM Replace original file with updated file
            move /y "!TEMPFILE!" "%%f" > nul
            echo [SUCCESS] Updated %%f
        ) else (
            echo [ERROR] Failed to update %%f
        )
    )
)

if !FOUND_KEIL_OPT!==0 (
    echo [INFO] No Keil options files (.uvoptx) found
)

echo ========================================
echo Post-Generation Complete!
echo ========================================
echo.
echo Your main.c has been renamed to main.cpp
echo Keil project files have been updated
echo You can now use C++ in your main file
echo ========================================

endlocal
exit /b 0
