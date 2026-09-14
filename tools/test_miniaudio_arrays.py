"""Real Windows device/PBO integration; human listening is a separate gate."""
import ctypes
import pathlib
import time

root = pathlib.Path(__file__).resolve().parents[1]
dll = ctypes.WinDLL(str(root / 'extensions/miniaudio/bin/edj_miniaudio_x64.dll'))
api = dll.RVExtensionArgs
api.argtypes = [ctypes.c_char_p, ctypes.c_int, ctypes.c_char_p, ctypes.POINTER(ctypes.c_char_p), ctypes.c_int]

def call(op, *values):
    args = [(f'"{v}"').encode() for v in values]
    out = ctypes.create_string_buffer(8192)
    api(out, len(out), op.encode(), (ctypes.c_char_p * len(args))(*args), len(args))
    return out.value.decode()

def ok(name, condition):
    assert condition, name
    print('PASS', name, flush=True)

def peak():
    time.sleep(.15)
    return float(call('meter').split(':')[2])

try:
    ok('init', call('init') == '1')
    ok('index', call('register_search_root', root / '.hemttout/build/addons').startswith('1:'))
    track = r'\z\edj\addons\example_music_pack\audio\edj_test_tone_a.ogg'
    ok('play', call('play', 'main', track, 1, 3, 0, 0, 0, 100) == '1')
    serial = call('debug_source', 'main').split(':')[3]
    call('set_listener', 0, 0, -10, 0, 0, 1)
    front = '0,0,0,0,0,-1,100,90'
    ok('one_array', call('set_arrays', 'main', front) == '1')
    p1 = peak()
    ok('real_pcm', p1 > .001)
    ok('two_arrays', call('set_arrays', 'main', front + ',' + front) == '1')
    p2 = peak()
    print('array peaks', p1, p2, flush=True)
    ok('coincident_arrays_no_gain_buildup', .8 < p2 / p1 < 1.2)
    call('set_listener', 0, 0, 10, 0, 0, -1)
    back = peak()
    ok('rear_cone', back < p1 * .2)
    call('set_listener', 0, 0, -70, 0, 0, 1)
    far = peak()
    ok('distance_attenuation', far < p1 * .5)
    call('set_listener', 0, 0, -110, 0, 0, 1)
    time.sleep(.5) # allow the spatializer's gain smoothing to settle
    outside = peak(); print('outside', outside, flush=True)
    ok('outside_range', outside < .00001)
    call('set_listener', 0, 0, -10, 0, 0, 1)
    ok('pause', call('pause', 'main') == '1')
    time.sleep(.1)
    pos = call('position', 'main')
    time.sleep(.2)
    ok('paused_cursor', call('position', 'main') == pos)
    ok('seek', call('seek', 'main', 6) == '1')
    time.sleep(.1)
    ok('seek_position', abs(float(call('position', 'main')[2:]) - 6) < .01)
    ok('resume', call('resume', 'main') == '1')
    time.sleep(.2)
    ok('resume_position', 6.1 < float(call('position', 'main')[2:]) < 6.5)
    ok('one_primary_cursor', call('debug_source', 'main').split(':')[3] == serial)
    ok('invalid_array_limit', call('set_arrays', 'main', ','.join([front] * 9)).startswith('0:'))
    ok('invalid_array_data', call('set_arrays', 'main', 'nan,0,0,0,0,1,100,90').startswith('0:'))
    ok('stop', call('stop', 'main') == '1' and call('playback_status', 'main') == 'missing')
finally:
    call('shutdown')
