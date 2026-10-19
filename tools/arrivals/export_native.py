"""Export the arrivals V1 to official Godot 4.7.2 Windows templates."""
import re
import argparse,hashlib,json,shutil,struct,subprocess,tempfile,zipfile
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('--godot',required=True);p.add_argument('--templates',required=True)
p.add_argument('--output',required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[2]
godot=Path(a.godot).resolve();templates=Path(a.templates).resolve();output=Path(a.output).resolve()
assert subprocess.check_output([str(godot),'--version'],text=True).startswith('4.7.2.stable')
assert (templates/'version.txt').read_text().strip()=='4.7.2.stable'
stage=Path(tempfile.mkdtemp(prefix='issue27-native-',dir=root/'work'))
for folder in ['scripts','scenes','config','shaders','materials','assets']:
    shutil.copytree(root/folder,stage/folder,ignore=shutil.ignore_patterns('source') if folder=='assets' else None)
project=re.sub(r'^run/main_scene="[^"\r\n]*"', 'run/main_scene="res://scenes/arrivals/receiving_room.tscn"', (root/'project.godot').read_text(encoding='utf-8'), flags=re.M).replace('renderer/rendering_method="gl_compatibility"','renderer/rendering_method="forward_plus"')
(stage/'project.godot').write_text(project,encoding='utf-8')
# Reuse immutable import artifacts, then let the editor verify the stage.
cache=stage/'.godot';cache.mkdir()
shutil.copytree(root/'.godot/imported',cache/'imported')
for name in ['uid_cache.bin','global_script_class_cache.cfg']:
    if (root/'.godot'/name).exists():shutil.copy2(root/'.godot'/name,cache/name)
(stage/'export_presets.cfg').write_text(f'''[preset.0]
name="Windows Arrivals V1"
platform="Windows Desktop"
runnable=true
export_filter="all_resources"
include_filter="*.gdshaderinc"
exclude_filter="assets/p6a32/b17_binding_probe.glb"
script_export_mode=2
[preset.0.options]
custom_template/release="{(templates/'windows_release_x86_64.exe').as_posix()}"
debug/export_console_wrapper=0
binary_format/embed_pck=false
binary_format/architecture="x86_64"
texture_format/s3tc_bptc=true
texture_format/etc2_astc=false
codesign/enable=false
application/modify_resources=false
''')
output.mkdir(parents=True,exist_ok=True)
def run(args,log):
    with (output/log).open('w') as f:subprocess.run(args,stdout=f,stderr=subprocess.STDOUT,check=True)
run([str(godot),'--headless','--path',str(stage),'--editor','--import','--quit'],'import.log')
run([str(godot),'--headless','--path',str(stage),'--export-release','Windows Arrivals V1',str(output/'ArchaeologyGame.exe')],'export.log')
run([str(godot),'--headless','--path',str(root),'--script','tools/p6a3/export_notices.gd','--',str(output)],'notices.log')
notice=output/'LICENCES.txt'
notice.write_text(notice.read_text().replace('ArchaeologyGame P6A3 — Windows playtest','ArchaeologyGame — Arrivals V1')+'\nArrivals props: Tripo Studio exports supplied by Antoine, originals and provenance in assets/arrivals/source. Runtime fitting/reduction in Blender 4.3.2; visual references generated with Imagegen. Museum assets reused with their existing provenance. Original runtime audio retained; Claude reserved for the future sound pass.\n')
shutil.copy2(root/'docs/dev/ISSUE27_PLAYTEST_README.txt',output/'LISEZ-MOI.txt')
exe=(output/'ArchaeologyGame.exe').read_bytes();assert exe[:2]==b'MZ'
pe=struct.unpack_from('<I',exe,0x3c)[0];assert exe[pe:pe+4]==b'PE\0\0' and struct.unpack_from('<H',exe,pe+4)[0]==0x8664
archive=output.parent/'ArchaeologyGame-Arrivals-V1-Windows.zip'
names=['ArchaeologyGame.exe','ArchaeologyGame.pck','LISEZ-MOI.txt','LICENCES.txt']
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for name in names:z.write(output/name,name)
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
report={'filename':archive.name,'size':archive.stat().st_size,'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'game_runtime_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'engine':subprocess.check_output([str(godot),'--version'],text=True).strip(),'windows_execution_verified':False,'stage':str(stage)}
(output/'build.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
