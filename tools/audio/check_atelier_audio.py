"""Verify original PCM masters and the Vorbis decode, not compressed bytes as PCM."""
from pathlib import Path
import array, json, math, shutil, subprocess, wave
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"assets/audio/atelier"
report=[]
failures=[]
for path in sorted(OUT.glob("*.wav")):
    with wave.open(str(path),"rb") as w:
        assert w.getnchannels()==1 and w.getsampwidth()==2 and w.getframerate()==44100
        data=array.array("h",w.readframes(w.getnframes()))
    peak=max(map(abs,data))/32767
    dc=abs(sum(data)/len(data))/32767
    rms=math.sqrt(sum(v*v for v in data)/len(data))/32767
    loop="_loop" in path.stem
    seam=abs(data[-1]-data[0])/32767
    near_steps=[abs(data[i]-data[i-1])/32767 for i in range(1,len(data))]
    near_steps.sort()
    p999=near_steps[int(len(near_steps)*.999)]
    checks={"headroom":peak<.52,"non_silent":rms>.008,"dc":dc<.001,
            "seam" if loop else "zero_endpoints":seam<=p999*1.2 if loop else data[0]==data[-1]==0}
    if not loop:
        # Short imperceptible soft onset; no leading delay before a strike.
        first_active=next((i for i,v in enumerate(data) if abs(v)>100),len(data))/44100
        checks["prompt_attack"]=first_active<.004
        checks["short_tail"]=len(data)/44100<.4
    for check,ok in checks.items():
        if not ok:failures.append(path.name+": "+check)
    report.append({"file":path.name,"peak_dbfs":20*math.log10(peak),
                   "rms_dbfs":20*math.log10(rms),"dc":dc,"seam":seam,"checks":checks})
# Check that the actual imported-room source decodes non-silent and unclipped.
raw=subprocess.check_output([shutil.which("ffmpeg"),"-hide_banner","-loglevel","error",
                             "-i",str(OUT/"workshop_room.ogg"),"-f","s16le","-"])
room=array.array("h",raw)
assert max(map(abs,room))<9000 and len(room)>44100*20
summary={"files":report,"room_peak_dbfs":20*math.log10(max(map(abs,room))/32767),
         "failures":failures}
(ROOT/"work/audio").mkdir(parents=True,exist_ok=True)
(ROOT/"work/audio/signal-checks.json").write_text(json.dumps(summary,indent=2)+"\n")
print("AUDIO SIGNAL: %d PCM masters + Vorbis room, %d failures"%(len(report),len(failures)))
for failure in failures:print("FAIL:",failure)
raise SystemExit(bool(failures))
