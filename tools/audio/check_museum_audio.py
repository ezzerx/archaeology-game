"""Checks the actual decoded runtime Vorbis files and the offline nominal mix."""
from pathlib import Path
import array,json,math,shutil,subprocess
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"assets/audio/museum"
WORK=ROOT/"work/audio/museum"
FFMPEG=shutil.which("ffmpeg")
failures=[]
results=[]
for name,channels,seconds in [("museum_contemplation.ogg",2,84),("museum_room.ogg",1,48)]:
    raw=subprocess.check_output([FFMPEG,"-v","error","-i",str(OUT/name),
        "-ar","44100","-f","f32le","-"])
    data=array.array("f",raw)
    frames=len(data)//channels
    peak=max(map(abs,data))
    rms=math.sqrt(sum(v*v for v in data)/len(data))
    dc=max(abs(sum(data[ch::channels])/frames) for ch in range(channels))
    seam=max(abs(data[ch]-data[-channels+ch]) for ch in range(channels))
    # A loop boundary should be no more abrupt than normal local sample steps.
    steps=[abs(data[i]-data[i-channels]) for i in range(channels,len(data),37)]
    steps.sort()
    p999=steps[int(len(steps)*.999)]
    checks={"duration":abs(frames/44100-seconds)<.03,"headroom":peak<.70,
        "audible":rms>.015,"dc":dc<.001,"seam":seam<max(.002,p999*1.4)}
    for label,ok in checks.items():
        if not ok:failures.append(name+": "+label)
    results.append({"file":name,"seconds":frames/44100,"peak_dbfs":20*math.log10(peak),
        "rms_dbfs":20*math.log10(rms),"dc":dc,"seam":seam,"checks":checks})
preview=array.array("f",subprocess.check_output([FFMPEG,"-v","error","-i",
    str(WORK/"museum-audition.mp3"),"-f","f32le","-"]))
preview_peak=max(map(abs,preview))
if preview_peak>.30:failures.append("nominal preview exceeds conservative headroom")
result={"streams":results,"preview_peak_dbfs":20*math.log10(preview_peak),"failures":failures}
(WORK/"signal-checks.json").write_text(json.dumps(result,indent=2)+"\n")
print("MUSEUM SIGNAL:",json.dumps(result))
raise SystemExit(bool(failures))
