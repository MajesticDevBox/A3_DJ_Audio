param(
    [ValidateSet('A','B','C')][string]$Role,
    [string]$Server = '127.0.0.1',
    [int]$Port = 2392,
    [string]$ArmaPath = 'D:\SteamLibrary\steamapps\common\Arma 3',
    [string]$WorkshopPath = 'D:\SteamLibrary\steamapps\workshop\content\107410'
)
$ErrorActionPreference = 'Stop'
$edjRoot = Split-Path -Parent $PSScriptRoot
$edjBuild = Join-Path $edjRoot '.hemttout\build'
if (!(Test-Path -LiteralPath $edjBuild)) { throw 'Run hemtt build first' }
$edjProfile = Join-Path $edjRoot ('.hemttout\runtime-client-{0}' -f $Role)
New-Item -ItemType Directory -Force -Path $edjProfile | Out-Null
$edjMods = @('450814997', '463939057', '2888888564', '3464681191') | ForEach-Object {
    $edjModPath = Join-Path $WorkshopPath $_
    if (!(Test-Path -LiteralPath $edjModPath)) { throw "Missing dependency: $edjModPath" }
    $edjModPath
}
$edjMods += $edjBuild
$edjArguments = '-noSplash -skipIntro -window -noPause "-profiles={0}" -name=EDJ_Client{1} -connect={2} -port={3} "-mod={4}"' -f $edjProfile, $Role, $Server, $Port, ($edjMods -join ';')
Start-Process -FilePath (Join-Path $ArmaPath 'arma3_x64.exe') -ArgumentList $edjArguments -WorkingDirectory $ArmaPath -PassThru | Select-Object Id, ProcessName
Write-Host "Client $Role RPT directory: $edjProfile"
