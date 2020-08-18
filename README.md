<center>
    <h1 align="center">BlockTheSpot</h1>
    <h4 align="center">A multi-purpose adblocker and skip bypass for the <strong>Windows</strong> Spotify Desktop Application.</h4>
    <h5 align="center">Please support Spotify by purchasing premium</h5>
    <p align="center">
        <strong>Last updated:</strong> 17 August 2020<br>
        <strong>Last tested version:</strong> 1.1.39.612.g1e7e78a4
    </p>
</center>

### Features:
- Blocks all banner/video/audio ads within the app
- Retains friend, vertical video and radio functionality
- Unlocks the skip function for any track

:warning: This mod is for the [**Desktop Application**](https://www.spotify.com/download/windows/) of Spotify on Windows, **not the Microsoft Store version**.

#### Installation/Update:
- Just run BlockTheSpot.ps1
  or
1. Browse to Spotify installation folder `%APPDATA%\Spotify`
2. Download chrome_elf.zip from [releases](https://github.com/mrpond/BlockTheSpot/releases)
3. Replace chrome_elf.dll, config.ini from chrome_elf.zip to that folder.

#### Uninstall:
<!--- Just run UninstallBlockTheSpot.ps1
  or -->
1. Browse to Spotify installation folder `%APPDATA%/Spotify`
2. Simply delete chrome_elf.dll, config.ini from your Spotify installation
3. Rename your backup dll to chrome_elf.dll

#### Note:
- "chrome_elf.dll" gets replaced by Spotify Installer each time it updates, make sure to replace it again.
- Ads banner maybe appear if you network use 'Web Proxy Auto-Discovery Protocol'
  <https://en.wikipedia.org/wiki/Web_Proxy_Auto-Discovery_Protocol>
  set Skip_wpad in config.ini to 1 may help.
