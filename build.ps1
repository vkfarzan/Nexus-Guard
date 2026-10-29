# Run from Windows PowerShell 5.1 on 64-bit Windows.
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSEdition -ne 'Desktop') { throw 'Run this script with Windows PowerShell 5.1 (powershell.exe), not PowerShell 7.' }
$root = $PSScriptRoot
$out = Join-Path $root 'dist'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $compiler)) { throw '.NET Framework C# compiler was not found.' }
$automation = [System.Management.Automation.PSObject].Assembly.Location
$icon = Join-Path $root 'Nexus-Guard.ico'
$script = Join-Path $root 'Nexus-Watcher.ps1'
$portable = Join-Path $out 'Nexus Guard.exe'
$setup = Join-Path $out 'Nexus Guard Setup.exe'
$tokens = $null; $errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($script, [ref]$tokens, [ref]$errors) | Out-Null
if ($errors.Count) { throw ($errors | Out-String) }
& $compiler /nologo /target:winexe /platform:anycpu "/out:$portable" "/win32icon:$icon" "/reference:$automation" /reference:System.Windows.Forms.dll /reference:System.Security.dll "/resource:$script,NexusGuard.script" "/resource:$icon,NexusGuard.icon" (Join-Path $root 'PortableHost.cs')
if ($LASTEXITCODE -ne 0) { throw 'Portable build failed.' }
& $compiler /nologo /target:winexe /platform:anycpu "/out:$setup" "/win32icon:$icon" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:Microsoft.CSharp.dll "/resource:$portable,NexusGuard.portable" (Join-Path $root 'Installer.cs')
if ($LASTEXITCODE -ne 0) { throw 'Installer build failed.' }
foreach ($file in @($portable, $setup)) { $test = Start-Process -FilePath $file -ArgumentList '--self-test' -Wait -PassThru; if ($test.ExitCode -ne 0) { throw "Self-test failed: $file" } }
Write-Host "Built and checked: $portable"
Write-Host "Built and checked: $setup"

