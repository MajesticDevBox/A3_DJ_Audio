# Development

Prerequisites: Windows, Arma 3 2.20+, Steam, CBA_A3, ACE3, Advanced Equipment,
Carpinchos Radio, HEMTT 1.21.0. Use Arma 3 Tools (Object Builder, Buldozer and
Binarize) for model work. Python 3 and Blender are only needed to regenerate assets.

Download the Windows HEMTT release from
https://github.com/BrettMayson/HEMTT/releases/tag/v1.21.0, extract it to a tools
directory and add that directory to PATH. Do not commit the executable.

```powershell
Set-Location 'G:\Github Repos\A3_DJ_Audio'
hemtt check
hemtt build
hemtt launch
hemtt release
```

Build output is `.hemttout/build`; dev output is `.hemttout/dev`; release archives
are under `releases`. Release packaging does not publish to Workshop. To install
one through Arma Launcher, extract the ZIP and select its `@edj` directory itself;
do not select the parent `releases` directory. CI checks
and builds with `--no-bin` on Linux: SQF and configs still compile/rapify; that is
not model binarization validation. Signing keys are ignored by Git.

`.hemtt/project.toml` defines dependency Workshop IDs. HEMTT resolves installed
Steam content and creates its `z/edj` file-patching link during launch. Paths vary
per installation; do not copy another machine's Steam paths. For local dependency
checkouts use HEMTT global launch pointers (documented in its launch help).

Close the development game before rebuilding: Arma may hold file-patched SQF
files open on Windows. Run `hemtt check` after each change; do not use direct PBO
packing as the normal workflow. The project is not linked to a remote repository.
No commit/push/branch switch is required to use this scaffold.

For dedicated multiplayer, copy the small `tests/EDJ_V01.VR` mission into your
server mpmissions, load the same built mod/dependencies, and follow TESTING.md.
Use a private/local test server and retain RPT logs from every participant.
