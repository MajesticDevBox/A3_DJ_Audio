param(
    [string]$SourceRoot = 'G:\1 ARMA3_DEVELOPMENT\Blinder Assets',
    [string]$WorkRoot = (Join-Path $PSScriptRoot '..\asset_work\source_copies')
)

$ErrorActionPreference = 'Stop'
$repo = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$work = [System.IO.Path]::GetFullPath($WorkRoot)
New-Item -ItemType Directory -Force -Path $work | Out-Null
$manifestPath = Join-Path $work 'source-manifest.json'

$sources = [ordered]@{
    ravespace_co = (Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'RAVESpace - Speakers\Textures') -File | Where-Object Name -Match 'BaseColor' | Select-Object -First 1).FullName
    ravespace_nohq = (Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'RAVESpace - Speakers\Textures') -File | Where-Object Name -Match 'Normal' | Select-Object -First 1).FullName
    horn_row_curved_3 = Join-Path $repo 'asset_work\production_sources\horn_row_curved_3_retained.blend'
    array_row_curved_4 = Join-Path $repo 'asset_work\legacy_ravespace_stacks\array_row_curved_4.blend'
    array_row_straight_4 = Join-Path $repo 'asset_work\legacy_ravespace_stacks\array_row_straight_4.blend'
    horn_row_straight_3 = Join-Path $repo 'asset_work\legacy_ravespace_stacks\horn_row_straight_3.blend'
    sub_row_3 = Join-Path $repo 'asset_work\legacy_ravespace_stacks\sub_row_3.blend'
    array_curved_stack = Join-Path $repo 'asset_work\legacy_ravespace_stacks\array_curved_stack.blend'
    dj_mixer_1 = Join-Path $SourceRoot 'DJ Mixer 1\dj_mixer_1.blend'
    dj_mixer_2 = Join-Path $SourceRoot 'DJ Mixer 2\dj_mixer_2.blend'
    audio_soundboard = Join-Path $SourceRoot 'Audio Equipment\audio_soundboard.blend'
    dj_keyboard = Join-Path $SourceRoot 'Audio Equipment\dj_keyboard.blend'
    dj_player_01_co = Join-Path $SourceRoot 'DJ Mixer 1\textures\DJ__01_Diffuse.png'
    dj_player_01_nohq = Join-Path $SourceRoot 'DJ Mixer 1\textures\DJ__01_Normal.png'
    dj_player_02_co = Join-Path $SourceRoot 'DJ Mixer 1\textures\DJ__02_Diffuse.png'
    dj_player_02_nohq = Join-Path $SourceRoot 'DJ Mixer 1\textures\DJ__02_Normal.png'
    dj_player_light_co = Join-Path $SourceRoot 'DJ Mixer 1\textures\DJ__04_Light_Diffuse.png'
    dj_player_light_nohq = Join-Path $SourceRoot 'DJ Mixer 1\textures\DJ__04_Light_Normal.png'
}

$destinations = [ordered]@{
    ravespace_co = 'ravespace_co.jpg'
    ravespace_nohq = 'ravespace_nohq.jpg'
    horn_row_curved_3 = 'horn_row_curved_3_retained.blend'
    array_row_curved_4 = 'array_row_curved_4.blend'
    array_row_straight_4 = 'array_row_straight_4.blend'
    horn_row_straight_3 = 'horn_row_straight_3.blend'
    sub_row_3 = 'sub_row_3.blend'
    array_curved_stack = 'array_curved_stack.blend'
    dj_mixer_1 = 'dj_mixer_1.blend'
    dj_mixer_2 = 'dj_mixer_2.blend'
    audio_soundboard = 'audio_soundboard.blend'
    dj_keyboard = 'dj_keyboard.blend'
    dj_player_01_co = 'dj_player_01_co.png'
    dj_player_01_nohq = 'dj_player_01_nohq.png'
    dj_player_02_co = 'dj_player_02_co.png'
    dj_player_02_nohq = 'dj_player_02_nohq.png'
    dj_player_light_co = 'dj_player_light_co.png'
    dj_player_light_nohq = 'dj_player_light_nohq.png'
}

$records = @()
foreach ($key in $sources.Keys) {
    $source = $sources[$key]
    if (-not $source -or -not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Required source is missing: $key ($source)"
    }
    $before = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $destination = Join-Path $work $destinations[$key]
    Copy-Item -LiteralPath $source -Destination $destination -Force
    $after = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    if ($before -ne $after) {
        throw "Original source changed while staging: $source"
    }
    $records += [ordered]@{
        key = $key
        original = $source
        workingCopy = $destination
        sha256 = $before
        bytes = (Get-Item -LiteralPath $source).Length
    }
}

$manifest = [ordered]@{
    generatedUtc = [DateTime]::UtcNow.ToString('o')
    sourceRoot = [System.IO.Path]::GetFullPath($SourceRoot)
    policy = 'Originals are read-only; all conversion occurs in ignored asset_work.'
    files = $records
}
$manifestPath = Join-Path $work 'source-manifest.json'
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding utf8
Write-Output "Staged $($records.Count) read-only source copies."
Write-Output $manifestPath
