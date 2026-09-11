"""Canonical production assets for the reviewed speaker and DJ equipment catalog."""

from __future__ import annotations


def asset(cls, display, source, objects, category, material="speaker_rave", **extra):
    return {
        "class": cls,
        "display": display,
        "file": cls.removeprefix("EDJ_").lower(),
        "source": source,
        "objects": objects if isinstance(objects, list) else [objects],
        "category": category,
        "material": material,
        **extra,
    }


ASSETS = [
    asset(
        "EDJ_Speaker_HornArray_Curved_03", "Curved Horn Array 3 Cabinet 01",
        "horn_row_curved_3_retained.blend", "Resolution_1",
        "EDJ_AudioSpeakers", bake_world=True, expected=(1.6474, .6606, .9),
        mass=114, memory="audio_origin", lod_ratios=(1.0, .72, .38, .16),
        geometry_components=[
            {"dimensions": (.5489, .5588, .9), "location": (-.4998, .0061, 0), "rotate_z": -.2094395102},
            {"dimensions": (.5489, .5588, .9), "location": (.0001, -.0571, 0)},
            {"dimensions": (.5489, .5588, .9), "location": (.4998, .0061, 0), "rotate_z": .2094395102},
        ],
    ),
    asset(
        "EDJ_Speaker_LineArray_Curved_04", "Curved Line Array 4 Cabinet 01",
        "array_row_curved_4.blend", [f"array_curved_4_{i:02d}" for i in range(1, 5)],
        "EDJ_AudioLineArrays", bake_world=True, expected=(.8, .6448, .9631),
        mass=136, memory="audio_origin", lod_ratios=(1.0, .72, .38, .16),
        geometry_components=[
            {"dimensions": (.8, .5, .24913), "center": (0, -.081797, .840651)},
            {"dimensions": (.8, .529807, .316292), "center": (0, -.066407, .628315)},
            {"dimensions": (.8, .5493, .377298), "center": (0, -.02005, .41876)},
            {"dimensions": (.8, .558103, .43096), "center": (0, .052746, .21548)},
        ],
    ),
    asset(
        "EDJ_Speaker_LineArray_Straight_04", "Straight Line Array 4 Cabinet 01",
        "array_row_straight_4.blend", [f"array_straight_4_{i:02d}" for i in range(1, 5)],
        "EDJ_AudioLineArrays", bake_world=True, expected=(.8, .5, 1.0145),
        mass=136, memory="audio_origin", lod_ratios=(1.0, .72, .38, .16),
        geometry_components=[
            {"dimensions": (.8, .5, .249131), "center": (0, 0, .889956)},
            {"dimensions": (.8, .5, .24913), "center": (0, 0, .634825)},
            {"dimensions": (.8, .5, .24913), "center": (0, 0, .379695)},
            {"dimensions": (.8, .5, .24913), "center": (0, 0, .124565)},
        ],
    ),
    asset(
        "EDJ_Speaker_HornArray_Straight_03", "Straight Horn Array 3 Cabinet 01",
        "horn_row_straight_3.blend", [f"horn_row_3_{i:02d}" for i in range(1, 4)],
        "EDJ_AudioSpeakers", bake_world=True, expected=(1.6537, .5653, .9),
        mass=114, memory="audio_origin", lod_ratios=(1.0, .72, .38, .16),
        geometry_components=[
            {"dimensions": (.548924, .558787, .9), "center": (-.552385, .003248, .45)},
            {"dimensions": (.548924, .558786, .9), "center": (.000901, -.003248, .45)},
            {"dimensions": (.548924, .558787, .9), "center": (.552385, .003248, .45)},
        ],
    ),
    asset(
        "EDJ_Speaker_SubwooferArray_Straight_03", "Straight Subwoofer Array 3 Cabinet 01",
        "sub_row_3.blend", [f"sub_row_3_{i:02d}" for i in range(1, 4)],
        "EDJ_AudioSubwoofers", bake_world=True, expected=(1.8155, .8, 1.0),
        mass=186, memory="audio_origin", lod_ratios=(1.0, .72, .38, .16),
        geometry_components=[
            {"dimensions": (.6, .8, 1.0), "center": (-.607732, 0, .5)},
            {"dimensions": (.6, .8, 1.0), "center": (0, 0, .5)},
            {"dimensions": (.6, .8, 1.0), "center": (.607732, 0, .5)},
        ],
    ),
    asset(
        "EDJ_Speaker_LineArray_CurvedStack_08", "Curved Line Array 8 Cabinet Stack 01",
        "array_curved_stack.blend",
        [*[f"array_curved_4_{i:02d}" for i in range(1, 5)], *[f"array_straight_4_{i:02d}" for i in range(1, 5)]],
        "EDJ_AudioLineArrays", bake_world=True, expected=(.8, .6532, 1.9946),
        mass=272, memory="audio_origin", lod_ratios=(1.0, .72, .38, .16),
        geometry_components=[
            {"dimensions": (.8, .501722, .252604), "center": (0, -.08532, .855696)},
            {"dimensions": (.8, .531026, .319489), "center": (0, -.065669, .637814)},
            {"dimensions": (.8, .549994, .380157), "center": (0, -.01566, .423098)},
            {"dimensions": (.8, .558259, .433423), "center": (0, .057052, .216712)},
            {"dimensions": (.8, .5, .24913), "center": (0, -.084453, 1.872172)},
            {"dimensions": (.8, .5, .24913), "center": (0, -.084453, 1.617042)},
            {"dimensions": (.8, .5, .24913), "center": (0, -.084453, 1.361912)},
            {"dimensions": (.8, .5, .24913), "center": (0, -.084453, 1.106782)},
        ],
    ),
    asset(
        "EDJ_DJ_MediaPlayer_01", "DJ Media Player 01",
        "dj_mixer_1.blend", [
            "Disc_01", "Disc_02",
            "Light_01", "Light_02", "Light_03", "Light_04", "Light_05",
            "pane_A_01", "pane_A_02", "pane_A_03",
            "pane_B_01", "pane_B_01_vector", "pane_B_02", "pane_B_03",
        ],
        "EDJ_DJPlayers", material="equipment", bake_world=True, scale=1.85,
        expected=(.3251, .3878, .1364), mass=6, memory="control_origin",
        lod_ratios=(1.0, .55, .25, .10), material_mode="dj_player_textures",
        force_smooth=None,
    ),
    asset(
        "EDJ_DJ_Controller_01", "Dual-Deck DJ Controller 01",
        "dj_mixer_2.blend", "*ALL_MESHES*",
        "EDJ_DJMixers", material="equipment", bake_world=True, scale=.07645,
        expected=(.7501, .4013, .1213), mass=9, memory="control_origin",
        lod_ratios=(1.0, .55, .25, .10), material_mode="palette",
        palette_overrides={
            "Material.001": "black",
            "Material.009": "charcoal",
            "Material.011": "black",
            "DB ANZEIGE": "charcoal",
            "GLAS BILDSCHIRM": "charcoal",
            "UNTER DEM GLAS": "blue",
            "GRAU TASTE": "darkgray",
            "SCHRAUBEN": "darkgray",
        },
        force_smooth=None,
    ),
    asset(
        "EDJ_Audio_MixingConsole_01", "Digital Audio Mixing Console 01",
        "audio_soundboard.blend", "meter_base.002",
        "EDJ_AudioConsoles", material="equipment", bake_world=True, scale=.23883,
        expected=(1.1000, .9019, .2350), mass=22, memory="control_origin",
        lod_ratios=(1.0, .50, .22, .08), material_mode="palette",
        force_smooth=None,
    ),
    asset(
        "EDJ_DJ_PerformanceKeyboard_01", "DJ Performance Keyboard 01",
        "dj_keyboard.blend", ["Text.003", "Text.001", "Plane.115"],
        "EDJ_DJControllers", material="equipment", bake_world=True, scale=.1373,
        expected=(1.3778, .5293, .1555), mass=17, memory="control_origin",
        lod_ratios=(1.0, .62, .28, .10), material_mode="palette",
        force_smooth=None,
    ),
]

