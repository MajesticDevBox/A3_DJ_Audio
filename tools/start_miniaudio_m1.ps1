param(
    [switch]$Interactive,
    [ValidateSet("None", "SingleArray", "DualArray", "DualVolume", "DualPause", "DualSeek", "DualCompletion", "DualDirection", "DualRange", "DualListener", "DualMoveListener", "DualMoveArrays", "DualCue", "DualDelete")][string]$ListeningTest = "None",
    [ValidateSet("EDJ_Miniaudio_M1.VR", "EDJ_Miniaudio_Arrays.VR")][string]$MissionName = "EDJ_Miniaudio_M1.VR",
    [string]$ArmaPath = 'D:\SteamLibrary\steamapps\common\Arma 3',
    [string]$WorkshopPath = 'D:\SteamLibrary\steamapps\workshop\content\107410'
)
$ErrorActionPreference = 'Stop'
$edjRoot = Split-Path -Parent $PSScriptRoot
$edjBuild = Join-Path $edjRoot '.hemttout\build'
$edjDll = Join-Path $edjBuild 'edj_miniaudio_x64.dll'
if (!(Test-Path -LiteralPath $edjDll)) { throw 'Run hemtt build; the runtime DLL must be packaged automatically.' }
# Arma's autotest config loader does not handle the repository's spaced path.
$edjRun = Join-Path $env:LOCALAPPDATA ('Temp\' + $MissionName.Replace('.VR', '').ToLower())
$edjProfile = Join-Path $edjRun 'profiles'
$edjMission = Join-Path $edjProfile ('autotest\' + $MissionName)
New-Item -ItemType Directory -Force -Path $edjMission | Out-Null
Get-ChildItem -LiteralPath (Join-Path $edjRoot ('tests\' + $MissionName)) -File | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $edjMission $_.Name) -Force
}
$edjAutotest = Join-Path $edjRun 'autotest.cfg'
$ListeningTest | Set-Content -LiteralPath (Join-Path $edjMission 'human_test.txt') -Encoding ascii
@"
class TestMissions {
 class EDJ {campaign=""; mission="$edjMission";};
};
"@ | Set-Content -LiteralPath $edjAutotest -Encoding ascii
$edjMods = @('450814997', '463939057', '2888888564', '3464681191') | ForEach-Object {
    $edjPath = Join-Path $WorkshopPath $_
    if (!(Test-Path -LiteralPath $edjPath)) { throw "Missing dependency: $edjPath" }
    $edjPath
}
$edjMods += $edjBuild
$edjArguments = '-noSplash -skipIntro -window -noPause "-profiles={0}" "-autoTest={1}" "-mod={2}"' -f $edjProfile, $edjAutotest, ($edjMods -join ';')
$edjWindow = if ($Interactive) { 'Normal' } else { 'Hidden' }
Start-Process -FilePath (Join-Path $ArmaPath 'arma3_x64.exe') -ArgumentList $edjArguments -WorkingDirectory $ArmaPath -WindowStyle $edjWindow -PassThru | Select-Object Id,ProcessName
Write-Host "RPT directory: $edjProfile"
