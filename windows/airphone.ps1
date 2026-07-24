#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$ConfigFile = Join-Path $PSScriptRoot "config.conf"

# Global variables
$script:AdbPath = $null
$script:ScrcpyPath = $null
$script:PHONE_IP = $null
$script:PHONE_PORT = $null

# GPT codes
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

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

# GPT codes
function Show-InputBox {

    param(
        [string]$Title,
        [string]$Message,
        [string]$Default = ""
    )

    return [Microsoft.VisualBasic.Interaction]::InputBox(
        $Message,
        $Title,
        $Default
    )

}

function Show-Message {

    param(
        [string]$Text,
        [string]$Title = "AirPhone"
    )

    [System.Windows.Forms.MessageBox]::Show(
        $Text,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null

}

function Test-Connection {
    & $AdbPath disconnect "$PHONE_IP`:$PHONE_PORT" | Out-Null
    & $AdbPath connect "$PHONE_IP`:$PHONE_PORT" | Out-Null
    
    $devices = & $AdbPath devices
    return ($devices | Select-String "$PHONE_IP`:$PHONE_PORT\s+device")
}

# edit GPT codes
function Ask-For-Connection {

    Show-Message @"
Could not connect using the saved IP address.

You can find the correct values on your phone:

Settings
→ Developer options
→ Wireless debugging
→ IP address & Port
"@

    $script:PHONE_IP = Show-InputBox `
        "AirPhone" `
        "Enter Phone IP" `
        $PHONE_IP

    if ([string]::IsNullOrWhiteSpace($PHONE_IP)) {
        exit
    }

    $script:PHONE_PORT = Show-InputBox `
        "AirPhone" `
        "Enter Phone Port" `
        $PHONE_PORT

    if ([string]::IsNullOrWhiteSpace($PHONE_PORT)) {
        exit
    }

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
        Show-Message @"
Could not connect to your phone.

Please check:

• Phone and PC are connected to the same Wi-Fi.

• Wireless debugging is enabled.

• The IP address and port are correct.
"@

exit 1
    }
}

Start-AirPhone