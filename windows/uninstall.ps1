# AirPhone Uninstaller

$AppName      = "AirPhone"
$InstallDir   = "$env:LOCALAPPDATA\AirPhone"
$StartMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$ShortcutPath = "$StartMenuDir\$AppName.lnk"

Write-Host "Uninstalling $AppName..." -ForegroundColor Cyan

# Remove shortcut
if (Test-Path $ShortcutPath) {
    Remove-Item $ShortcutPath -Force
    Write-Host "✓ Removed Start Menu shortcut" -ForegroundColor Green
}

# Remove installation folder
if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
    Write-Host "✓ Removed program files" -ForegroundColor Green
}

# Optional: Remove config from roaming (if any)
$ConfigPath = "$env:APPDATA\AirPhone"
if (Test-Path $ConfigPath) {
    Remove-Item $ConfigPath -Recurse -Force
}

Write-Host "`n✅ $AppName has been uninstalled successfully." -ForegroundColor Green
Write-Host "You can delete the original folder if you want." -ForegroundColor Gray

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")