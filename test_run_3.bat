@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Configuration
set "keyhunt=KeyHunt-Cuda.exe"
set "hashfile=puzzle71_hash160_sorted.bin"
set "log=log.txt"
set "chunksize=0010000000000000"
set "start=4000000000000000"
set "count=256"

:: Begin scanning loop
for /L %%i in (0,1,%count%) do (
    call :hexadd %start% %%i start_hex
    call :hexadd %start% %%i+1 end_hex

    echo ============================================================
    echo [!date! !time!] ?? Scanning range !start_hex!:!end_hex!
    echo ============================================================

    %keyhunt% -t 0 -g --gpui 0 --gpux 256,256 -m addresses --coin BTC -o Found.txt --range !start_hex!:!end_hex! -i %hashfile%

    if exist Found.txt (
        echo ?? --- FOUND! --- >> %log%
        type Found.txt >> %log%
        del Found.txt
    )

    echo Finished range !start_hex!:!end_hex! >> %log%
    echo. >> %log%
    timeout /t 2 >nul
)

echo ? All %count% chunks scanned!
pause
goto :eof

:: Hex addition function using PowerShell
:hexadd
:: Args: %1 = base hex start, %2 = multiplier, %3 = output variable
setlocal
set "start=%1"
set "offset=%2"

:: Use PowerShell to compute: start + offset * chunksize
for /f %%H in ('powershell -NoProfile -Command "('{0:X016}' -f ([convert]::ToInt64('0x%start%',16) + (%offset% * 0x%chunksize%)))"') do (
    endlocal & set "%3=0x%%H"
)
goto :eof
