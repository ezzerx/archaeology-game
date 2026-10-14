"""Reproducible Godot 4.7.2 Web playtest; staging never edits project.godot.
Usage: python3 tools/p6a31/export_web.py --godot BIN --templates DIR --output DIR
"""
import re
import argparse, shutil, subprocess
from pathlib import Path

parser=argparse.ArgumentParser()
parser.add_argument('--godot',required=True)
parser.add_argument('--templates',required=True)
parser.add_argument('--output',required=True)
args=parser.parse_args()
root=Path(__file__).resolve().parents[2]
godot=Path(args.godot).resolve()
templates=Path(args.templates).resolve()
output=Path(args.output).resolve()
if not subprocess.check_output([str(godot),'--version'],text=True).startswith('4.7.2.stable'):
    raise SystemExit('Godot 4.7.2 stable required.')
if (templates/'version.txt').read_text().strip()!='4.7.2.stable':
    raise SystemExit('Matching official export templates required.')
stage=root/'work/p6a31-web-stage'
if stage.exists(): shutil.rmtree(stage)
stage.mkdir(parents=True)
for folder in ['scripts','scenes','config','shaders','materials','assets']:
    shutil.copytree(root/folder,stage/folder)
project=re.sub(r'^run/main_scene="[^"\r\n]*"', 'run/main_scene="res://scenes/p6a31_mastery_readability.tscn"', (root/'project.godot').read_text(encoding='utf-8'), flags=re.M).replace('config/name="ArchaeologyGame — P4"','config/name="ArchaeologyGame Playtest"')
(stage/'project.godot').write_text(project,encoding='utf-8')
(stage/'export_presets.cfg').write_text(f'''[preset.0]
name="Web Playtest"
platform="Web"
runnable=true
export_filter="all_resources"
include_filter="*.gdshaderinc"
exclude_filter=""
script_export_mode=2
[preset.0.options]
custom_template/release="{(templates/'web_nothreads_release.zip').as_posix()}"
variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false
''')
output.mkdir(parents=True,exist_ok=True)
subprocess.run([str(godot),'--headless','--editor','--path',str(stage),'--quit'],check=True)
subprocess.run([str(godot),'--headless','--path',str(stage),'--export-release','Web Playtest',str(output/'index.html')],check=True)
subprocess.run(['python3',str(root/'tools/p6a31/package_web.py'),str(output)],check=True)

subprocess.run([str(godot),"--headless","--path",str(root),"--script","tools/p6a31/export_notices.gd","--",str(output)],check=True)
