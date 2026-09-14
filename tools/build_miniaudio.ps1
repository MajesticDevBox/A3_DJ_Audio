$ErrorActionPreference = 'Stop'
$edjRoot = Split-Path -Parent $PSScriptRoot
$edjCmake = Get-Command cmake -ErrorAction SilentlyContinue
if ($edjCmake) { $edjCmakePath = $edjCmake.Source } else {
    $edjVswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    $edjVs = & $edjVswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if (!$edjVs) { throw 'Install Visual Studio C++ Build Tools and CMake.' }
    $edjCmakePath = Join-Path $edjVs 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
}
$edjOutput = Join-Path $edjRoot '.hemttout\miniaudio-native'
& $edjCmakePath -S (Join-Path $edjRoot 'extensions\miniaudio') -B $edjOutput -A x64
if ($LASTEXITCODE) { throw 'Miniaudio configuration failed' }
& $edjCmakePath --build $edjOutput --config Release
if ($LASTEXITCODE) { throw 'Miniaudio build failed' }
$edjBin = Join-Path $edjRoot 'extensions\miniaudio\bin'
New-Item -ItemType Directory -Force -Path $edjBin | Out-Null
Copy-Item -LiteralPath (Join-Path $edjOutput 'Release\edj_miniaudio_x64.dll') -Destination $edjBin -Force
Write-Host 'Native runtime updated. HEMTT automatically packages this DLL.'
