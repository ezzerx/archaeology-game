"""Original, deterministic atelier Foley. Python stdlib + ffmpeg for streamed room Ogg.

No source recording, model/service, paid generation or borrowed sample.
Regenerate: python tools/audio/build_atelier_audio.py
Writes runtime assets, a signal-quality manifest and a local 24-second audition.
"""
from pathlib import Path
import array
import hashlib
import json
import math
import random
import shutil
import subprocess
import wave

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/audio/atelier"
WORK = ROOT / "work/audio"
RATE = 44100
TAU = math.tau
FILES = {}
RAW = {}


def noise_band(rng, length, low_alpha=.18, high_alpha=.012):
    low = high = 0.
    result = []
    for _ in range(length):
        n = rng.uniform(-1., 1.)
        low += low_alpha * (n - low)
        high += high_alpha * (n - high)
        result.append(low - high)
    return result


def grain(values, at, duration, amplitude, frequency, rng, noise=.3):
    start = round(at * RATE)
    count = round(duration * RATE)
    phase = rng.uniform(-math.pi, math.pi)
    for j in range(count):
        i = start + j
        if i >= len(values):
            break
        t = j / RATE
        envelope = min(1., t/.0007) * math.exp(-t / (duration*.18))
        envelope *= min(1., (count-j-1) / max(1, .004*RATE))
        values[i] += amplitude * envelope * (
            (1-noise) * math.sin(TAU*frequency*t + phase)
            + noise * rng.uniform(-1., 1.))


def prepare(values, peak_db, loop=False):
    # Remove numerical DC before the endpoint treatment, retain natural dynamics.
    mean = sum(values)/len(values)
    values = [v-mean for v in values]
    if loop:
        # Periodic crossfade: end of original overlaps its start, then join at
        # adjacent source samples. Unlike independent fades, there is no gap.
        cross = int(.16*RATE)
        original = values
        values = original[cross:]
        for i in range(cross):
            mix = .5 - .5*math.cos(math.pi*i/(cross-1))
            values[-cross+i] = original[-cross+i]*(1-mix) + original[i]*mix
    else:
        attack, release = int(.0012*RATE), int(.022*RATE)
        for i in range(attack):
            values[i] *= (.5-.5*math.cos(math.pi*i/(attack-1)))
        for i in range(release):
            values[-i-1] *= (.5-.5*math.cos(math.pi*i/(release-1)))
    scale = 10**(peak_db/20) / max(max(map(abs, values)), 1e-12)
    return [v*scale for v in values]


def write_wave(path, values):
    pcm = array.array("h", (round(max(-.999, min(.999, v))*32767) for v in values))
    with wave.open(str(path), "wb") as stream:
        stream.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        stream.writeframes(pcm.tobytes())
    return pcm


def save(name, values, peak_db=-6., loop=False):
    values = prepare(values, peak_db, loop)
    path = OUT / (name+".wav")
    pcm = write_wave(path, values)
    rms = math.sqrt(sum(v*v for v in values)/len(values))
    RAW[name] = values
    FILES[path.name] = {
        "frames": len(values), "seconds": round(len(values)/RATE, 4),
        "peak_dbfs": round(20*math.log10(max(map(abs, values))), 3),
        "rms_dbfs": round(20*math.log10(rms), 3),
        "dc": round(sum(values)/len(values), 8), "loop": loop,
        "endpoint_step": abs(pcm[-1]-pcm[0])/32767,
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
    }


def brush(kind, variant=0):
    rng = random.Random(91703+variant+31*kind)
    count = round(5.16*RATE)
    band = noise_band(rng, count, .22 if kind else .11, .014 if kind else .007)
    fine = noise_band(rng, count, .62, .15)
    values = []
    for i in range(count):
        t = i/RATE
        # Asynchronous bristles/granular friction, no mechanical regular stroke.
        texture = .69 + .13*math.sin(TAU*1.13*t) + .10*math.sin(TAU*2.79*t+.7)
        texture += .05*math.sin(TAU*8.61*t)
        values.append((band[i] + fine[i]*(.25 if kind else .13))*texture)
    for _ in range(145 if kind else 78):
        grain(values, rng.uniform(0,5.16), rng.uniform(.006,.018),
              rng.uniform(.012,.047), rng.uniform(650,2200), rng, .86)
    return values


