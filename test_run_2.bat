@echo off
chcp 65001 >nul
cd /d "%~dp0"
setlocal enabledelayedexpansion

:: CONFIGURATION
set "keyhunt=KeyHunt-Cuda.exe"
set "hashfile=puzzle71_hash160_sorted.bin"
set "log=log.txt"
set "resume=resume.txt"
set "chunksize=10000000000"
set "start=6000000000000000"
set "end=7FFFFFFFFFFFFFFF"

:: Load resume point or start fresh
if exist "%resume%" (
    set /p current=<"%resume%"
    echo 🔁 Resuming from !current!
) else (
    set "current=%start%"
    echo 🚀 Starting from beginning: !current!
)

:: Main scanning loop
:loop
call :hexcmp !current! %end%
if errorlevel 1 (
    echo ✅ All batches complete >> "%log%"
    echo ✅ All batches complete
    goto :eof
)

call :hexadd !current! %chunksize% next
echo ============================================================
echo [%date% %time%] 🔍 Scanning range !current!:!next!
echo ============================================================
echo [%date% %time%] 🔍 Scanning range !current!:!next! >> "%log%"

%keyhunt% -t 0 -g --gpui 0 --gpux 256,256 -m addresses --coin BTC -o Found.txt --range !current!:!next! -i "%hashfile%"

:: Save if wallet found
if exist Found.txt (
    echo --- 🎯 FOUND WALLET! --- >> "%log%"
    type Found.txt >> "%log%"

    :: Save permanent backup with timestamp
    echo [%date% %time%] 🎯 Wallet found in range !current!:!next! >> found_keys.txt
    type Found.txt >> found_keys.txt
    echo. >> found_keys.txt

    del Found.txt
)

:: Save resume point
echo Saving resume point: !next!
(echo !next!) > "%~dp0%resume%"
set "current=!next!"
goto loop

:: --- Hex Add Function ---
:hexadd
setlocal
set "a=%~1"
set "b=%~2"
set "a=%a:0x=%"
set "b=%b:0x=%"
for /f "usebackq delims=" %%X in (`powershell -noprofile -command "$a=[UInt64]::Parse('%a%', 'HexNumber'); $b=[UInt64]::Parse('%b%', 'HexNumber'); $c=$a+$b; '0x'+$c.ToString('X16')"` ) do (
    endlocal & set "%~3=%%X"
)
goto :eof

:: --- Hex Compare Function ---
:hexcmp
setlocal
set "a=%~1"
set "b=%~2"
set "a=%a:0x=%"
set "b=%b:0x=%"
powershell -noprofile -command "$a=[UInt64]::Parse('%a%', 'HexNumber'); $b=[UInt64]::Parse('%b%', 'HexNumber'); if ($a -ge $b) { exit 1 } else { exit 0 }"
exit /b %ERRORLEVEL%
