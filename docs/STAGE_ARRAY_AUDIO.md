# Stage Speaker Array audio

Main PA remains the only logical stage controller, with one track, revision and
server timeline. Miniaudio decodes that track once into one ma_sound. A downstream
array node spatializes the same PCM frames for every array. PLAY, STOP, PAUSE,
RESUME and SEEK therefore control all arrays together; arrays have no separate
cursors, starts or stage states. Cue uses a separate DJ-local source.

Synchronize a Main PA to one workstation module and up to eight nonempty Stage
Speaker Array modules. Synchronize each array to its speaker cabinets. An array's
position is the centroid of its living cabinets; its facing is the array module's
direction. Move the cabinets to move its centroid and rotate the module to change
facing. There is one spatial emitter per array, regardless of cabinet count.

Miniaudio prefers arrays when both arrays and a physical prop are synchronized.
If no usable arrays remain, the physical prop is the fallback. If no physical prop
was configured, the first cabinet is the legacy-provider fallback. Native and
Carpinchos retain single-object playback; they do not gain independent array
emitters. Deleting the last usable source stops output. Deleting Main PA stops
its stage. Changing geometry does not publish stage revisions.

Spatial updates run locally at 20 Hz. Arma [east,north,up] becomes miniaudio
[east,up,-north], consistently for source and listener vectors. Each array uses
a linear distance law: full gain through 1 metre, falling to zero at the stage
range. The configured cone is the inner angle; the outer angle is 1.5 times that
angle, capped at 360 degrees, with 10% rear gain. Spatial gain smoothing prevents
abrupt steps; allow approximately half a second for silence to settle after a
teleport beyond range.

Each of N arrays receives 1/N of the stage gain. This prevents coincident arrays
from multiplying volume but makes an isolated hang quieter as more arrays are
added. Stereo tracks are downmixed to mono before spatialization. No per-array
propagation delay, resampling, Doppler or HRTF filtering is introduced, avoiding
timeline drift and synthetic inter-array comb filtering. Antiphase stereo content
can cancel when downmixed; use mono-compatible music for PA playback.

Limits: eight arrays per stage, sixteen active primary/cue sources per client,
256 MiB active encoded audio and 128 MiB cached encoded audio (cache eviction does
not affect active sounds). PCM scratch memory is fixed and the array callback
does not allocate memory. PBO loading/decoder initialization remains synchronous;
the broader asynchronous-loading milestone is still outstanding.

## Packaging

`tools/build_miniaudio.ps1` builds the Windows runtime into the portable
`extensions/miniaudio/bin` artifact directory using a static MSVC runtime. The
HEMTT post-build hook automatically copies it to the mod root for build and
release. Both release ZIPs contain `@edj/edj_miniaudio_x64.dll`; install the whole
`@edj` directory. No consumer DLL-copy step or developer-local path is required.
Native source changes require rebuilding the bundled DLL before HEMTT packaging.
The hook fails if the runtime artifact is missing.

## First human test

Run only this test and report PASS, FAIL, BLOCKED or SKIP:

```powershell
powershell -ExecutionPolicy Bypass -File "G:\Github Repos\A3_DJ_Audio\tools\start_miniaudio_m1.ps1" -MissionName EDJ_Miniaudio_Arrays.VR -ListeningTest SingleArray -Interactive
```

The scenario opens AE3, claims the workstation and plays through one nearby
four-cabinet array. The fallback prop is over 500 metres away, outside range.
Expect a continuous tone for approximately eight seconds, followed by silence
when STOP appears. The scenario then exits. Later tests will be presented
individually; this test does not establish multiplayer acceptance.
