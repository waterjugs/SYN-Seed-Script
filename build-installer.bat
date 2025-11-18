@echo off
REM Build script for Inno Setup installer
REM This script helps automate the build process

echo ========================================
echo HLL Seed Script - Inno Setup Builder
echo ========================================
echo.

REM Check if Inno Setup Compiler is available
where iscc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Inno Setup Compiler (iscc.exe) is not found.
    echo.
    echo Please install Inno Setup from:
    echo https://jrsoftware.org/isdl.php
    echo.
    echo Make sure to add Inno Setup to your system PATH, or
    echo provide the full path to iscc.exe below.
    echo.
    set /p ISCC_PATH="Enter full path to iscc.exe (or press Enter to exit): "
    if "!ISCC_PATH!"=="" (
        exit /b 1
    )
) else (
    set ISCC_PATH=iscc
)

REM Check if installer.iss exists
if not exist "installer.iss" (
    echo ERROR: installer.iss not found in current directory.
    echo Please run this script from the project root directory.
    pause
    exit /b 1
)

REM Create dist directory if it doesn't exist
if not exist "dist" (
    mkdir dist
)

echo Building installer...
echo.

REM Build the installer
"%ISCC_PATH%" installer.iss

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build completed successfully!
    echo ========================================
    echo.
    echo Installer location: dist\SYN-Seed-Script-Setup-v4.0.0.exe
    echo.
) else (
    echo.
    echo ========================================
    echo Build failed!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo.
)

pause
