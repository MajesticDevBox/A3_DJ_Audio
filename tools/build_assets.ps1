param(
    [string]$Blender = 'C:\Program Files\Blender Foundation\Blender 5.2\blender.exe',
    [string]$Pal2PacE = 'C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\TexView2\Pal2PacE.exe'
)

$ErrorActionPreference = 'Stop'
$repo = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$data = Join-Path $repo 'addons\assets\data'
$models = Join-Path $repo 'addons\assets\models'
New-Item -ItemType Directory -Force -Path $data | Out-Null
New-Item -ItemType Directory -Force -Path $models | Out-Null
Get-ChildItem -LiteralPath $models -Filter '*.p3d' -File -ErrorAction SilentlyContinue | Remove-Item -Force
$expectedBlendFiles = @(
    'speaker_hornarray_curved_03.blend',
    'speaker_linearray_curved_04.blend',
    'speaker_linearray_straight_04.blend',
    'speaker_hornarray_straight_03.blend',
    'speaker_subwooferarray_straight_03.blend',
    'speaker_linearray_curvedstack_08.blend',
    'dj_mediaplayer_01.blend',
    'dj_controller_01.blend',
    'audio_mixingconsole_01.blend',
    'dj_performancekeyboard_01.blend'
)
$generatedBlendRoot = Join-Path $repo 'asset_work\blender'
Get-ChildItem -LiteralPath $generatedBlendRoot -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin $expectedBlendFiles } |
    Remove-Item -Force

& (Join-Path $PSScriptRoot 'stage_asset_sources.ps1')
if (-not $?) { throw 'Source staging failed.' }

& $Pal2PacE '-size=2048' (Join-Path $repo 'asset_work\source_copies\ravespace_co.jpg') (Join-Path $data 'speaker_co.paa')
if ($LASTEXITCODE -ne 0) { throw 'RaveSpace base-color conversion failed.' }
& $Pal2PacE '-size=2048' (Join-Path $repo 'asset_work\source_copies\ravespace_nohq.jpg') (Join-Path $data 'speaker_nohq.paa')
if ($LASTEXITCODE -ne 0) { throw 'RaveSpace normal-map conversion failed.' }

python (Join-Path $PSScriptRoot 'create_asset_textures.py')
if ($LASTEXITCODE -ne 0) { throw 'Equipment texture generation failed.' }
& $Pal2PacE (Join-Path $repo 'asset_work\textures\equipment_co.tga') (Join-Path $data 'equipment_co.paa')
if ($LASTEXITCODE -ne 0) { throw 'Equipment texture conversion failed.' }
& $Pal2PacE (Join-Path $repo 'asset_work\textures\equipment_nohq.tga') (Join-Path $data 'equipment_nohq.paa')
if ($LASTEXITCODE -ne 0) { throw 'Equipment normal conversion failed.' }
python (Join-Path $PSScriptRoot 'generate_palette_textures.py')
if ($LASTEXITCODE -ne 0) { throw 'Equipment palette generation failed.' }

foreach ($name in @('dj_player_01','dj_player_02','dj_player_light')) {
    & $Pal2PacE '-size=2048' (Join-Path $repo "asset_work\source_copies\${name}_co.png") (Join-Path $data "${name}_co.paa")
    if ($LASTEXITCODE -ne 0) { throw "$name base-color conversion failed." }
    & $Pal2PacE '-size=2048' (Join-Path $repo "asset_work\source_copies\${name}_nohq.png") (Join-Path $data "${name}_nohq.paa")
    if ($LASTEXITCODE -ne 0) { throw "$name normal conversion failed." }
}

& $Blender --background --python-exit-code 1 --python (Join-Path $PSScriptRoot 'build_asset_models.py')
if ($LASTEXITCODE -ne 0) { throw 'MLOD generation failed.' }

& $Blender --background --python-exit-code 1 --python (Join-Path $PSScriptRoot 'validate_asset_models.py')
if ($LASTEXITCODE -ne 0) { throw 'MLOD validation failed.' }

Write-Output 'Event DJ asset sources, textures, and MLODs built successfully.'
