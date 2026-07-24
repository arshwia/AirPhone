# AirPhone Silent Installer

$AppName      = "AirPhone"
$InstallDir   = "$env:LOCALAPPDATA\AirPhone"
$StartMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"

Write-Host "Installing $AppName (Fully Hidden)..." -ForegroundColor Cyan

New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null

Copy-Item -Path "$PSScriptRoot\airphone.ps1" -Destination "$InstallDir\airphone.ps1" -Force
Copy-Item -Path "$PSScriptRoot\config.conf"   -Destination "$InstallDir\config.conf"   -Force

# Create VBS wrapper to run completely hidden
$VBSPath = "$InstallDir\run.vbs"
@"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""$InstallDir\airphone.ps1""", 0, False
"@ | Set-Content $VBSPath -Encoding ASCII

# Create Start Menu shortcut to VBS
$ShortcutPath = "$StartMenuDir\$AppName.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = "`"$VBSPath`""
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.IconLocation = "powershell.exe,0"
$Shortcut.Description = "AirPhone"
$Shortcut.Save()

Write-Host "`n✅ Installation completed!" -ForegroundColor Green
Write-Host "Search 'AirPhone' in Start Menu." -ForegroundColor Green
Write-Host "No console window will appear." -ForegroundColor Gray

Pause