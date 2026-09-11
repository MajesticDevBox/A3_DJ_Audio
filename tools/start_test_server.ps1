param(
    [string]$ArmaPath = 'D:\SteamLibrary\steamapps\common\Arma 3',
    [string]$WorkshopPath = 'D:\SteamLibrary\steamapps\workshop\content\107410'
)
$ErrorActionPreference = 'Stop'
$edjRoot = Split-Path -Parent $PSScriptRoot
$edjOutput = Join-Path $edjRoot '.hemttout\runtime-server'
$edjMission = Join-Path $ArmaPath 'mpmissions\EDJ_V01.VR'
New-Item -ItemType Directory -Force -Path $edjMission | Out-Null
Get-ChildItem -LiteralPath (Join-Path $edjRoot 'tests\EDJ_V01.VR') -File | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $edjMission $_.Name) -Force
}
$edjMods = @('450814997', '463939057', '2888888564', '3464681191') | ForEach-Object {
    $edjModPath = Join-Path $WorkshopPath $_
    if (!(Test-Path -LiteralPath $edjModPath)) { throw "Missing dependency: $edjModPath" }
    $edjModPath
}
$edjMods += Join-Path $edjRoot '.hemttout\build'
if (!(Test-Path -LiteralPath $edjMods[-1])) { throw 'Run hemtt build first' }
New-Item -ItemType Directory -Force $edjOutput | Out-Null
$edjArguments = @(
    '-ip=127.0.0.1', '-port=2392', '-autoInit', '-noSound',
    ('-config="{0}"' -f (Join-Path $edjRoot 'tests\server.cfg')),
    ('-profiles="{0}"' -f $edjOutput),
    ('-mod="{0}"' -f ($edjMods -join ';'))
)
$edjArgumentLine = ($edjArguments -join ' ')
Start-Process -FilePath (Join-Path $ArmaPath 'arma3server_x64.exe') -ArgumentList $edjArgumentLine -WorkingDirectory $ArmaPath -WindowStyle Hidden -PassThru | Select-Object Id, ProcessName
