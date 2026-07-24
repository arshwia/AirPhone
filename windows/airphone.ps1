#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$ConfigFile = Join-Path $PSScriptRoot "config.conf"

# Global variables
$script:AdbPath = $null
$script:ScrcpyPath = $null
$script:PHONE_IP = $null
$script:PHONE_PORT = $null

# ====================== Functions ======================

function Find-Executable {
    param([string]$Name)
    
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $found = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter $Name -ErrorAction SilentlyContinue |
             Select-Object -First 1
    if ($found) { return $found.FullName }

    return $null
}

function Install-Dependencies {
    Write-Host "`nInstalling dependencies..." -ForegroundColor Cyan
    
    winget install Genymobile.scrcpy --source winget --accept-source-agreements --accept-package-agreements --silent
    winget install Google.PlatformTools --source winget --accept-source-agreements --accept-package-agreements --silent

    $script:AdbPath = Find-Executable "adb.exe"
    $script:ScrcpyPath = Find-Executable "scrcpy.exe"
}

function Test-Dependencies {
    $script:AdbPath = Find-Executable "adb.exe"
    $script:ScrcpyPath = Find-Executable "scrcpy.exe"

    if (-not $AdbPath -or -not $ScrcpyPath) {
        Install-Dependencies
    }

    if (-not $AdbPath -or -not $ScrcpyPath) {
        Write-Host "`nFailed to install dependencies!" -ForegroundColor Red
        Pause
        exit 1
    }
}

function Load-Config {
    if (-not (Test-Path $ConfigFile)) {
        @"
PHONE_IP="192.168.1.100"
PHONE_PORT="5555"
"@ | Set-Content $ConfigFile -Encoding UTF8
    }

    foreach ($line in Get-Content $ConfigFile) {
        if ($line -match '^PHONE_IP="(.+)"$') { $script:PHONE_IP = $Matches[1] }
        if ($line -match '^PHONE_PORT="(.+)"$') { $script:PHONE_PORT = $Matches[1] }
    }
}

function Save-Config {
    @"
PHONE_IP="$PHONE_IP"
PHONE_PORT="$PHONE_PORT"
"@ | Set-Content $ConfigFile -Encoding UTF8
}

function Test-Connection {
    & $AdbPath disconnect "$PHONE_IP`:$PHONE_PORT" | Out-Null
    & $AdbPath connect "$PHONE_IP`:$PHONE_PORT" | Out-Null
    
    $devices = & $AdbPath devices
    return ($devices | Select-String "$PHONE_IP`:$PHONE_PORT\s+device")
}

function Ask-For-Connection {
    Write-Host "`nCould not connect to your phone." -ForegroundColor Yellow
    Write-Host "Please enter the current IP and Port from your phone:" -ForegroundColor Cyan
    Write-Host "(Settings → Developer options → Wireless debugging → IP address & Port)" -ForegroundColor Gray
    
    $script:PHONE_IP   = Read-Host "Phone IP"
    $script:PHONE_PORT = Read-Host "Phone Port"
    
    Save-Config
}

function Start-AirPhone {
    Write-Host "`nLaunching scrcpy..." -ForegroundColor Green
    & $ScrcpyPath -e --turn-screen-off --stay-awake
}

# ====================== Main ======================

Write-Host "🚀 Starting AirPhone..." -ForegroundColor Cyan

Test-Dependencies
Load-Config

# Try to connect
if (-not (Test-Connection)) {
    Ask-For-Connection
    
    if (-not (Test-Connection)) {
        Write-Host "`nStill could not connect. Please check:" -ForegroundColor Red
        Write-Host "- Phone and PC are on the same Wi-Fi" -ForegroundColor Gray
        Write-Host "- Wireless debugging is enabled" -ForegroundColor Gray
        Pause
        exit 1
    }
}

Start-AirPhone