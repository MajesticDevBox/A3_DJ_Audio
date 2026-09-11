param(
    [string]$SourceRoot = 'G:\1 ARMA3_DEVELOPMENT\Blinder Assets',
    [string]$Blender = 'C:\Program Files\Blender Foundation\Blender 5.2\blender.exe'
)

$ErrorActionPreference = 'Stop'
$repo = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$output = Join-Path $repo 'asset_work\validation\source-inventory.json'
New-Item -ItemType Directory -Force -Path (Split-Path $output) | Out-Null

$targets = [ordered]@{
    eventStage = Join-Path $SourceRoot 'Event Stage setup\Event+STAGE.blend'
    arenaStage = Join-Path $SourceRoot 'Arena Stage Venue Props Pack -  Modular Event Stage\Blender_5.0.1.blend'
    truss = Join-Path $SourceRoot 'truss system line array\truss+square+line+array.blend'
    lighting = (Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'Various projection sound and lighting devices') -File | Where-Object Extension -EQ '.fbx' | Select-Object -First 1).FullName
    raveSpace = Join-Path $SourceRoot 'RAVESpace - Speakers\RaveSpace_Audio_Systems.obj'
    musicMixtable = Join-Path $SourceRoot 'Music Mixtable\Mixtable.blend'
}

$records = [ordered]@{}
foreach ($entry in $targets.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
        $records[$entry.Key] = [ordered]@{ status = 'SOURCE NOT PRESENT'; source = $entry.Value }
        continue
    }
    $lines = & $Blender --background --factory-startup --python-exit-code 1 --python (Join-Path $PSScriptRoot 'inventory_asset_source.py') -- $entry.Value
    if ($LASTEXITCODE -ne 0) { throw "Inventory failed: $($entry.Key)" }
    $payload = $lines | Where-Object { $_ -like 'EDJ_ASSET_INVENTORY=*' } | Select-Object -Last 1
    if (-not $payload) { throw "Inventory output missing: $($entry.Key)" }
    $records[$entry.Key] = ($payload.Substring('EDJ_ASSET_INVENTORY='.Length) | ConvertFrom-Json)
}

$result = [ordered]@{
    generatedUtc = [DateTime]::UtcNow.ToString('o')
    sourceRoot = [System.IO.Path]::GetFullPath($SourceRoot)
    packs = $records
    djPlayer = [ordered]@{ status = 'DEFERRED - SOURCE NOT PRESENT'; path = (Join-Path $SourceRoot 'DJ player Free 3D model') }
    musicMixtableStatus = 'LICENSE_HOLD'
}
$result | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $output -Encoding utf8
Write-Output $output