def strike(family, variant):
    rng = random.Random(52609 + variant*19 + (100 if family == "chisel_stone" else 0))
    stone = family == "chisel_stone"
    duration = .34 if stone else .31
    count = round(duration*RATE)
    band = noise_band(rng, count, .32, .018)
    scale = rng.uniform(.92,1.09)
    values = []
    modes = [(178,.24,38), (337,.18,53), (793,.12,62)] if not stone else [
        (286,.20,42),(1067,.14,44),(1763,.11,59),(2933,.05,88)]
    for i in range(count):
        t = i/RATE
        body = sum(a*math.sin(TAU*f*scale*t)*math.exp(-t*d) for f,a,d in modes)
        crush = band[i]*(.85 if stone else 1.05)*math.exp(-t*33)
        edge = rng.uniform(-1,1)*.20*math.exp(-t*210)
        values.append(body+crush+edge)
    # Tiny irregular chips settle behind the strike; never an extra full hit.
    for _ in range(10 if stone else 7):
        grain(values, rng.uniform(.018,.18), rng.uniform(.006,.027),
              rng.uniform(.018,.065), rng.uniform(550,3100), rng, .72)
    return values


def pick(variant):
    rng = random.Random(72911+variant*23)
    count = round(.14*RATE)
    band = noise_band(rng, count, .29, .035)
    values = []
    f = rng.uniform(1700,2400)
    for i in range(count):
        t = i/RATE
        values.append(.18*math.sin(TAU*f*t)*math.exp(-t*155)
                      + .43*band[i]*math.exp(-t*64)
                      + .11*math.sin(TAU*f*.713*t)*math.exp(-t*95))
    for _ in range(3):
        grain(values,rng.uniform(.012,.06),.012,rng.uniform(.008,.028),
              rng.uniform(1400,2900),rng,.85)
    return values


def air():
    rng = random.Random(960007)
    count = round(6.16*RATE)
    body = noise_band(rng,count,.13,.006)
    silk = noise_band(rng,count,.48,.09)
    values = []
    for i in range(count):
        t=i/RATE
        breath=.86+.06*math.sin(TAU*.73*t)+.05*math.sin(TAU*1.81*t+.4)
        values.append((body[i]+.19*silk[i])*breath)
    return values


def abrasive():
    rng = random.Random(60117)
    count = round(4.16*RATE)
    body = noise_band(rng,count,.38,.048)
    values=[]
    for i in range(count):
        t=i/RATE
        # Hand-worked fine stone, no power-drill whine.
        grit=.73+.14*math.sin(TAU*7.31*t)+.09*math.sin(TAU*13.73*t)
        values.append(body[i]*grit)
    for _ in range(120):
        grain(values,rng.uniform(0,4.16),rng.uniform(.004,.014),
              rng.uniform(.016,.045),rng.uniform(1900,3800),rng,.86)
    return values


def room():
    rng=random.Random(271836)
    count=round(24.16*RATE)
    body=noise_band(rng,count,.009,.0006)
    breeze=noise_band(rng,count,.028,.004)
    values=[]
    for i in range(count):
        t=i/RATE
        # Soft room air / distant ventilation, with slow non-tonal movement.
        values.append(body[i]*(.75+.16*math.sin(TAU*.071*t))
                      +breeze[i]*(.15+.07*math.sin(TAU*.113*t+.8)))
    # Quiet, infrequent wood settling; subordinate to the close tool work.
    for start in [4.12,13.68,19.45]:
        for j in range(6):
            grain(values,start+j*.035,.08,.0025,110+j*19,rng,.55)
    return values


