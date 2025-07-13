@echo off

setlocal

REM Enable ANSI color support for Windows 10/11
for /f "tokens=2 delims=." %%a in ('ver') do set "winver=%%a"
if %winver% geq 10 (
    reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f > nul 2>&1
)

REM ANSI Escape Code for Colors (ESC character is ASCII 27)
set "reset=[0m"

REM Strong Foreground Colors
set "white_fg_strong=[90m"
set "red_fg_strong=[91m"
set "green_fg_strong=[92m"
set "yellow_fg_strong=[93m"
set "blue_fg_strong=[94m"
set "magenta_fg_strong=[95m"
set "cyan_fg_strong=[96m"
set "blue_bg=[44m"
set "yellow_bg=[43m"

REM Environment Variables (winget)
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"

REM Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "current_path=%%B"

REM Handle case where PATH doesn't exist in registry
if not defined current_path set "current_path="

REM Check if winget path is already in the current PATH
echo %current_path% | find /i "%winget_path%" > nul
set "ff_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %ff_path_exists% neq 0 (
    if defined current_path (
        set "new_path=%current_path%;%winget_path%"
    ) else (
        set "new_path=%winget_path%"
    )
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "winget_path is:%cyan_fg_strong% %winget_path%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f > nul

    REM Update the PATH value for the current session
    set "PATH=!new_path!"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%winget added to PATH.%reset%
) else (
    echo %blue_fg_strong%[INFO] winget already exists in PATH.%reset%
)

REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Winget is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Winget...
    
    REM Download and install winget
    curl -L -o "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "https://github.com/microsoft/winget-cli/releases/download/v1.7.10661/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    
    if exist "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" (
        start "" /wait "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Winget installation completed. Please restart this script.%reset%
    ) else (
        echo %red_fg_strong%[ERROR] Failed to download winget installer.%reset%
    )
    pause
    exit /b
) else (
    echo %blue_fg_strong%[INFO] Winget is already installed.%reset%
)

REM Check if ffmpeg is installed; if not then install FFmpeg
ffmpeg -version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] FFmpeg is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing FFmpeg using Winget...
    
    REM Install FFmpeg using winget
    winget install --id=Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements
	
    
    REM Since winget doesn't update PATH for current session, we can't test immediately
    REM Just check if winget command completed without major errors
    
    echo [INFO]Please restart the script to verify the installation.
    pause
    exit /b
) else (
    echo %blue_fg_strong%[INFO] FFmpeg is already installed.%reset%
    ffmpeg -version 2>&1 | findstr "ffmpeg version"
)

echo.
echo %green_fg_strong%Script completed successfully.%reset%
pause