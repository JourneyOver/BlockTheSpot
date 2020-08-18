# Ignore errors from `Stop-Process`
$PSDefaultParameterValues['Stop-Process:ErrorAction'] = 'SilentlyContinue'

# Setup script
$SpotifyDirectory = "$env:APPDATA\Spotify"
$SpotifyUpdateDirectory = "$env:LOCALAPPDATA\Spotify\Update"
$SpotifyExecutable = "$SpotifyDirectory\Spotify.exe"
$spotifyInstalled = (Test-Path -LiteralPath $SpotifyExecutable)

# Stop Spotify
Write-Host `n'Stopping Spotify...'`n -ForegroundColor Yellow
Stop-Process -Name Spotify
Stop-Process -Name SpotifyWebHelper

# Check if Microsoft Store version is installed
if (Get-AppxPackage -Name SpotifyAB.SpotifyMusic) {
  Write-Host 'The Microsoft Store version of Spotify has been detected which is not supported.'`n -ForegroundColor Red
  # Ask user if they want to uninstall Microsoft Store version
  $ch = Read-Host -Prompt "Uninstall Spotify Windows Store edition? (y/N) "
  if ($ch -eq 'y') {
    Write-Host 'Uninstalling Spotify...'`n
    Get-AppxPackage -Name SpotifyAB.SpotifyMusic | Remove-AppxPackage
  } else {
    Write-Host 'Exiting...'`n
    exit
  }
}

# Check if Win32 version is installed
if (-not $spotifyInstalled) {
  Write-Host 'Spotify installation was not detected.'`n -ForegroundColor Red
  # Ask user if they want to install Win32 version
  $ch = Read-Host -Prompt "Install Spotify? (y/N) "
  if ($ch -eq 'y') {
    Write-Host 'Downloading Spotify Installer...'`n
    try {
      $webClient.DownloadFile(
        # Remote file URL
        'http://upgrade.spotify.com/upgrade/client/win32-x86/spotify_installer-1.1.4.197.g92d52c4f-13.exe',
        # Local file path
        "$PWD\SpotifyFullSetup.exe"
      )
    } catch {
      Write-Output $_
      exit
    }
    mkdir $SpotifyDirectory >$null 2>&1
    Write-Host 'Installing Spotify...'`n
    Start-Process -FilePath "$PWD\SpotifyFullSetup.exe"
    while ($null -eq (Get-Process -name Spotify -ErrorAction SilentlyContinue)) {
      #waiting until installation complete
    }
    Write-Host 'Stopping Spotify...'`n
    Stop-Process -Name Spotify >$null 2>&1
    Stop-Process -Name SpotifyWebHelper >$null 2>&1
    Stop-Process -Name SpotifyFullSetup >$null 2>&1

  } else {
    Write-Host 'Exiting...'`n
    exit
  }
}

# Uninstall patch if user wants
if ($rm) {
  $ch = Read-Host -Prompt "Remove BlockTheSpot? (y/N)"
  if ($ch -eq 'y') {
    Write-Host `n'Removing patch...'`n
    Remove-Item -LiteralPath $SpotifyDirectory\netutils.dll >$null 2>&1
    Move-Item $SpotifyDirectory\netutils.dll.bak $SpotifyDirectory\netutils.dll >$null 2>&1
    Write-Host 'Patch removed'`n -ForegroundColor Green
    Write-Host 'Starting Spotify...'`n
    Start-Process -WorkingDirectory $SpotifyDirectory -FilePath $SpotifyExecutable
    Write-Host 'Done.'`n
  }
  $rm = $false
  Write-Host 'Exiting...'`n
  exit
}

# Setup environment
Push-Location -LiteralPath $env:TEMP
try {
  # Unique directory name based on time
  New-Item -Type Directory -Name "BlockTheSpot-$(Get-Date -UFormat '%Y-%m-%d_%H-%M-%S')" `
  | Convert-Path `
  | Set-Location
} catch {
  Write-Output $_
  exit
}

# Download patch files
Write-Host 'Downloading latest patch...'`n
$webClient = New-Object -TypeName System.Net.WebClient
try {
  $webClient.DownloadFile(
    # Remote file URL
    'https://github.com/JourneyOver/BlockTheSpot/releases/latest/download/netutils.dll',
    # Local file path
    "$PWD\netutils.dll"
  )
} catch {
  Write-Output $_
  Start-Sleep
}

# Create a backup of original file
if (!(test-path $SpotifyDirectory/netutils.dll.bak)) {
  Move-Item $SpotifyDirectory\netutils.dll $SpotifyDirectory\netutils.dll.bak >$null 2>&1
}

# Start patch
Write-Host 'Patching Spotify...'`n
$patchFiles = "$PWD\netutils.dll"
Copy-Item -LiteralPath $patchFiles -Destination "$SpotifyDirectory"

# Disabling auto-update
Write-Host 'Disabling Auto-Updates...'`n
if ((test-path $SpotifyUpdateDirectory)) {
  cmd /c icacls "$SpotifyUpdateDirectory" /reset /T >$null 2>&1
  Remove-Item "$SpotifyUpdateDirectory" -Force >$null 2>&1
  mkdir "$SpotifyUpdateDirectory" >$null 2>&1
  cmd /c icacls "$SpotifyUpdateDirectory" /deny %username%:W >$null 2>&1
}
if ((test-path "$SpotifyDirectory\SpotifyMigrator.exe")) {
  Remove-Item -LiteralPath "$SpotifyDirectory\SpotifyMigrator.exe" >$null 2>&1
  Remove-Item -LiteralPath "$SpotifyDirectory\SpotifyStartupTask.exe" >$null 2>&1
}

# Clean up
$tempDirectory = $PWD
Pop-Location
Remove-Item -Recurse -LiteralPath $tempDirectory
Write-Host 'Patching Complete!'`n -ForegroundColor Green

# Launch Spotify
Write-Host 'Starting Spotify...'`n
Start-Process -WorkingDirectory $SpotifyDirectory -FilePath $SpotifyExecutable

# Exit
Write-Host 'Done.'`n
Write-Host 'Exiting...'`n
exit
