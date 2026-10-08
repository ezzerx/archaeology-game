"""Reproducible, non-destructive edits of the three approved test MP3 sources.

Requires ffmpeg on PATH and Python stdlib. Source MP3s are never overwritten.
No denoising or invented layers: trim, mono, gentle high-pass, fade, peak level.
"""
from pathlib import Path
import array, hashlib, json, math, subprocess, wave

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'art/source/p6a3/audio/raw'
OUT = ROOT / 'assets/p6a3/audio'
OUT.mkdir(parents=True, exist_ok=True)
RATE = 44100
report = {'sample_rate': RATE, 'format': 'mono PCM16', 'sources': {}, 'runtime': {}}

def decode(name):
    path = SOURCE / (name + '_test_v01.mp3')
    pcm = subprocess.check_output(['ffmpeg', '-hide_banner', '-loglevel', 'error',
        '-i', str(path), '-ac', '1', '-ar', str(RATE), '-af', 'highpass=f=75',
        '-f', 's16le', '-'])
    values = array.array('h', pcm)
    report['sources'][path.name] = {'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
        'decoded_seconds': len(values)/RATE}
    return [v/32768 for v in values]

def save(name, samples, edits, loop=False, peak_db=-5):
    # Short equal-power fades remove edit clicks. Brush loops crossfade separately.
    if not loop:
        attack, release = int(.0015*RATE), int(.035*RATE)
        for i in range(attack): samples[i] *= i/attack
        for i in range(release): samples[-i-1] *= i/release
    scale = 10**(peak_db/20)/max(max(abs(s) for s in samples), 1e-9)
    pcm = array.array('h', (round(max(-.999, min(.999, s*scale))*32767) for s in samples))
    path = OUT/(name+'.wav')
    with wave.open(str(path), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE); w.writeframes(pcm.tobytes())
    report['runtime'][path.name] = {'seconds': len(samples)/RATE, 'peak_dbfs': peak_db,
        'loop': loop, 'edits': edits, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}

brush = decode('brush_soil')
# The source contains three short sweeps, not a stable noise bed. Preserve the
# grain signature while stitching the useful region into a quiet contact texture.
bed = brush[int(.16*RATE):int(.77*RATE)]
cross = int(.055*RATE)
loop = bed[cross:]
for i in range(cross):
    t = i/cross
    loop[-cross+i] = bed[-cross+i]*(1-t) + bed[i]*t
save('brush_soil_loop', loop, '0.16–0.77 s; 55 ms wrap crossfade; -10 dBFS peak', True, -10)

clay = decode('chisel_clay')
stone = decode('chisel_sandstone')
# Distinct excerpts of the supplied performances; no stretch or extra impacts.
# Remove the pre-hit approach from Clay; omit the unwanted late (~1.5s) stone tap.
for name, source, windows in [
    ('chisel_clay', clay, [(.16,.43),(.175,.46),(.185,.49),(.15,.435)]),
    ('chisel_stone', stone, [(.00,.24),(.22,.49),(.37,.61),(.835,1.07)])]:
    for i,(start,end) in enumerate(windows):
        save(f'{name}_{i+1:02}', source[int(start*RATE):int(end*RATE)],
             f'{start:.3f}–{end:.3f} s; 1.5 ms attack / 35 ms release', peak_db=-6 if name.endswith('clay') else -7)

(OUT/'processing.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
print(json.dumps(report, indent=2))