def audition():
    length=24
    values=[0.]*(length*RATE)
    def add(name,start,duration=None,gain=1.,release=.13,attack=.04):
        source=RAW[name]
        count=round((duration or len(source)/RATE)*RATE)
        for i in range(count):
            target=round(start*RATE)+i
            if target>=len(values):break
            env=min(1.,i/(attack*RATE), (count-i-1)/(release*RATE))
            values[target]+=source[i%len(source)]*gain*max(0,env)
    add("room_source",0,24,.13,1.,1.)
    add("brush_soil_loop",1,3,.60)
    add("brush_clay_loop",4.5,2.5,.54)
    for i in range(6):
        add("chisel_clay_%02d"%(i%6+1),8+i/4.5,gain=.8,attack=.0012,release=.022)
        add("chisel_stone_%02d"%(i%6+1),10+i/4.5,gain=.8,attack=.0012,release=.022)
    for i in range(10):
        add("precision_pick_%02d"%(i%6+1),12+i/6,gain=.42,attack=.0012,release=.022)
    add("abrasive_tip_loop",14.5,2.5,.32)
    add("air_loop",18,3.5,.65,.24,.10)
    # Equivalent baseline -15 dB event gain; a preview is not loudness-normalized.
    values=[v*10**(-15/20) for v in values]
    write_wave(WORK/"atelier-audition.wav",values)
    (WORK/"atelier-audition.txt").write_text(
        "Original atelier audio audition, 24 s, nominal -15 dB event gain.\n"
        "0-1 room / 1-4 soft soil brush / 4.5-7 harder dry brush\n"
        "8-9.5 clay / 10-11.5 sandstone / 12-13.8 precision pick\n"
        "14.5-17 abrasive tip / 18-21.5 air / 21.5-24 quiet room\n"
        "This is an offline sound-design audition, not a gameplay capture.\n",encoding="utf-8")


def main():
    OUT.mkdir(parents=True,exist_ok=True)
    WORK.mkdir(parents=True,exist_ok=True)
    save("brush_soil_loop",brush(0),-8,True)
    save("brush_clay_loop",brush(1),-9,True)
    save("air_loop",air(),-8,True)
    save("abrasive_tip_loop",abrasive(),-10,True)
    for family in ["chisel_clay","chisel_stone"]:
        for variant in range(6):
            save("%s_%02d"%(family,variant+1),strike(family,variant),-6)
    for variant in range(6):
        save("precision_pick_%02d"%(variant+1),pick(variant),-9)
    # Room is streamed Vorbis at runtime; the PCM master is kept only in work.
    original=prepare(room(),-15,True)
    RAW["room_source"]=original
    source=WORK/"room_source.wav"
    write_wave(source,original)
    ffmpeg=shutil.which("ffmpeg")
    if not ffmpeg:
        raise RuntimeError("ffmpeg required to encode the streamed room ambience")
    path=OUT/"workshop_room.ogg"
    subprocess.run([ffmpeg,"-y","-hide_banner","-loglevel","error","-i",str(source),
                    "-c:a","libvorbis","-q:a","4","-fflags","+bitexact",
                    "-flags:a","+bitexact",str(path)],check=True)
    FILES[path.name]={"seconds":24,"codec":"Vorbis mono, q4, streamed",
                     "source_peak_dbfs":-15,
                     "sha256":hashlib.sha256(path.read_bytes()).hexdigest()}
    manifest={"authorship":"Original deterministic synthesis, no external samples.",
              "generator":"tools/audio/build_atelier_audio.py","sample_rate":RATE,
              "wav_format":"mono PCM16 masters; Godot imports short impacts as IMA ADPCM",
              "files":FILES}
    (OUT/"manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
    audition()
    total=sum(p.stat().st_size for p in OUT.glob("*") if p.is_file())
    print("Generated %d assets, %.2f MiB. Audition: work/audio/atelier-audition.wav"%
          (len(FILES),total/1048576))


if __name__=="__main__":
    main()
