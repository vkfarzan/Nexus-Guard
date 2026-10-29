# Nexus Guard

Nexus Guard is a small Windows utility that pauses the Hello Nexus application while selected games are running, then starts it again after those games close.

## Features

- Monitor a list of game executables and restore Nexus when the last monitored game closes, if Nexus was running before it was paused.
- Add `.exe` files or Windows shortcuts that point directly to an executable. Shortcuts using a launcher URI, such as `steam://`, need the actual game executable instead.
- Select multiple games with Ctrl and remove them together after confirmation.
- Control Nexus manually, choose light or dark appearance, and use the system tray.
- Configure startup, tray behavior, and the monitoring interval; see the app's CPU use.
- Install per user or run the single-file portable build.

## Requirements

- Windows with .NET Framework 4.x and Windows PowerShell 5.1.
- Hello Nexus installed. Some installations may require appropriate Windows permissions to stop and start the Nexus service.

Nexus Guard finds the Nexus installation through Windows' installed-app information and otherwise checks the usual Program Files location. When pausing Nexus, it stops the Nexus service and processes launched from its installation directory. Apps that share those processes may be affected.

## Download and use

Download the [installer](Nexus%20Guard%20Setup.exe?raw=1), or the [portable executable](Nexus%20Guard.exe?raw=1). Launch the program, select **Add a game**, and choose a game's `.exe` or shortcut. Counter-Strike 2 is present by default; remove it if you do not need it.

The installer registers the app for removal in Windows Settings. Close Nexus Guard from the tray before uninstalling. Your configuration is preserved during uninstall.

The portable executable is a single file for distribution, but extracts its internal components and saves settings and the watch list under `%LOCALAPPDATA%\NexusGuard` for the current Windows user. The installer and portable versions use this same per-user data directory. The binaries are unsigned; Windows may show a publisher warning.

## Build from source

Open Windows PowerShell 5.1 on Windows and run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
```

The script uses the .NET Framework C# compiler installed with Windows and produces `dist/Nexus Guard.exe` and `dist/Nexus Guard Setup.exe`. It also runs each executable's built-in package self-test. The self-tests check that embedded resources are present; they do not replace end-to-end testing with Nexus and games.

## Privacy

Nexus Guard stores its watch list and settings locally. It does not include analytics or send the list to a server.

## License

MIT; see [LICENSE](LICENSE). Nexus Guard is an independent project and is not affiliated with Hello Nexus or Valve.


