# Stage asset workflow

V0.2.5 established the production workflow in [ASSET_PIPELINE.md](ASSET_PIPELINE.md),
the source and license decisions in [ASSET_MANIFEST.md](ASSET_MANIFEST.md), and the
human gates in [V0.2.5_VALIDATION.md](V0.2.5_VALIDATION.md).

The `EDJ_assets` PBO currently contains six reviewed RaveSpace speaker assemblies
and four reviewed DJ/audio-equipment props defined by
`tools/asset_ingestion_plan.py`. Source coverage and exclusions are reconciled in
`ASSET_COVERAGE.md`; the exact public classes and source files are listed in
`ASSET_MANIFEST.md`.

The older original speaker blockout remains under `assets/speaker/` as project-owned
source art and is not packed. Marketplace working copies and editable conversion
scenes live only under ignored `asset_work/`. Run `tools/build_assets.ps1` to stage
read-only copies, convert textures, export MLODs, and re-import each result before
HEMTT binarization.

Stage, truss, and lighting conversions from the earlier expanded catalog are no
longer packed. Their original source records remain inventoried and deferred until
the current speaker and DJ-equipment set has been reviewed in game and the next
stage selection is made.

Physical speaker models remain separate from Event DJ audio emitters. Placing a
speaker prop never starts or duplicates a stream. Future V0.3 linking may use the
inert `audio_origin` Memory points added to the production speaker models.