for current_asset in ASSETS:
    if current_asset["class"] == "EDJ_DJ_MediaPlayer_01":
        current_asset["manual_acceptance"] = (
            "Scale and runtime behavior confirmed on 2026-09-11; corrected display-screen crop requires in-game reconfirmation."
        )
    else:
        current_asset["manual_acceptance"] = (
            "User confirmed correct scale and runtime behavior on 2026-09-11."
        )


SOURCE_PACKS = {
    "raveSpace": "RaveSpace PA Free Audio Systems Speaker Set",
    "truss": "Truss system line array",
    "eventStage": "Event Stage setup",
    "arenaStage": "Arena Stage Venue Props Pack",
    "lighting": "Various projection, sound and lighting devices",
    "musicMixtable": "Music Mixtable",
    "djMixer1": "DJ Mixer 1 source",
    "djMixer2": "DJ Mixer 2 source",
    "audioEquipment": "Audio Equipment source",
}

SOURCE_FILE_TO_PACK = {
    "horn_row_curved_3_retained.blend": "raveSpace",
    "array_row_curved_4.blend": "raveSpace",
    "array_row_straight_4.blend": "raveSpace",
    "horn_row_straight_3.blend": "raveSpace",
    "sub_row_3.blend": "raveSpace",
    "array_curved_stack.blend": "raveSpace",
    "dj_mixer_1.blend": "djMixer1",
    "dj_mixer_2.blend": "djMixer2",
    "audio_soundboard.blend": "audioEquipment",
    "dj_keyboard.blend": "audioEquipment",
}
