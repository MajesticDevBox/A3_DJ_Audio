param(
    [string]$ArmaPath = 'D:\SteamLibrary\steamapps\common\Arma 3',
    [string]$WorkshopPath = 'D:\SteamLibrary\steamapps\workshop\content\107410'
)
$ErrorActionPreference = 'Stop'
$edjRoot = Split-Path -Parent $PSScriptRoot
$edjBuild = Join-Path $edjRoot '.hemttout\build'
if (!(Test-Path -LiteralPath $edjBuild)) { throw 'Run hemtt build first' }
$edjRun = Join-Path $env:LOCALAPPDATA 'Temp\edj-runtime-smoke'
$edjProfile = Join-Path $edjRun 'profiles'
$edjMission = Join-Path $edjProfile 'autotest\EDJ_Smoke.VR'
New-Item -ItemType Directory -Force -Path $edjMission | Out-Null
Get-ChildItem -LiteralPath (Join-Path $edjRoot 'tests\EDJ_Smoke.VR') -File | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $edjMission $_.Name) -Force
}
$edjAutotest = Join-Path $edjRun 'autotest.cfg'
$edjMissionConfigPath = $edjMission.Replace('\', '\')
@"
class TestMissions {
 class EDJ {
  campaign="";
  mission="$edjMissionConfigPath";
 };
};
"@ | Set-Content -LiteralPath $edjAutotest -Encoding ascii
$edjMods = @('450814997', '463939057', '2888888564', '3464681191') | ForEach-Object {
    $edjModPath = Join-Path $WorkshopPath $_
    if (!(Test-Path -LiteralPath $edjModPath)) { throw "Missing dependency: $edjModPath" }
    $edjModPath
}
$edjMods += $edjBuild
$edjArguments = '-noSplash -skipIntro -window -noPause "-profiles={0}" "-autoTest={1}" "-mod={2}"' -f $edjProfile, $edjAutotest, ($edjMods -join ';')
Start-Process -FilePath (Join-Path $ArmaPath 'arma3_x64.exe') -ArgumentList $edjArguments -WorkingDirectory $ArmaPath -WindowStyle Hidden -PassThru | Select-Object Id, ProcessName
Write-Host "RPT directory: $edjProfile"
